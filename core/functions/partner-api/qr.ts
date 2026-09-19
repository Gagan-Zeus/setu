/// The QR token a mother presents, and why it is not her id.
///
/// A QR containing the mother's UUID is a permanent, un-revocable credential.
/// Photograph it once — over her shoulder, from a printout, off a screen — and
/// that record is readable forever by anyone who kept the picture.
///
/// So the app renders a signed JWT that lives five minutes and refreshes on a
/// timer. A photograph is useless almost immediately, and the mother physically
/// holding out her phone is the consent event. The jti is recorded on every
/// lookup, so one scan can be traced end to end, and spent once so a token
/// captured inside its five minutes still cannot be replayed.

const encoder = new TextEncoder();

function b64urlToBytes(s: string): Uint8Array {
  const padded = s.replace(/-/g, "+").replace(/_/g, "/")
    .padEnd(s.length + ((4 - (s.length % 4)) % 4), "=");
  return Uint8Array.from(atob(padded), (c) => c.charCodeAt(0));
}

function bytesToB64url(b: Uint8Array): string {
  return btoa(String.fromCharCode(...b))
    .replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

async function hmacKey(secret: string) {
  return await crypto.subtle.importKey(
    "raw", encoder.encode(secret),
    { name: "HMAC", hash: "SHA-256" }, false, ["sign", "verify"],
  );
}

export interface QrClaims {
  sub: string;   // the mother's id
  jti: string;   // unique per token, so a scan is traceable and single-use
  iat: number;
  exp: number;
}

/// Minted by Thayi Setu (through an Edge Function that holds the secret, never
/// in the app) and rendered as the QR.
export async function mintQrToken(
  motherId: string, secret: string, ttlSeconds = 300,
): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const header = { alg: "HS256", typ: "JWT" };
  const claims: QrClaims = {
    sub: motherId,
    jti: crypto.randomUUID(),
    iat: now,
    exp: now + ttlSeconds,
  };
  const body = `${bytesToB64url(encoder.encode(JSON.stringify(header)))}.` +
    bytesToB64url(encoder.encode(JSON.stringify(claims)));
  const sig = new Uint8Array(
    await crypto.subtle.sign("HMAC", await hmacKey(secret), encoder.encode(body)),
  );
  return `${body}.${bytesToB64url(sig)}`;
}

export type VerifyResult =
  | { ok: true; claims: QrClaims }
  | { ok: false; reason: "malformed" | "bad_signature" | "expired" };

export async function verifyQrToken(
  token: string, secret: string,
): Promise<VerifyResult> {
  const parts = token.split(".");
  if (parts.length !== 3) return { ok: false, reason: "malformed" };
  const [h, p, s] = parts;

  // Verified before the payload is read, let alone trusted. Parsing an
  // unverified JWT and acting on its claims is the classic way to be handed
  // someone else's mother id.
  const valid = await crypto.subtle.verify(
    "HMAC", await hmacKey(secret), b64urlToBytes(s), encoder.encode(`${h}.${p}`),
  );
  if (!valid) return { ok: false, reason: "bad_signature" };

  let claims: QrClaims;
  try {
    claims = JSON.parse(new TextDecoder().decode(b64urlToBytes(p)));
  } catch {
    return { ok: false, reason: "malformed" };
  }
  if (!claims.sub || !claims.jti || !claims.exp) {
    return { ok: false, reason: "malformed" };
  }
  if (claims.exp * 1000 < Date.now()) return { ok: false, reason: "expired" };

  return { ok: true, claims };
}
