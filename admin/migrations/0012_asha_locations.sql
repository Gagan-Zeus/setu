-- Every ASHA worker gets a coordinate, so "nearest to you" can mean something.
--
-- Thayi's first screen lists ASHA workers for a woman to phone, nearest first.
-- The sorting was written and correct; it did nothing because
-- asha_workers.latitude was NULL for every worker who was not one of the four
-- demo villages hardcoded in core/public_asha_directory.sql. The admin portal,
-- which is the only way a real worker enters the system, inserted her with no
-- coordinate at all. So every production worker sorted to the bottom of the
-- list in arbitrary order, with no distance shown.
--
-- The fix is not a better sort. It is making sure nobody is unlocatable.
--
-- Idempotent: re-running is how a change is applied here.
--
-- This lives in admin/migrations and NOT in core/bootstrap_new_project.sh's
-- SCHEMA list, although core/public_asha_directory.sql owns the columns it
-- builds on. The PHC fallback below reads staff.phc_id, and that column is
-- added by 0003, which the bootstrap does not run — folding this into the
-- bootstrap would fail on a fresh project. A new project runs the bootstrap
-- and then these migrations in order, which is the documented flow.

-- ---------------------------------------------------------------- identity
-- A worker is identified by her posting, not by her name.
--
-- core/dedupe_asha_workers.sql put a unique index on name_en to stop the
-- per-app seeds inserting the same person twice. It does that, and it also
-- rejects the second real Lakshmi N registered in a district — a name
-- collision is not a duplicate. staff_id is what actually identifies her, it
-- is already written by admin-api on every ASHA it creates, and the presence
-- lookup below needs to be able to say "her row" and mean exactly one row.
drop index if exists public.asha_workers_name_unique;

-- Legacy rows predate admin-api writing staff_id. Match them to their staff
-- row by name while name is still unambiguous, so they are not stranded.
update public.asha_workers a
   set staff_id = s.id
  from public.staff s
 where a.staff_id is null
   and s.role = 'asha'
   and lower(btrim(s.name)) = lower(btrim(a.name_en))
   and not exists (select 1 from public.asha_workers x where x.staff_id = s.id);

create unique index if not exists asha_workers_staff_unique
  on public.asha_workers (staff_id) where staff_id is not null;

-- -------------------------------------------------------------- provenance
-- Whether a coordinate is a real pin or an inherited PHC centroid decides how
-- the distance is worded to her: "4.2 km away" claims a precision that a PHC
-- centroid does not have.
alter table public.asha_workers
  add column if not exists located_source text
    check (located_source is null
           or located_source in ('gps', 'phc', 'seed')),
  add column if not exists located_at timestamptz;

-- Rows that already carry a coordinate got it from the demo seed.
update public.asha_workers
   set located_source = 'seed'
 where latitude is not null and located_source is null;

-- --------------------------------------------------------- the PHC fallback
-- health_centres already carries real coordinates and every portal-registered
-- worker has a staff row pointing at one. Inheriting that is what makes the
-- whole existing directory sortable, today, with no app change.
--
-- Materialised onto the row rather than resolved in a view, so the view the
-- mother reads stays a pure projection with no join into staff.
create or replace function public.asha_worker_inherit_location()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if new.latitude is null and new.staff_id is not null then
    select hc.latitude, hc.longitude, 'phc'::text, now()
      into new.latitude, new.longitude, new.located_source, new.located_at
      from public.staff s
      join public.health_centres hc on hc.id = s.phc_id
     where s.id = new.staff_id and hc.latitude is not null;
  end if;
  return new;
end $$;

-- A trigger function is not a client entry point; Supabase's default grants
-- make it one regardless.
revoke all on function public.asha_worker_inherit_location() from public, anon, authenticated;

drop trigger if exists asha_worker_inherit_location on public.asha_workers;
create trigger asha_worker_inherit_location
  before insert or update of staff_id, latitude on public.asha_workers
  for each row execute function public.asha_worker_inherit_location();

-- Backfill everyone who exists now.
update public.asha_workers a
   set latitude       = hc.latitude,
       longitude      = hc.longitude,
       located_source = 'phc',
       located_at     = now()
  from public.staff s
  join public.health_centres hc on hc.id = s.phc_id
 where a.staff_id = s.id
   and a.latitude is null
   and hc.latitude is not null;

-- ------------------------------------------------------- the mother's query
-- She has no account and no session when she reads this, so it runs as its
-- owner. It carries only what a sub-centre noticeboard already carries: a
-- name, a phone number, a sub-centre. No mother, no clinical data, no email.
-- Dropped rather than replaced: 0013 widens this function's return type, so
-- on a re-run there is an existing version whose OUT columns differ and
-- `create or replace` cannot change a return type. Re-running this file then
-- leaves the narrower version behind until 0013 runs again — which is why
-- these are applied in order, as the directory's README says.
drop function if exists public.asha_nearby(double precision, double precision, int);

create function public.asha_nearby(
  p_lat   double precision default null,
  p_lng   double precision default null,
  p_limit int              default 10
)
returns table (
  id             uuid,
  name_kn        text,
  name_en        text,
  phone          text,
  sub_centre_kn  text,
  sub_centre_en  text,
  village        text,
  accuracy       text,
  distance_km    double precision
)
language sql stable security definer set search_path = public as $$
  with asked as (
    -- Snapped to ~110 m. She does not need more than that to be told who is
    -- closest, and it caps how precisely the endpoint can be probed.
    select round(p_lat::numeric, 3)::double precision as lat,
           round(p_lng::numeric, 3)::double precision as lng
  ),
  scored as (
    select a.id, a.name_kn, a.name_en, a.phone,
           a.sub_centre_kn, a.sub_centre_en, a.village,
           coalesce(a.located_source, 'none') as accuracy,
           case
             when k.lat is null or k.lng is null or a.latitude is null then null
             else 6371 * 2 * asin(least(1, sqrt(
                    power(sin(radians(a.latitude  - k.lat) / 2), 2)
                  + cos(radians(k.lat)) * cos(radians(a.latitude))
                  * power(sin(radians(a.longitude - k.lng) / 2), 2))))
           end as distance_km
      from public.asha_workers a cross join asked k
  )
  select id, name_kn, name_en, phone, sub_centre_kn, sub_centre_en,
         village, accuracy, distance_km
    from scored
   -- Located workers first and never interleaved with unlocated ones; within
   -- each group, nearest first. Deliberately no radius filter: a woman 60 km
   -- from the only ASHA in her taluk must still be given that ASHA. An empty
   -- list is the one answer this screen must never give while a worker exists.
   order by (distance_km is null), distance_km, name_en
   limit greatest(1, least(coalesce(p_limit, 10), 20));
$$;

revoke all on function public.asha_nearby(double precision, double precision, int) from public;
grant execute on function public.asha_nearby(double precision, double precision, int)
  to anon, authenticated;

notify pgrst, 'reload schema';
