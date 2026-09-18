// Supabase Auth "Send Email" hook.
//
// Auth calls this instead of its own SMTP sender, handing over the six digit
// code it has already generated and recorded. We render it and hand it to
// Resend. Auth still owns generation, expiry and verification - this function
// only decides what the email looks like.
//
// Required secrets (never hardcode, never commit):
//   RESEND_API_KEY         - from resend.com/api-keys
//   SEND_EMAIL_HOOK_SECRET - shown when the hook is created, `v1,whsec_...`
//   OTP_FROM               - sender on a domain verified in Resend
//
//   supabase secrets set RESEND_API_KEY=re_... \
//     SEND_EMAIL_HOOK_SECRET=v1,whsec_... \
//     OTP_FROM="ತಾಯಿ ಸೇತು <no-reply@yourdomain.in>"

import { Webhook } from "https://esm.sh/standardwebhooks@1.0.0";

const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");
const HOOK_SECRET = Deno.env.get("SEND_EMAIL_HOOK_SECRET");
const FROM = Deno.env.get("OTP_FROM") ?? "Thayi Setu <no-reply@example.invalid>";

interface HookPayload {
  user: { email: string };
  email_data: {
    token: string;
    email_action_type: string;
  };
}

// Kannada first, English underneath. She may hand the phone to someone else to
// read it out, and that person may read either script.
function render(code: string): { subject: string; html: string; text: string } {
  const spaced = code.split("").join(" ");
  return {
    subject: `${code} - ತಾಯಿ ಸೇತು ಕೋಡ್`,
    text:
      `ನಿಮ್ಮ ತಾಯಿ ಸೇತು ಕೋಡ್: ${code}\n` +
      `ಈ ಕೋಡ್ ಅನ್ನು ಯಾರಿಗೂ ಹೇಳಬೇಡಿ. 10 ನಿಮಿಷದಲ್ಲಿ ಇದು ನಿಲ್ಲುತ್ತದೆ.\n\n` +
      `Your Thayi Setu code: ${code}\n` +
      `Do not share this code with anyone. It expires in 10 minutes.\n`,
    html: `<!doctype html>
<html lang="kn">
  <body style="margin:0;padding:24px;background:#faf7f2;font-family:'Noto Sans Kannada',system-ui,-apple-system,'Segoe UI',sans-serif;color:#2b2724;">
    <div style="max-width:440px;margin:0 auto;background:#ffffff;border-radius:16px;padding:28px 24px;">
      <p style="margin:0 0 4px;font-size:18px;font-weight:600;">ತಾಯಿ ಸೇತು</p>
      <p style="margin:0 0 20px;font-size:14px;color:#6b635c;">ನಿಮ್ಮ ಗರ್ಭಾವಸ್ಥೆಯ ಸಂಗಾತಿ</p>

      <p style="margin:0 0 8px;font-size:16px;">ನಿಮ್ಮ ಕೋಡ್ ಇಲ್ಲಿದೆ</p>
      <p style="margin:0 0 20px;font-size:34px;font-weight:700;letter-spacing:6px;font-family:ui-monospace,SFMono-Regular,Menlo,monospace;">${spaced}</p>

      <p style="margin:0 0 20px;font-size:15px;line-height:1.6;">
        ಆ್ಯಪ್‌ನಲ್ಲಿ ಈ 6 ಅಂಕಿ ಹಾಕಿ. ಈ ಕೋಡ್ ಅನ್ನು ಯಾರಿಗೂ ಹೇಳಬೇಡಿ.
        10 ನಿಮಿಷದಲ್ಲಿ ಇದು ನಿಲ್ಲುತ್ತದೆ.
      </p>

      <hr style="border:none;border-top:1px solid #ece6df;margin:20px 0;" />

      <p style="margin:0;font-size:13px;line-height:1.6;color:#6b635c;">
        Your Thayi Setu code is <strong style="color:#2b2724;">${code}</strong>.
        Enter it in the app. Do not share it with anyone. It expires in 10 minutes.
        If you did not ask for this code, you can ignore this email.
      </p>
    </div>
  </body>
</html>`,
  };
}

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }
  if (!RESEND_API_KEY || !HOOK_SECRET) {
    console.error("send-email: RESEND_API_KEY or SEND_EMAIL_HOOK_SECRET unset");
    return new Response(
      JSON.stringify({ error: { http_code: 500, message: "Mailer not configured" } }),
      { status: 500, headers: { "Content-Type": "application/json" } },
    );
  }

  const raw = await req.text();
  let payload: HookPayload;

  // Anyone can reach a deployed function URL. Only Auth can sign the body, so
  // an unverified request never reaches Resend and never burns quota.
  try {
    const headers = Object.fromEntries(req.headers);
    const wh = new Webhook(HOOK_SECRET.replace("v1,whsec_", ""));
    payload = wh.verify(raw, headers) as HookPayload;
  } catch (error) {
    console.error("send-email: signature rejected", error);
    return new Response(
      JSON.stringify({ error: { http_code: 401, message: "Invalid signature" } }),
      { status: 401, headers: { "Content-Type": "application/json" } },
    );
  }

  const { subject, html, text } = render(payload.email_data.token);

  const res = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${RESEND_API_KEY}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      from: FROM,
      to: [payload.user.email],
      subject,
      html,
      text,
    }),
  });

  if (!res.ok) {
    // Never log the body of a failure that might echo the code back.
    console.error(`send-email: resend returned ${res.status}`);
    return new Response(
      JSON.stringify({ error: { http_code: 502, message: "Could not send the code" } }),
      { status: 502, headers: { "Content-Type": "application/json" } },
    );
  }

  return new Response("{}", {
    status: 200,
    headers: { "Content-Type": "application/json" },
  });
});
