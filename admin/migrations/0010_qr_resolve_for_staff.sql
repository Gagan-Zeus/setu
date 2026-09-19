-- Setu — a clinician scanning the same QR the mother now shows.
--
-- Thayi Setu stopped rendering `setu://m/<uuid>?t=<token>` and now renders a
-- five-minute signed token, so grant_access_by_qr — which matches the static
-- mothers.qr_token — has nothing to match any more. Setu Care's scanner would
-- simply stop working.
--
-- A doctor is not a partner and does not get the partner summary. He already
-- has RLS access to the mothers in his facility; the QR is how he finds the
-- right one in a queue, and it opens the 24-hour grant the consent flow
-- expects. So this mirrors grant_access_by_qr exactly, except that the token
-- has already been verified by the time it is called.
--
-- It takes the staff id rather than reading auth.uid(), because the caller is
-- the Edge Function running as the service role — it has verified the HMAC,
-- which no database function can do — and there is no session for auth.uid()
-- to resolve. That is also why it is granted to service_role alone: with the
-- staff id as an argument, any caller who could execute it could open a grant
-- in someone else's name.
create or replace function public.grant_access_after_qr(
  p_mother_id uuid, p_staff_id uuid)
returns boolean
language plpgsql security definer set search_path = public as $$
begin
  if not exists (select 1 from public.staff where id = p_staff_id and active) then
    return false;
  end if;
  if not exists (select 1 from public.mothers where id = p_mother_id and active) then
    return false;
  end if;

  delete from public.access_grants
   where mother_id = p_mother_id and staff_id = p_staff_id;

  -- A hospital visit, not a standing permission. Same 24 hours the old path
  -- gave, because the consent it records is the same act: she held out her
  -- phone to this person, once.
  insert into public.access_grants (mother_id, staff_id, status, method,
                                    decided_at, expires_at)
  values (p_mother_id, p_staff_id, 'approved', 'qr', now(), now() + interval '24 hours');
  return true;
end $$;

revoke all on function public.grant_access_after_qr(uuid, uuid) from public;
revoke all on function public.grant_access_after_qr(uuid, uuid) from anon, authenticated;
grant execute on function public.grant_access_after_qr(uuid, uuid) to service_role;

notify pgrst, 'reload schema';
