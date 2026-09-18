-- Only a mother an ASHA has registered may sign in.
--
-- Two holes closed here. The app called signInWithOtp without
-- shouldCreateUser:false, so Supabase minted an auth user for any address
-- typed in. And nothing checked that the address belonged to a registered
-- mother, so a stranger reached the signed-in shell — empty, because RLS gave
-- her no rows, but she was inside.

alter table public.mothers
  add column if not exists email text;

create unique index if not exists mothers_email_unique
  on public.mothers (lower(email)) where email is not null;

-- Backfill the three existing accounts from the login they are already tied to.
update public.mothers m
   set email = u.email
  from auth.users u
 where m.auth_user_id = u.id and m.email is null;

-- Called before any code is sent. SECURITY DEFINER so it can see the table
-- without a session; it returns a boolean and never leaks a row.
create or replace function public.mother_email_registered(p_email text)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.mothers
     where lower(email) = lower(trim(p_email))
       -- A typed address cannot unlock health information. It must have been
       -- proved at registration and linked to the account that received OTP.
       and email_verified is true
       and auth_user_id is not null
  )
$$;

revoke all on function public.mother_email_registered(text) from public;
grant execute on function public.mother_email_registered(text) to anon, authenticated;

-- When she verifies her code, tie the login to her record automatically —
-- the same pattern staff use.
create or replace function public.link_mother_to_auth_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  update public.mothers
     set auth_user_id = new.id
   where lower(email) = lower(new.email)
     and auth_user_id is distinct from new.id;
  return new;
end $$;

drop trigger if exists on_auth_user_created_link_mother on auth.users;
create trigger on_auth_user_created_link_mother
  after insert on auth.users
  for each row execute function public.link_mother_to_auth_user();
