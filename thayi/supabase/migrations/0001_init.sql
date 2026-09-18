-- Thayi Setu — initial schema.
-- Run this in the Supabase SQL editor (Dashboard → SQL → New query).
--
-- Design notes:
--   * Text the mother reads is stored in BOTH scripts (…_kn / …_en), the way
--     the paper Thayi Card carries it. Static app content (scheme benefits,
--     danger signs) stays in the app's ARB files, not here.
--   * Ids that the app maps to translated labels (risk flags, checkup
--     activities, documents) are stored as stable text ids, never as prose.
--   * RLS is ON for every table. A mother can read only her own record.

create extension if not exists "pgcrypto";

-- ---------------------------------------------------------------- reference

create table if not exists public.health_centres (
  id           uuid primary key default gen_random_uuid(),
  name_kn      text not null,
  name_en      text not null,
  phone        text not null,
  latitude     double precision,
  longitude    double precision,
  created_at   timestamptz not null default now()
);

create table if not exists public.asha_workers (
  id            uuid primary key default gen_random_uuid(),
  name_kn       text not null,
  name_en       text not null,
  phone         text not null,
  sub_centre_kn text not null,
  sub_centre_en text not null,
  created_at    timestamptz not null default now()
);

-- ----------------------------------------------------------------- mothers

create table if not exists public.mothers (
  id                            uuid primary key default gen_random_uuid(),
  -- Links the record to a Supabase auth user. Null until she signs in.
  auth_user_id                  uuid unique references auth.users (id) on delete set null,
  -- Rotatable token embedded in the QR alongside the id. No personal data.
  qr_token                      text not null,
  thayi_card_number             text not null unique,

  name_kn                       text not null,
  name_en                       text not null,
  age                           int  not null check (age between 10 and 60),
  guardian_kn                   text,
  guardian_en                   text,
  village_kn                    text,
  village_en                    text,
  district_kn                   text,
  district_en                   text,
  blood_group                   text,

  -- Every date in the app derives from this.
  lmp                           date not null,

  risk_flag_ids                 text[] not null default '{}',
  allergy_ids                   text[] not null default '{}',

  -- Fields the scheme eligibility rules read.
  is_bpl                        boolean not null default false,
  delivery_number               int     not null default 1,
  plans_institutional_delivery  boolean not null default true,
  has_bank_account              boolean not null default false,

  asha_id                       uuid references public.asha_workers (id),
  phc_id                        uuid references public.health_centres (id),

  created_at                    timestamptz not null default now(),
  updated_at                    timestamptz not null default now()
);

create index if not exists mothers_auth_user_id_idx on public.mothers (auth_user_id);

-- ---------------------------------------------------------------- clinical

create table if not exists public.checkups (
  id             uuid primary key default gen_random_uuid(),
  mother_id      uuid not null references public.mothers (id) on delete cascade,
  visit_number   int  not null,
  scheduled_on   date not null,
  location_kn    text,
  location_en    text,
  activity_ids   text[] not null default '{}',
  completed      boolean not null default false,
  weight_kg      numeric(5,2),
  systolic       int,
  diastolic      int,
  recorded_by_kn text,
  recorded_by_en text,
  created_at     timestamptz not null default now(),
  unique (mother_id, visit_number)
);

create index if not exists checkups_mother_idx on public.checkups (mother_id, scheduled_on);

create table if not exists public.weight_entries (
  id         uuid primary key default gen_random_uuid(),
  mother_id  uuid not null references public.mothers (id) on delete cascade,
  week       int  not null,
  kg         numeric(5,2) not null,
  created_at timestamptz not null default now(),
  unique (mother_id, week)
);

create table if not exists public.bp_entries (
  id         uuid primary key default gen_random_uuid(),
  mother_id  uuid not null references public.mothers (id) on delete cascade,
  week       int not null,
  systolic   int not null,
  diastolic  int not null,
  created_at timestamptz not null default now(),
  unique (mother_id, week)
);

create table if not exists public.tt_doses (
  id         uuid primary key default gen_random_uuid(),
  mother_id  uuid not null references public.mothers (id) on delete cascade,
  dose_number int not null,
  given      boolean not null default false,
  given_on   date,
  unique (mother_id, dose_number)
);

-- ------------------------------------------------------------------- baby

create table if not exists public.baby_vaccines (
  id         uuid primary key default gen_random_uuid(),
  mother_id  uuid not null references public.mothers (id) on delete cascade,
  vaccine_id text not null,   -- bcg | opv | hepB | penta | rota | mr
  age_id     text not null,   -- atBirth | w6 | w10 | w14 | m9
  given      boolean not null default false,
  given_on   date,
  sort_order int not null default 0
);

create table if not exists public.baby_growth (
  id         uuid primary key default gen_random_uuid(),
  mother_id  uuid not null references public.mothers (id) on delete cascade,
  week       int not null,
  kg         numeric(5,2) not null,
  unique (mother_id, week)
);

-- ---------------------------------------------------------------- schemes

-- Eligibility is computed in the app from the mother's profile fields, so this
-- table only carries what varies per scheme: papers to carry, where to go.
create table if not exists public.schemes (
  id           text primary key,  -- thayiBhagya | pmmvy | jsy | prasootiAraike | madilu | jssk
  document_ids text[] not null default '{}',
  hospital_ids uuid[] not null default '{}',
  sort_order   int not null default 0
);

-- ------------------------------------------------------------- row security

alter table public.health_centres enable row level security;
alter table public.asha_workers   enable row level security;
alter table public.mothers        enable row level security;
alter table public.checkups       enable row level security;
alter table public.weight_entries enable row level security;
alter table public.bp_entries     enable row level security;
alter table public.tt_doses       enable row level security;
alter table public.baby_vaccines  enable row level security;
alter table public.baby_growth    enable row level security;
alter table public.schemes        enable row level security;

-- Reference data is readable by any signed-in user.
create policy "read health centres" on public.health_centres
  for select to authenticated using (true);
create policy "read asha workers" on public.asha_workers
  for select to authenticated using (true);
create policy "read schemes" on public.schemes
  for select to authenticated using (true);

-- She reads her own record and nothing else. There is no insert/update/delete
-- policy anywhere: the app is read-only by design. ASHA and PHC staff write
-- through a separate, privileged path.
create policy "read own record" on public.mothers
  for select to authenticated using (auth_user_id = (select auth.uid()));

create policy "read own checkups" on public.checkups
  for select to authenticated using (
    mother_id in (select id from public.mothers where auth_user_id = (select auth.uid()))
  );
create policy "read own weights" on public.weight_entries
  for select to authenticated using (
    mother_id in (select id from public.mothers where auth_user_id = (select auth.uid()))
  );
create policy "read own bp" on public.bp_entries
  for select to authenticated using (
    mother_id in (select id from public.mothers where auth_user_id = (select auth.uid()))
  );
create policy "read own tt" on public.tt_doses
  for select to authenticated using (
    mother_id in (select id from public.mothers where auth_user_id = (select auth.uid()))
  );
create policy "read own baby vaccines" on public.baby_vaccines
  for select to authenticated using (
    mother_id in (select id from public.mothers where auth_user_id = (select auth.uid()))
  );
create policy "read own baby growth" on public.baby_growth
  for select to authenticated using (
    mother_id in (select id from public.mothers where auth_user_id = (select auth.uid()))
  );
