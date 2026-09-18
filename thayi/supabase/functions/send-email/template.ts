// The OTP email itself.
//
// Built as nested tables with inline styles, not divs: Outlook renders through
// Word and drops most modern CSS. Type runs a size larger than a normal email
// for the same reason the apps do — it may be read in sunlight, with poor
// eyesight, on a cheap screen.
//
// Every brand-specific value arrives in the Brand record. There is one layout,
// so a fix to the code block or the dark-mode guard lands in all three apps at
// once, and a brand can never drift into its own half-maintained template.

import { type Brand, C } from "./brands.ts";

export interface Email {
  subject: string;
  html: string;
  text: string;
}

export function render(brand: Brand, code: string, logoUrl: string): Email {
  // Spaced so a screen reader says "four, one, nine" rather than a number in
  // the hundred thousands, and so the digits are easy to copy by eye.
  //
  // Thin spaces rather than ordinary ones. Six digits joined by normal spaces
  // is eleven characters, and at the old size that came to about 326px of
  // monospace inside the roughly 248px a phone-width client leaves - so the
  // code broke across two lines, which is the one thing in the email that must
  // never happen.
  const spaced = code.split("").join("\u2009");

  return {
    subject: brand.subject(code),
    text: brand.text(code),
    html: `<!doctype html>
<html lang="${brand.lang}">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1" />
    <!-- Light only. A client that inverts this would drop the code block's
         contrast to nothing, and the code is the whole email. -->
    <meta name="color-scheme" content="light" />
    <meta name="supported-color-schemes" content="light" />
    <title>${brand.name}</title>
  </head>
  <body style="margin:0;padding:0;background:${C.bg};">
    <!-- Preview line. Without one, Gmail pulls the first words of the body
         into the inbox list; this puts the code there instead. -->
    <div style="display:none;max-height:0;overflow:hidden;opacity:0;">
      ${brand.preheader(code)} &#8203;&#8203;&#8203;&#8203;&#8203;&#8203;&#8203;
    </div>

    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="background:${C.bg};">
      <tr>
        <td align="center" style="padding:24px 12px;">

          <table role="presentation" width="480" cellpadding="0" cellspacing="0" border="0" style="width:100%;max-width:480px;background:${C.card};border-radius:18px;">

            <!-- Masthead. The logo is the one thing that differs at a glance,
                 so it leads. Most clients block remote images by default, so
                 the wordmark sits beside it in text and the header still says
                 which app this is with nothing loaded. -->
            <tr>
              <td style="padding:24px 24px 0 24px;">
                <table role="presentation" cellpadding="0" cellspacing="0" border="0">
                  <tr>
                    <td width="52" valign="middle" style="width:52px;">
                      <img src="${logoUrl}" width="52" height="52" alt="${brand.nameLatin}"
                           style="display:block;width:52px;height:52px;border:0;outline:none;text-decoration:none;" />
                    </td>
                    <td width="12" style="width:12px;font-size:0;line-height:0;">&nbsp;</td>
                    <td valign="middle" style="font-family:${brand.font};">
                      <div style="font-size:19px;font-weight:700;color:${brand.accent};">${brand.name}</div>
                      <div style="font-size:14px;color:${C.textSoft};padding-top:2px;">${brand.tagline}</div>
                    </td>
                  </tr>
                </table>
              </td>
            </tr>

            <tr>
              <td style="padding:24px 24px 0 24px;font-family:${brand.font};font-size:18px;color:${C.ink};">
                ${brand.heading}
              </td>
            </tr>

            <!-- The code sits in its own filled block so it is findable at a
                 glance when the app is switched back to. -->
            <tr>
              <td style="padding:12px 24px 0 24px;">
                <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="background:${C.tealSoft};border-radius:14px;">
                  <tr>
                    <td align="center" style="padding:20px 12px;font-family:ui-monospace,SFMono-Regular,Menlo,Consolas,monospace;font-size:25px;font-weight:700;letter-spacing:5px;white-space:nowrap;color:${brand.accent};">
                      ${spaced}
                    </td>
                  </tr>
                </table>
              </td>
            </tr>

            <tr>
              <td style="padding:20px 24px 0 24px;font-family:${brand.font};font-size:17px;line-height:1.6;color:${C.ink};">
                ${brand.body}
              </td>
            </tr>

            <tr>
              <td style="padding:20px 24px 0 24px;">
                <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0">
                  <tr><td style="border-top:1px solid ${C.divider};font-size:0;line-height:0;">&nbsp;</td></tr>
                </table>
              </td>
            </tr>

            <tr>
              <td style="padding:16px 24px 28px 24px;font-family:${brand.font};font-size:14px;line-height:1.6;color:${C.textSoft};">
                ${brand.footnote(code)}
              </td>
            </tr>
          </table>

          <div style="font-family:${brand.font};font-size:12px;color:${C.textSoft};padding:16px 8px 0 8px;">
            ${brand.name} &middot; mysetu.live
          </div>

        </td>
      </tr>
    </table>
  </body>
</html>`,
  };
}
