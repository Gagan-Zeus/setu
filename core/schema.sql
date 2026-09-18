-- Setu — canonical schema.
--
-- THIS FILE IS THE CONTRACT. Column names here must match the Drift tables in
-- the ASHA app and the typed models in Setu Care. If they drift apart, the
-- three clients stop being one platform.
--
-- Roles
--   mother  — reads her own record only (Setu Thayi)
--   asha    — reads and writes the mothers in her sub-centre (Setu ASHA)
--   doctor  — reads everything in her facility, assigns work (Setu Care)
--
-- Identity lives in auth.users; role and scope live in public.staff.

create extension if not exists "pgcrypto";

-- ------------------------------------- mothers: platform columns, added first
-- The helper functions below read these, so the columns must exist before the
-- functions are defined.

alter table public.mothers
  add column if not exists sub_centre text,
  add column if not exists asha_worker_id uuid,
  add column if not exists risk_level text not null default 'green',
  add column if not exists risk_reasons text[] not null default '{}',
  add column if not exists last_visit_date date,
  -- Obstetric history. Thayi only had delivery_number; ASHA and Care both
  -- need the full gravida/para pair and the complication list.
  add column if not exists gravida int not null default 1,
  add column if not exists para int not null default 0,
  add column if not exists height_cm numeric(5,1),
  add column if not exists prev_complications text[] not null default '{}',
  add column if not exists phone text,
  add column if not exists abha_id text;

alter table public.asha_workers
  add column if not exists village text;

-- ------------------------------------------------------------------ staff

create table if not exists public.staff (
  id            uuid primary key default gen_random_uuid(),
  auth_user_id  uuid unique references auth.users (id) on delete cascade,
  role          text not null check (role in ('asha', 'doctor')),
  name          text not null,
  phone         text,
  facility      text,
  -- An ASHA is scoped to one sub-centre; a doctor to the whole facility.
  sub_centre    text,
  created_at    timestamptz not null default now()
);

create index if not exists staff_auth_idx on public.staff (auth_user_id);

-- Who am I, resolved once per statement rather than per row.
create or replace function public.current_role_name()
returns text language sql stable security definer set search_path = public as $$
  select role from public.staff where auth_user_id = auth.uid()
$$;

create or replace function public.current_sub_centre()
returns text language sql stable security definer set search_path = public as $$
  select sub_centre from public.staff where auth_user_id = auth.uid()
$$;

create or replace function public.is_doctor()
returns boolean language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from public.staff where auth_user_id = auth.uid() and role = 'doctor'
  )
$$;

-- True when the signed-in user may touch this mother: she is the mother, or
-- an ASHA covering her sub-centre, or a doctor.
create or replace function public.can_access_mother(m_id uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from public.mothers m
    where m.id = m_id
      and (
        m.auth_user_id = auth.uid()
        or public.is_doctor()
        or m.sub_centre = public.current_sub_centre()
      )
  )
$$;

-- ---------------------------------------------------- clinical encounters

-- The canonical clinical record. APPEND-ONLY: a correction is a new row whose
-- corrects_id points at the original, so two offline devices can never
-- conflict and the audit trail is free.
create table if not exists public.anc_visits (
  id                uuid primary key default gen_random_uuid(),
  mother_id         uuid not null references public.mothers (id) on delete cascade,
  visit_no          int  not null,
  visit_date        date not null,
  bp_sys            int,
  bp_dia            int,
  weight_kg         numeric(5,2),
  fundal_height_cm  numeric(4,1),
  hb                numeric(4,1),
  urine_albumin     text,
  fetal_hr          int,
  fetal_movement    boolean,
  danger_signs      text[] not null default '{}',
  ifa_taken         boolean not null default false,
  calcium_taken     boolean not null default false,
  tt_dose_given     int,
  notes             text,
  gps_lat           double precision,
  gps_lng           double precision,
  photo_paths       text[] not null default '{}',
  recorded_by       text not null,
  -- 'asha' | 'doctor' — drives the role icon in every timeline.
  source            text not null default 'asha',
  corrects_id       uuid references public.anc_visits (id),
  client_created_at timestamptz not null default now(),
  created_at        timestamptz not null default now()
);

create index if not exists anc_visits_mother_idx
  on public.anc_visits (mother_id, visit_date desc);

-- --------------------------------------------------------------- tasks

-- The point of the platform: a doctor assigns work that lands on an ASHA's
-- phone. assigned_to_asha_id is resolved from the mother, never chosen.
create table if not exists public.tasks (
  id                   uuid primary key default gen_random_uuid(),
  mother_id            uuid not null references public.mothers (id) on delete cascade,
  created_by           text not null,
  assigned_to_asha_id  uuid references public.asha_workers (id),
  assigned_to_asha_name text,
  type                 text not null,
  instruction_kn       text,
  instruction_en       text,
  due_date             date not null,
  priority             text not null default 'normal' check (priority in ('normal','high')),
  status               text not null default 'open'   check (status in ('open','done','missed')),
  -- 'doctor' | 'system' | 'self'
  origin               text not null default 'doctor',
  closed_by_visit_id   uuid references public.anc_visits (id),
  created_at           timestamptz not null default now(),
  closed_at            timestamptz
);

create index if not exists tasks_mother_idx on public.tasks (mother_id, status);
create index if not exists tasks_asha_idx   on public.tasks (assigned_to_asha_id, status);

-- --------------------------------------------------------------- alerts

create table if not exists public.alerts (
  id           uuid primary key default gen_random_uuid(),
  mother_id    uuid not null references public.mothers (id) on delete cascade,
  rule_id      text not null,
  severity     text not null check (severity in ('red','amber')),
  message_kn   text not null,
  message_en   text not null,
  visit_id     uuid references public.anc_visits (id),
  acknowledged boolean not null default false,
  created_at   timestamptz not null default now()
);

-- ------------------------------------------------------------ referrals

create table if not exists public.referrals (
  id           uuid primary key default gen_random_uuid(),
  mother_id    uuid not null references public.mothers (id) on delete cascade,
  from_user    text not null,
  to_facility  text not null,
  reason_kn    text,
  reason_en    text,
  status       text not null default 'open' check (status in ('open','arrived','closed')),
  outcome_note text,
  visit_id     uuid references public.anc_visits (id),
  created_at   timestamptz not null default now()
);

-- ------------------------------------------- doctor-authored clinical data

create table if not exists public.clinical_notes (
  id          uuid primary key default gen_random_uuid(),
  mother_id   uuid not null references public.mothers (id) on delete cascade,
  author_name text not null,
  body        text not null,
  created_at  timestamptz not null default now()
);

create table if not exists public.labs (
  id          uuid primary key default gen_random_uuid(),
  mother_id   uuid not null references public.mothers (id) on delete cascade,
  type        text not null,
  value       text not null,
  unit        text,
  result_date date not null,
  ordered_by  text,
  report_url  text,
  created_at  timestamptz not null default now()
);

-- ------------------------------------------- remaining constraints and links
-- Added here, once every referenced table exists.

alter table public.mothers
  drop constraint if exists mothers_asha_worker_fk,
  add constraint mothers_asha_worker_fk
    foreign key (asha_worker_id) references public.asha_workers (id);

alter table public.mothers
  drop constraint if exists mothers_risk_level_check,
  add constraint mothers_risk_level_check
    check (risk_level in ('green','amber','red'));

-- asha_workers gains the link to a login, so an ASHA is a real user.
alter table public.asha_workers
  add column if not exists staff_id uuid references public.staff (id);

-- ------------------------------------------------------------ row security

alter table public.staff          enable row level security;
alter table public.anc_visits     enable row level security;
alter table public.tasks          enable row level security;
alter table public.alerts         enable row level security;
alter table public.referrals      enable row level security;
alter table public.clinical_notes enable row level security;
alter table public.labs           enable row level security;

-- Staff can read their own row; doctors can see the roster.
drop policy if exists "staff reads self" on public.staff;
create policy "staff reads self" on public.staff
  for select to authenticated
  using (auth_user_id = (select auth.uid()) or public.is_doctor());

-- Clinical tables: one rule, applied everywhere — can_access_mother().
do $$
declare t text;
begin
  foreach t in array array['anc_visits','tasks','alerts','referrals',
                           'clinical_notes','labs']
  loop
    execute format('drop policy if exists "read %1$s" on public.%1$I', t);
    execute format(
      'create policy "read %1$s" on public.%1$I for select to authenticated
         using (public.can_access_mother(mother_id))', t);

    -- Only staff write. A mother never writes clinical data.
    execute format('drop policy if exists "staff insert %1$s" on public.%1$I', t);
    execute format(
      'create policy "staff insert %1$s" on public.%1$I for insert to authenticated
         with check (public.current_role_name() is not null
                     and public.can_access_mother(mother_id))', t);

    execute format('drop policy if exists "staff update %1$s" on public.%1$I', t);
    execute format(
      'create policy "staff update %1$s" on public.%1$I for update to authenticated
         using (public.current_role_name() is not null
                and public.can_access_mother(mother_id))', t);
  end loop;
end $$;

-- anc_visits is append-only: no update, no delete, for anyone.
drop policy if exists "staff update anc_visits" on public.anc_visits;

-- mothers: she reads her own; staff read and write within scope.
drop policy if exists "read own record" on public.mothers;
drop policy if exists "read mothers in scope" on public.mothers;
create policy "read mothers in scope" on public.mothers
  for select to authenticated
  using (
    auth_user_id = (select auth.uid())
    or public.is_doctor()
    or sub_centre = public.current_sub_centre()
  );

drop policy if exists "staff insert mothers" on public.mothers;
create policy "staff insert mothers" on public.mothers
  for insert to authenticated
  with check (public.current_role_name() is not null);

drop policy if exists "staff update mothers" on public.mothers;
create policy "staff update mothers" on public.mothers
  for update to authenticated
  using (public.current_role_name() is not null
         and (public.is_doctor() or sub_centre = public.current_sub_centre()));

-- Reference data stays readable to any signed-in user.
drop policy if exists "read health centres" on public.health_centres;
create policy "read health centres" on public.health_centres
  for select to authenticated using (true);
drop policy if exists "read asha workers" on public.asha_workers;
create policy "read asha workers" on public.asha_workers
  for select to authenticated using (true);

-- Staff need write privileges back; they were revoked when the app was
-- read-only. RLS above still decides which rows.
grant insert, update on public.mothers, public.anc_visits, public.tasks,
  public.alerts, public.referrals, public.clinical_notes, public.labs
  to authenticated;
