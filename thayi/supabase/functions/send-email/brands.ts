// Which product the person is signing in to, and what the email should look
// like because of it.
//
// One Supabase project backs all three apps, so one Send Email hook serves all
// three. Without this table every code — the mother's, the ASHA's, the
// doctor's — arrives wearing the mother app's face.
//
// Adding a fourth app means adding an entry here and an asset in the bucket.
// Nothing else in this function knows how many brands there are.

/// Shared surface tokens, identical in all three lib/theme/tokens.dart files.
/// They are the product's palette, not this email's — do not invent colour
/// here that does not exist on the screen she lands on.
export const C = {
  bg: "#F7F2EA",
  card: "#FFFFFF",
  ink: "#10312B",
  teal: "#0F5257",
  tealSoft: "#E4EFEC",
  textSoft: "#5E6E6A",
  divider: "#E6DED2",
} as const;

// No mail client loads a web font, so the device's own faces have to be named.
// Nirmala UI covers Windows; the rest fall through to the system.
const FONT_KN =
  "'Noto Sans Kannada','Nirmala UI','Tunga',system-ui,-apple-system," +
  "'Segoe UI',Roboto,sans-serif";

// Setu Care bundles no font either (see care/lib/theme/tokens.dart) — the
// brief's stack is Inter over system-ui, and the platform sans is what
// actually renders. The email says the same thing.
const FONT_EN =
  "Inter,system-ui,-apple-system,'Segoe UI',Roboto,'Helvetica Neue',sans-serif";

export interface Brand {
  /// Matches the logo filename in the asset bucket and the marker an app may
  /// put in its redirect URL.
  key: string;
  /// Display name, in the script the reader actually uses.
  name: string;
  /// Latin form, for the From header and the plain-text part. A name in
  /// Kannada in a From header renders as boxes on a client with no such font,
  /// and the inbox list is the one place she cannot tap to fix it.
  nameLatin: string;
  tagline: string;
  lang: "kn" | "en";
  font: string;
  /// The wordmark and the code block. Teal in all three today; it is a field
  /// so a brand can diverge later without touching the template.
  accent: string;
  subject: (code: string) => string;
  /// Shown in the inbox list instead of the first words of the body.
  preheader: (code: string) => string;
  heading: string;
  /// Trusted HTML — these are our own strings, never anything from the hook.
  body: string;
  /// The recap under the rule. Kannada-first brands put the English here, so
  /// whoever she hands the phone to can read it out. An English-first brand
  /// puts the "you didn't ask for this" line here instead.
  footnote: (code: string) => string;
  text: (code: string) => string;
}

const THAYI: Brand = {
  key: "thayi",
  name: "ತಾಯಿ ಸೇತು",
  nameLatin: "Thayi Setu",
  tagline: "ನಿಮ್ಮ ಗರ್ಭಾವಸ್ಥೆಯ ಸಂಗಾತಿ",
  lang: "kn",
  font: FONT_KN,
  accent: C.teal,
  subject: (code) => `${code} - ತಾಯಿ ಸೇತು ಕೋಡ್`,
  preheader: (code) => `ನಿಮ್ಮ ಕೋಡ್ ${code}`,
  heading: "ನಿಮ್ಮ ಕೋಡ್ ಇಲ್ಲಿದೆ",
  body:
    `ಆ್ಯಪ್‌ನಲ್ಲಿ ಈ 6 ಅಂಕಿ ಹಾಕಿ.<br />` +
    `ಈ ಕೋಡ್ ಅನ್ನು <strong>ಯಾರಿಗೂ ಹೇಳಬೇಡಿ</strong>. 10 ನಿಮಿಷದಲ್ಲಿ ಇದು ನಿಲ್ಲುತ್ತದೆ.`,
  footnote: (code) =>
    `Your Thayi Setu code is <strong style="color:${C.ink};">${code}</strong>. ` +
    `Enter it in the app. Do not share it with anyone. It expires in 10 minutes. ` +
    `If you did not ask for this code, you can ignore this email.`,
  text: (code) =>
    `ನಿಮ್ಮ ತಾಯಿ ಸೇತು ಕೋಡ್: ${code}\n` +
    `ಈ ಕೋಡ್ ಅನ್ನು ಯಾರಿಗೂ ಹೇಳಬೇಡಿ. 10 ನಿಮಿಷದಲ್ಲಿ ಇದು ನಿಲ್ಲುತ್ತದೆ.\n\n` +
    `Your Thayi Setu code: ${code}\n` +
    `Do not share this code with anyone. It expires in 10 minutes.\n`,
};

const ASHA: Brand = {
  key: "asha",
  name: "ಆಶಾ ಸೇತು",
  nameLatin: "ASHA Setu",
  tagline: "ನಿಮ್ಮ ಕ್ಷೇತ್ರ ಸಂಗಾತಿ",
  lang: "kn",
  font: FONT_KN,
  accent: C.teal,
  subject: (code) => `${code} - ಆಶಾ ಸೇತು ಕೋಡ್`,
  preheader: (code) => `ನಿಮ್ಮ ಕೋಡ್ ${code}`,
  heading: "ನಿಮ್ಮ ಕೋಡ್ ಇಲ್ಲಿದೆ",
  body:
    `ಆ್ಯಪ್‌ನಲ್ಲಿ ಈ 6 ಅಂಕಿ ಹಾಕಿ.<br />` +
    `ಈ ಕೋಡ್ ಅನ್ನು <strong>ಯಾರಿಗೂ ಹೇಳಬೇಡಿ</strong>. 10 ನಿಮಿಷದಲ್ಲಿ ಇದು ನಿಲ್ಲುತ್ತದೆ.`,
  footnote: (code) =>
    `Your ASHA Setu code is <strong style="color:${C.ink};">${code}</strong>. ` +
    `Enter it in the app. Do not share it with anyone. It expires in 10 minutes. ` +
    `If you did not ask for this code, you can ignore this email.`,
  text: (code) =>
    `ನಿಮ್ಮ ಆಶಾ ಸೇತು ಕೋಡ್: ${code}\n` +
    `ಈ ಕೋಡ್ ಅನ್ನು ಯಾರಿಗೂ ಹೇಳಬೇಡಿ. 10 ನಿಮಿಷದಲ್ಲಿ ಇದು ನಿಲ್ಲುತ್ತದೆ.\n\n` +
    `Your ASHA Setu code: ${code}\n` +
    `Do not share this code with anyone. It expires in 10 minutes.\n`,
};

// English only, and shorter. Setu Care ships no localisation and its login
// screen is English; a clinician reading between patients wants the code and
// nothing else.
const CARE: Brand = {
  key: "care",
  name: "Setu Care",
  nameLatin: "Setu Care",
  tagline: "Clinical console",
  lang: "en",
  font: FONT_EN,
  accent: C.teal,
  subject: (code) => `${code} - Setu Care sign-in code`,
  preheader: (code) => `Your sign-in code is ${code}`,
  heading: "Your sign-in code",
  body:
    `Enter these 6 digits in Setu Care.<br />` +
    `<strong>Do not share this code with anyone.</strong> It expires in 10 minutes.`,
  footnote: () =>
    `If you did not ask for this code, ignore this email — someone may have ` +
    `typed your address by mistake. No action is needed and no one has reached ` +
    `your account.`,
  text: (code) =>
    `Your Setu Care sign-in code: ${code}\n` +
    `Enter it in the console. Do not share this code with anyone.\n` +
    `It expires in 10 minutes.\n\n` +
    `If you did not ask for this code, ignore this email.\n`,
};

export const BRANDS: Record<string, Brand> = {
  thayi: THAYI,
  asha: ASHA,
  care: CARE,
};

// The mother app carries by far the most sign-ins, and an unrecognised address
// is far likelier to be a mother whose record has not synced than a doctor.
export const DEFAULT_BRAND = THAYI;

/// 'asha' and 'doctor' are the two values staff.role accepts; the doctor-facing
/// app is called Care, so the role does not name its own app.
export function brandForRole(role: string | null | undefined): Brand | null {
  switch (role) {
    case "mother":
      return THAYI;
    case "asha":
      return ASHA;
    case "doctor":
      return CARE;
    default:
      return null;
  }
}

/// An explicit marker in the redirect URL, e.g. `https://mysetu.live/auth/asha`
/// or `...?app=care`. Optional, and only an override: nothing breaks when an
/// app sends no redirect at all, which is the case today.
export function brandFromRedirect(redirectTo?: string | null): Brand | null {
  if (!redirectTo) return null;
  let url: URL;
  try {
    url = new URL(redirectTo);
  } catch {
    return null;
  }
  const marker = url.searchParams.get("app") ??
    url.pathname.split("/").filter(Boolean).pop();
  if (!marker) return null;
  return BRANDS[marker.toLowerCase()] ?? null;
}
