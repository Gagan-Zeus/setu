-- A pregnant woman who has not registered yet has no session, so RLS blocks
-- every table. She still needs to find an ASHA worker to call — that is the
-- whole point of the first-open flow.
--
-- ASHA workers are public-facing government community health workers whose
-- names and numbers are already displayed at sub-centres and on state health
-- portals, so publishing them to anonymous users matches how they are found
-- today. Nothing else is exposed: this view carries no mother, no clinical
-- data, and no staff email.

alter table public.asha_workers
  add column if not exists latitude  double precision,
  add column if not exists longitude double precision;

-- Approximate sub-centre locations around Nanjangud taluk, Mysuru district.
update public.asha_workers set latitude = 12.2958, longitude = 76.6394
  where village = 'Hosahalli' and latitude is null;
update public.asha_workers set latitude = 12.2731, longitude = 76.6802
  where village = 'Kempanahalli' and latitude is null;
update public.asha_workers set latitude = 12.1904, longitude = 76.6115
  where village = 'Madapura' and latitude is null;
update public.asha_workers set latitude = 12.2405, longitude = 76.7218
  where village = 'Beedanahalli' and latitude is null;

create or replace view public.asha_directory as
  select id, name_kn, name_en, phone, sub_centre_kn, sub_centre_en,
         village, latitude, longitude
    from public.asha_workers;

-- security_invoker = off means the view reads with its owner's rights, so it
-- is deliberately readable without a session.
alter view public.asha_directory set (security_invoker = off);

grant select on public.asha_directory to anon, authenticated;
