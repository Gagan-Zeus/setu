# Setu Admin Portal

The control plane for Setu: PHCs, staff, ASHA-to-doctor assignments, mother
records, partner API access, and the audit trail.

React 18 + Vite + TypeScript + Tailwind, Supabase for auth and data, TanStack
Query for server state, Zod for every form.

## Run it

```bash
cp .env.example .env.local     # fill in the project URL and publishable key
npm install
npm run dev                    # http://localhost:5174
```

`npm run build` type-checks and bundles to `dist/`.

## What is deliberately not here

**No service-role key.** The portal authenticates as the signed-in
administrator and nothing else. Anything shipped to a browser is readable by
whoever opens it, and the service role bypasses RLS entirely — so key
generation, staff invites and the partner API live in the Node service, which
is the only thing that holds that key.

Two screens call that service and say so plainly when `VITE_ADMIN_API` is
unset, rather than failing in a way that looks like a bug:

- registering a medical officer or ASHA (creates the auth user *and* the staff
  row, which has to happen together)
- issuing a partner API key (CSPRNG, hashed before storage, shown once)

**No column-hiding in the client.** `api_keys.key_hash` is never granted to
`authenticated`, so `select('*')` on that table is refused by Postgres. The
query asks for an explicit column list for that reason.

**No admin writes to clinical data.** RLS cannot restrict which columns an
update touches, so admins have no UPDATE policy on `mothers` at all.
Reassignment and deactivation go through `admin_reassign_mother()` and
`admin_set_mother_active()`, which touch those columns and no others.

## Routes

| Route | Who |
|---|---|
| `/partner-access` | public — the API request form |
| `/` | dashboard |
| `/phcs`, `/staff`, `/assignments`, `/mothers` | any admin; writes need super or district admin |
| `/partners` | any admin reads; only super_admin approves |
| `/audit` | any admin, viewers included |

A `viewer` never sees a control that would fail at the database anyway.

## Migrations

`migrations/0001…0006` — apply in order. See the header of `0001` for why
administrators are not `staff` rows; it is the load-bearing decision.

## Deploying to Vercel

Import the repo at vercel.com/new with **Root Directory: `admin`**. Everything
else comes from `vercel.json` — Vite preset, `npm run build`, `dist/`, the SPA
rewrite, and the security headers.

Set both environment variables before the first deploy:

```
VITE_SUPABASE_URL       https://<ref>.supabase.co
VITE_SUPABASE_ANON_KEY  sb_publishable_xxxx
```

They are read at **build** time, not runtime — Vite compiles them into the
bundle — so a deploy without them produces an app that throws on load.
`src/lib/supabase.ts` fails loudly rather than silently pointing at nothing.

`vercel.json` carries no comments on purpose. Vercel validates it with
`additionalProperties: false` at the top level and inside `rewrites[]` and
`headers[]`, so a `"//"` key fails the deploy with "should NOT have additional
properties". The reasoning lives here instead:

- **rewrite** `/((?!assets/).*)` → `/index.html` — every route except the built
  assets is client-side, and without this a hard refresh on `/partner-access`
  returns a 404.
- **X-Robots-Tag: noindex** — the portal renders mothers' names and risk
  levels. It should never appear in a search index.
- **X-Frame-Options: DENY** — nothing here should ever be framed.

For GitHub Pages instead, build with `VITE_BASE=/setu/`, copy `index.html` to
`404.html`, and add `.nojekyll`.
