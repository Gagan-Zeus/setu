/// Generating, formatting and checking a partner API key.
///
/// A key is a bearer credential: whoever holds the string is the partner. That
/// puts every property worth having into how it is made, stored and checked.

/// setu_live_<40 base32 chars><4 char checksum>
///
/// Base32 without I, L, O, U — the alphabet Crockford uses — because these are
/// read off a screen and typed into a config file, and 1/I/l and 0/O are where
/// that goes wrong. Excluding U additionally keeps accidental words out.
const ALPHABET = "0123456789ABCDEFGHJKMNPQRSTVWXYZ";
const BODY_LEN = 40;

export type Environment = "sandbox" | "live";

function prefixFor(env: Environment) {
  return env === "live" ? "setu_live_" : "setu_test_";
}

/// Four characters derived from the body. A mistyped key fails here rather than
/// at the database, so a typo cannot be confused with a revoked key, and a
/// mistyped key never becomes a row in the failed-authentication count that is
/// meant to show an attack.
async function checksum(body: string): Promise<string> {
  const digest = new Uint8Array(
    await crypto.subtle.digest("SHA-256", new TextEncoder().encode(body)),
  );
  return Array.from(digest.slice(0, 4))
    .map((b) => ALPHABET[b % ALPHABET.length])
    .join("");
}

export async function generateKey(env: Environment): Promise<{
  key: string;
  prefix: string;
  lastFour: string;
  hash: string;
}> {
  // crypto.getRandomValues, never Math.random. 40 characters of this alphabet
  // is 200 bits; the modulo below is uniform because 256 is divisible by 32.
  const raw = new Uint8Array(BODY_LEN);
  crypto.getRandomValues(raw);
  const body = Array.from(raw).map((b) => ALPHABET[b % ALPHABET.length]).join("");

  const key = prefixFor(env) + body + (await checksum(body));
  return {
    key,
    prefix: key.slice(0, 12),
    lastFour: key.slice(-4),
    hash: await sha256(key),
  };
}

/// SHA-256 of the whole key, hex. The plaintext exists in one email and nowhere
/// else — not in a column, not in a log line, not in the response that issued
/// it. A stolen database yields hashes, and a hash cannot be presented as a key.
export async function sha256(value: string): Promise<string> {
  const digest = await crypto.subtle.digest(
    "SHA-256",
    new TextEncoder().encode(value),
  );
  return Array.from(new Uint8Array(digest))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

/// Shape and checksum only — this says nothing about whether the key exists.
export async function looksLikeAKey(key: string): Promise<boolean> {
  const m = /^setu_(live|test)_([0-9A-HJKMNP-TV-Z]{40})([0-9A-HJKMNP-TV-Z]{4})$/
    .exec(key);
  if (!m) return false;
  return (await checksum(m[2])) === m[3];
}

export function environmentOf(key: string): Environment | null {
  if (key.startsWith("setu_live_")) return "live";
  if (key.startsWith("setu_test_")) return "sandbox";
  return null;
}
