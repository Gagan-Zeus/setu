-- The mother reads what her ASHA recorded.
--
-- There were two parallel schemas that had never been joined. The ASHA app and
-- Setu Care write and read anc_visits; Thayi Setu reads checkups,
-- weight_entries, bp_entries and tt_doses — four tables that NOTHING in the
-- repo has ever written. A grep across asha/, care/ and core/functions/ for
-- any of those names returns nothing at all.
--
-- So her Checkups screen and the weight and blood-pressure charts on her Health
-- screen were reading a schema no app populates. However well the ASHA's sync
-- worked, her own record was always going to be empty — it was not a sync bug
-- underneath, it was a second data model.
--
-- These four are replaced by views over anc_visits. Her app needs no change and
-- no rebuild: the table names, the column names and the ordering columns are
-- all preserved, so the same queries now return her real visits.
--
-- All four were empty when this ran (0 rows each), so nothing is lost. To undo,
-- drop the views and recreate the tables from
-- thayi/supabase/migrations/0001_init.sql.
--
-- security_invoker = on is the important part: each view reads with the
-- caller's own rights, so anc_visits' own policy applies and a mother sees her
-- own visits and nobody else's. Defining them any other way would hand every
-- signed-in user the whole antenatal record of every woman in the state.
--
-- Idempotent.

-- Dropped by whatever they actually are. `drop view if exists` raises on a
-- table and `drop table if exists` raises on a view, so neither alone is
-- re-runnable: the first run meets four tables, every run after meets four
-- views.
do $$
declare
  n text;
  k char;
begin
  foreach n in array array['checkups','weight_entries','bp_entries','tt_doses']
  loop
    select c.relkind into k
      from pg_class c join pg_namespace s on s.oid = c.relnamespace
     where s.nspname = 'public' and c.relname = n;

    if k = 'v' then
      execute format('drop view %I cascade', n);
    elsif k in ('r', 'p') then
      execute format('drop table %I cascade', n);
    end if;
  end loop;
end $$;

-- Her visit list. A visit that was recorded is a visit that happened, so
-- completed is true by construction — the screen's "upcoming" tab is driven by
-- her schedule, not by this.
create view public.checkups as
select v.id,
       v.mother_id,
       v.visit_no                         as visit_number,
       v.visit_date                       as scheduled_on,
       m.sub_centre                       as location_kn,
       m.sub_centre                       as location_en,
       '{}'::text[]                       as activity_ids,
       true                               as completed,
       v.weight_kg,
       v.bp_sys                           as systolic,
       v.bp_dia                           as diastolic,
       v.recorded_by                      as recorded_by_kn,
       v.recorded_by                      as recorded_by_en,
       v.created_at
  from public.anc_visits v
  join public.mothers m on m.id = v.mother_id;

-- The charts are plotted against gestational week, which the visit itself does
-- not carry — it is the visit date measured from her last period.
create view public.weight_entries as
select v.id,
       v.mother_id,
       greatest(0, ((v.visit_date - m.lmp) / 7))::int as week,
       v.weight_kg                                    as kg,
       v.created_at
  from public.anc_visits v
  join public.mothers m on m.id = v.mother_id
 where v.weight_kg is not null and m.lmp is not null;

create view public.bp_entries as
select v.id,
       v.mother_id,
       greatest(0, ((v.visit_date - m.lmp) / 7))::int as week,
       v.bp_sys                                       as systolic,
       v.bp_dia                                       as diastolic,
       v.created_at
  from public.anc_visits v
  join public.mothers m on m.id = v.mother_id
 where v.bp_sys is not null and m.lmp is not null;

-- A dose recorded at a visit is a dose she was given.
create view public.tt_doses as
select v.id,
       v.mother_id,
       v.tt_dose_given as dose_number,
       true            as given,
       v.visit_date    as given_on
  from public.anc_visits v
 where v.tt_dose_given is not null;

alter view public.checkups       set (security_invoker = on);
alter view public.weight_entries set (security_invoker = on);
alter view public.bp_entries     set (security_invoker = on);
alter view public.tt_doses       set (security_invoker = on);

grant select on public.checkups, public.weight_entries,
                public.bp_entries, public.tt_doses to authenticated;

notify pgrst, 'reload schema';
