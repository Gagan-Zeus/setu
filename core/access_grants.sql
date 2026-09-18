-- Consent before a doctor reads a woman's record.
--
-- Until now any doctor in the facility could read every mother's clinical
-- history. That is convenient and wrong: she never agreed to it. A doctor now
-- needs an active grant, obtained one of two ways.
--
--   request — she asks, the mother approves or rejects in Thayi Setu
--   qr      — the mother shows her Thayi Card QR at the hospital. Presenting
--             it IS the consent, so access opens immediately with no request.
--
-- Her ASHA is unaffected: she records the data during home visits and is
-- already scoped to her own sub-centre.

create table if not exists public.access_grants (
  id           uuid primary key default gen_random_uuid(),
  mother_id    uuid not null references public.mothers (id) on delete cascade,
  staff_id     uuid not null references public.staff (id) on delete cascade,
  status       text not null default 'pending'
                 check (status in ('pending','approved','rejected','expired')),
  method       text not null default 'request'
                 check (method in ('request','qr')),
  reason       text,
  requested_at timestamptz not null default now(),
  decided_at   timestamptz,
  expires_at   timestamptz
);

create index if not exists access_grants_mother_idx
  on public.access_grants (mother_id, status);
create index if not exists access_grants_staff_idx
  on public.access_grants (staff_id, status);

-- One live request per doctor per mother; re-asking updates rather than piles up.
create unique index if not exists access_grants_one_pending
  on public.access_grants (mother_id, staff_id)
  where status = 'pending';

-- ---------------------------------------------------------------- the gate

create or replace function public.has_active_grant(m_id uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select exists (
    select 1
      from public.access_grants g
      join public.staff s on s.id = g.staff_id
     where g.mother_id = m_id
       and s.auth_user_id = auth.uid()
       and g.status = 'approved'
       and (g.expires_at is null or g.expires_at > now())
  )
$$;

-- Clinical data. A doctor needs a grant; the mother and her own ASHA do not.
create or replace function public.can_access_mother(m_id uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from public.mothers m
    where m.id = m_id
      and (
        m.auth_user_id = auth.uid()
        or m.sub_centre = public.current_sub_centre()
        or (public.is_doctor() and public.has_active_grant(m.id))
      )
  )
$$;

-- --------------------------------------------------------------- requesting

create or replace function public.request_mother_access(
  p_mother_id uuid, p_reason text default null)
returns uuid language plpgsql security definer set search_path = public as $$
declare v_staff uuid; v_id uuid;
begin
  select id into v_staff from public.staff where auth_user_id = auth.uid();
  if v_staff is null then raise exception 'Not staff'; end if;

  -- Re-asking after a rejection is allowed; it replaces the old request.
  delete from public.access_grants
   where mother_id = p_mother_id and staff_id = v_staff
     and status in ('pending','rejected','expired');

  insert into public.access_grants (mother_id, staff_id, status, method, reason)
  values (p_mother_id, v_staff, 'pending', 'request', p_reason)
  returning id into v_id;
  return v_id;
end $$;

-- The QR path. Presenting the card at the hospital is the consent, so this
-- approves immediately — but only if the token matches the one in her QR,
-- which means the card was physically shown.
create or replace function public.grant_access_by_qr(
  p_mother_id uuid, p_token text)
returns boolean language plpgsql security definer set search_path = public as $$
declare v_staff uuid;
begin
  select id into v_staff from public.staff where auth_user_id = auth.uid();
  if v_staff is null then raise exception 'Not staff'; end if;

  if not exists (
    select 1 from public.mothers
     where id = p_mother_id and qr_token = p_token
  ) then
    return false;
  end if;

  delete from public.access_grants
   where mother_id = p_mother_id and staff_id = v_staff;

  -- A hospital visit, not a standing permission.
  insert into public.access_grants (mother_id, staff_id, status, method,
                                    decided_at, expires_at)
  values (p_mother_id, v_staff, 'approved', 'qr', now(), now() + interval '24 hours');
  return true;
end $$;

-- Her decision.
create or replace function public.decide_access_request(
  p_grant_id uuid, p_approve boolean)
returns boolean language plpgsql security definer set search_path = public as $$
declare v_mother uuid;
begin
  select m.id into v_mother
    from public.mothers m
    join public.access_grants g on g.mother_id = m.id
   where g.id = p_grant_id and m.auth_user_id = auth.uid();
  if v_mother is null then raise exception 'Not your request'; end if;

  update public.access_grants
     set status = case when p_approve then 'approved' else 'rejected' end,
         decided_at = now(),
         -- An approval she gave deliberately lasts longer than a QR scan.
         expires_at = case when p_approve then now() + interval '30 days' end
   where id = p_grant_id;
  return true;
end $$;

-- ------------------------------------------------------------ row security

alter table public.access_grants enable row level security;

drop policy if exists "read own grants" on public.access_grants;
create policy "read own grants" on public.access_grants
  for select to authenticated
  using (
    mother_id in (select id from public.mothers where auth_user_id = (select auth.uid()))
    or staff_id in (select id from public.staff where auth_user_id = (select auth.uid()))
  );

revoke all on function public.request_mother_access(uuid, text) from public;
revoke all on function public.grant_access_by_qr(uuid, text) from public;
revoke all on function public.decide_access_request(uuid, boolean) from public;
grant execute on function public.request_mother_access(uuid, text) to authenticated;
grant execute on function public.grant_access_by_qr(uuid, text) to authenticated;
grant execute on function public.decide_access_request(uuid, boolean) to authenticated;

-- ------------------------------------------------- no duplicate emails, ever

-- Each table already guards itself; nothing stopped the same address being
-- used by a mother and a staff member.
create or replace function public.reject_cross_table_email()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if new.email is null then return new; end if;
  if tg_table_name = 'mothers' then
    if exists (select 1 from public.staff where lower(email) = lower(new.email)) then
      raise exception 'That email already belongs to a staff member';
    end if;
  else
    if exists (select 1 from public.mothers where lower(email) = lower(new.email)) then
      raise exception 'That email already belongs to a mother';
    end if;
  end if;
  return new;
end $$;

drop trigger if exists mothers_email_not_staff on public.mothers;
create trigger mothers_email_not_staff
  before insert or update of email on public.mothers
  for each row execute function public.reject_cross_table_email();

drop trigger if exists staff_email_not_mother on public.staff;
create trigger staff_email_not_mother
  before insert or update of email on public.staff
  for each row execute function public.reject_cross_table_email();
