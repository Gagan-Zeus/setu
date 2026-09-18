-- Only a verified address may sign in, and a mother row must find its auth
-- user whichever order the two arrive in.

-- ------------------------------------------------------------------ the gate
-- Registration is offline, so an unverified address is a normal state, not an
-- error — but it must not open a record. Until an ASHA has proved the address
-- reaches her, "someone typed this into a form once" is all it means, and that
-- is not an identity.
create or replace function public.mother_email_registered(p_email text)
returns boolean
language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from public.mothers
     where lower(email) = lower(trim(p_email))
       and email_verified
  )
$$;

grant execute on function public.mother_email_registered(text)
  to anon, authenticated;

-- --------------------------------------------------- linking, in both orders
-- The existing trigger links when the auth user is created. That covers a
-- mother who already exists in the record. It does not cover the new flow,
-- where an ASHA verifies at the doorstep and the auth user is created first,
-- or where her row syncs up afterwards from the outbox. Without this half she
-- authenticates successfully and then sees an empty app, because RLS resolves
-- her through mothers.auth_user_id.
create or replace function public.link_mother_row_to_auth_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if new.email is not null and new.auth_user_id is null then
    select id into new.auth_user_id
      from auth.users
     where lower(email) = lower(trim(new.email))
     limit 1;
  end if;
  return new;
end $$;

drop trigger if exists link_mother_row_to_auth_user on public.mothers;
create trigger link_mother_row_to_auth_user
  before insert or update of email on public.mothers
  for each row execute function public.link_mother_row_to_auth_user();

-- Catch up anything already sitting unlinked.
update public.mothers m set auth_user_id = u.id
  from auth.users u
 where lower(u.email) = lower(m.email) and m.auth_user_id is null;
