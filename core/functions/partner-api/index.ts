// Setu partner API.
//
//   POST /partner-api/admin/issue-key   — an administrator issues a key; the
//                                         key itself is emailed, never returned
//   POST /partner-api/v1/mothers/lookup — a partner reads a mother's summary
//   POST /partner-api/admin/mint-qr     — a QR token, for integration testing
//
// This runs as the service role, which bypasses RLS entirely. Every check that
// matters is therefore written out here, in order, and the function refuses by
// default: nothing reaches a mother's record without a valid key, the right
// scope, a signed unexpired unspent token, and an environment that matches.
//
// Secrets (already set for send-email, shared here):
//   RESEND_API_KEY, OTP_FROM_ADDRESS
// Additionally:
//   QR_TOKEN_SECRET — HMAC secret for the mother's QR JWT

import { generateKey, looksLikeAKey, sha256, environmentOf } from "./keys.ts";
import { mintQrToken, verifyQrToken } from "./qr.ts";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");
const FROM_ADDRESS = Deno.env.get("OTP_FROM_ADDRESS") ?? "no-reply@mysetu.live";
const QR_SECRET = Deno.env.get("QR_TOKEN_SECRET") ?? "";

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, content-type, apikey",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json", ...CORS },
  });
}

/// PostgREST as the service role. RLS does not apply, which is the point and
/// the danger; nothing calls this before the checks above it have passed.
async function db(path: string, init: RequestInit = {}) {
  const res = await fetch(`${SUPABASE_URL}/rest/v1/${path}`, {
    ...init,
    headers: {
      apikey: SERVICE_KEY,
      Authorization: `Bearer ${SERVICE_KEY}`,
      "Content-Type": "application/json",
      ...(init.headers ?? {}),
    },
  });
  const body = await res.text();
  if (!res.ok) {
    const err = new Error(`db ${res.status}: ${body}`) as Error & { status?: number; body?: string };
    err.status = res.status;
    err.body = body;
    throw err;
  }
  // PostgREST answers an insert with 201 and an EMPTY body unless asked for a
  // representation, so res.json() throws "Unexpected end of JSON input" on a
  // write that in fact succeeded. Parse only when there is something to parse.
  return body ? JSON.parse(body) : null;
}

const rpc = (fn: string, args: unknown) =>
  db(`rpc/${fn}`, { method: "POST", body: JSON.stringify(args) });

/// Never the key, never the token, never the mother's id. A log line that
/// echoes a credential turns log access into API access.
function clientIp(req: Request): string | null {
  const fwd = req.headers.get("x-forwarded-for");
  return fwd ? fwd.split(",")[0].trim() : null;
}

/// Written on every call, success or failure. A burst of 401s from one address
/// is the signal that matters, and it only exists if failures are logged too.
async function logAccess(row: Record<string, unknown>) {
  try {
    await db("phi_access_log", { method: "POST", body: JSON.stringify(row) });
  } catch (error) {
    // Never fail a request because the audit insert failed, but never lose it
    // silently either.
    console.error("phi_access_log insert failed", error);
  }
}

// ---------------------------------------------------------------- issue a key
async function issueKey(req: Request): Promise<Response> {
  // The caller is an administrator in the portal, identified by their own JWT.
  // The service role key is not accepted here: it would let anything holding it
  // mint partner credentials.
  const jwt = (req.headers.get("authorization") ?? "").replace(/^Bearer /, "");
  if (!jwt) return json({ message: "Sign in first" }, 401);

  const who = await fetch(`${SUPABASE_URL}/auth/v1/user`, {
    headers: { apikey: SERVICE_KEY, Authorization: `Bearer ${jwt}` },
  });
  if (!who.ok) return json({ message: "Sign in first" }, 401);
  const authUserId = (await who.json()).id as string;

  const admins = await db(
    `admin_users?auth_user_id=eq.${authUserId}&active=is.true&select=id,role,email`,
  );
  const admin = admins?.[0];
  // Approving partner access is a super_admin power, and so is issuing the
  // credential that follows from it.
  if (!admin || admin.role !== "super_admin") {
    return json({ message: "Only a super admin may issue an API key" }, 403);
  }

  const { partner_org_id, environment } = await req.json();
  if (!partner_org_id || !["sandbox", "live"].includes(environment)) {
    return json({ message: "partner_org_id and environment are required" }, 400);
  }

  const orgs = await db(`partner_orgs?id=eq.${partner_org_id}&select=*`);
  const org = orgs?.[0];
  if (!org) return json({ message: "No such partner" }, 404);
  if (org.status !== "approved") {
    return json({ message: `Partner is ${org.status}, not approved` }, 409);
  }
  if (environment === "live" && !org.live_access_granted_at) {
    return json({ message: "Live access has not been confirmed" }, 409);
  }

  // The key goes to the address the medical council holds, not one typed into
  // the request form. A form field is attacker-controlled; the register is not.
  let to: string | null = org.contact_email;
  if (org.kmc_registration_number) {
    const v = await rpc("kmc_verify_public", {
      p_registration_number: org.kmc_registration_number,
    });
    if (!v?.valid) {
      return json({
        message: `The registration behind this request is no longer valid (${v?.reason}). ` +
          "Re-verify before issuing a key.",
      }, 409);
    }
    to = v.email ?? to;
  }
  if (!to) return json({ message: "No address to send the key to" }, 409);
  if (!RESEND_API_KEY) return json({ message: "Mailer not configured" }, 500);

  const { key, prefix, lastFour, hash } = await generateKey(environment);

  // Stored first. If the email fails the key still exists and can be revoked;
  // emailing first and failing to store would put a working credential in
  // someone's inbox that we have no record of.
  const inserted = await db("api_keys", {
    method: "POST",
    headers: { Prefer: "return=representation" },
    body: JSON.stringify({
      partner_org_id,
      key_prefix: prefix,
      key_hash: hash,
      key_last_four: lastFour,
      scopes: ["mother.read_by_qr"],
      environment,
      created_by: admin.id,
      issued_to_email: to,
      issued_at: new Date().toISOString(),
    }),
  });

  const sent = await sendKeyEmail(to, org, key, environment, lastFour);

  // The response says where it went and what it ends with. Never the key: this
  // travels back through a browser, and the whole point is that it exists in
  // exactly one place.
  return json({
    issued: true,
    key_id: inserted?.[0]?.id,
    key_prefix: prefix,
    key_last_four: lastFour,
    emailed_to: to,
    email_sent: sent,
  });
}

async function sendKeyEmail(
  to: string, org: Record<string, unknown>, key: string,
  environment: string, lastFour: string,
): Promise<boolean> {
  const isLive = environment === "live";
  const html = `<!doctype html><html><body style="margin:0;background:#F7F2EA;font-family:Inter,system-ui,sans-serif;color:#10312B">
<table width="100%" cellpadding="0" cellspacing="0"><tr><td align="center" style="padding:24px 12px">
<table width="560" cellpadding="0" cellspacing="0" style="width:100%;max-width:560px;background:#fff;border-radius:16px">
<tr><td style="padding:26px 26px 0">
  <div style="font-size:19px;font-weight:700;color:#0F5257">Setu API</div>
  <div style="font-size:14px;color:#5E6E6A;padding-top:2px">${org.legal_name}</div>
</td></tr>
<tr><td style="padding:20px 26px 0;font-size:15px;line-height:1.6">
  Your ${isLive ? "<strong>live</strong>" : "sandbox"} API key is below. It is shown here and
  nowhere else — we store only a hash of it, so if it is lost it has to be replaced, not recovered.
</td></tr>
<tr><td style="padding:14px 26px 0">
  <div style="background:#E4EFEC;border-radius:12px;padding:16px;font-family:ui-monospace,Menlo,monospace;font-size:14px;word-break:break-all;color:#0F5257">${key}</div>
</td></tr>
<tr><td style="padding:16px 26px 0;font-size:14px;line-height:1.6;color:#5E6E6A">
  Ends in <strong style="color:#10312B">${lastFour}</strong> — we will refer to it that way, and
  will never ask you for the whole key.
</td></tr>
<tr><td style="padding:16px 26px 0;font-size:14px;line-height:1.6">
  <strong>How to use it</strong><br/>
  <div style="background:#F7F2EA;border-radius:10px;padding:12px;margin-top:8px;font-family:ui-monospace,Menlo,monospace;font-size:12px;white-space:pre-wrap">POST ${SUPABASE_URL}/functions/v1/partner-api/v1/mothers/lookup
Authorization: Bearer &lt;your key&gt;
Content-Type: application/json

{ "qr_token": "&lt;the JWT from her Thayi Setu QR&gt;" }</div>
</td></tr>
<tr><td style="padding:16px 26px 0;font-size:14px;line-height:1.6">
  <strong>What it can do</strong><br/>
  Read the antenatal summary of a mother who is standing in front of you showing her QR code.
  Nothing else. It cannot list mothers, cannot search, and cannot write.
  ${isLive
    ? "This key reads real patient records."
    : "This is a sandbox key: it resolves only seeded test records and can never reach a real one."}
</td></tr>
<tr><td style="padding:16px 26px 26px;font-size:13px;line-height:1.6;color:#5E6E6A;border-top:1px solid #E6DED2;margin-top:8px">
  Treat it like a password. Do not put it in a mobile app, a browser, or anything a patient could
  read — it belongs on your server. If it leaks, tell us and we will revoke it; a revoked key stops
  working on the next request.
</td></tr>
</table></td></tr></table></body></html>`;

  const res = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${RESEND_API_KEY}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      from: `Setu API <${FROM_ADDRESS}>`,
      to: [to],
      subject: `Your Setu ${isLive ? "live" : "sandbox"} API key (ends ${lastFour})`,
      html,
    }),
  });
  if (!res.ok) console.error(`resend returned ${res.status}`);
  return res.ok;
}

// ------------------------------------------------------------- the lookup
async function lookup(req: Request): Promise<Response> {
  const ip = clientIp(req);
  const ua = req.headers.get("user-agent");
  const endpoint = "/v1/mothers/lookup";
  const base = { endpoint, ip_address: ip, user_agent: ua };

  const presented = (req.headers.get("authorization") ?? "").replace(/^Bearer /i, "").trim();

  // Shape and checksum first: a mistyped key fails here without a database
  // round trip and without being counted as a failed authentication.
  if (!presented || !(await looksLikeAKey(presented))) {
    await logAccess({ ...base, response_status: 401, failure_reason: "malformed_key" });
    return json({ error: "unauthorized", message: "Missing or malformed API key" }, 401);
  }

  const rows = await db(
    `api_keys?key_hash=eq.${await sha256(presented)}&select=*,partner_orgs(id,legal_name,status)`,
  );
  const key = rows?.[0];
  if (!key) {
    await logAccess({ ...base, response_status: 401, failure_reason: "unknown_key" });
    return json({ error: "unauthorized", message: "Invalid API key" }, 401);
  }

  const fail = async (status: number, error: string, message: string, reason: string) => {
    await logAccess({
      ...base, api_key_id: key.id, partner_org_id: key.partner_org_id,
      response_status: status, failure_reason: reason,
    });
    return json({ error, message }, status);
  };

  // Revocation is immediate by construction: the key is read from the database
  // on every request, so there is no cache to expire.
  if (key.revoked_at) return fail(401, "unauthorized", "This API key has been revoked", "revoked");
  if (key.expires_at && new Date(key.expires_at) < new Date()) {
    return fail(401, "unauthorized", "This API key has expired", "expired_key");
  }
  if (key.partner_orgs?.status !== "approved") {
    return fail(403, "forbidden", "Partner access is not active", "partner_not_approved");
  }
  if (!(key.scopes ?? []).includes("mother.read_by_qr")) {
    return fail(403, "forbidden", "This key lacks the mother.read_by_qr scope", "missing_scope");
  }
  if (key.allowed_ips?.length && ip && !key.allowed_ips.includes(ip)) {
    return fail(403, "forbidden", "This key is not permitted from this address", "ip_not_allowed");
  }

  // Counted from the audit log rather than a separate counter: the row has to
  // be written anyway, and a counter that can drift from the log is worse than
  // a slightly heavier query.
  const since = new Date(Date.now() - 60_000).toISOString();
  const recent = await db(
    `phi_access_log?api_key_id=eq.${key.id}&accessed_at=gte.${since}&select=id`,
  );
  if ((recent?.length ?? 0) >= (key.rate_limit_per_min ?? 60)) {
    return fail(429, "rate_limited",
      `Rate limit of ${key.rate_limit_per_min}/min exceeded`, "rate_limited");
  }

  let body: { qr_token?: string };
  try { body = await req.json(); } catch { body = {}; }
  if (!body.qr_token) {
    return fail(400, "bad_request", "qr_token is required", "missing_qr_token");
  }
  if (!QR_SECRET) {
    return fail(500, "server_error", "QR verification is not configured", "no_qr_secret");
  }

  const verified = await verifyQrToken(body.qr_token, QR_SECRET);
  if (!verified.ok) {
    // 410 for an expired token, distinct from 401: the caller's credential is
    // fine, the mother's code has simply aged out and she can show a fresh one.
    const status = verified.reason === "expired" ? 410 : 400;
    return fail(status,
      verified.reason === "expired" ? "qr_expired" : "bad_request",
      verified.reason === "expired"
        ? "This QR code has expired. Ask her to show the code again."
        : "The QR token could not be verified",
      `qr_${verified.reason}`);
  }

  const { sub: motherId, jti, exp } = verified.claims;

  // Single use. The primary key does the enforcing, so a replay is a duplicate
  // key violation rather than a race between a read and a write.
  try {
    await db("qr_token_jti_used", {
      method: "POST",
      body: JSON.stringify({
        jti, mother_id: motherId, api_key_id: key.id,
        expires_at: new Date(exp * 1000).toISOString(),
      }),
    });
  } catch (error) {
    // Only a duplicate key is a replay. Treating every failure here as one
    // reported a perfectly good token as already spent and hid the real cause,
    // which is the worst kind of error message: confident and wrong.
    const e = error as Error & { status?: number; body?: string };
    const isReplay = e.status === 409 || (e.body ?? "").includes("23505");
    if (!isReplay) {
      console.error("qr_token_jti_used insert failed", e.status, e.body);
      await logAccess({
        ...base, api_key_id: key.id, partner_org_id: key.partner_org_id,
        mother_id: motherId, qr_token_jti: jti,
        response_status: 500, failure_reason: "jti_insert_failed",
      });
      return json({ error: "server_error", message: "Something went wrong" }, 500);
    }
    await logAccess({
      ...base, api_key_id: key.id, partner_org_id: key.partner_org_id,
      mother_id: motherId, qr_token_jti: jti,
      response_status: 409, failure_reason: "qr_replayed",
    });
    return json({
      error: "qr_already_used",
      message: "This QR code has already been used. Ask her to show the code again.",
    }, 409);
  }

  // A sandbox key resolves only seeded records and a live key only real ones.
  // Enforced on the row, not on the caller's word.
  const mothers = await db(`mothers?id=eq.${motherId}&select=id,is_sandbox,active`);
  const mother = mothers?.[0];
  const wantSandbox = environmentOf(presented) === "sandbox";
  if (!mother || !mother.active || mother.is_sandbox !== wantSandbox) {
    await logAccess({
      ...base, api_key_id: key.id, partner_org_id: key.partner_org_id,
      mother_id: motherId, qr_token_jti: jti,
      response_status: 404,
      failure_reason: mother && mother.is_sandbox !== wantSandbox
        ? "environment_mismatch" : "mother_not_found",
    });
    return json({ error: "not_found", message: "No record for that code" }, 404);
  }

  const summary = await rpc("partner_mother_summary", { p_mother_id: motherId });

  await db(`api_keys?id=eq.${key.id}`, {
    method: "PATCH",
    body: JSON.stringify({ last_used_at: new Date().toISOString() }),
  });
  await logAccess({
    ...base, api_key_id: key.id, partner_org_id: key.partner_org_id,
    mother_id: motherId, qr_token_jti: jti, response_status: 200,
  });

  return json({ mother: summary });
}

// ------------------------------------------- a QR token, for integration tests
async function mintQr(req: Request): Promise<Response> {
  const jwt = (req.headers.get("authorization") ?? "").replace(/^Bearer /, "");
  const who = await fetch(`${SUPABASE_URL}/auth/v1/user`, {
    headers: { apikey: SERVICE_KEY, Authorization: `Bearer ${jwt}` },
  });
  if (!who.ok) return json({ message: "Sign in first" }, 401);
  const admins = await db(
    `admin_users?auth_user_id=eq.${(await who.json()).id}&active=is.true&select=id`,
  );
  if (!admins?.[0]) return json({ message: "Administrators only" }, 403);

  const { mother_id } = await req.json();
  if (!mother_id) return json({ message: "mother_id is required" }, 400);
  if (!QR_SECRET) return json({ message: "QR_TOKEN_SECRET is not set" }, 500);

  return json({
    qr_token: await mintQrToken(mother_id, QR_SECRET),
    expires_in_seconds: 300,
  });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  if (req.method !== "POST") return json({ message: "Method not allowed" }, 405);

  const path = new URL(req.url).pathname.replace(/^\/partner-api/, "");
  try {
    if (path === "/admin/issue-key") return await issueKey(req);
    if (path === "/admin/mint-qr") return await mintQr(req);
    if (path === "/v1/mothers/lookup") return await lookup(req);
    return json({ message: "Not found" }, 404);
  } catch (error) {
    // Never return the message: it can carry a database error containing the
    // query, and the query can contain a key hash.
    console.error("partner-api", error);
    return json({ error: "server_error", message: "Something went wrong" }, 500);
  }
});
