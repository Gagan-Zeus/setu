-- "I am on duty" — and a mother within 2 km sees that she is reachable now.
--
-- An ASHA turns this on during working hours. Her app sends a position as she
-- moves and on a timer, and Thayi badges her as available to any woman within
-- 2 km of where she actually is.
--
-- 2 km is a badge threshold, never a filter. Filtering the list by it would
-- put a woman 6 km from the only ASHA in her taluk back on an empty screen,
-- which is the one thing that screen must never do. Everyone is still listed,
-- nearest first; being on duty and close only moves her to the top.
--
-- Requires 0012. Idempotent.

-- ----------------------------------------------------------------- the row
-- Separate from asha_workers so the directory row stays static while the
-- position is rewritten every few minutes.
create table if not exists public.asha_presence (
  asha_worker_id uuid primary key
                 references public.asha_workers (id) on delete cascade,
  latitude       double precision,
  longitude      double precision,
  on_duty_since  timestamptz not null default now(),
  on_duty_until  timestamptz not null,
  updated_at     timestamptz not null default now()
);

alter table public.asha_presence enable row level security;

-- Deliberately no policy and no grant, for anon or authenticated. A live
-- position is not noticeboard data: an ASHA is usually a woman working alone
-- in a village, and a table of where health workers are right now is not
-- something to hand to anyone holding a public key. Every read goes through
-- asha_nearby, which answers "is someone near me" and never "where is she".
revoke all on public.asha_presence from anon, authenticated;

-- ------------------------------------------------------------- going on duty
-- One function for the toggle, the position stream and the heartbeat, because
-- they are the same statement with different reasons for firing.
--
-- She never sends an id: it is resolved from her login, so a signed-in worker
-- cannot post a position for somebody else. She never sends a timestamp
-- either — only how long her shift runs — because a cheap handset's clock is
-- not to be trusted and now() here is the database's.
create or replace function public.asha_set_duty(
  p_on      boolean,
  p_lat     double precision default null,
  p_lng     double precision default null,
  p_minutes int             default 240
)
returns timestamptz
language plpgsql security definer set search_path = public as $$
declare
  v_worker uuid;
  v_until  timestamptz;
begin
  select a.id into v_worker
    from public.asha_workers a
    join public.staff s on s.id = a.staff_id
   where s.auth_user_id = auth.uid()
   limit 1;

  if v_worker is null then
    raise exception 'no ASHA posting for this login';
  end if;

  if not p_on then
    delete from public.asha_presence where asha_worker_id = v_worker;
    return null;
  end if;

  -- Clamped: a shift is not 40 seconds and it is not a week. The upper bound
  -- is what stops a handset that was never turned off from advertising her as
  -- on duty indefinitely.
  v_until := now() + make_interval(mins => greatest(15, least(coalesce(p_minutes, 240), 720)));

  insert into public.asha_presence
         (asha_worker_id, latitude, longitude, on_duty_since, on_duty_until, updated_at)
  values (v_worker, p_lat, p_lng, now(), v_until, now())
  on conflict (asha_worker_id) do update
     set latitude      = coalesce(excluded.latitude,  asha_presence.latitude),
         longitude     = coalesce(excluded.longitude, asha_presence.longitude),
         on_duty_until = excluded.on_duty_until,
         updated_at    = now();

  return v_until;
end $$;

-- Supabase grants EXECUTE to anon and authenticated by default as a function
-- is created, and those are grants to those roles by name — revoking from
-- PUBLIC does not touch them. Only a signed-in worker may report a position,
-- so anon is revoked explicitly. Calling it as anon would fail anyway, because
-- auth.uid() finds no posting, but a function that writes positions should not
-- be reachable by an anonymous caller at all.
revoke all on function public.asha_set_duty(boolean, double precision, double precision, int)
  from public, anon;
grant execute on function public.asha_set_duty(boolean, double precision, double precision, int)
  to authenticated;

-- Whether she is currently on duty, for her own app to re-arm after a restart.
create or replace function public.asha_my_duty()
returns timestamptz
language sql stable security definer set search_path = public as $$
  select p.on_duty_until
    from public.asha_presence p
    join public.asha_workers a on a.id = p.asha_worker_id
    join public.staff s on s.id = a.staff_id
   where s.auth_user_id = auth.uid()
     and p.on_duty_until > now()
   limit 1;
$$;

revoke all on function public.asha_my_duty() from public, anon;
grant execute on function public.asha_my_duty() to authenticated;

-- ------------------------------------------------------- the mother's query
-- Replaces 0012's version: same contract, two more columns. The return type
-- changes, so it has to be dropped rather than replaced.
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
  distance_km    double precision,
  on_duty        boolean,
  nearby         boolean,
  proximity_band text
)
language sql stable security definer set search_path = public as $$
  with asked as (
    -- Snapped to ~110 m. She does not need more than that to be told who is
    -- closest, and it caps how precisely this endpoint can be probed.
    select round(p_lat::numeric, 3)::double precision as lat,
           round(p_lng::numeric, 3)::double precision as lng
  ),
  scored as (
    select a.id, a.name_kn, a.name_en, a.phone,
           a.sub_centre_kn, a.sub_centre_en, a.village,
           coalesce(a.located_source, 'none') as accuracy,
           -- Distance to her sub-centre. Public either way, so it is given
           -- exactly.
           case
             when k.lat is null or a.latitude is null then null
             else 6371 * 2 * asin(least(1, sqrt(
                    power(sin(radians(a.latitude  - k.lat) / 2), 2)
                  + cos(radians(k.lat)) * cos(radians(a.latitude))
                  * power(sin(radians(a.longitude - k.lng) / 2), 2))))
           end as distance_km,
           -- Distance to where she actually is. Never returned as a number —
           -- only the 2 km answer and a band are, because an exact distance
           -- to a moving person, asked three times, is a position.
           case
             when k.lat is null or p.latitude is null then null
             else 6371 * 2 * asin(least(1, sqrt(
                    power(sin(radians(p.latitude  - k.lat) / 2), 2)
                  + cos(radians(k.lat)) * cos(radians(p.latitude))
                  * power(sin(radians(p.longitude - k.lng) / 2), 2))))
           end as live_km,
           (p.asha_worker_id is not null) as on_duty
      from public.asha_workers a
      cross join asked k
      -- Fifteen minutes, judged by the database's clock. A handset that died,
      -- lost signal or was put in a drawer stops being advertised as present
      -- without anything having to notice that it did.
      left join public.asha_presence p
             on p.asha_worker_id = a.id
            and p.on_duty_until  > now()
            and p.updated_at     > now() - interval '15 minutes'
  )
  select id, name_kn, name_en, phone, sub_centre_kn, sub_centre_en,
         village, accuracy, distance_km, on_duty,
         coalesce(live_km <= 2, false) as nearby,
         case
           when live_km is null   then null
           when live_km <= 1      then 'under_1km'
           when live_km <= 2      then '1_to_2km'
           else null
         end as proximity_band
    from scored
   -- On duty and within 2 km first; then anyone else on duty; then everyone
   -- else, nearest first, with the unlocatable last. No filter at any point.
   order by (on_duty and coalesce(live_km <= 2, false)) desc,
            on_duty desc,
            (distance_km is null), distance_km, name_en
   limit greatest(1, least(coalesce(p_limit, 10), 20));
$$;

revoke all on function public.asha_nearby(double precision, double precision, int) from public;
grant execute on function public.asha_nearby(double precision, double precision, int)
  to anon, authenticated;

notify pgrst, 'reload schema';
