// The assistant behind "Ask Setu" in Thayi Setu.
//
// This runs on Supabase, not on her phone, for one reason: the Gemini key.
// A key shipped inside an APK can be pulled out of it in a minute and spent by
// anyone. It lives here as a project secret and never leaves the server.
//
// The function is also where grounding happens. Her question is used to pull
// approved answers out of pregnancy_faqs, and the model is told to answer only
// from those. It rewrites clinician-approved material in her words; it is not
// the source of the medical fact.

const GEMINI_KEY = Deno.env.get("GEMINI_API_KEY");
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY")!;

const MODEL = "gemini-3.6-flash";

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

// What the model is and is not allowed to do. The hard rules are repeated as
// prohibitions rather than preferences because that is what survives a user
// pushing back over several turns.
const SYSTEM = `
You are Setu, a health companion inside a mobile app used by pregnant women and
new mothers in rural Karnataka, India. Most have limited schooling and are
reading on a small phone.

HOW YOU SPEAK
- Reply in the SAME language the woman wrote in. If she writes Kannada, reply in
  Kannada. If she writes English or transliterated Kannada, reply in simple
  English. Never mix scripts in one reply.
- Two to four short sentences. No lists, no headings, no markdown, no emoji.
- Everyday village words. Say "low blood" not "anaemia", "fits" not "eclampsia".
- Talk to her directly and warmly, as a person, not as a leaflet. Never lecture
  her, never imply she has been careless.

WHAT YOU MAY SAY
- Answer using the APPROVED ANSWERS supplied below. They are reviewed by a
  clinician. Rewrite them in your own simple words to fit exactly what she asked.
- If the approved answers do not cover her question, say plainly that you do not
  know this one and that her ASHA worker can tell her. Then stop. Never fill the
  gap from your own knowledge, never guess, and never say something that merely
  sounds reasonable.

WHAT YOU MUST NEVER DO
- Never name a medicine, a brand, a dose, or how much of anything to take. Not
  even a common painkiller, not even if she insists or says a doctor told her to.
  Say that only her doctor or ASHA worker can decide about medicines.
- Never diagnose her or tell her what her symptom means.
- Never tell her a symptom is nothing to worry about, and never talk her out of
  going to the health centre.
- Never discuss abortion, sex determination or the sex of the baby. Both are
  criminal offences in India. Say you cannot help with that.
- Never claim to be a doctor or a nurse.

WHEN SOMETHING SOUNDS DANGEROUS
If she describes bleeding, severe headache, blurred vision, the baby moving less,
fever, sudden swelling of the face or hands, fits, or severe belly pain: your
whole reply is to tell her to contact her ASHA worker or go to the health centre
now. Do not reassure her, do not explain the cause, do not offer home remedies.
`.trim();

interface Turn {
  role: "user" | "model";
  text: string;
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });

  const json = (body: unknown, status = 200) =>
    new Response(JSON.stringify(body), {
      status,
      headers: { ...CORS, "Content-Type": "application/json" },
    });

  if (!GEMINI_KEY) return json({ error: "assistant_unconfigured" }, 503);

  // She must be signed in. Her JWT is passed straight through to PostgREST so
  // retrieval runs under her own RLS, not under a service role.
  const auth = req.headers.get("Authorization") ?? "";
  if (!auth.startsWith("Bearer ")) return json({ error: "unauthenticated" }, 401);

  let question = "";
  let history: Turn[] = [];
  try {
    const body = await req.json();
    question = String(body.question ?? "").trim();
    if (Array.isArray(body.history)) {
      history = body.history
        .filter((t: Turn) => t && (t.role === "user" || t.role === "model"))
        .slice(-6) // enough for follow-ups like "and after delivery?"
        .map((t: Turn) => ({ role: t.role, text: String(t.text ?? "").slice(0, 600) }));
    }
  } catch {
    return json({ error: "bad_request" }, 400);
  }

  if (!question) return json({ error: "empty_question" }, 400);
  if (question.length > 500) question = question.slice(0, 500);

  // ------------------------------------------------------------ retrieval
  let approved: Array<Record<string, string>> = [];
  try {
    const res = await fetch(
      `${SUPABASE_URL}/rest/v1/rpc/search_pregnancy_faqs`,
      {
        method: "POST",
        headers: {
          apikey: ANON_KEY,
          Authorization: auth,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ p_query: question, p_limit: 5 }),
      },
    );
    if (res.ok) approved = await res.json();
  } catch {
    // Retrieval failing is not fatal — the model still has to answer within
    // its rules, and with no approved material it will say it does not know.
  }

  const context = approved.length === 0
    ? "(no approved answer matched this question)"
    : approved
      .map((r, i) =>
        `--- approved answer ${i + 1} (${r.category}, urgency: ${r.urgency}) ---\n` +
        `Q: ${r.question}\nA: ${r.answer}\n` +
        (r.answer_kn ? `Kannada version: ${r.answer_kn}\n` : "")
      )
      .join("\n");

  // ------------------------------------------------------------ generation
  const contents = [
    ...history.map((t) => ({ role: t.role, parts: [{ text: t.text }] })),
    {
      role: "user",
      parts: [{
        text:
          `APPROVED ANSWERS you may use:\n${context}\n\n` +
          `She asks: ${question}`,
      }],
    },
  ];

  let reply = "";
  try {
    const res = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent`,
      {
        method: "POST",
        headers: {
          "x-goog-api-key": GEMINI_KEY,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          contents,
          systemInstruction: { parts: [{ text: SYSTEM }] },
          generationConfig: {
            temperature: 0.3, // low: this is health information, not writing
            maxOutputTokens: 900,
            thinkingConfig: { thinkingLevel: "low" },
          },
          safetySettings: [
            "HARM_CATEGORY_HARASSMENT",
            "HARM_CATEGORY_HATE_SPEECH",
            "HARM_CATEGORY_SEXUALLY_EXPLICIT",
            "HARM_CATEGORY_DANGEROUS_CONTENT",
          ].map((category) => ({ category, threshold: "BLOCK_ONLY_HIGH" })),
        }),
      },
    );

    if (!res.ok) {
      console.error("gemini", res.status, (await res.text()).slice(0, 300));
      return json({ error: "assistant_unavailable" }, 502);
    }

    const data = await res.json();
    const parts = data?.candidates?.[0]?.content?.parts ?? [];
    reply = parts.map((p: { text?: string }) => p.text ?? "").join("").trim();
  } catch (error) {
    console.error("gemini call failed", error);
    return json({ error: "assistant_unavailable" }, 502);
  }

  // An empty reply means it was filtered or ran out of room. Saying nothing is
  // better than saying something unreviewed, so hand her to her ASHA worker.
  if (!reply) return json({ error: "no_answer" }, 200);

  return json({
    reply,
    grounded: approved.length > 0,
    sources: [...new Set(approved.map((r) => r.source_name))],
  });
});
