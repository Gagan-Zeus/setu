-- A third complete demo record, linked to dhrruwa.work@gmail.com.
--
-- Deliberately the low-risk case: no risk flags, no overdue checkup, further
-- along than the other two. Between the three accounts the app can be shown in
-- its green, amber and red states without editing anything.
--
-- Dates are relative to the day you run this: she is 36 weeks pregnant.

do $$
declare
  v_phc      uuid;
  v_taluk    uuid;
  v_asha     uuid;
  v_mother   uuid;
  v_user     uuid;
  v_today    date := current_date;
begin

  select id into v_user from auth.users where email = 'dhrruwa.work@gmail.com';
  if v_user is null then
    raise exception 'No auth user for dhrruwa.work@gmail.com — sign in once first.';
  end if;

  select id into v_phc from public.health_centres
    where name_en = 'Government PHC, Hosahalli' limit 1;
  select id into v_taluk from public.health_centres
    where name_en = 'Taluk Government Hospital, Nanjangud' limit 1;

  insert into public.asha_workers (name_kn, name_en, phone, sub_centre_kn, sub_centre_en)
  values ('ಶಾರದಮ್ಮ', 'Sharadamma', '+919845098456',
          'ಮಾದಾಪುರ ಉಪ ಕೇಂದ್ರ', 'Madapura Sub-centre')
  returning id into v_asha;

  insert into public.mothers (
    auth_user_id, qr_token, thayi_card_number, name_kn, name_en, age,
    guardian_kn, guardian_en, village_kn, village_en, district_kn, district_en,
    blood_group, lmp, risk_flag_ids, allergy_ids,
    is_bpl, delivery_number, plans_institutional_delivery, has_bank_account,
    asha_id, phc_id
  ) values (
    v_user, 'q3Vb8Hn5Tj1R', 'KA-MYS-2026-005744', 'ಪಲ್ಲವಿ', 'Pallavi', 22,
    'ಕಿರಣ', 'Kiran', 'ಮಾದಾಪುರ', 'Madapura', 'ಮೈಸೂರು', 'Mysuru',
    'A+', v_today - 252, array[]::text[], array[]::text[],
    true, 1, true, true,
    v_asha, v_phc
  ) returning id into v_mother;

  insert into public.checkups (mother_id, visit_number, scheduled_on, location_kn, location_en,
                               activity_ids, completed, weight_kg, systolic, diastolic,
                               recorded_by_kn, recorded_by_en)
  values
    (v_mother, 1, v_today - 196, 'ಸರ್ಕಾರಿ ಪ್ರಾಥಮಿಕ ಆರೋಗ್ಯ ಕೇಂದ್ರ, ಹೊಸಳ್ಳಿ', 'Government PHC, Hosahalli',
     array['weightBp','bloodTest','urineTest','ifaTablets'], true, 46.8, 110, 70, 'ಶಾರದಮ್ಮ', 'Sharadamma'),
    (v_mother, 2, v_today - 154, 'ಸರ್ಕಾರಿ ಪ್ರಾಥಮಿಕ ಆರೋಗ್ಯ ಕೇಂದ್ರ, ಹೊಸಳ್ಳಿ', 'Government PHC, Hosahalli',
     array['weightBp','scan','ttVaccine'], true, 49.6, 112, 72, 'ಡಾ. ಶ್ರೀದೇವಿ', 'Dr. Sridevi'),
    (v_mother, 3, v_today - 98, 'ಸರ್ಕಾರಿ ಪ್ರಾಥಮಿಕ ಆರೋಗ್ಯ ಕೇಂದ್ರ, ಹೊಸಳ್ಳಿ', 'Government PHC, Hosahalli',
     array['weightBp','babyHeartbeat','bloodTest'], true, 53.2, 114, 74, 'ಶಾರದಮ್ಮ', 'Sharadamma'),
    (v_mother, 4, v_today - 42, 'ಸರ್ಕಾರಿ ಪ್ರಾಥಮಿಕ ಆರೋಗ್ಯ ಕೇಂದ್ರ, ಹೊಸಳ್ಳಿ', 'Government PHC, Hosahalli',
     array['weightBp','urineTest','babyHeartbeat'], true, 56.9, 116, 74, 'ಶಾರದಮ್ಮ', 'Sharadamma'),
    -- Nothing overdue: this is the account that shows the calm, green state.
    (v_mother, 5, v_today + 7, 'ತಾಲ್ಲೂಕು ಸರ್ಕಾರಿ ಆಸ್ಪತ್ರೆ, ನಂಜನಗೂಡು', 'Taluk Government Hospital, Nanjangud',
     array['weightBp','scan','deliveryPlanning'], false, null, null, null, null, null),
    (v_mother, 6, v_today + 21, 'ಸರ್ಕಾರಿ ಪ್ರಾಥಮಿಕ ಆರೋಗ್ಯ ಕೇಂದ್ರ, ಹೊಸಳ್ಳಿ', 'Government PHC, Hosahalli',
     array['weightBp','generalCheck','deliveryPlanning'], false, null, null, null, null, null);

  insert into public.weight_entries (mother_id, week, kg) values
    (v_mother, 8, 46.8), (v_mother, 14, 49.6), (v_mother, 22, 53.2),
    (v_mother, 30, 56.9), (v_mother, 34, 58.4);

  insert into public.bp_entries (mother_id, week, systolic, diastolic) values
    (v_mother, 8, 110, 70), (v_mother, 14, 112, 72), (v_mother, 22, 114, 74),
    (v_mother, 30, 116, 74), (v_mother, 34, 118, 76);

  insert into public.tt_doses (mother_id, dose_number, given, given_on) values
    (v_mother, 1, true, v_today - 168),
    (v_mother, 2, true, v_today - 140);

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

  raise notice 'Seeded mother % for dhrruwa.work@gmail.com', v_mother;
end $$;
