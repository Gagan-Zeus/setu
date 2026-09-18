-- A second fully-populated mother, so two people can be signed in to Thayi
-- Setu at once during the demo without sharing one login.
--
-- Cloned from Lakshmi (m-001) rather than invented, because her record is the
-- one with a story in it: five visits with blood pressure creeping up and
-- haemoglobin drifting down. A new mother with three flat readings demonstrates
-- nothing on the trend screens.
--
-- Everything is derived from the source row, so this stays correct if the
-- dataset is regenerated.

do $$
declare
  src   uuid;
  dst   uuid := '00000000-0000-5000-8000-00000000a814';
  addr  text := 'ashiika814@gmail.com';
begin
  select id into src from public.mothers where thayi_card_number = 'm-001';
  if src is null then
    raise exception 'm-001 not found — load the demo dataset first';
  end if;

  -- Re-runnable: clear any previous copy before rebuilding it.
  delete from public.mothers where id = dst;

  -- Copied column by column rather than through a row cast: hstore is not
  -- installed, and naming the columns makes the identity overrides obvious.
  insert into public.mothers
    (id, qr_token, thayi_card_number, name_en, name_kn, age, guardian_en,
     guardian_kn, phone, email, email_verified, email_verified_at,
     village_en, village_kn, district_en, district_kn, sub_centre,
     asha_worker_id, asha_id, phc_id, lmp, gravida, para, delivery_number,
     blood_group, height_cm, is_bpl, plans_institutional_delivery,
     has_bank_account, prev_complications, risk_level, risk_reasons,
     risk_flag_ids, allergy_ids, last_visit_date,
     home_lat, home_lng, home_note, home_located_at)
  select dst,
         md5(dst::text || 'setu'),
         'm-026',
         'Ashika N', 'ಆಶಿಕಾ ಎನ್', m.age,
         'Nagaraj B', 'ನಾಗರಾಜ್ ಬಿ',
         '+91 98867 40021',
         addr, true, now(),
         m.village_en, m.village_kn, m.district_en, m.district_kn, m.sub_centre,
         m.asha_worker_id, m.asha_id, m.phc_id, m.lmp, m.gravida, m.para,
         m.delivery_number, m.blood_group, m.height_cm, m.is_bpl,
         m.plans_institutional_delivery, m.has_bank_account,
         m.prev_complications, m.risk_level, m.risk_reasons,
         m.risk_flag_ids, m.allergy_ids, m.last_visit_date,
         m.home_lat, m.home_lng, m.home_note, m.home_located_at
    from public.mothers m where m.id = src;

  -- Her clinical history, visit for visit.
  insert into public.anc_visits
    (id, mother_id, visit_no, visit_date, bp_sys, bp_dia, weight_kg, hb,
     fundal_height_cm, fetal_hr, urine_albumin, danger_signs, ifa_taken,
     calcium_taken, tt_dose_given, recorded_by, source)
  select gen_random_uuid(), dst, v.visit_no, v.visit_date, v.bp_sys, v.bp_dia,
         v.weight_kg, v.hb, v.fundal_height_cm, v.fetal_hr, v.urine_albumin,
         v.danger_signs, v.ifa_taken, v.calcium_taken, v.tt_dose_given,
         v.recorded_by, v.source
    from public.anc_visits v where v.mother_id = src;

  -- The tables Thayi Setu actually reads. Without these her app opens empty,
  -- which is the failure this seed exists to avoid.
  insert into public.checkups
    (mother_id, visit_number, scheduled_on, location_kn, location_en,
     activity_ids, completed, weight_kg, systolic, diastolic,
     recorded_by_kn, recorded_by_en)
  select dst, c.visit_number, c.scheduled_on, c.location_kn, c.location_en,
         c.activity_ids, c.completed, c.weight_kg, c.systolic, c.diastolic,
         c.recorded_by_kn, c.recorded_by_en
    from public.checkups c where c.mother_id = src;

  insert into public.weight_entries (mother_id, week, kg)
  select dst, w.week, w.kg from public.weight_entries w where w.mother_id = src;

  insert into public.bp_entries (mother_id, week, systolic, diastolic)
  select dst, b.week, b.systolic, b.diastolic
    from public.bp_entries b where b.mother_id = src;

  insert into public.tt_doses (mother_id, dose_number, given, given_on)
  select dst, t.dose_number, t.given, t.given_on
    from public.tt_doses t where t.mother_id = src;

  insert into public.baby_vaccines
    (mother_id, vaccine_id, age_id, given, sort_order)
  select dst, v.vaccine_id, v.age_id, v.given, v.sort_order
    from public.baby_vaccines v where v.mother_id = src;

  insert into public.labs (mother_id, type, value, unit, result_date, ordered_by)
  select dst, l.type, l.value, l.unit, l.result_date, l.ordered_by
    from public.labs l where l.mother_id = src;

  -- Consent, so the doctor can open her without a request during the demo.
  insert into public.access_grants
    (mother_id, staff_id, status, method, reason, requested_at, decided_at, expires_at)
  select dst, s.id, 'approved', 'request', 'Routine antenatal review',
         now() - interval '2 days', now() - interval '2 days',
         now() + interval '28 days'
    from public.staff s where s.role = 'doctor';

  -- If she has already used this address anywhere, attach it now; otherwise
  -- the trigger on auth.users does it the first time she signs in.
  update public.mothers m set auth_user_id = u.id
    from auth.users u
   where m.id = dst and lower(u.email) = lower(addr);
end $$;
