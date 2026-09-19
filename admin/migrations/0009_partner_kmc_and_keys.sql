-- Setu Admin Portal — a named doctor behind every partner request, and the
-- security properties of an issued key.

-- ------------------------------------- who is accountable for the request
-- A hospital is not a person and cannot be struck off. Requiring the KMC
-- registration of the doctor making the request puts a named, registered
-- medical professional behind every application: someone the council can
-- identify, whose standing can be checked today and re-checked later.
--
-- It also removes four fields from the form. The contact's name, email and
-- phone are on the register already, and asking a person to retype what the
-- council holds is how the two end up disagreeing.
alter table public.partner_orgs
  add column if not exists kmc_registration_number text
    references public.kmc_registry (registration_number),
  -- Captured at the moment of the request. The register is live and a doctor
  -- may lapse afterwards; this records what was true when access was granted,
  -- which is the question an audit asks.
  add column if not exists kmc_verified_at   timestamptz,
  add column if not exists kmc_status_at_request text;

create index if not exists partner_orgs_kmc_idx
  on public.partner_orgs (kmc_registration_number);

-- The contact details now come from the register rather than the form. They
-- stay nullable for the rows that predate this.
alter table public.partner_orgs alter column contact_name  drop not null;
alter table public.partner_orgs alter column contact_email drop not null;
alter table public.partner_orgs alter column contact_phone drop not null;

-- A request must carry either a registration (the new way) or the contact
-- details typed by hand (the old rows). Never neither.
alter table public.partner_orgs drop constraint if exists partner_has_a_contact;
alter table public.partner_orgs add constraint partner_has_a_contact
  check (kmc_registration_number is not null or contact_email is not null);

-- ------------------------------------------- filling the form from the register
-- Anonymous, because the request form is not signed in. It answers only
-- "is this registration real and in good standing, and what is the contact
-- name and email" — never the date of birth, the address or the father's name.
-- A public endpoint that returned a doctor's full record would be a directory
-- of medical professionals' personal details, open to anyone.
create or replace function public.kmc_verify_public(p_registration_number text)
returns jsonb
language plpgsql stable security definer set search_path = public as $$
declare
  v_num text := upper(btrim(coalesce(p_registration_number, '')));
  r     public.kmc_registry;
begin
  if v_num = '' then
    return jsonb_build_object('valid', false, 'reason', 'empty');
  end if;

  select * into r from public.kmc_registry
   where upper(registration_number) = v_num;

  if not found then
    return jsonb_build_object('valid', false, 'reason', 'not_in_registry');
  end if;
  if r.status not in ('active', 'renewed') then
    return jsonb_build_object('valid', false, 'reason', 'not_in_good_standing',
                              'status', r.status);
  end if;

  return jsonb_build_object(
    'valid', true,
    'is_demo', r.is_demo,
    'registration_number', r.registration_number,
    'full_name', r.full_name,
    'qualification', r.qualification,
    'state_medical_council', r.state_medical_council,
    'status', r.status,
    -- Needed so the key can be emailed to an address the council holds rather
    -- than one the applicant typed. Returned because the applicant is the
    -- doctor and is looking at their own record.
    'email', r.email,
    'phone', r.phone);
end $$;

revoke all on function public.kmc_verify_public(text) from public;
grant execute on function public.kmc_verify_public(text) to anon, authenticated;

-- ------------------------------------------------------- key security layer
alter table public.api_keys
  -- The last four characters of the key, shown in the portal and in the email
  -- so a partner holding several can tell which is which without revealing any
  -- of them. Prefix alone is identical across every key of an environment.
  add column if not exists key_last_four text,
  -- Where the key was emailed. An issued key that reached the wrong inbox is a
  -- disclosure, and the audit needs to say where it went.
  add column if not exists issued_to_email text,
  add column if not exists issued_at timestamptz,
  -- Optional allowlist. A key is a bearer credential; pinning it to the
  -- hospital's egress addresses means a stolen one is useless off their network.
  add column if not exists allowed_ips inet[],
  -- Counted by the lookup endpoint, so a leaked key that starts being probed
  -- shows up as a number rather than as a line in a log nobody reads.
  add column if not exists failed_auth_count int not null default 0;

-- A key that never expires is a key nobody ever re-examines.
alter table public.api_keys alter column expires_at
  set default (now() + interval '1 year');

-- ------------------------------------------------------------ mother summary
-- What a partner receives, and nothing beyond it. Defined here rather than
-- assembled in the API so the shape is reviewable as data policy: adding a
-- column to mothers must not silently widen what a hospital can read.
--
-- SECURITY DEFINER because the caller is the service role acting for a partner
-- and has no session; the checks that matter — key, scope, token, sandbox —
-- happen in the endpoint before this is called.
create or replace function public.partner_mother_summary(p_mother_id uuid)
returns jsonb
language sql stable security definer set search_path = public as $$
  select jsonb_build_object(
    'name', m.name_en,
    'age', m.age,
    'blood_group', m.blood_group,
    -- Weeks since the last menstrual period, which is how gestational age is
    -- counted; capped at 45 so a stale record cannot report a nonsense number.
    'gestational_age_weeks',
      least(45, greatest(0, (current_date - m.lmp) / 7)),
    'expected_delivery_date', (m.lmp + interval '280 days')::date,
    'gravida', m.gravida,
    'parity', m.para,
    'risk_flags', coalesce((
      select jsonb_agg(jsonb_build_object(
               'type', reason, 'severity', m.risk_level))
        from unnest(m.risk_reasons) as reason), '[]'::jsonb),
    'allergies', coalesce(to_jsonb(m.allergy_ids), '[]'::jsonb),
    'recent_vitals', coalesce((
      select jsonb_agg(jsonb_build_object(
               'date', v.visit_date,
               'bp', concat(v.bp_sys, '/', v.bp_dia),
               'weight_kg', v.weight_kg,
               'hb', v.hb) order by v.visit_date desc)
        from (select * from public.anc_visits
               where mother_id = m.id
               order by visit_date desc limit 3) v), '[]'::jsonb),
    -- Only doses actually given. A planned-but-unadministered row would read
    -- to a clinician as protection the mother does not have.
    'tt_doses', coalesce((
      select jsonb_agg(jsonb_build_object('dose', t.dose_number, 'date', t.given_on)
                       order by t.dose_number)
        from public.tt_doses t
       where t.mother_id = m.id and t.given), '[]'::jsonb),
    'assigned_asha', (
      select jsonb_build_object('name', a.name_en, 'phone', a.phone)
        from public.asha_workers a
       where a.id = coalesce(m.asha_worker_id, m.asha_id)),
    'phc', (
      select jsonb_build_object('name', h.name_en, 'phone', h.phone)
        from public.health_centres h where h.id = m.phc_id)
  )
  from public.mothers m
  where m.id = p_mother_id and m.active
$$;

-- Nothing but the service role. A signed-in mother, ASHA or doctor reads the
-- real tables through their own policies; this exists for the partner path.
revoke all on function public.partner_mother_summary(uuid) from public;
revoke all on function public.partner_mother_summary(uuid) from anon, authenticated;
grant execute on function public.partner_mother_summary(uuid) to service_role;

notify pgrst, 'reload schema';
