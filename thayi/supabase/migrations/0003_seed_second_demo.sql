-- A second complete demo record, linked to dhrruwa@gmail.com.
--
-- Same shape as 0002_seed_demo.sql but a different woman, so two people can
-- sign in on two phones and each see their own record — which also proves RLS
-- is actually isolating rows rather than just returning everything.
--
-- Dates are relative to the day you run this: she is 24 weeks pregnant with
-- one overdue checkup.

do $$
declare
  v_phc      uuid;
  v_taluk    uuid;
  v_district uuid;
  v_asha     uuid;
  v_mother   uuid;
  v_user     uuid;
  v_today    date := current_date;
begin

  select id into v_user from auth.users where email = 'dhrruwa@gmail.com';
  if v_user is null then
    raise exception 'No auth user for dhrruwa@gmail.com — sign in once first.';
  end if;

  -- Reuse the facilities already seeded rather than duplicating them.
  select id into v_phc from public.health_centres
    where name_en = 'Government PHC, Hosahalli' limit 1;
  select id into v_taluk from public.health_centres
    where name_en = 'Taluk Government Hospital, Nanjangud' limit 1;
  select id into v_district from public.health_centres
    where name_en = 'District Hospital, Mysuru' limit 1;

  -- A different ASHA worker, so the two records are visibly distinct.
  insert into public.asha_workers (name_kn, name_en, phone, sub_centre_kn, sub_centre_en)
  values ('ಗೀತಮ್ಮ', 'Geethamma', '+919845067123',
          'ಕೆಂಪನಹಳ್ಳಿ ಉಪ ಕೇಂದ್ರ', 'Kempanahalli Sub-centre')
  returning id into v_asha;

  insert into public.mothers (
    auth_user_id, qr_token, thayi_card_number, name_kn, name_en, age,
    guardian_kn, guardian_en, village_kn, village_en, district_kn, district_en,
    blood_group, lmp, risk_flag_ids, allergy_ids,
    is_bpl, delivery_number, plans_institutional_delivery, has_bank_account,
    asha_id, phc_id
  ) values (
    v_user, 'p7Wm4Yz2Nk8Q', 'KA-MYS-2026-005219', 'ಸುಮಾ', 'Suma', 27,
    'ರಮೇಶ', 'Ramesh', 'ಕೆಂಪನಹಳ್ಳಿ', 'Kempanahalli', 'ಮೈಸೂರು', 'Mysuru',
    'O+', v_today - 168, array['anaemia','highBp'], array[]::text[],
    true, 2, true, true,
    v_asha, v_phc
  ) returning id into v_mother;

  insert into public.checkups (mother_id, visit_number, scheduled_on, location_kn, location_en,
                               activity_ids, completed, weight_kg, systolic, diastolic,
                               recorded_by_kn, recorded_by_en)
  values
    (v_mother, 1, v_today - 126, 'ಸರ್ಕಾರಿ ಪ್ರಾಥಮಿಕ ಆರೋಗ್ಯ ಕೇಂದ್ರ, ಹೊಸಳ್ಳಿ', 'Government PHC, Hosahalli',
     array['weightBp','bloodTest','urineTest','ifaTablets'], true, 49.0, 118, 76, 'ಗೀತಮ್ಮ', 'Geethamma'),
    (v_mother, 2, v_today - 84, 'ಸರ್ಕಾರಿ ಪ್ರಾಥಮಿಕ ಆರೋಗ್ಯ ಕೇಂದ್ರ, ಹೊಸಳ್ಳಿ', 'Government PHC, Hosahalli',
     array['weightBp','scan','ttVaccine'], true, 52.5, 124, 80, 'ಡಾ. ಶ್ರೀದೇವಿ', 'Dr. Sridevi'),
    (v_mother, 3, v_today - 35, 'ಸರ್ಕಾರಿ ಪ್ರಾಥಮಿಕ ಆರೋಗ್ಯ ಕೇಂದ್ರ, ಹೊಸಳ್ಳಿ', 'Government PHC, Hosahalli',
     array['weightBp','babyHeartbeat','bloodTest'], true, 55.1, 132, 86, 'ಗೀತಮ್ಮ', 'Geethamma'),
    -- Overdue on purpose, so the amber state shows on this account too.
    (v_mother, 4, v_today - 3, 'ಸರ್ಕಾರಿ ಪ್ರಾಥಮಿಕ ಆರೋಗ್ಯ ಕೇಂದ್ರ, ಹೊಸಳ್ಳಿ', 'Government PHC, Hosahalli',
     array['weightBp','urineTest','babyHeartbeat'], false, null, null, null, null, null),
    (v_mother, 5, v_today + 21, 'ತಾಲ್ಲೂಕು ಸರ್ಕಾರಿ ಆಸ್ಪತ್ರೆ, ನಂಜನಗೂಡು', 'Taluk Government Hospital, Nanjangud',
     array['weightBp','scan','deliveryPlanning'], false, null, null, null, null, null),
    (v_mother, 6, v_today + 45, 'ಸರ್ಕಾರಿ ಪ್ರಾಥಮಿಕ ಆರೋಗ್ಯ ಕೇಂದ್ರ, ಹೊಸಳ್ಳಿ', 'Government PHC, Hosahalli',
     array['weightBp','generalCheck','deliveryPlanning'], false, null, null, null, null, null);

  insert into public.weight_entries (mother_id, week, kg) values
    (v_mother, 6, 49.0), (v_mother, 12, 50.4), (v_mother, 16, 52.5),
    (v_mother, 20, 54.0), (v_mother, 22, 55.1);

  insert into public.bp_entries (mother_id, week, systolic, diastolic) values
    (v_mother, 6, 118, 76), (v_mother, 12, 122, 78), (v_mother, 16, 124, 80),
    (v_mother, 20, 128, 84), (v_mother, 22, 132, 86);

  insert into public.tt_doses (mother_id, dose_number, given, given_on) values
    (v_mother, 1, true, v_today - 98),
    (v_mother, 2, false, null);

  insert into public.baby_vaccines (mother_id, vaccine_id, age_id, given, sort_order) values
    (v_mother, 'bcg',   'atBirth', false, 1),
    (v_mother, 'opv',   'atBirth', false, 2),
    (v_mother, 'hepB',  'atBirth', false, 3),
    (v_mother, 'penta', 'w6',      false, 4),
    (v_mother, 'opv',   'w6',      false, 5),
    (v_mother, 'rota',  'w6',      false, 6),
    (v_mother, 'penta', 'w10',     false, 7),
    (v_mother, 'opv',   'w10',     false, 8),
    (v_mother, 'penta', 'w14',     false, 9),
    (v_mother, 'opv',   'w14',     false, 10),
    (v_mother, 'mr',    'm9',      false, 11);

  raise notice 'Seeded mother % for dhrruwa@gmail.com', v_mother;
end $$;
