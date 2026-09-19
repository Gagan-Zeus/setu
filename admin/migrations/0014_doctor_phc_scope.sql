-- A medical officer works with the mothers at her own PHC.
--
-- Two policies disagreed about what a doctor may touch, and the gap between
-- them is where doctor-assigned work disappeared.
--
--   "read mothers in scope"  allowed a bare is_doctor()   -> she saw everyone
--   can_access_mother()      required has_active_grant()  -> she could write
--                                                            to nobody
--
-- So Setu Care listed every mother in the database, the doctor assigned a
-- task, and the insert was refused by row level security. The app reported it
-- honestly — "She has not given you access yet" — but the doctor had no way to
-- act on that for a woman registered at her own facility, and the ASHA never
-- received the work. Nothing was lost in transit; the row was never created.
--
-- The read side was also wider than anyone intended: is_doctor() with no
-- further test means any doctor account could read every mother in the
-- database, not merely the ones at her facility.
--
-- Both now say the same thing:
--
--   the mother herself
--   or her own ASHA, by sub-centre
--   or a doctor at the PHC the mother is registered at
--   or a doctor the mother has actually granted access to
--
-- The last branch is what consent is for, and it still carries the cases that
-- cross a facility boundary — a referral hospital, a doctor she is not
-- registered with, a QR scanned at a counter. What it should never have been
-- carrying is the ordinary case of her own PHC's medical officer.
--
-- Idempotent.

-- The facility the signed-in staff member belongs to. Returns null for a
-- mother's own login and for an administrator, so neither matches a row by
-- accident — null = null is null, not true.
create or replace function public.current_phc()
returns uuid language sql stable security definer set search_path = public as $$
  select phc_id from public.staff where auth_user_id = auth.uid()
$$;

revoke all on function public.current_phc() from public, anon;
grant execute on function public.current_phc() to authenticated;

-- Clinical data: tasks, visits, alerts, referrals, notes and labs all gate on
-- this one function, so widening it here is what makes an assigned task reach
-- the ASHA who has to do it.
create or replace function public.can_access_mother(m_id uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from public.mothers m
    where m.id = m_id
      and (
        m.auth_user_id = auth.uid()
        or m.sub_centre = public.current_sub_centre()
        or (public.is_doctor() and m.phc_id = public.current_phc())
        or (public.is_doctor() and public.has_active_grant(m.id))
      )
  )
$$;

-- The read policy now matches it exactly, rather than being strictly wider.
drop policy if exists "read mothers in scope" on public.mothers;
create policy "read mothers in scope" on public.mothers
  for select to authenticated
  using (
    auth_user_id = (select auth.uid())
    or sub_centre = public.current_sub_centre()
    or (public.is_doctor() and phc_id = public.current_phc())
    or (public.is_doctor() and public.has_active_grant(id))
  );

notify pgrst, 'reload schema';
