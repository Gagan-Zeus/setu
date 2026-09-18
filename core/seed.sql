-- Setu — one canonical caseload for the whole platform.
--
-- 25 mothers across 4 villages, 4 ASHA workers and 1 medical officer. The
-- three existing Thayi accounts keep their records; the other 22 mothers are
-- added around them. After this, all three apps read the same rows.
--
-- Safe to re-run: it upserts by natural key and never duplicates.

do $$
declare
  v_phc      uuid;
  v_sub      text;
  r          record;
  v_mother   uuid;
  v_asha     uuid;
  v_today    date := current_date;
  v_visit    uuid;
  v_no       int;
  v_week     int;
  v_sys      int;
  v_dia      int;
  v_hb       numeric;
  v_signs    text[];
begin

  select id into v_phc from public.health_centres
    where name_en = 'Government PHC, Hosahalli' limit 1;

  -- ---------------------------------------------------------- staff logins
  alter table public.staff add column if not exists email text unique;

  insert into public.staff (role, name, email, phone, facility, sub_centre)
  values
    ('doctor', 'Dr. Sridevi R', 'sridevi@phc.kar.gov.in', '+918212345678',
     'PHC Hosahalli, Nanjangud Taluk', null),
    ('asha', 'Sarojamma',  'sarojamma@asha.gov.in',  '+919845012345',
     'PHC Hosahalli, Nanjangud Taluk', 'Hosahalli Sub-centre'),
    ('asha', 'Geethamma',  'geethamma@asha.gov.in',  '+919845067123',
     'PHC Hosahalli, Nanjangud Taluk', 'Kempanahalli Sub-centre'),
    ('asha', 'Sharadamma', 'sharadamma@asha.gov.in', '+919845098456',
     'PHC Hosahalli, Nanjangud Taluk', 'Madapura Sub-centre'),
    ('asha', 'Nagarathna', 'nagarathna@asha.gov.in', '+919845033210',
     'PHC Hosahalli, Nanjangud Taluk', 'Beedanahalli Sub-centre')
  on conflict (email) do update
    set role = excluded.role, name = excluded.name,
        sub_centre = excluded.sub_centre, facility = excluded.facility;

  -- Link any staff whose auth user already exists.
  update public.staff s
     set auth_user_id = u.id
    from auth.users u
   where lower(u.email) = lower(s.email) and s.auth_user_id is null;

  -- ------------------------------------------------------- asha_workers
  insert into public.asha_workers (name_kn, name_en, phone, sub_centre_kn, sub_centre_en, village)
  values
    ('ಸರೋಜಮ್ಮ','Sarojamma','+919845012345','ಹೊಸಳ್ಳಿ ಉಪ ಕೇಂದ್ರ','Hosahalli Sub-centre','Hosahalli'),
    ('ಗೀತಮ್ಮ','Geethamma','+919845067123','ಕೆಂಪನಹಳ್ಳಿ ಉಪ ಕೇಂದ್ರ','Kempanahalli Sub-centre','Kempanahalli'),
    ('ಶಾರದಮ್ಮ','Sharadamma','+919845098456','ಮಾದಾಪುರ ಉಪ ಕೇಂದ್ರ','Madapura Sub-centre','Madapura'),
    ('ನಾಗರತ್ನ','Nagarathna','+919845033210','ಬೀಡನಹಳ್ಳಿ ಉಪ ಕೇಂದ್ರ','Beedanahalli Sub-centre','Beedanahalli')
  on conflict do nothing;

  -- Collapse any duplicate workers left by earlier seeds: keep the oldest of
  -- each name and point everything at it.
  update public.asha_workers a set village =
    case a.name_en when 'Sarojamma' then 'Hosahalli'
                   when 'Geethamma' then 'Kempanahalli'
                   when 'Sharadamma' then 'Madapura'
                   when 'Nagarathna' then 'Beedanahalli' else a.village end
   where a.village is null;

  update public.asha_workers a set staff_id = s.id
    from public.staff s where s.name = a.name_en and a.staff_id is null;

  -- ------------------------------------------------------------ mothers
  for r in
    select * from (values
      -- name, age, husband, village, weeks, gravida, para, blood, bpl, risk, reasons
      ('Parvathi',31,'Shivanna','Kempanahalli',34,3,2,'A+',true,'red',
       array['BP 166/112 at last visit','Headache reported']),
      ('Sharada',19,'Kumara','Madapura',28,1,0,'O-',true,'red',
       array['Haemoglobin 6.4 g/dL']),
      ('Manjula',36,'Srinivas','Hosahalli',36,5,4,'A-',true,'red',
       array['Previous caesarean and PPH','BP 148/96']),
      ('Kamalamma',33,'Devaraj','Beedanahalli',31,4,3,'B+',true,'red',
       array['Reduced fetal movement reported']),
      ('Ratnamma',34,'Nagaraj','Madapura',12,4,3,'AB+',true,'amber',
       array['Age 34 with gravida 4']),
      ('Kavita',17,'Satish','Madapura',20,1,0,'A+',true,'amber',
       array['Age under 18']),
      ('Anasuya',25,'Ravi','Kempanahalli',30,2,1,'B+',true,'amber',
       array['Haemoglobin 8.6 g/dL']),
      ('Jayamma',33,'Chandrashekar','Beedanahalli',24,4,3,'A+',true,'amber',
       array['Previous stillbirth']),
      ('Yashoda',35,'Eshwar','Beedanahalli',33,3,2,'A+',true,'amber',
       array['Age 35']),
      ('Lalitha',29,'Basavaraj','Hosahalli',26,2,1,'O+',false,'amber',
       array['No visit in 34 days']),
      ('Lakshmi',24,'Manjunatha','Hosahalli',32,1,0,'B+',true,'green',array[]::text[]),
      ('Suma',23,'Ramesh','Hosahalli',22,2,1,'O+',true,'green',array[]::text[]),
      ('Geeta',27,'Basavaraju','Kempanahalli',18,2,1,'B+',false,'green',array[]::text[]),
      ('Nagarathna',22,'Prakash','Beedanahalli',8,1,0,'O+',false,'green',array[]::text[]),
      ('Saraswati',29,'Mahesh','Beedanahalli',26,2,1,'B-',true,'green',array[]::text[]),
      ('Pushpa',30,'Govinda','Hosahalli',14,3,2,'O+',false,'green',array[]::text[]),
      ('Renuka',21,'Harish','Madapura',16,1,0,'O+',false,'green',array[]::text[]),
      ('Shobha',28,'Venkatesh','Hosahalli',38,2,1,'AB-',true,'green',array[]::text[]),
      ('Bhagya',26,'Suresh','Kempanahalli',10,2,1,'B+',true,'green',array[]::text[]),
      ('Chandramma',24,'Lokesh','Madapura',6,1,0,'O+',true,'green',array[]::text[]),
      ('Vijaya',32,'Manju','Hosahalli',29,3,2,'B+',false,'green',array[]::text[]),
      ('Savita',20,'Ashok','Kempanahalli',21,1,0,'A-',true,'green',array[]::text[]),
      ('Pallavi',22,'Kiran','Madapura',36,1,0,'A+',true,'green',array[]::text[]),
      ('Roopa',26,'Ganesh','Beedanahalli',19,2,1,'O+',false,'green',array[]::text[]),
      ('Ambika',31,'Naveen','Kempanahalli',27,3,2,'AB+',true,'green',array[]::text[])
    ) as t(name,age,husband,village,weeks,gravida,para,blood,bpl,risk,reasons)
  loop
    select id, sub_centre_en into v_asha, v_sub
      from public.asha_workers where village = r.village
      order by created_at limit 1;

    select id into v_mother from public.mothers where name_en = r.name limit 1;

    if v_mother is null then
      insert into public.mothers (
        qr_token, thayi_card_number, name_kn, name_en, age,
        guardian_kn, guardian_en, village_kn, village_en,
        district_kn, district_en, blood_group, lmp,
        is_bpl, delivery_number, plans_institutional_delivery, has_bank_account,
        gravida, para, sub_centre, asha_worker_id, phc_id,
        risk_level, risk_reasons, asha_id
      ) values (
        substr(md5(random()::text), 1, 12),
        'KA-MYS-2026-' || lpad((6000 + floor(random()*3000))::int::text, 6, '0'),
        r.name, r.name, r.age, r.husband, r.husband,
        r.village, r.village, 'ಮೈಸೂರು', 'Mysuru', r.blood,
        v_today - (r.weeks * 7),
        r.bpl, r.para + 1, true, true,
        r.gravida, r.para, v_sub, v_asha, v_phc,
        r.risk, r.reasons, v_asha
      ) returning id into v_mother;
    else
      -- Existing Thayi records keep their auth link and card number.
      update public.mothers set
        age = r.age, village_en = r.village, blood_group = r.blood,
        lmp = v_today - (r.weeks * 7), gravida = r.gravida, para = r.para,
        sub_centre = v_sub, asha_worker_id = v_asha, asha_id = v_asha,
        risk_level = r.risk, risk_reasons = r.reasons
      where id = v_mother;
    end if;

    -- --------------------------------------------------------- anc_visits
    delete from public.anc_visits where mother_id = v_mother;
    v_no := 0;
    v_week := 8;
    while v_week <= r.weeks loop
      v_no := v_no + 1;
      v_sys := 108 + (v_no * 3) % 12;
      v_dia := 68 + (v_no * 2) % 10;
      v_hb  := 10.2 + ((v_no * 7) % 15) / 10.0;
      v_signs := array[]::text[];

      -- The last visit carries the readings that justify the risk flag.
      if v_week + 6 > r.weeks then
        if r.name = 'Parvathi' then
          v_sys := 166; v_dia := 112; v_signs := array['headache'];
        elsif r.name = 'Sharada' then v_hb := 6.4;
        elsif r.name = 'Manjula' then
          v_sys := 148; v_dia := 96; v_signs := array['swelling'];
        elsif r.name = 'Kamalamma' then v_signs := array['reducedFetalMovement'];
        elsif r.name = 'Anasuya' then v_hb := 8.6;
        end if;
      end if;

      insert into public.anc_visits (
        mother_id, visit_no, visit_date, bp_sys, bp_dia, weight_kg,
        fundal_height_cm, hb, urine_albumin, fetal_hr, fetal_movement,
        danger_signs, ifa_taken, calcium_taken, recorded_by, source
      ) values (
        v_mother, v_no, v_today - ((r.weeks - v_week) * 7),
        v_sys, v_dia, 46 + v_week * 0.32,
        least(v_week, 40), v_hb, 'nil', 132 + (v_no % 8),
        not ('reducedFetalMovement' = any(v_signs)),
        v_signs, true, v_no % 2 = 0,
        (select name_en from public.asha_workers where id = v_asha), 'asha'
      ) returning id into v_visit;

      v_week := v_week + 6;
    end loop;

    update public.mothers
       set last_visit_date = (select max(visit_date) from public.anc_visits
                               where mother_id = v_mother)
     where id = v_mother;
  end loop;

  -- ------------------------------------------------------------- tasks
  delete from public.tasks;
  insert into public.tasks (mother_id, created_by, assigned_to_asha_id,
                            assigned_to_asha_name, type, instruction_kn,
                            instruction_en, due_date, priority, status, origin)
  select m.id, 'Dr. Sridevi R', m.asha_worker_id, a.name_en, t.type,
         t.kn, t.en, v_today + t.due, t.pri, t.st, 'doctor'
    from (values
      ('Parvathi','recheckBp',
       'ರಕ್ತದೊತ್ತಡ ಮತ್ತೆ ಪರೀಕ್ಷಿಸಿ. 160/110 ಕ್ಕಿಂತ ಹೆಚ್ಚಿದ್ದರೆ ತಕ್ಷಣ ಕಳುಹಿಸಿ.',
       'Recheck her blood pressure. If it is above 160/110, refer at once.',
       0,'high','open'),
      ('Sharada','bringToPhc',
       'ಹಿಮೋಗ್ಲೋಬಿನ್ 6.4 — ಕಬ್ಬಿಣಾಂಶದ ಚುಚ್ಚುಮದ್ದಿಗೆ ಪಿಎಚ್‌ಸಿಗೆ ಕರೆತನ್ನಿ.',
       'Haemoglobin is 6.4 — bring her to the PHC for iron injection.',
       1,'high','open'),
      ('Kavita','counselling',
       'ವಯಸ್ಸು 17 — ಪೌಷ್ಟಿಕ ಆಹಾರದ ಬಗ್ಗೆ ಮಾತನಾಡಿ.',
       'She is 17 — talk to her about nutrition.', 2,'normal','open'),
      ('Lalitha','revisit',
       '34 ದಿನಗಳಿಂದ ಭೇಟಿ ಇಲ್ಲ. ಮನೆ ಭೇಟಿ ಬಾಕಿ.',
       'No visit in 34 days. Home visit due.', -3,'normal','open'),
      ('Anasuya','confirmMedication',
       'ಕಬ್ಬಿಣಾಂಶದ ಮಾತ್ರೆ ತೆಗೆದುಕೊಳ್ಳುತ್ತಿದ್ದಾರೆಯೇ ಖಚಿತಪಡಿಸಿ.',
       'Confirm she is taking her IFA tablets daily.', -8,'normal','missed')
    ) as t(name,type,kn,en,due,pri,st)
    join public.mothers m on m.name_en = t.name
    left join public.asha_workers a on a.id = m.asha_worker_id;

  -- --------------------------------------------------------- referrals
  delete from public.referrals;
  insert into public.referrals (mother_id, from_user, to_facility, reason_kn,
                                reason_en, status)
  select m.id, a.name_en, t.fac, t.en, t.en, t.st
    from (values
      ('Parvathi','Taluk Government Hospital, Nanjangud',
       'BP 166/112 with headache — suspected pre-eclampsia','open'),
      ('Sharada','District Hospital, Mysuru',
       'Severe anaemia, haemoglobin 6.4 g/dL','arrived'),
      ('Manjula','Taluk Government Hospital, Nanjangud',
       'Previous caesarean with raised BP','open'),
      ('Kamalamma','District Hospital, Mysuru','Reduced fetal movement','closed')
    ) as t(name,fac,en,st)
    join public.mothers m on m.name_en = t.name
    left join public.asha_workers a on a.id = m.asha_worker_id;

  raise notice 'Seeded % mothers', (select count(*) from public.mothers);
end $$;
