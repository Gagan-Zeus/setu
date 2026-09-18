-- Setu Admin Portal — staff roster, ASHA assignments, and what an admin may
-- do to a mother's record.

-- ------------------------------------------------------------ staff, extended
-- staff.role keeps its ('asha','doctor') check. See the note at the top of
-- 0001: 'admin' is deliberately not a staff role, and 'doctor' is not renamed
-- to 'medical_officer' because is_doctor(), can_access_mother() and every
-- clinical policy read that literal.
alter table public.staff
  add column if not exists phc_id         uuid references public.health_centres (id),
  add column if not exists district_id    uuid references public.districts (id),
  add column if not exists employee_code  text,
  add column if not exists active         boolean not null default true,
  add column if not exists created_by     uuid references public.admin_users (id),
  add column if not exists deactivated_at timestamptz;

-- An employee code is a government identifier and must not repeat, but plenty
-- of existing rows have none. Unique among those that do.
create unique index if not exists staff_employee_code_unique
  on public.staff (upper(employee_code)) where employee_code is not null;
create index if not exists staff_phc_idx on public.staff (phc_id) where active;
create index if not exists staff_district_idx on public.staff (district_id) where active;

-- Backfill phc_id from the free-text facility the rows already carry.
update public.staff s
   set phc_id = hc.id
  from public.health_centres hc
 where s.phc_id is null
   and (lower(s.facility) = lower(hc.name_en) or lower(s.facility) = lower(hc.name_kn));

update public.staff s
   set district_id = hc.district_id
  from public.health_centres hc
 where s.district_id is null and s.phc_id = hc.id;

-- Now that staff.phc_id and staff.active exist, the PHC guard from 0002 can
-- be attached.
drop trigger if exists health_centres_deactivation_guard on public.health_centres;
create trigger health_centres_deactivation_guard
  before update of active on public.health_centres
  for each row execute function public.phc_deactivation_guard();

-- ---------------------------------------------------------- mothers, extended
alter table public.mothers
  -- Soft delete; clinical systems keep history.
  add column if not exists active         boolean not null default true,
  add column if not exists deactivated_at timestamptz,
  -- Sandbox API keys resolve only these, and live keys only resolve the rest.
  -- Without a flag on the row, "sandbox cannot reach a real mother" is a
  -- promise in application code rather than a property of the data.
  add column if not exists is_sandbox     boolean not null default false;

create index if not exists mothers_sandbox_idx on public.mothers (is_sandbox);
create index if not exists mothers_phc_active_idx
  on public.mothers (phc_id) where active;

-- ------------------------------------------------------- asha_assignments
-- Which ASHA reports to which medical officer, and which villages she covers.
--
-- asha_id and medical_officer_id both point at public.staff, not at
-- public.asha_workers. asha_workers is the directory a mother browses to find
-- someone to call; staff is the person who logs in. They are already linked by
-- asha_workers.staff_id. Assignments are about people who authenticate, so
-- they key on staff, and the directory entry is resolved through that link.
create table if not exists public.asha_assignments (
  id                  uuid primary key default gen_random_uuid(),
  asha_id             uuid not null references public.staff (id),
  medical_officer_id  uuid not null references public.staff (id),
  phc_id              uuid not null references public.health_centres (id),
  villages            uuid[] not null default '{}',
  assigned_at         timestamptz not null default now(),
  assigned_by         uuid references public.admin_users (id),
  active              boolean not null default true,
  ended_at            timestamptz,
  ended_by            uuid references public.admin_users (id),
  -- Why the previous assignment ended, for the audit trail.
  end_reason          text,
  constraint asha_assignment_ends_consistently
    check (active or ended_at is not null),
  constraint asha_assignment_distinct_people
    check (asha_id <> medical_officer_id)
);

-- One live assignment per ASHA. Reassignment closes the old row and opens a
-- new one; the index is what makes "she reports to two doctors" impossible
-- rather than merely unlikely.
create unique index if not exists asha_assignments_one_active
  on public.asha_assignments (asha_id) where active;
create index if not exists asha_assignments_mo_idx
  on public.asha_assignments (medical_officer_id) where active;
create index if not exists asha_assignments_history_idx
  on public.asha_assignments (asha_id, assigned_at desc);

-- The roles have to be the right way round, and both people have to be real
-- and active. A check constraint cannot look at another table, so it is a
-- trigger.
create or replace function public.asha_assignment_roles_guard()
returns trigger language plpgsql security definer set search_path = public as $$
declare a_role text; mo_role text; a_active boolean; mo_active boolean;
begin
  select role, active into a_role,  a_active  from public.staff where id = new.asha_id;
  select role, active into mo_role, mo_active from public.staff where id = new.medical_officer_id;

  if a_role is distinct from 'asha' then
    raise exception 'asha_id must be a staff member with role asha, not %', a_role;
  end if;
  if mo_role is distinct from 'doctor' then
    raise exception 'medical_officer_id must be a staff member with role doctor, not %', mo_role;
  end if;
  if new.active and not (a_active and mo_active) then
    raise exception 'Cannot open an assignment involving a deactivated staff member';
  end if;
  return new;
end $$;

drop trigger if exists asha_assignments_roles on public.asha_assignments;
create trigger asha_assignments_roles
  before insert or update on public.asha_assignments
  for each row execute function public.asha_assignment_roles_guard();

-- History is clinical audit data. Closing a row is an UPDATE of active;
-- removing one is not allowed at all.
create or replace function public.no_delete()
returns trigger language plpgsql as $$
begin
  raise exception 'Rows in % are never deleted; deactivate instead', TG_TABLE_NAME;
end $$;

drop trigger if exists asha_assignments_no_delete on public.asha_assignments;
create trigger asha_assignments_no_delete
  before delete on public.asha_assignments
  for each row execute function public.no_delete();

-- --------------------------------------------- reassignment, done atomically
-- Closing the old row and opening the new one must not be two round trips
-- from a browser: a dropped connection between them leaves an ASHA reporting
-- to nobody, which is the error state the dashboard exists to shout about.
create or replace function public.admin_reassign_asha(
  p_asha_id            uuid,
  p_medical_officer_id uuid,
  p_villages           uuid[] default null,
  p_reason             text   default null)
returns uuid
language plpgsql security definer set search_path = public as $$
declare
  v_admin   uuid;
  v_phc     uuid;
  v_prev    public.asha_assignments;
  v_new_id  uuid;
begin
  select id into v_admin from public.admin_users
   where auth_user_id = auth.uid() and active;
  if v_admin is null or not public.admin_may_write() then
    raise exception 'Only an administrator may reassign an ASHA worker';
  end if;

  select phc_id into v_phc from public.staff where id = p_medical_officer_id;
  if v_phc is null then
    raise exception 'That medical officer has no PHC; assign one first';
  end if;
  if not public.admin_sees_district(
       (select district_id from public.health_centres where id = v_phc)) then
    raise exception 'That PHC is outside your district';
  end if;

  select * into v_prev from public.asha_assignments
   where asha_id = p_asha_id and active;

  if found then
    if v_prev.medical_officer_id = p_medical_officer_id
       and p_villages is null then
      return v_prev.id;                       -- nothing actually changed
    end if;
    update public.asha_assignments
       set active = false, ended_at = now(), ended_by = v_admin,
           end_reason = coalesce(p_reason, 'reassigned')
     where id = v_prev.id;
  end if;

  insert into public.asha_assignments
    (asha_id, medical_officer_id, phc_id, villages, assigned_by)
  values (p_asha_id, p_medical_officer_id, v_phc,
          coalesce(p_villages, v_prev.villages, '{}'), v_admin)
  returning id into v_new_id;

  return v_new_id;
end $$;

revoke all on function public.admin_reassign_asha(uuid, uuid, uuid[], text) from public;
grant execute on function public.admin_reassign_asha(uuid, uuid, uuid[], text)
  to authenticated;

-- How many mothers move with her — the number the confirmation dialog has to
-- name before anyone clicks through it.
create or replace function public.asha_caseload_size(p_asha_id uuid)
returns int language sql stable security definer set search_path = public as $$
  select count(*)::int
    from public.mothers m
    join public.asha_workers aw on aw.id = coalesce(m.asha_worker_id, m.asha_id)
   where aw.staff_id = p_asha_id
     and coalesce(m.active, true)
$$;
grant execute on function public.asha_caseload_size(uuid) to authenticated;

-- ---------------------------------------------------------------------- RLS
alter table public.asha_assignments enable row level security;

drop policy if exists "read asha_assignments" on public.asha_assignments;
create policy "read asha_assignments" on public.asha_assignments
  for select to authenticated
  using (
    public.is_admin()
    or public.is_doctor()
    or exists (select 1 from public.staff s
                where s.id = asha_assignments.asha_id
                  and s.auth_user_id = (select auth.uid()))
  );

drop policy if exists "admins write asha_assignments" on public.asha_assignments;
create policy "admins write asha_assignments" on public.asha_assignments
  for all to authenticated
  using (public.admin_may_write()
         and public.admin_sees_district(
               (select district_id from public.health_centres
                 where id = asha_assignments.phc_id)))
  with check (public.admin_may_write()
         and public.admin_sees_district(
               (select district_id from public.health_centres
                 where id = asha_assignments.phc_id)));

grant select, insert, update on public.asha_assignments to authenticated;

-- staff: the existing "staff reads self" policy stays. Add the admin view.
drop policy if exists "admins read staff" on public.staff;
create policy "admins read staff" on public.staff
  for select to authenticated
  using (public.is_admin() and public.admin_sees_district(district_id));

drop policy if exists "admins write staff" on public.staff;
create policy "admins write staff" on public.staff
  for all to authenticated
  using (public.admin_may_write() and public.admin_sees_district(district_id))
  with check (public.admin_may_write() and public.admin_sees_district(district_id));

grant insert, update on public.staff to authenticated;

-- mothers: an administrator READS within district and writes nothing.
--
-- There is deliberately no admin update policy. RLS cannot restrict which
-- columns an update touches, so any policy permissive enough to let an admin
-- move a mother between ASHAs would also let them rewrite her haemoglobin.
-- Reassignment and deactivation go through the two functions below, which
-- touch those columns and no others.
drop policy if exists "admins read mothers" on public.mothers;
create policy "admins read mothers" on public.mothers
  for select to authenticated
  using (
    public.is_admin()
    and public.admin_sees_district(
          (select hc.district_id from public.health_centres hc
            where hc.id = mothers.phc_id))
  );

create or replace function public.admin_reassign_mother(
  p_mother_id uuid, p_asha_worker_id uuid)
returns void language plpgsql security definer set search_path = public as $$
declare v_district uuid;
begin
  if not public.admin_may_write() then
    raise exception 'Only an administrator may reassign a mother';
  end if;
  select hc.district_id into v_district
    from public.mothers m join public.health_centres hc on hc.id = m.phc_id
   where m.id = p_mother_id;
  if not public.admin_sees_district(v_district) then
    raise exception 'That mother is outside your district';
  end if;

  -- Both columns exist and both are read by different apps; letting them
  -- drift is how a record shows one ASHA in Care and another in Thayi.
  update public.mothers
     set asha_worker_id = p_asha_worker_id,
         asha_id        = p_asha_worker_id,
         updated_at     = now()
   where id = p_mother_id;
end $$;

create or replace function public.admin_set_mother_active(
  p_mother_id uuid, p_active boolean)
returns void language plpgsql security definer set search_path = public as $$
declare v_district uuid;
begin
  if not public.admin_may_write() then
    raise exception 'Only an administrator may deactivate a mother record';
  end if;
  select hc.district_id into v_district
    from public.mothers m join public.health_centres hc on hc.id = m.phc_id
   where m.id = p_mother_id;
  if not public.admin_sees_district(v_district) then
    raise exception 'That mother is outside your district';
  end if;

  update public.mothers
     set active = p_active,
         deactivated_at = case when p_active then null else now() end,
         updated_at = now()
   where id = p_mother_id;
end $$;

revoke all on function public.admin_reassign_mother(uuid, uuid) from public;
revoke all on function public.admin_set_mother_active(uuid, boolean) from public;
grant execute on function public.admin_reassign_mother(uuid, uuid) to authenticated;
grant execute on function public.admin_set_mother_active(uuid, boolean) to authenticated;

notify pgrst, 'reload schema';
