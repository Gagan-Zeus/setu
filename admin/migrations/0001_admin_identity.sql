-- Setu Admin Portal — who an administrator is.
--
-- Run these in order, in the Supabase SQL editor or via core/run_sql.py.
-- Everything here is idempotent; re-running is how you apply a change.
--
-- ---------------------------------------------------------------------------
-- WHY ADMINS ARE NOT IN public.staff
-- ---------------------------------------------------------------------------
-- The build spec put admins in staff with role 'admin'. They must not be, and
-- this is the single most important decision in these migrations.
--
-- Every clinical write policy already in this database is gated on
--
--     public.current_role_name() is not null
--
-- and current_role_name() reads public.staff.role. Give an administrator a
-- staff row and that function stops returning null for them, which silently
-- grants them insert and update on mothers, anc_visits, tasks, alerts,
-- referrals, clinical_notes and labs — the exact thing the spec forbids
-- ("Don't let admins edit clinical data through this portal, even just in
-- case"). The UI would hide the buttons and the database would happily accept
-- the writes.
--
-- Keeping administrators in their own table means current_role_name() stays
-- null for them and every one of those policies denies them by construction.
-- Nothing has to be added to enforce it, which is why it cannot rot.
--
-- staff.role therefore keeps its existing ('asha','doctor') check untouched.
-- Renaming 'doctor' to 'medical_officer' as the spec suggested would break
-- is_doctor(), can_access_mother(), every clinical policy and all three
-- Flutter apps, for a word.

-- ------------------------------------------------------------- admin_users
create table if not exists public.admin_users (
  id             uuid primary key default gen_random_uuid(),
  -- Null until they accept the invite and Supabase mints the auth user.
  auth_user_id   uuid unique references auth.users (id) on delete cascade,
  full_name      text not null,
  email          text not null unique,
  phone          text,
  role           text not null
                   check (role in ('super_admin', 'district_admin', 'viewer')),
  active         boolean not null default true,
  created_by     uuid references public.admin_users (id),
  created_at     timestamptz not null default now(),
  deactivated_at timestamptz,
  -- Soft delete everywhere: active is the switch, the row stays.
  constraint admin_users_deactivation_consistent
    check (active or deactivated_at is not null)
);

create unique index if not exists admin_users_email_unique
  on public.admin_users (lower(email));
create index if not exists admin_users_auth_idx
  on public.admin_users (auth_user_id) where auth_user_id is not null;

-- A district_admin is scoped to one or more districts. Many-to-many, because
-- a taluk-level administrator covering two districts is normal and encoding
-- it as a single column forces a duplicate person row.
create table if not exists public.admin_districts (
  admin_user_id uuid not null references public.admin_users (id) on delete cascade,
  district_id   uuid not null,
  granted_at    timestamptz not null default now(),
  granted_by    uuid references public.admin_users (id),
  primary key (admin_user_id, district_id)
);

-- The FK is added in 0002, once districts exists. Stated here so the reading
-- order matches the dependency order rather than the other way round.

-- ------------------------------------------- the same person cannot be both
-- An account that is both clinical staff and an administrator would defeat
-- the separation above by holding a staff row. Refuse it on both sides, the
-- way access_grants.sql already refuses an address that is both a mother and
-- a staff member.
create or replace function public.admin_not_staff()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if new.auth_user_id is not null and exists (
       select 1 from public.staff s where s.auth_user_id = new.auth_user_id) then
    raise exception
      'That login is already clinical staff; an administrator must be separate';
  end if;
  return new;
end $$;

create or replace function public.staff_not_admin()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if new.auth_user_id is not null and exists (
       select 1 from public.admin_users a where a.auth_user_id = new.auth_user_id) then
    raise exception
      'That login is already an administrator; clinical staff must be separate';
  end if;
  return new;
end $$;

drop trigger if exists admin_users_not_staff on public.admin_users;
create trigger admin_users_not_staff
  before insert or update of auth_user_id on public.admin_users
  for each row execute function public.admin_not_staff();

drop trigger if exists staff_not_admin on public.staff;
create trigger staff_not_admin
  before insert or update of auth_user_id on public.staff
  for each row execute function public.staff_not_admin();

-- Attach the auth user on first sign-in, the same pattern staff and mothers
-- already use. The invite creates the auth user; this links it.
create or replace function public.link_admin_to_auth_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  update public.admin_users
     set auth_user_id = new.id
   where lower(email) = lower(new.email)
     and auth_user_id is distinct from new.id;
  return new;
end $$;

drop trigger if exists on_auth_user_created_link_admin on auth.users;
create trigger on_auth_user_created_link_admin
  after insert on auth.users
  for each row execute function public.link_admin_to_auth_user();

-- ------------------------------------------------------------------ helpers
-- All SECURITY DEFINER so a policy can call them without the caller needing
-- to read admin_users, and STABLE so they resolve once per statement rather
-- than once per row.

create or replace function public.admin_role()
returns text language sql stable security definer set search_path = public as $$
  select role from public.admin_users
   where auth_user_id = (select auth.uid()) and active
$$;

create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path = public as $$
  select public.admin_role() is not null
$$;

create or replace function public.is_super_admin()
returns boolean language sql stable security definer set search_path = public as $$
  select public.admin_role() = 'super_admin'
$$;

-- Who may write. A viewer is read-only everywhere, enforced here once rather
-- than repeated in thirty policies.
create or replace function public.admin_may_write()
returns boolean language sql stable security definer set search_path = public as $$
  select public.admin_role() in ('super_admin', 'district_admin')
$$;

-- District scope. A super_admin sees everything; a district_admin sees only
-- what they were granted. Null district (data not yet backfilled) is visible
-- only to a super_admin, so nothing silently escapes scope.
create or replace function public.admin_sees_district(p_district uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select case
    when public.admin_role() is null then false
    when public.admin_role() = 'super_admin' then true
    when p_district is null then false
    else exists (
      select 1 from public.admin_districts ad
        join public.admin_users au on au.id = ad.admin_user_id
       where au.auth_user_id = (select auth.uid())
         and au.active
         and ad.district_id = p_district)
  end
$$;

-- ---------------------------------------------------------------------- RLS
alter table public.admin_users     enable row level security;
alter table public.admin_districts enable row level security;

-- An administrator reads the roster; only a super_admin changes it. Managing
-- administrators is the one power a district_admin does not get, alongside
-- partner API approval.
drop policy if exists "admins read admin_users" on public.admin_users;
create policy "admins read admin_users" on public.admin_users
  for select to authenticated
  using (public.is_admin() or auth_user_id = (select auth.uid()));

drop policy if exists "super_admin writes admin_users" on public.admin_users;
create policy "super_admin writes admin_users" on public.admin_users
  for all to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

drop policy if exists "admins read admin_districts" on public.admin_districts;
create policy "admins read admin_districts" on public.admin_districts
  for select to authenticated using (public.is_admin());

drop policy if exists "super_admin writes admin_districts" on public.admin_districts;
create policy "super_admin writes admin_districts" on public.admin_districts
  for all to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

grant select on public.admin_users, public.admin_districts to authenticated;
grant insert, update on public.admin_users, public.admin_districts to authenticated;

notify pgrst, 'reload schema';
