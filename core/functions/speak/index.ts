// Reads a line of text aloud, in her language.
//
// Literacy is the reason this exists. A woman who cannot read the assistant's
// answer, or the danger-sign screen telling her to go to the health centre
// now, gets nothing from either. Speech is not a convenience feature here.
//
// The ElevenLabs key lives in this function, never in the app, for the same
// reason as the Gemini key: anything shipped in an APK can be pulled back out
// of it, and this one is billed per character.
//
// Audio is cached in Storage under a hash of the text. Danger-sign warnings
// and common answers are the same sentences over and over, and re-synthesising
// them would be paid for every single time.

const KEY = Deno.env.get("ELEVENLABS_API_KEY");
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

// Kannada is only supported on v3. Multilingual v2 and Flash v2.5 do not
// include it, so this model id is not interchangeable.
const MODEL = "eleven_v3";

// Overridable so the voice can be changed without a redeploy.
const VOICE = Deno.env.get("ELEVENLABS_VOICE_ID") ?? "21m00Tcm4TlvDq8ikWAM";

const BUCKET = "speech-cache";

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

async function sha256(text: string): Promise<string> {
  const data = new TextEncoder().encode(text);
  const digest = await crypto.subtle.digest("SHA-256", data);
  return [...new Uint8Array(digest)]
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });

  const json = (body: unknown, status = 200) =>
    new Response(JSON.stringify(body), {
      status,
      headers: { ...CORS, "Content-Type": "application/json" },
    });

  if (!KEY) return json({ error: "speech_unconfigured" }, 503);

  // Signed-in callers only: this costs money per character.
  const auth = req.headers.get("Authorization") ?? "";
  if (!auth.startsWith("Bearer ")) return json({ error: "unauthenticated" }, 401);

  let text = "";
  let lang = "kn";
  try {
    const body = await req.json();
    text = String(body.text ?? "").trim();
    lang = String(body.lang ?? "kn").slice(0, 5);
  } catch {
    return json({ error: "bad_request" }, 400);
  }

  if (!text) return json({ error: "empty_text" }, 400);
  // A hard ceiling, because the caller decides the length and the bill.
  if (text.length > 1200) text = text.slice(0, 1200);

  const key = `${lang}/${await sha256(`${MODEL}:${VOICE}:${lang}:${text}`)}.mp3`;
  const storage = `${SUPABASE_URL}/storage/v1/object`;

  // ---------------------------------------------------------------- cache
  const cached = await fetch(`${storage}/${BUCKET}/${key}`, {
    headers: { Authorization: `Bearer ${SERVICE_KEY}` },
  });
  if (cached.ok) {
    return new Response(await cached.arrayBuffer(), {
      headers: { ...CORS, "Content-Type": "application/octet-stream", "X-Cache": "hit" },
    });
  }

  // ------------------------------------------------------------ synthesis
  let audio: ArrayBuffer;
  try {
    const res = await fetch(
      `https://api.elevenlabs.io/v1/text-to-speech/${VOICE}?output_format=mp3_22050_32`,
      {
        method: "POST",
        headers: { "xi-api-key": KEY, "Content-Type": "application/json" },
        body: JSON.stringify({
          text,
          model_id: MODEL,
          language_code: lang,
          voice_settings: {
            // Steady and plain. This is health information being read to
            // someone who may be frightened, not a performance.
            stability: 0.5,
            similarity_boost: 0.75,
            speed: 0.92,
          },
        }),
      },
    );

    if (!res.ok) {
      console.error("elevenlabs tts", res.status, (await res.text()).slice(0, 300));
      return json({ error: "speech_unavailable" }, 502);
    }
    audio = await res.arrayBuffer();
  } catch (error) {
    console.error("tts call failed", error);
    return json({ error: "speech_unavailable" }, 502);
  }

  // Cache write is best-effort: failing to store must not fail the request,
  // she is waiting to hear it.
  fetch(`${storage}/${BUCKET}/${key}`, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${SERVICE_KEY}`,
      "Content-Type": "audio/mpeg",
      "x-upsert": "true",
    },
    body: audio,
  }).catch((e) => console.error("cache write failed", e));

  return new Response(audio, {
    headers: { ...CORS, "Content-Type": "application/octet-stream", "X-Cache": "miss" },
  });
});
