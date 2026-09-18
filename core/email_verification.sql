-- Verifying a mother's email at the doorstep.
--
-- The ASHA types the address while standing in the house. If she mistypes it,
-- nobody finds out until the mother tries to sign in weeks later — by which
-- time the ASHA has gone and the record is unreachable by the person it
-- belongs to.
--
-- Registration itself stays offline, because that is the whole design. This is
-- opportunistic: verify when there is signal, and carry an honest "not
-- verified yet" state when there is not.
--
-- The code is Supabase's own login OTP rather than a second scheme of ours.
-- What the ASHA is confirming, standing there, is precisely the thing that
-- matters: that this address receives the code the mother will later sign in
-- with. Inventing a parallel code would need its own delivery, its own
-- expiry, its own brute-force limit, and would prove something weaker.

alter table public.mothers
  add column if not exists email_verified boolean not null default false,
  add column if not exists email_verified_at timestamptz;

-- The custom-code table from the first cut of this is not needed once the
-- login OTP is the code. Dropped rather than left to rot.
drop function if exists public.consume_email_verification(uuid, text);
drop table if exists public.email_verifications;

-- Recorded by the ASHA app once the mother has read the code back correctly.
-- SECURITY DEFINER so it can set the flag without granting write access to
-- the rest of her row, and scoped so a worker can only do it for a mother in
-- her own sub-centre.
create or replace function public.mark_email_verified(
  p_mother_id uuid, p_email text)
returns boolean
language plpgsql security definer set search_path = public as $$
declare
  allowed boolean;
begin
  select public.can_access_mother(p_mother_id) into allowed;
  if not allowed then
    return false;
  end if;

  update public.mothers
     set email = lower(trim(p_email)),
         email_verified = true,
         email_verified_at = now(),
         -- This also repairs accounts created by an older client before the
         -- mother row had synchronised. For new accounts the auth trigger
         -- below does the same linking as soon as the OTP is requested.
         auth_user_id = (
           select id from auth.users
            where lower(email) = lower(trim(p_email))
            limit 1
         )
   where id = p_mother_id;

  return found;
end $$;

grant execute on function public.mark_email_verified(uuid, text) to authenticated;

-- Everyone already in the demo dataset signed in before this existed, so their
-- addresses are verified by definition — they have each received a code.
update public.mothers m set email_verified = true, email_verified_at = now()
 where m.email is not null and m.auth_user_id is not null;
