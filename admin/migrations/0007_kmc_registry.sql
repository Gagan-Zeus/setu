-- Setu Admin Portal — a stand-in for the Karnataka Medical Council registry.
--
-- ---------------------------------------------------------------------------
-- WHAT THIS IS, AND WHAT IT IS NOT
-- ---------------------------------------------------------------------------
-- A medical officer is registered here by KMC number, not by typing their name.
-- That is the right shape: the council is the authority on who is a doctor, and
-- an administrator should be confirming a record rather than composing one.
--
-- Karnataka publishes no API for this. Verification is a form on the council's
-- website, so until there is something to call, this table stands in for it.
-- Every row is INVENTED. It is not a copy of the register, it verifies nothing,
-- and a number found here means only that this demo knows about it.
--
-- Two things keep that honest:
--   * every row carries is_demo, and the lookup returns it, so the portal can
--     say on screen that the source is a demo registry
--   * the numbers use a KMC-DEMO- prefix, which no real registration has
--
-- When a real endpoint exists, replace the body of kmc_lookup() and nothing
-- above it changes. That is why the portal calls a function rather than reading
-- the table.
--
-- ---------------------------------------------------------------------------
-- THE FIELDS
-- ---------------------------------------------------------------------------
-- Modelled on what the NMC's Indian Medical Register search returns for a
-- Karnataka doctor — registration number, name, father's name, the state
-- council, registration date, qualification, university and year of passing —
-- plus what a KMC registration certificate carries that the search does not:
-- date of birth, gender, address, and the renewal state, since KMC registration
-- is renewed periodically rather than being permanent.

create table if not exists public.kmc_registry (
  -- As printed on the certificate. Text, not an integer: it is an identifier
  -- that happens to contain digits, and leading zeros must survive.
  registration_number   text primary key,

  full_name             text not null,
  -- The register prints "Father's Name" as the disambiguator rather than a
  -- surname, because namesakes are common and it is what the certificate shows.
  father_name           text,
  gender                text check (gender in ('male', 'female', 'other')),
  date_of_birth         date,

  -- "MBBS" or "MBBS, MD (Community Medicine)". One string, as the register
  -- prints it, rather than a parsed list: the portal displays it and never
  -- reasons about it.
  qualification         text not null,
  university            text not null,
  year_of_passing       int check (year_of_passing between 1950 and 2100),

  registration_date     date not null,
  state_medical_council text not null default 'Karnataka Medical Council',

  -- KMC registration is renewed, so a number alone does not mean a doctor may
  -- practise today. The portal refuses anything but active or renewed.
  status                text not null default 'active'
                          check (status in ('active', 'renewed', 'expired', 'suspended')),
  renewal_due           date,

  address               text,
  phone                 text,
  email                 text,

  -- False would mean a row that came from the real council. Nothing sets that
  -- today, and the default is deliberately the safe one.
  is_demo               boolean not null default true,
  created_at            timestamptz not null default now()
);

create index if not exists kmc_registry_name_idx on public.kmc_registry (lower(full_name));

-- Nothing invented may pass for real. A row without the demo prefix would be
-- claiming to be a council record.
alter table public.kmc_registry drop constraint if exists kmc_demo_rows_are_marked;
alter table public.kmc_registry add constraint kmc_demo_rows_are_marked
  check (not is_demo or registration_number like 'KMC-DEMO-%');

-- ------------------------------------------------- the number on a staff row
alter table public.staff
  add column if not exists kmc_registration_number text;

-- One doctor, one registration. Without this the same council number could be
-- attached to two logins, which is the exact thing registering by number is
-- meant to prevent.
create unique index if not exists staff_kmc_number_unique
  on public.staff (upper(kmc_registration_number))
  where kmc_registration_number is not null;

-- Only a doctor has one. An ASHA worker is not registered with a medical
-- council, and a row that claimed otherwise would be a data error, not a quirk.
alter table public.staff drop constraint if exists staff_kmc_only_for_doctors;
alter table public.staff add constraint staff_kmc_only_for_doctors
  check (kmc_registration_number is null or role = 'doctor');

-- ---------------------------------------------------------------------- RLS
alter table public.kmc_registry enable row level security;

-- Administrators only. This is a roster of doctors with dates of birth and
-- addresses on it; it is not reference data for any signed-in user to browse.
drop policy if exists "admins read kmc_registry" on public.kmc_registry;
create policy "admins read kmc_registry" on public.kmc_registry
  for select to authenticated using (public.is_admin());

drop policy if exists "super_admin writes kmc_registry" on public.kmc_registry;
create policy "super_admin writes kmc_registry" on public.kmc_registry
  for all to authenticated
  using (public.is_super_admin()) with check (public.is_super_admin());

grant select on public.kmc_registry to authenticated;
grant insert, update on public.kmc_registry to authenticated;

-- --------------------------------------------------------------- the lookup
-- One call answers everything the Register screen needs: is the number known,
-- is the registration in good standing, and is this doctor already on staff.
--
-- Returning "already registered" as data rather than an error matters: the
-- screen has to show WHO, so the administrator can go and find them instead of
-- being told no.
create or replace function public.kmc_lookup(p_registration_number text)
returns jsonb
language plpgsql stable security definer set search_path = public as $$
declare
  v_num   text := upper(btrim(coalesce(p_registration_number, '')));
  r       public.kmc_registry;
  s       public.staff;
begin
  if not public.is_admin() then
    raise exception 'Only an administrator may look up a registration';
  end if;
  if v_num = '' then
    return jsonb_build_object('found', false, 'reason', 'empty');
  end if;

  select * into r from public.kmc_registry
   where upper(registration_number) = v_num;

  if not found then
    return jsonb_build_object('found', false, 'reason', 'not_in_registry');
  end if;

  select * into s from public.staff
   where upper(kmc_registration_number) = v_num and active;

  return jsonb_build_object(
    'found', true,
    'is_demo', r.is_demo,
    'in_good_standing', r.status in ('active', 'renewed'),
    'already_registered', found,
    'existing_staff', case when found then jsonb_build_object(
        'id', s.id, 'name', s.name, 'email', s.email, 'phc_id', s.phc_id) end,
    'doctor', jsonb_build_object(
      'registration_number',   r.registration_number,
      'full_name',             r.full_name,
      'father_name',           r.father_name,
      'gender',                r.gender,
      'date_of_birth',         r.date_of_birth,
      'qualification',         r.qualification,
      'university',            r.university,
      'year_of_passing',       r.year_of_passing,
      'registration_date',     r.registration_date,
      'state_medical_council', r.state_medical_council,
      'status',                r.status,
      'renewal_due',           r.renewal_due,
      'address',               r.address,
      'phone',                 r.phone,
      'email',                 r.email));
end $$;

revoke all on function public.kmc_lookup(text) from public;
grant execute on function public.kmc_lookup(text) to authenticated;

notify pgrst, 'reload schema';
