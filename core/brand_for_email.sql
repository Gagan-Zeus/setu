-- Which app is this address signing in to?
--
-- One Supabase project backs Thayi, ASHA and Care, so one Send Email hook
-- serves all three and every code used to arrive wearing the mother app's
-- face. The hook needs to know who it is writing to before it picks a logo.
--
-- Answered from the role tables rather than from anything the client sends,
-- because the client is not always the reader: when an ASHA verifies a
-- mother's address at the doorstep, the request comes from the ASHA app but
-- the email lands in the mother's inbox and must wear Thayi's logo. Keyed on
-- the address, that case is right without anyone having to remember it.
--
-- staff.email and mothers.email cannot collide — access_grants.sql refuses an
-- address already used by the other side (mothers_email_not_staff and
-- staff_email_not_mother) — so there is no precedence to argue about.

create or replace function public.setu_role_for_email(p_email text)
returns text
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(
    (select s.role
       from public.staff s
      where lower(s.email) = lower(trim(p_email))
      limit 1),
    (select 'mother'
       from public.mothers m
      where lower(m.email) = lower(trim(p_email))
      limit 1)
  )
$$;

-- Only the hook may ask. The answer is thin — 'asha', 'doctor', 'mother' or
-- null — but it still reports whether an address is registered and what it is,
-- which is exactly what the mother_email_registered gate exists to withhold
-- from anonymous callers. The edge function runs as service_role.
revoke all on function public.setu_role_for_email(text) from public;
revoke all on function public.setu_role_for_email(text) from anon, authenticated;
grant execute on function public.setu_role_for_email(text) to service_role;

-- PostgREST caches the list of callable functions, and the hook reaches this
-- one through /rest/v1/rpc. Without the reload the first sign-in after
-- deploying gets a 404, falls back to the default brand, and looks like the
-- bug this file exists to fix.
notify pgrst, 'reload schema';
