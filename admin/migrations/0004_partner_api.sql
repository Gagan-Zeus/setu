-- Setu Admin Portal — partner organisations, API keys, and the PHI access log.

-- ------------------------------------------------------------ partner_orgs
create table if not exists public.partner_orgs (
  id                  uuid primary key default gen_random_uuid(),
  legal_name          text not null,
  type                text not null
                        check (type in ('private_hospital', 'lab', 'ngo')),
  registration_number text not null,
  contact_name        text not null,
  contact_email       text not null,
  contact_phone       text not null,
  address             text not null,
  district_id         uuid references public.districts (id),
  intended_use        text not null,
  status              text not null default 'pending'
                        check (status in ('pending','approved','rejected','suspended')),
  requested_at        timestamptz not null default now(),
  reviewed_at         timestamptz,
  reviewed_by         uuid references public.admin_users (id),
  rejection_reason    text,
  -- A live key is a second, deliberate decision after approval, so the
  -- moment it was taken is recorded separately from the approval itself.
  live_access_granted_at timestamptz,
  live_access_granted_by uuid references public.admin_users (id),
  constraint partner_rejection_has_a_reason
    check (status <> 'rejected' or rejection_reason is not null),
  constraint partner_review_is_attributed
    check (status = 'pending' or (reviewed_at is not null and reviewed_by is not null))
);

create unique index if not exists partner_orgs_registration_unique
  on public.partner_orgs (upper(registration_number));
create index if not exists partner_orgs_pending_idx
  on public.partner_orgs (requested_at desc) where status = 'pending';

-- ---------------------------------------------------------------- api_keys
create table if not exists public.api_keys (
  id                 uuid primary key default gen_random_uuid(),
  partner_org_id     uuid not null references public.partner_orgs (id),
  -- First 12 characters, e.g. 'setu_live_7f'. Enough to name a key in the UI
  -- and to look one up; useless as a credential.
  key_prefix         text not null,
  -- SHA-256 of the whole key. The plaintext exists once, in the response that
  -- issued it, and nowhere else — not in a column, not in a log line.
  key_hash           text not null unique,
  scopes             text[] not null default '{}',
  environment        text not null check (environment in ('sandbox', 'live')),
  rate_limit_per_min int  not null default 60 check (rate_limit_per_min between 1 and 10000),
  created_at         timestamptz not null default now(),
  created_by         uuid references public.admin_users (id),
  last_used_at       timestamptz,
  expires_at         timestamptz,
  revoked_at         timestamptz,
  revoked_by         uuid references public.admin_users (id),
  revocation_reason  text,
  constraint api_key_revocation_has_a_reason
    check (revoked_at is null or revocation_reason is not null),
  -- Exactly one scope exists today. The column is an array because the check
  -- is written as a real permission test, but nothing unbuilt is allowed in.
  constraint api_key_scopes_are_known
    check (scopes <@ array['mother.read_by_qr']::text[])
);

create unique index if not exists api_keys_prefix_unique on public.api_keys (key_prefix);
create index if not exists api_keys_partner_idx on public.api_keys (partner_org_id);
-- The lookup the partner API does on every single request.
create index if not exists api_keys_live_idx
  on public.api_keys (key_hash) where revoked_at is null;

-- Only an approved partner may hold a key, and a live key needs the second
-- confirmation to have happened.
create or replace function public.api_key_partner_guard()
returns trigger language plpgsql security definer set search_path = public as $$
declare p public.partner_orgs;
begin
  select * into p from public.partner_orgs where id = new.partner_org_id;
  if p.status <> 'approved' then
    raise exception 'Cannot issue a key to a partner with status %', p.status;
  end if;
  if new.environment = 'live' and p.live_access_granted_at is null then
    raise exception
      'Live access has not been confirmed for this partner; issue a sandbox key first';
  end if;
  return new;
end $$;

drop trigger if exists api_keys_partner_guard on public.api_keys;
create trigger api_keys_partner_guard
  before insert on public.api_keys
  for each row execute function public.api_key_partner_guard();

drop trigger if exists api_keys_no_delete on public.api_keys;
create trigger api_keys_no_delete
  before delete on public.api_keys
  for each row execute function public.no_delete();

-- ------------------------------------------------------- single-use QR tokens
-- The mother's app mints a 5-minute JWT and renders it as the QR. A photograph
-- of that QR is useless once it expires — but inside those five minutes it
-- would still work, so a jti may be spent exactly once.
--
-- The primary key does the enforcing: a replay is a duplicate key violation,
-- not a race between a SELECT and an INSERT.
create table if not exists public.qr_token_jti_used (
  jti          text primary key,
  mother_id    uuid not null references public.mothers (id),
  api_key_id   uuid references public.api_keys (id),
  used_at      timestamptz not null default now(),
  expires_at   timestamptz not null
);

-- Spent tokens only matter until they would have expired anyway; this is what
-- a nightly job prunes on.
create index if not exists qr_jti_expiry_idx on public.qr_token_jti_used (expires_at);

-- ------------------------------------------------------------ phi_access_log
-- Every partner lookup, successful or not. Append-only.
create table if not exists public.phi_access_log (
  id              bigserial primary key,
  api_key_id      uuid references public.api_keys (id),
  partner_org_id  uuid references public.partner_orgs (id),
  -- Null on a failure that never resolved a mother — a bad key, an expired
  -- token. The row is still written; a burst of those is the signal.
  mother_id       uuid references public.mothers (id),
  endpoint        text not null,
  qr_token_jti    text,
  ip_address      inet,
  user_agent      text,
  response_status int not null,
  -- Distinguishes 'wrong key' from 'right key, wrong scope' when reading the
  -- log months later, without having to infer it from the status code.
  failure_reason  text,
  accessed_at     timestamptz not null default now()
);

-- Rate limiting counts from this table rather than a second counter: the row
-- has to be written anyway, and a counter that can drift from the audit log is
-- worse than a slightly heavier query.
create index if not exists phi_access_rate_idx
  on public.phi_access_log (api_key_id, accessed_at desc);
create index if not exists phi_access_partner_idx
  on public.phi_access_log (partner_org_id, accessed_at desc);
create index if not exists phi_access_mother_idx
  on public.phi_access_log (mother_id, accessed_at desc);
-- "Who has been failing to authenticate, from where" — the query that matters
-- when something is wrong.
create index if not exists phi_access_failures_idx
  on public.phi_access_log (ip_address, accessed_at desc)
  where response_status >= 400;

-- Append-only, enforced by triggers rather than by the absence of a policy.
-- RLS is bypassed by the service role, and the partner API runs as the service
-- role, so "no UPDATE policy" would not actually stop an UPDATE. A trigger
-- stops everyone, including us.
create or replace function public.append_only()
returns trigger language plpgsql as $$
begin
  raise exception '% is append-only', TG_TABLE_NAME;
end $$;

drop trigger if exists phi_access_log_append_only on public.phi_access_log;
create trigger phi_access_log_append_only
  before update or delete on public.phi_access_log
  for each row execute function public.append_only();

-- ---------------------------------------------------------------------- RLS
alter table public.partner_orgs       enable row level security;
alter table public.api_keys           enable row level security;
alter table public.phi_access_log     enable row level security;
alter table public.qr_token_jti_used  enable row level security;

-- The public request form is unauthenticated, so anon may insert a request —
-- and nothing else. It cannot read back what it wrote.
drop policy if exists "anyone may request partner access" on public.partner_orgs;
create policy "anyone may request partner access" on public.partner_orgs
  for insert to anon, authenticated
  with check (status = 'pending' and reviewed_at is null and reviewed_by is null);

drop policy if exists "admins read partner_orgs" on public.partner_orgs;
create policy "admins read partner_orgs" on public.partner_orgs
  for select to authenticated using (public.is_admin());

-- Approval is a super_admin power. The spec is explicit that a district_admin
-- cannot approve partner API access, and this is where that is true.
drop policy if exists "super_admin reviews partner_orgs" on public.partner_orgs;
create policy "super_admin reviews partner_orgs" on public.partner_orgs
  for update to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

drop policy if exists "admins read api_keys" on public.api_keys;
create policy "admins read api_keys" on public.api_keys
  for select to authenticated using (public.is_admin());

-- Revocation has to be instant and available to any administrator: the person
-- who notices a leaked key at 2am should not have to find a super_admin.
-- Issuing is the Node service's job and runs as the service role.
drop policy if exists "admins revoke api_keys" on public.api_keys;
create policy "admins revoke api_keys" on public.api_keys
  for update to authenticated
  using (public.is_admin()) with check (public.is_admin());

drop policy if exists "admins read phi_access_log" on public.phi_access_log;
create policy "admins read phi_access_log" on public.phi_access_log
  for select to authenticated using (public.is_admin());

drop policy if exists "admins read qr_token_jti_used" on public.qr_token_jti_used;
create policy "admins read qr_token_jti_used" on public.qr_token_jti_used
  for select to authenticated using (public.is_admin());

-- Column grants, not a view: key_hash is never granted to `authenticated` at
-- all, so no policy mistake and no accidental `select *` from the browser can
-- surface it. Postgres refuses the column, not the row.
revoke all on public.api_keys from authenticated;
grant select (id, partner_org_id, key_prefix, scopes, environment,
              rate_limit_per_min, created_at, created_by, last_used_at,
              expires_at, revoked_at, revoked_by, revocation_reason)
  on public.api_keys to authenticated;
grant update (revoked_at, revoked_by, revocation_reason, rate_limit_per_min)
  on public.api_keys to authenticated;

grant select on public.partner_orgs, public.phi_access_log,
                public.qr_token_jti_used to authenticated;
grant insert on public.partner_orgs to anon, authenticated;
grant update on public.partner_orgs to authenticated;

notify pgrst, 'reload schema';
