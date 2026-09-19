// The assistant behind "Ask Setu" in Thayi Setu.
//
// This runs on Supabase, not on her phone, for one reason: the Gemini key.
// A key shipped inside an APK can be pulled out of it in a minute and spent by
// anyone. It lives here as a project secret and never leaves the server.
//
// The function is also where grounding happens. Her question pulls approved
// answers out of pregnancy_faqs, and those are what the model rewrites in her
// words whenever they cover what she asked.
//
// They cannot cover everything. Twenty-odd rows never will, and a woman who
// asks something outside them and is told "I do not know, ask your ASHA
// worker" has been handed nothing — she may not see that worker for a
// fortnight. So where the approved set falls short the model answers from
// standard WHO and MoHFW guidance rather than refusing, and the reply carries
// grounded:false so it is never mistaken for clinician-reviewed material.
//
// What does not bend, approved answer or not: no medicine, brand or dose; no
// diagnosis; never talking her out of the health centre; nothing on abortion
// or the sex of the baby; and any danger sign ends the reply by sending her to
// the health centre now.

const GEMINI_KEY = Deno.env.get("GEMINI_API_KEY");
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY")!;

// Tried in order, first one that answers wins.
//
// This is a list rather than a single id because of how the free tier meters:
// twenty requests per day, counted separately for each model. One model alone
// gives the assistant twenty questions a day across every woman using it,
// which a single afternoon of testing spends. Five give it five times that,
// for no cost and no loss — they are all current Flash-class models and any
// of them handles simple Kannada health guidance.
//
// The order is quality first. Later entries are lighter models, used only
// when the ones above them have nothing left.
//
// None of this makes the free tier sufficient for real use. It buys headroom
// for a pilot; a deployment needs billing enabled on the Google AI Studio
// project, which replaces the per-day cap with a per-minute one.
const MODELS = [
  "gemini-3.6-flash",
  "gemini-3.8-flash",
  "gemini-3.5-flash",
  "gemini-3.1-flash-lite",
  "gemini-3.5-flash-lite",
];

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
- The APPROVED ANSWERS below are reviewed by a clinician. Whenever they cover
  what she asked, they are your source: rewrite them in your own simple words
  to fit exactly the question she asked.
- When they do not cover it, you must still answer her. Use standard maternal
  health guidance — WHO and India's MoHFW — on pregnancy, labour and delivery,
  the weeks after birth, and the newborn's health. Never reply that you do not
  know a question that falls inside those subjects, and never close a reply by
  sending her to her ASHA worker in place of an answer.
- Stay with what is settled, ordinary guidance that would be given at any
  health centre. Where something genuinely differs from woman to woman, give
  her the general picture first and then say her ASHA worker or the health
  centre can tell her what is right for her.
- If she asks about something outside pregnancy, birth, the time after it, or
  the baby, say kindly that you can only help with those.

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
    // Retrieval failing is not fatal. The model still answers within its
    // rules, from standard guidance rather than from an approved row, and the
    // reply comes back grounded:false to say so.
  }

  const context = approved.length === 0
    ? "(nothing in the approved set matched this question. Answer her anyway, " +
      "from standard maternal health guidance, within the rules above.)"
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

  const geminiBody = JSON.stringify({
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
  });

  let reply = "";
  try {
    // Walk down MODELS until one answers.
    //
    // The free tier's limit is twenty requests per day PER MODEL, so a 429 on
    // the first model says nothing about the second — each has its own
    // untouched allowance. Falling through the list multiplies what a free
    // key can serve, which is the difference between an assistant that dies
    // mid-afternoon and one that lasts the day.
    //
    // Waiting is deliberately not part of this. A per-day quota does not
    // refill in the nine seconds Gemini suggests, so sleeping would only make
    // her stare at a spinner before failing anyway. Moving to the next model
    // costs her nothing and usually works.
    let res!: Response;
    let lastStatus = 0;
    let lastDetail = "";

    for (const model of MODELS) {
      res = await fetch(
        `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent`,
        {
          method: "POST",
          headers: {
            "x-goog-api-key": GEMINI_KEY,
            "Content-Type": "application/json",
          },
          body: geminiBody,
        },
      );

      if (res.ok) break;

      lastStatus = res.status;
      lastDetail = (await res.text()).slice(0, 200);
      console.error("gemini", model, res.status, lastDetail);

      // Out of quota (429), or the model itself is overloaded (5xx): the next
      // one may well be fine. Anything else is our own bad request and every
      // model will reject it identically, so stop rather than send it four
      // more times.
      if (res.status !== 429 && res.status < 500) break;
    }

    if (!res.ok) {
      // Quota is worth separating from a genuine outage: it is the one the
      // operator can fix, and it is invisible inside a generic 502.
      if (lastStatus === 429) {
        console.error("gemini: every model out of quota");
        return json({ error: "assistant_busy" }, 503);
      }
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
