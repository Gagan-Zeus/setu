-- Setu Admin Portal — districts, villages, and PHCs.
--
-- ---------------------------------------------------------------------------
-- WHY THERE IS NO `phcs` TABLE
-- ---------------------------------------------------------------------------
-- The spec asked for `phcs`. The repo already has public.health_centres, and
-- mothers.phc_id points at it. A second table for the same real-world thing
-- would leave every screen having to ask which one it meant, so health_centres
-- is extended instead. "PHC" is what the portal calls it in the UI.
--
-- Geography is denormalised as text in the existing schema — mothers carry
-- district_en/district_kn/village_en/village_kn, asha_workers carry village and
-- sub_centre. Those columns stay: three Flutter apps read them, two of them
-- offline, and a mother's record has to render with no joins available. The
-- tables below are added alongside and linked by nullable FKs, so the portal
-- gets real referential integrity while nothing that exists has to change.

-- --------------------------------------------------------------- districts
create table if not exists public.districts (
  id         uuid primary key default gen_random_uuid(),
  name       text not null,
  name_kn    text,
  state      text not null default 'Karnataka',
  active     boolean not null default true,
  created_at timestamptz not null default now(),
  unique (name, state)
);

-- Deferred from 0001, now that districts exists.
alter table public.admin_districts
  drop constraint if exists admin_districts_district_id_fkey;
alter table public.admin_districts
  add constraint admin_districts_district_id_fkey
  foreign key (district_id) references public.districts (id) on delete cascade;

-- ------------------------------------------------- health_centres, extended
alter table public.health_centres
  add column if not exists district_id  uuid references public.districts (id),
  add column if not exists contact_name text,
  add column if not exists address      text,
  -- Soft delete. A PHC that closes still has years of records pointing at it.
  add column if not exists active       boolean not null default true,
  add column if not exists created_at_admin timestamptz not null default now();

create index if not exists health_centres_district_idx
  on public.health_centres (district_id) where active;

-- ---------------------------------------------------------------- villages
-- catchment_villages[] on the PHC, as the spec had it, cannot be pointed at:
-- a mother lives in a village and an ASHA covers villages, and neither can
-- hold a foreign key into an array element. A village is a row.
create table if not exists public.villages (
  id                  uuid primary key default gen_random_uuid(),
  name                text not null,
  name_kn             text,
  phc_id              uuid references public.health_centres (id),
  district_id         uuid references public.districts (id),
  population_estimate int check (population_estimate is null
                                 or population_estimate >= 0),
  active              boolean not null default true,
  created_at          timestamptz not null default now()
);

-- A village name repeats across districts in Karnataka — Hosahalli alone
-- appears in several. Unique per PHC, never globally.
create unique index if not exists villages_name_per_phc
  on public.villages (phc_id, lower(name)) where phc_id is not null;
create index if not exists villages_district_idx on public.villages (district_id);

-- ---------------------------------------------------------------- backfill
-- Build the geography from what the existing rows already say, so the portal
-- opens with real data rather than an empty shell someone has to retype.
insert into public.districts (name, state)
select distinct m.district_en, 'Karnataka'
  from public.mothers m
 where m.district_en is not null and btrim(m.district_en) <> ''
on conflict (name, state) do nothing;

update public.health_centres hc
   set district_id = d.id
  from public.districts d
 where hc.district_id is null
   and d.id = (select id from public.districts order by name limit 1)
   and (select count(*) from public.districts) = 1;

insert into public.villages (name, phc_id, district_id)
select distinct m.village_en, m.phc_id, d.id
  from public.mothers m
  left join public.districts d
    on d.name = m.district_en and d.state = 'Karnataka'
 where m.village_en is not null and btrim(m.village_en) <> ''
   and m.phc_id is not null
on conflict do nothing;

-- ---------------------------------------------------------------------- RLS
alter table public.districts enable row level security;
alter table public.villages  enable row level security;

-- Reference geography is readable to any signed-in user: the ASHA app shows a
-- village list, Care filters by district. Reads are not the sensitive part.
drop policy if exists "read districts" on public.districts;
create policy "read districts" on public.districts
  for select to authenticated using (true);

drop policy if exists "read villages" on public.villages;
create policy "read villages" on public.villages
  for select to authenticated using (true);

-- Writes are administrators only, within their district.
drop policy if exists "admins write districts" on public.districts;
create policy "admins write districts" on public.districts
  for all to authenticated
  using (public.admin_may_write() and public.admin_sees_district(id))
  with check (public.admin_may_write() and public.admin_sees_district(id));

drop policy if exists "admins write villages" on public.villages;
create policy "admins write villages" on public.villages
  for all to authenticated
  using (public.admin_may_write() and public.admin_sees_district(district_id))
  with check (public.admin_may_write() and public.admin_sees_district(district_id));

-- health_centres already has "read health centres" for authenticated. Add the
-- admin write side; policies are OR'd, so the existing read is untouched.
drop policy if exists "admins write health_centres" on public.health_centres;
create policy "admins write health_centres" on public.health_centres
  for all to authenticated
  using (public.admin_may_write() and public.admin_sees_district(district_id))
  with check (public.admin_may_write() and public.admin_sees_district(district_id));

grant select on public.districts, public.villages to authenticated;
grant insert, update on public.districts, public.villages to authenticated;
grant insert, update on public.health_centres to authenticated;

-- ------------------------------------------ deactivating a PHC with staff on it
-- The spec: deactivation must block while staff are still assigned. A trigger
-- rather than a UI check, because the UI is not the only way in.
create or replace function public.phc_deactivation_guard()
returns trigger language plpgsql security definer set search_path = public as $$
declare remaining int;
begin
  if old.active and not new.active then
    select count(*) into remaining
      from public.staff s
     where s.phc_id = new.id and s.active;
    if remaining > 0 then
      raise exception
        'Cannot deactivate this PHC: % staff member(s) are still assigned. '
        'Reassign them first.', remaining;
    end if;
  end if;
  return new;
end $$;

-- The trigger is created in 0003, once staff.phc_id and staff.active exist.

notify pgrst, 'reload schema';
