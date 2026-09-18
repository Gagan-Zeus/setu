-- Setu Admin Portal — the admin audit log.
--
-- Every administrative write records what changed, who changed it and what it
-- looked like before. This is the screen that makes the system defensible to a
-- health department, so it is a trigger on the tables rather than a call the
-- application layer is trusted to remember.

create table if not exists public.admin_audit_log (
  id          bigserial primary key,
  -- The admin_users row, resolved at write time. Null only for something the
  -- service role did with no admin session, which is itself worth seeing.
  actor_id    uuid references public.admin_users (id),
  actor_email text,
  action      text not null check (action in ('insert', 'update', 'delete')),
  entity_type text not null,
  entity_id   text,
  before      jsonb,
  after       jsonb,
  -- Set by the API layer via set_config('setu.client_ip', ...). Null when a
  -- change is made straight through SQL.
  ip_address  inet,
  created_at  timestamptz not null default now()
);

create index if not exists admin_audit_actor_idx
  on public.admin_audit_log (actor_id, created_at desc);
create index if not exists admin_audit_entity_idx
  on public.admin_audit_log (entity_type, entity_id, created_at desc);
create index if not exists admin_audit_time_idx
  on public.admin_audit_log (created_at desc);

drop trigger if exists admin_audit_log_append_only on public.admin_audit_log;
create trigger admin_audit_log_append_only
  before update or delete on public.admin_audit_log
  for each row execute function public.append_only();

-- --------------------------------------------------------------- the trigger
-- One function for every audited table. to_jsonb(row) means a column added
-- later is captured without anyone remembering to update this.
create or replace function public.write_admin_audit()
returns trigger language plpgsql security definer set search_path = public as $$
declare
  v_actor  uuid;
  v_email  text;
  v_ip     inet;
  v_before jsonb;
  v_after  jsonb;
begin
  select id, email into v_actor, v_email
    from public.admin_users where auth_user_id = auth.uid() and active;

  -- Never let a missing setting turn a real write into an error.
  begin
    v_ip := nullif(current_setting('setu.client_ip', true), '')::inet;
  exception when others then
    v_ip := null;
  end;

  if TG_OP = 'DELETE' then
    v_before := to_jsonb(old);
  elsif TG_OP = 'INSERT' then
    v_after := to_jsonb(new);
  else
    v_before := to_jsonb(old);
    v_after  := to_jsonb(new);
    -- An update that changed nothing is noise in a log people have to read.
    if v_before = v_after then
      return new;
    end if;
  end if;

  insert into public.admin_audit_log
    (actor_id, actor_email, action, entity_type, entity_id, before, after, ip_address)
  values (v_actor, v_email, lower(TG_OP), TG_TABLE_NAME,
          coalesce((v_after ->> 'id'), (v_before ->> 'id')),
          v_before, v_after, v_ip);

  return coalesce(new, old);
end $$;

-- Attach to everything the portal writes. anc_visits, labs and the rest are
-- deliberately absent: they are clinical, no admin can write them, and mixing
-- them in would bury the administrative trail in routine care.
do $$
declare t text;
begin
  foreach t in array array['admin_users','admin_districts','districts','villages',
                           'health_centres','staff','asha_assignments',
                           'partner_orgs','api_keys']
  loop
    execute format('drop trigger if exists %1$s_audit on public.%1$I', t);
    execute format(
      'create trigger %1$s_audit after insert or update or delete on public.%1$I
         for each row execute function public.write_admin_audit()', t);
  end loop;
end $$;

-- ---------------------------------------------------------------------- RLS
alter table public.admin_audit_log enable row level security;

-- Every administrator can read the audit log, viewers included — a read-only
-- auditor who cannot see the audit trail is not an auditor.
drop policy if exists "admins read admin_audit_log" on public.admin_audit_log;
create policy "admins read admin_audit_log" on public.admin_audit_log
  for select to authenticated using (public.is_admin());

grant select on public.admin_audit_log to authenticated;

notify pgrst, 'reload schema';
