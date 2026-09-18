-- Thayi Setu — demo seed. Mirrors lib/data/mock_data.dart exactly, so the app
-- looks identical whether it is reading the mock repository or Supabase.
-- Dates are relative to the day you run this: she is 32 weeks pregnant and has
-- one overdue checkup.

do $$
declare
  v_phc      uuid;
  v_taluk    uuid;
  v_district uuid;
  v_asha     uuid;
  v_mother   uuid;
  v_today    date := current_date;
begin

  insert into public.health_centres (name_kn, name_en, phone, latitude, longitude)
  values ('ಸರ್ಕಾರಿ ಪ್ರಾಥಮಿಕ ಆರೋಗ್ಯ ಕೇಂದ್ರ, ಹೊಸಳ್ಳಿ', 'Government PHC, Hosahalli',
          '+918212345678', 12.2958, 76.6394)
  returning id into v_phc;

  insert into public.health_centres (name_kn, name_en, phone, latitude, longitude)
  values ('ತಾಲ್ಲೂಕು ಸರ್ಕಾರಿ ಆಸ್ಪತ್ರೆ, ನಂಜನಗೂಡು', 'Taluk Government Hospital, Nanjangud',
          '+918221223344', 12.1167, 76.6833)
  returning id into v_taluk;

  insert into public.health_centres (name_kn, name_en, phone, latitude, longitude)
  values ('ಜಿಲ್ಲಾ ಆಸ್ಪತ್ರೆ, ಮೈಸೂರು', 'District Hospital, Mysuru',
          '+918212423456', 12.3052, 76.6552)
  returning id into v_district;

  insert into public.asha_workers (name_kn, name_en, phone, sub_centre_kn, sub_centre_en)
  values ('ಸರೋಜಮ್ಮ', 'Sarojamma', '+919845012345',
          'ಹೊಸಳ್ಳಿ ಉಪ ಕೇಂದ್ರ', 'Hosahalli Sub-centre')
  returning id into v_asha;

  insert into public.mothers (
    qr_token, thayi_card_number, name_kn, name_en, age,
    guardian_kn, guardian_en, village_kn, village_en, district_kn, district_en,
    blood_group, lmp, risk_flag_ids, allergy_ids,
    is_bpl, delivery_number, plans_institutional_delivery, has_bank_account,
    asha_id, phc_id
  ) values (
    'k9Rt2Xq7Lm4P', 'KA-MYS-2026-004871', 'ಲಕ್ಷ್ಮಿ', 'Lakshmi', 24,
    'ಮಂಜುನಾಥ', 'Manjunatha', 'ಹೊಸಳ್ಳಿ', 'Hosahalli', 'ಮೈಸೂರು', 'Mysuru',
    'B+', v_today - 224, array['anaemia'], array[]::text[],
    true, 1, true, true,
    v_asha, v_phc
  ) returning id into v_mother;

  insert into public.checkups (mother_id, visit_number, scheduled_on, location_kn, location_en,
                               activity_ids, completed, weight_kg, systolic, diastolic,
                               recorded_by_kn, recorded_by_en)
  values
    (v_mother, 1, v_today - 154, 'ಸರ್ಕಾರಿ ಪ್ರಾಥಮಿಕ ಆರೋಗ್ಯ ಕೇಂದ್ರ, ಹೊಸಳ್ಳಿ', 'Government PHC, Hosahalli',
     array['weightBp','bloodTest','urineTest','ifaTablets'], true, 47.5, 112, 72, 'ಸರೋಜಮ್ಮ', 'Sarojamma'),
    (v_mother, 2, v_today - 98, 'ಸರ್ಕಾರಿ ಪ್ರಾಥಮಿಕ ಆರೋಗ್ಯ ಕೇಂದ್ರ, ಹೊಸಳ್ಳಿ', 'Government PHC, Hosahalli',
     array['weightBp','scan','ttVaccine'], true, 51.0, 118, 76, 'ಡಾ. ಶ್ರೀದೇವಿ', 'Dr. Sridevi'),
    (v_mother, 3, v_today - 42, 'ಸರ್ಕಾರಿ ಪ್ರಾಥಮಿಕ ಆರೋಗ್ಯ ಕೇಂದ್ರ, ಹೊಸಳ್ಳಿ', 'Government PHC, Hosahalli',
     array['weightBp','babyHeartbeat','bloodTest'], true, 54.2, 122, 78, 'ಸರೋಜಮ್ಮ', 'Sarojamma'),
    -- Overdue on purpose: the amber state has to be visible in the demo.
    (v_mother, 4, v_today - 5, 'ಸರ್ಕಾರಿ ಪ್ರಾಥಮಿಕ ಆರೋಗ್ಯ ಕೇಂದ್ರ, ಹೊಸಳ್ಳಿ', 'Government PHC, Hosahalli',
     array['weightBp','urineTest','babyHeartbeat'], false, null, null, null, null, null),
    (v_mother, 5, v_today + 16, 'ತಾಲ್ಲೂಕು ಸರ್ಕಾರಿ ಆಸ್ಪತ್ರೆ, ನಂಜನಗೂಡು', 'Taluk Government Hospital, Nanjangud',
     array['weightBp','scan','deliveryPlanning'], false, null, null, null, null, null),
    (v_mother, 6, v_today + 37, 'ಸರ್ಕಾರಿ ಪ್ರಾಥಮಿಕ ಆರೋಗ್ಯ ಕೇಂದ್ರ, ಹೊಸಳ್ಳಿ', 'Government PHC, Hosahalli',
     array['weightBp','generalCheck','deliveryPlanning'], false, null, null, null, null, null);

  insert into public.weight_entries (mother_id, week, kg) values
    (v_mother, 10, 47.5), (v_mother, 18, 51.0), (v_mother, 22, 52.6),
    (v_mother, 26, 54.2), (v_mother, 30, 56.4);

  insert into public.bp_entries (mother_id, week, systolic, diastolic) values
    (v_mother, 10, 112, 72), (v_mother, 18, 118, 76), (v_mother, 22, 116, 74),
    (v_mother, 26, 122, 78), (v_mother, 30, 126, 82);

  insert into public.tt_doses (mother_id, dose_number, given, given_on) values
    (v_mother, 1, true, v_today - 126),
    (v_mother, 2, true, v_today - 98);

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

  insert into public.schemes (id, document_ids, hospital_ids, sort_order) values
    ('thayiBhagya',    array['thayiCard','aadhaar','bplCard'],                                            array[v_taluk, v_district], 1),
    ('pmmvy',          array['thayiCard','aadhaar','husbandAadhaar','bankPassbook','mchRegistration'],    array[v_phc, v_taluk],      2),
    ('jsy',            array['thayiCard','aadhaar','bankPassbook','bplCard','deliveryProof'],             array[v_phc, v_taluk, v_district], 3),
    ('prasootiAraike', array['thayiCard','bplCard','bankPassbook'],                                       array[v_phc, v_taluk],      4),
    ('madilu',         array['thayiCard','bplCard','deliveryProof'],                                      array[v_taluk, v_district], 5),
    ('jssk',           array['thayiCard','aadhaar'],                                                      array[v_phc, v_taluk, v_district], 6);

  raise notice 'Demo mother id: %', v_mother;
end $$;

-- After the demo user signs in for the first time, link the record to them:
--
--   update public.mothers
--   set auth_user_id = (select id from auth.users where phone = '919845012345')
--   where thayi_card_number = 'KA-MYS-2026-004871';
--
-- Without this link, RLS correctly returns zero rows.
