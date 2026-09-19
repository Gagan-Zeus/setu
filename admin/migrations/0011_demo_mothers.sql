-- Setu — ten mothers, in the database rather than in the app.
--
-- The ASHA app used to carry an invented caseload of twenty women in Dart
-- (asha/lib/data/seed_data.dart), written into the handset's own SQLite the
-- first time it ran. They were never on the server, so the website and the app
-- disagreed permanently: the portal showed the mothers who existed and the
-- phone showed twenty who did not. Anything a worker did to one of them went
-- nowhere, and a mother registered for real sat in a list of strangers.
--
-- These ten live here instead, so there is exactly one place a mother can come
-- from and every app reads the same rows. They are invented, but they are
-- shaped like a real sub-centre caseload rather than ten variations of one
-- person: gestation spread from the first trimester to term, two carrying red
-- flags and three amber, a range of gravida/para, a mix of BPL and not, and
-- four villages. A caseload where nothing is ever wrong exercises nothing.
--
-- They are attached to whichever ASHA and PHC actually exist, looked up by
-- name, so this does not hard-code an id that differs per project. Re-running
-- is safe: thayi_card_number is unique and every insert is guarded by it.

do $$
declare
  v_asha    uuid;
  v_sub     text;
  v_phc     uuid;
  v_dist_en text;
  v_dist_kn text;
begin
  -- The sub-centre is the thing that matters: Row Level Security scopes an
  -- ASHA to `sub_centre = current_sub_centre()`, so a mother filed under any
  -- other one is a mother the worker cannot open.
  select a.id, a.sub_centre_en into v_asha, v_sub
    from public.asha_workers a
    join public.staff s on s.id = a.staff_id
   where s.role = 'asha'
   order by a.created_at
   limit 1;

  if v_asha is null then
    -- No ASHA registered yet. Seeding mothers nobody can see would be worse
    -- than seeding none, so this stops and says so.
    raise notice 'no ASHA worker on file — no mothers seeded. Register one in the admin portal first.';
    return;
  end if;

  select hc.id, d.name, d.name_kn into v_phc, v_dist_en, v_dist_kn
    from public.health_centres hc
    left join public.districts d on d.id = hc.district_id
   order by hc.created_at
   limit 1;

  insert into public.mothers (
    id, thayi_card_number, qr_token,
    name_en, name_kn, age, phone,
    village_en, village_kn, district_en, district_kn, phc_id,
    sub_centre, asha_worker_id,
    lmp, gravida, para, delivery_number,
    blood_group, height_cm, is_bpl,
    risk_level, prev_complications,
    plans_institutional_delivery, has_bank_account,
    email_verified, active, is_sandbox
  )
  select
    gen_random_uuid(), m.card, m.qr,
    m.name_en, m.name_kn, m.age, m.phone,
    m.village_en, m.village_kn, v_dist_en, v_dist_kn, v_phc,
    v_sub, v_asha,
    -- Gestation is stated in weeks, so the caseload stays spread out however
    -- long after this migration the project is first opened.
    (current_date - (m.weeks * 7))::date,
    m.gravida, m.para, m.para + 1,
    m.blood, m.height, m.bpl,
    m.risk, m.complications,
    m.inst, m.bank,
    false, true, false
  from (values
    -- card,         qr,           name_en,        name_kn,           age, phone,             village_en,    village_kn,     wk, gr, pa, blood, height, bpl,   risk,    previous complications,  inst,  bank
    ('TC-2026-0101','qr26tc0101','Lakshmi Devi', 'ಲಕ್ಷ್ಮಿ ದೇವಿ',      24, '+91 90080 11201','Taverekere',   'ತಾವರೆಕೆರೆ',    32,  1,  0, 'B+',  152.0, true,  'green', '{}'::text[],             true,  true),
    ('TC-2026-0102','qr26tc0102','Suma R',       'ಸುಮಾ ಆರ್',          23, '+91 90080 11202','Taverekere',   'ತಾವರೆಕೆರೆ',    22,  2,  1, 'O+',  158.0, true,  'green', '{}'::text[],             true,  true),
    -- Red: hypertension in a previous pregnancy, and she is near term.
    ('TC-2026-0103','qr26tc0103','Parvathi S',   'ಪಾರ್ವತಿ ಎಸ್',        31, '+91 90080 11203','Kempanahalli','ಕೆಂಪನಹಳ್ಳಿ',   34,  3,  2, 'A+',  149.0, true,  'red',   '{hypertension}'::text[], true,  true),
    ('TC-2026-0104','qr26tc0104','Nagaratna B',  'ನಾಗರತ್ನ ಬಿ',        27, '+91 90080 11204','Kempanahalli','ಕೆಂಪನಹಳ್ಳಿ',   12,  1,  0, 'AB+', 161.0, false, 'green', '{}'::text[],             true,  true),
    -- Amber: a previous C-section, so this delivery has to be planned.
    ('TC-2026-0105','qr26tc0105','Shobha M',     'ಶೋಭಾ ಎಂ',           29, '+91 90080 11205','Hulimavu',    'ಹುಳಿಮಾವು',     28,  2,  1, 'O-',  155.0, true,  'amber', '{cSection}'::text[],     true,  false),
    ('TC-2026-0106','qr26tc0106','Roopa K',      'ರೂಪಾ ಕೆ',           21, '+91 90080 11206','Hulimavu',    'ಹುಳಿಮಾವು',      8,  1,  0, 'B+',  157.0, true,  'green', '{}'::text[],             true,  true),
    -- Amber: anaemic last pregnancy, and a short interval since.
    ('TC-2026-0107','qr26tc0107','Jayamma T',    'ಜಯಮ್ಮ ಟಿ',          34, '+91 90080 11207','Bommasandra', 'ಬೊಮ್ಮಸಂದ್ರ',   19,  4,  3, 'A-',  147.0, true,  'amber', '{anaemia}'::text[],      false, true),
    ('TC-2026-0108','qr26tc0108','Kavitha N',    'ಕವಿತಾ ಎನ್',          26, '+91 90080 11208','Bommasandra', 'ಬೊಮ್ಮಸಂದ್ರ',   25,  2,  1, 'O+',  160.0, false, 'green', '{}'::text[],             true,  true),
    -- Red: a stillbirth in her history. She is the one the doctor should see.
    ('TC-2026-0109','qr26tc0109','Mangala Gowri','ಮಂಗಳ ಗೌರಿ',         36, '+91 90080 11209','Taverekere',  'ತಾವರೆಕೆರೆ',    36,  3,  1, 'B-',  151.0, true,  'red',   '{stillbirth}'::text[],   true,  true),
    -- Amber: gestational diabetes last time, first visit still ahead of her.
    ('TC-2026-0110','qr26tc0110','Asha Rani',    'ಆಶಾ ರಾಣಿ',          30, '+91 90080 11210','Hulimavu',    'ಹುಳಿಮಾವು',     15,  2,  1, 'AB-', 154.0, false, 'amber', '{gdm}'::text[],          true,  true)
  ) as m(card, qr, name_en, name_kn, age, phone, village_en, village_kn,
         weeks, gravida, para, blood, height, bpl, risk, complications, inst, bank)
  where not exists (
    select 1 from public.mothers x where x.thayi_card_number = m.card
  );

  raise notice 'demo mothers seeded into sub-centre %', v_sub;
end $$;
