// Turns what she said into text.
//
// She may not be able to type, and Kannada on a phone keyboard is slow even
// for someone who can. Speaking a question has to work as well as typing one.
//
// Android's own recogniser is unreliable for Kannada and absent on many cheap
// handsets. ElevenLabs Scribe transcribes it at under 5% word error, so the
// device recogniser is the fallback rather than the default — see
// SpeechInput in the app, which uses it when this is unreachable.
//
// The key stays here, never in the APK.

const KEY = Deno.env.get("ELEVENLABS_API_KEY");
const MODEL = "scribe_v2";

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

// ElevenLabs wants three-letter codes here; the app speaks in ISO 639-1.
const LANG: Record<string, string> = { kn: "kan", en: "eng", hi: "hin" };

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });

  const json = (body: unknown, status = 200) =>
    new Response(JSON.stringify(body), {
      status,
      headers: { ...CORS, "Content-Type": "application/json" },
    });

  if (!KEY) return json({ error: "speech_unconfigured" }, 503);

  const auth = req.headers.get("Authorization") ?? "";
  if (!auth.startsWith("Bearer ")) return json({ error: "unauthenticated" }, 401);

  let audio: File | null = null;
  let lang = "kn";
  try {
    const form = await req.formData();
    const file = form.get("file");
    if (file instanceof File) audio = file;
    lang = String(form.get("lang") ?? "kn");
  } catch {
    return json({ error: "bad_request" }, 400);
  }

  if (!audio) return json({ error: "no_audio" }, 400);
  // Roughly a minute of speech. A question is short; anything longer is a
  // stuck recorder, and it would be billed by the second.
  if (audio.size > 4 * 1024 * 1024) return json({ error: "audio_too_long" }, 413);
  if (audio.size < 1024) return json({ error: "audio_too_short" }, 400);

  const upstream = new FormData();
  upstream.append("file", audio, "speech.m4a");
  upstream.append("model_id", MODEL);
  // Telling it the language beats letting it guess: she is speaking Kannada,
  // and a short clip is exactly where auto-detection goes wrong.
  upstream.append("language_code", LANG[lang] ?? "kan");

  try {
    const res = await fetch("https://api.elevenlabs.io/v1/speech-to-text", {
      method: "POST",
      headers: { "xi-api-key": KEY },
      body: upstream,
    });

    if (!res.ok) {
      console.error("elevenlabs stt", res.status, (await res.text()).slice(0, 300));
      return json({ error: "transcription_unavailable" }, 502);
    }

    const data = await res.json();
    const text = String(data?.text ?? "").trim();
    if (!text) return json({ error: "nothing_heard" }, 200);

    return json({
      text,
      language: data?.language_code ?? null,
      confidence: data?.language_probability ?? null,
    });
  } catch (error) {
    console.error("stt call failed", error);
    return json({ error: "transcription_unavailable" }, 502);
  }
});
