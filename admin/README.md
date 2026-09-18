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
