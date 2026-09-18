-- Attach a staff row to its login automatically on first sign-in.
--
-- Without this, an ASHA or doctor authenticates fine but has no role, so RLS
-- resolves their scope to nothing and every screen comes back empty. Matching
-- on email at insert time removes the manual linking step entirely.

create or replace function public.link_staff_to_auth_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  update public.staff
     set auth_user_id = new.id
   where lower(email) = lower(new.email)
     and auth_user_id is distinct from new.id;
  return new;
end $$;

drop trigger if exists on_auth_user_created_link_staff on auth.users;
create trigger on_auth_user_created_link_staff
  after insert on auth.users
  for each row execute function public.link_staff_to_auth_user();

-- Catch up anyone who signed in before this existed.
update public.staff s
   set auth_user_id = u.id
  from auth.users u
 where lower(u.email) = lower(s.email) and s.auth_user_id is null;
