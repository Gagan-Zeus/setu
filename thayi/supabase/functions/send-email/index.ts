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
//     OTP_FROM="ತಾಯಿ ಸೇತು <no-reply@mysetu.live>"

import { Webhook } from "https://esm.sh/standardwebhooks@1.0.0";

const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");
const HOOK_SECRET = Deno.env.get("SEND_EMAIL_HOOK_SECRET");
const FROM = Deno.env.get("OTP_FROM") ?? "ತಾಯಿ ಸೇತು <no-reply@mysetu.live>";

interface HookPayload {
  user: { email: string };
  email_data: {
    token: string;
    email_action_type: string;
  };
}

// Kannada first, English underneath. She may hand the phone to someone else
// to read it out, and that person may read either script.
//
// Built as nested tables with inline styles, not divs: Outlook renders through
// Word and drops most modern CSS. Colours are the app's own tokens from
// lib/theme/tokens.dart so the email and the screen she lands on match. Type
// runs a size larger than a normal email for the same reason the app does -
// she may be reading in sunlight with poor eyesight.
const BG = "#F7F2EA";
const CARD = "#FFFFFF";
const INK = "#10312B";
const TEAL = "#0F5257";
const TEAL_SOFT = "#E4EFEC";
const TEXT_SOFT = "#5E6E6A";
const DIVIDER = "#E6DED2";

// No mail client loads a web font, so the device's own Kannada face has to be
// named. Nirmala UI covers Windows, the rest fall through to the system.
const FONT =
  "'Noto Sans Kannada','Nirmala UI','Tunga',system-ui,-apple-system," +
  "'Segoe UI',Roboto,sans-serif";

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
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1" />
    <meta name="color-scheme" content="light" />
    <title>ತಾಯಿ ಸೇತು</title>
  </head>
  <body style="margin:0;padding:0;background:${BG};">
    <!-- Preview line. Without one, Gmail pulls the first words of the body
         into the inbox list; this puts the code there instead. -->
    <div style="display:none;max-height:0;overflow:hidden;opacity:0;">
      ನಿಮ್ಮ ಕೋಡ್ ${code} &#8203;&#8203;&#8203;&#8203;&#8203;&#8203;&#8203;
    </div>

    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="background:${BG};">
      <tr>
        <td align="center" style="padding:24px 12px;">

          <table role="presentation" width="480" cellpadding="0" cellspacing="0" border="0" style="width:100%;max-width:480px;background:${CARD};border-radius:18px;">
            <tr>
              <td style="padding:28px 24px 0 24px;font-family:${FONT};">
                <div style="font-size:19px;font-weight:700;color:${TEAL};">ತಾಯಿ ಸೇತು</div>
                <div style="font-size:14px;color:${TEXT_SOFT};padding-top:2px;">ನಿಮ್ಮ ಗರ್ಭಾವಸ್ಥೆಯ ಸಂಗಾತಿ</div>
              </td>
            </tr>

            <tr>
              <td style="padding:24px 24px 0 24px;font-family:${FONT};font-size:18px;color:${INK};">
                ನಿಮ್ಮ ಕೋಡ್ ಇಲ್ಲಿದೆ
              </td>
            </tr>

            <!-- The code sits in its own filled block so it is findable at a
                 glance when she switches back to the app. -->
            <tr>
              <td style="padding:12px 24px 0 24px;">
                <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="background:${TEAL_SOFT};border-radius:14px;">
                  <tr>
                    <td align="center" style="padding:20px 12px;font-family:ui-monospace,SFMono-Regular,Menlo,Consolas,monospace;font-size:36px;font-weight:700;letter-spacing:8px;color:${TEAL};">
                      ${spaced}
                    </td>
                  </tr>
                </table>
              </td>
            </tr>

            <tr>
              <td style="padding:20px 24px 0 24px;font-family:${FONT};font-size:17px;line-height:1.6;color:${INK};">
                ಆ್ಯಪ್‌ನಲ್ಲಿ ಈ 6 ಅಂಕಿ ಹಾಕಿ.<br />
                ಈ ಕೋಡ್ ಅನ್ನು <strong>ಯಾರಿಗೂ ಹೇಳಬೇಡಿ</strong>. 10 ನಿಮಿಷದಲ್ಲಿ ಇದು ನಿಲ್ಲುತ್ತದೆ.
              </td>
            </tr>

            <tr>
              <td style="padding:20px 24px 0 24px;">
                <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0">
                  <tr><td style="border-top:1px solid ${DIVIDER};font-size:0;line-height:0;">&nbsp;</td></tr>
                </table>
              </td>
            </tr>

            <tr>
              <td style="padding:16px 24px 28px 24px;font-family:${FONT};font-size:14px;line-height:1.6;color:${TEXT_SOFT};">
                Your Thayi Setu code is <strong style="color:${INK};">${code}</strong>. Enter it in the app.
                Do not share it with anyone. It expires in 10 minutes.
                If you did not ask for this code, you can ignore this email.
              </td>
            </tr>
          </table>

          <div style="font-family:${FONT};font-size:12px;color:${TEXT_SOFT};padding:16px 8px 0 8px;">
            ತಾಯಿ ಸೇತು &middot; mysetu.live
          </div>

        </td>
      </tr>
    </table>
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
