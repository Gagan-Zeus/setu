// Setu admin API — the operations that cannot run in a browser.
//
//   POST /admin-api/staff  — create a login and a staff row, together
//
// Registering a medical officer or an ASHA worker means creating a Supabase
// auth user AND a public.staff row, and for an ASHA a public.asha_workers
// directory entry too. All of that needs the service-role key, which bypasses
// RLS and must never reach a browser — anything shipped to a client is readable
// by whoever opens it.
//
// Deliberately a separate function from partner-api. That one is exposed to the
// internet with no JWT gate so a hospital can present an API key; this one only
// ever answers an administrator's session. Sharing a deployment would put staff
// creation behind the same front door as the public endpoint, and the blast
// radius of a mistake there is every login in the system.

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");
const FROM_ADDRESS = Deno.env.get("OTP_FROM_ADDRESS") ?? "no-reply@mysetu.live";

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
    const err = new Error(`db ${res.status}: ${body}`) as Error & {
      status?: number; body?: string;
    };
    err.status = res.status;
    err.body = body;
    throw err;
  }
  // PostgREST answers an insert with 201 and an empty body unless a
  // representation is asked for, so parse only when there is something to parse.
  return body ? JSON.parse(body) : null;
}

/// The administrator making the request, or null.
async function adminFrom(req: Request) {
  const jwt = (req.headers.get("authorization") ?? "").replace(/^Bearer /, "");
  if (!jwt) return null;
  const who = await fetch(`${SUPABASE_URL}/auth/v1/user`, {
    headers: { apikey: SERVICE_KEY, Authorization: `Bearer ${jwt}` },
  });
  if (!who.ok) return null;
  const uid = (await who.json()).id as string;
  const rows = await db(
    `admin_users?auth_user_id=eq.${uid}&active=is.true&select=id,role,email,full_name`,
  );
  return rows?.[0] ?? null;
}

interface StaffBody {
  role: "doctor" | "asha";
  name: string;
  name_kn?: string;
  email: string;
  phone: string;
  employee_code: string;
  phc_id: string;
  kmc_registration_number?: string;
  sub_centre?: string;
  villages?: string[];
}

async function createStaff(req: Request): Promise<Response> {
  const admin = await adminFrom(req);
  if (!admin) return json({ message: "Sign in as an administrator" }, 401);
  if (admin.role === "viewer") {
    return json({ message: "A viewer cannot register staff" }, 403);
  }

  const b = await req.json() as StaffBody;
  for (const f of ["role", "name", "email", "phone", "employee_code", "phc_id"] as const) {
    if (!b[f]) return json({ message: `${f} is required` }, 400);
  }
  if (b.role !== "doctor" && b.role !== "asha") {
    return json({ message: "role must be doctor or asha" }, 400);
  }
  const email = b.email.trim().toLowerCase();

  const phc = (await db(
    `health_centres?id=eq.${b.phc_id}&select=id,name_en,district_id,active`,
  ))?.[0];
  if (!phc) return json({ message: "No such PHC" }, 404);
  if (!phc.active) return json({ message: "That PHC is not active" }, 409);

  // A district_admin may only staff their own districts. Checked here because
  // the service role bypasses the RLS policy that would otherwise say so.
  if (admin.role !== "super_admin") {
    const scoped = await db(
      `admin_districts?admin_user_id=eq.${admin.id}&district_id=eq.${phc.district_id}&select=district_id`,
    );
    if (!scoped?.length) {
      return json({ message: "That PHC is outside your district" }, 403);
    }
  }

  // An address already in use would create a second login for one person, and
  // the two would diverge. Refuse it by name rather than with a constraint
  // error nobody can read.
  const clash = await db(`staff?email=eq.${encodeURIComponent(email)}&select=id,name,active`);
  if (clash?.length) {
    return json({
      message: `${clash[0].name} is already registered with that email address`,
    }, 409);
  }
  const adminClash = await db(
    `admin_users?email=eq.${encodeURIComponent(email)}&select=id`,
  );
  if (adminClash?.length) {
    return json({
      message: "That address belongs to an administrator. Clinical staff must be separate.",
    }, 409);
  }

  // A doctor is registered by council number, so it must still be valid at the
  // moment of registration — the register is live and a doctor may have lapsed
  // since the lookup that filled the form.
  if (b.role === "doctor") {
    if (!b.kmc_registration_number) {
      return json({ message: "A medical officer needs a KMC registration number" }, 400);
    }
    const v = await db("rpc/kmc_verify_public", {
      method: "POST",
      body: JSON.stringify({ p_registration_number: b.kmc_registration_number }),
    });
    if (!v?.valid) {
      return json({
        message: `That registration is not usable (${v?.reason ?? "unknown"})`,
      }, 409);
    }
    const kmcClash = await db(
      `staff?kmc_registration_number=eq.${b.kmc_registration_number}&select=id,name`,
    );
    if (kmcClash?.length) {
      return json({
        message: `That registration already belongs to ${kmcClash[0].name}`,
      }, 409);
    }
  }

  // ------------------------------------------------------------ the writes
  // The staff row first. If the auth user is created and the row insert then
  // fails, there is a login with no role and no scope: the person signs in
  // successfully and sees an empty app, which looks like a bug in the app
  // rather than an interrupted registration. This order leaves the opposite
  // and better failure — a record with no login yet, which the invite fixes.
  const staff = (await db("staff", {
    method: "POST",
    headers: { Prefer: "return=representation" },
    body: JSON.stringify({
      role: b.role,
      name: b.name.trim(),
      email,
      phone: b.phone.trim(),
      employee_code: b.employee_code.trim(),
      phc_id: b.phc_id,
      district_id: phc.district_id,
      facility: phc.name_en,
      sub_centre: b.sub_centre?.trim() || null,
      kmc_registration_number: b.role === "doctor" ? b.kmc_registration_number : null,
      created_by: admin.id,
      active: true,
    }),
  }))?.[0];

  // An ASHA is two things: a login, and an entry in the directory a mother
  // browses to find someone to call. Without the second she can be signed in
  // and still invisible to every pregnant woman in her village, which is the
  // one thing the directory exists for.
  let directoryId: string | null = null;
  if (b.role === "asha") {
    // The village is what a mother recognises — she knows "the Hosahalli
    // worker", not a sub-centre's formal name. It is also what the directory
    // shows beside her name, and it used to be dropped on the floor here: the
    // form sent an empty array and asha_workers.village stayed null for every
    // worker ever registered through the portal.
    //
    // The form sends the village's id; the directory column is its name.
    let villageName: string | null = null;
    const villageId = b.villages?.[0];
    if (villageId) {
      const v = await db(`villages?id=eq.${villageId}&select=name`);
      villageName = v?.[0]?.name ?? null;
    }

    const dir = (await db("asha_workers", {
      method: "POST",
      headers: { Prefer: "return=representation" },
      body: JSON.stringify({
        name_en: b.name.trim(),
        // name_kn is NOT NULL and the mother reads it. Falling back to the
        // English name keeps her findable; it can be corrected later.
        name_kn: (b.name_kn?.trim() || b.name.trim()),
        phone: b.phone.trim(),
        sub_centre_en: b.sub_centre?.trim() || phc.name_en,
        sub_centre_kn: b.sub_centre?.trim() || phc.name_en,
        village: villageName,
        // No latitude here on purpose. A trigger on asha_workers inherits the
        // PHC's coordinate from staff_id, so she is locatable the instant this
        // row exists and there is one place that decides where a worker is.
        staff_id: staff.id,
      }),
    }))?.[0];
    directoryId = dir?.id ?? null;
  }

  // The login. email_confirm because the address was chosen by an
  // administrator from a register, not typed by a stranger at a signup form,
  // and because both apps sign in with a code rather than a password.
  let authCreated = false;
  try {
    const res = await fetch(`${SUPABASE_URL}/auth/v1/admin/users`, {
      method: "POST",
      headers: {
        apikey: SERVICE_KEY,
        Authorization: `Bearer ${SERVICE_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ email, email_confirm: true }),
    });

    let authUserId: string | null = res.ok ? (await res.json()).id : null;

    // An address can already have a login: someone registered before, was
    // removed, and is being registered again. The trigger that ties a staff row
    // to its auth user fires on auth.users INSERT, so nothing would attach this
    // one — she would sign in successfully, have no role, and see an empty app,
    // which reads as a broken app rather than an unfinished registration.
    if (!res.ok) {
      console.error("auth user create failed", res.status);
      const existing = await fetch(
        `${SUPABASE_URL}/auth/v1/admin/users?filter=${encodeURIComponent(email)}`,
        { headers: { apikey: SERVICE_KEY, Authorization: `Bearer ${SERVICE_KEY}` } },
      );
      if (existing.ok) {
        const found = (await existing.json()).users?.find(
          (u: { email?: string }) => u.email?.toLowerCase() === email,
        );
        authUserId = found?.id ?? null;
      }
    }

    if (authUserId) {
      await db(`staff?id=eq.${staff.id}`, {
        method: "PATCH",
        body: JSON.stringify({ auth_user_id: authUserId }),
      });
      authCreated = true;
    }
  } catch (error) {
    console.error("auth user create threw", error);
  }

  const invited = await sendInvite(email, b.name.trim(), b.role, phc.name_en);

  return json({
    created: true,
    staff_id: staff.id,
    asha_worker_id: directoryId,
    login_created: authCreated,
    invite_sent: invited,
  });
}

async function sendInvite(
  to: string, name: string, role: "doctor" | "asha", phc: string,
): Promise<boolean> {
  if (!RESEND_API_KEY) return false;
  const app = role === "doctor" ? "Setu Care" : "ASHA Setu";
  const html = `<!doctype html><html><body style="margin:0;background:#F7F2EA;font-family:Inter,system-ui,sans-serif;color:#10312B">
<table width="100%" cellpadding="0" cellspacing="0"><tr><td align="center" style="padding:24px 12px">
<table width="520" cellpadding="0" cellspacing="0" style="width:100%;max-width:520px;background:#fff;border-radius:16px">
<tr><td style="padding:26px 26px 0">
  <div style="font-size:19px;font-weight:700;color:#0F5257">${app}</div>
  <div style="font-size:14px;color:#5E6E6A;padding-top:2px">${phc}</div>
</td></tr>
<tr><td style="padding:20px 26px 0;font-size:15px;line-height:1.6">
  ${name}, you have been registered at ${phc}.
</td></tr>
<tr><td style="padding:14px 26px 0;font-size:15px;line-height:1.6">
  Open <strong>${app}</strong> and sign in with <strong>${to}</strong>. A six digit code is
  emailed to you each time — there is no password to choose or forget, and nobody who registered
  you can sign in as you.
</td></tr>
<tr><td style="padding:18px 26px 26px;font-size:13px;line-height:1.6;color:#5E6E6A">
  If you were not expecting this, ignore it. Nothing happens until you sign in.
</td></tr>
</table></td></tr></table></body></html>`;

  const res = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${RESEND_API_KEY}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      from: `Setu <${FROM_ADDRESS}>`,
      to: [to],
      subject: `You are registered on ${app}`,
      html,
    }),
  });
  if (!res.ok) console.error(`invite: resend returned ${res.status}`);
  return res.ok;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  if (req.method !== "POST") return json({ message: "Method not allowed" }, 405);

  const path = new URL(req.url).pathname.replace(/^\/admin-api/, "");
  try {
    if (path === "/staff") return await createStaff(req);
    return json({ message: "Not found" }, 404);
  } catch (error) {
    const e = error as Error & { status?: number; body?: string };
    console.error("admin-api", e.status, e.body ?? e.message);
    // A database error can carry the failing query, and the query can carry an
    // address or a registration number. Never return it.
    return json({ error: "server_error", message: "Something went wrong" }, 500);
  }
});
