-- Setu Admin Portal — seed data.
--
-- One district, two PHCs, a handful of villages, and two sandbox mothers for
-- partner integration testing. Safe to re-run: everything upserts on a natural
-- key and nothing here deletes.
--
-- The demo caseload in core/demo_dataset.sql is separate and still owns the
-- real-looking clinical data. This file only adds the structures the portal
-- needs and the fake mothers a sandbox key is allowed to resolve.

begin;

-- ---------------------------------------------------------------- district
insert into public.districts (name, name_kn, state)
values ('Hassan', 'ಹಾಸನ', 'Karnataka')
on conflict (name, state) do nothing;

-- ------------------------------------------------------------------- PHCs
do $$
declare d_hassan uuid;
begin
  select id into d_hassan from public.districts
   where name = 'Hassan' and state = 'Karnataka';

  -- health_centres has no natural unique key, so match on the English name.
  if not exists (select 1 from public.health_centres
                  where lower(name_en) = lower('Halebeedu Primary Health Centre')) then
    insert into public.health_centres
      (name_en, name_kn, phone, latitude, longitude, district_id, contact_name, address)
    values ('Halebeedu Primary Health Centre', 'ಹಳೇಬೀಡು ಪ್ರಾಥಮಿಕ ಆರೋಗ್ಯ ಕೇಂದ್ರ',
            '+91 81772 20101', 13.2137, 75.9946, d_hassan,
            'Dr. Dhrruwa H L', 'Halebeedu, Belur Taluk, Hassan');
  else
    update public.health_centres
       set district_id = coalesce(district_id, d_hassan)
     where lower(name_en) = lower('Halebeedu Primary Health Centre');
  end if;

  if not exists (select 1 from public.health_centres
                  where lower(name_en) = lower('Konanur Primary Health Centre')) then
    insert into public.health_centres
      (name_en, name_kn, phone, latitude, longitude, district_id, contact_name, address)
    values ('Konanur Primary Health Centre', 'ಕೊಣನೂರು ಪ್ರಾಥಮಿಕ ಆರೋಗ್ಯ ಕೇಂದ್ರ',
            '+91 81772 20202', 12.6389, 76.0631, d_hassan,
            null, 'Konanur, Arkalgud Taluk, Hassan');
  else
    update public.health_centres
       set district_id = coalesce(district_id, d_hassan)
     where lower(name_en) = lower('Konanur Primary Health Centre');
  end if;
end $$;

-- --------------------------------------------------------------- villages
do $$
declare
  d_hassan uuid;
  phc_h    uuid;
  phc_k    uuid;
  v        record;
begin
  select id into d_hassan from public.districts where name = 'Hassan';
  select id into phc_h from public.health_centres
   where lower(name_en) = lower('Halebeedu Primary Health Centre');
  select id into phc_k from public.health_centres
   where lower(name_en) = lower('Konanur Primary Health Centre');

  for v in
    select * from (values
      ('Halebeedu',   'ಹಳೇಬೀಡು',     phc_h, 4200),
      ('Belur Road',  'ಬೇಲೂರು ರಸ್ತೆ', phc_h, 1800),
      ('Adagur',      'ಅಡಗೂರು',      phc_h, 2600),
      ('Konanur',     'ಕೊಣನೂರು',     phc_k, 5100),
      ('Ramanathpura','ರಾಮನಾಥಪುರ',   phc_k, 3300)
    ) as t(name, name_kn, phc_id, pop)
  loop
    if not exists (select 1 from public.villages
                    where phc_id = v.phc_id and lower(name) = lower(v.name)) then
      insert into public.villages (name, name_kn, phc_id, district_id, population_estimate)
      values (v.name, v.name_kn, v.phc_id, d_hassan, v.pop);
    end if;
  end loop;
end $$;

-- ------------------------------------------------ link existing staff to PHCs
update public.staff s
   set phc_id      = hc.id,
       district_id = hc.district_id
  from public.health_centres hc
 where s.phc_id is null
   and lower(s.facility) = lower(hc.name_en);

-- ----------------------------------------------------- the first super_admin
-- Seeded without auth_user_id. The trigger in 0001 attaches it the first time
-- that address signs in, so no password is set here and none is known.
insert into public.admin_users (full_name, email, role)
values ('Setu Platform Admin', 'dhrruwa@gmail.com', 'super_admin')
on conflict (email) do nothing;

-- ------------------------------------------------------- sandbox mothers
-- What a sandbox API key is allowed to resolve, and the only thing it can.
-- Obviously fake names and a reserved-for-documentation phone range, so that
-- a sandbox response appearing in a partner's production logs is recognisable
-- at a glance as test data.
do $$
declare
  phc_h uuid;
  asha  uuid;
begin
  select id into phc_h from public.health_centres
   where lower(name_en) = lower('Halebeedu Primary Health Centre');
  select id into asha from public.asha_workers order by created_at limit 1;

  if not exists (select 1 from public.mothers where thayi_card_number = 'sandbox-001') then
    insert into public.mothers
      (thayi_card_number, qr_token, name_en, name_kn, age, guardian_en, phone,
       village_en, village_kn, district_en, district_kn, sub_centre, lmp,
       gravida, para, delivery_number, blood_group, height_cm, is_bpl,
       risk_level, risk_reasons, phc_id, asha_worker_id, asha_id,
       is_sandbox, active)
    values ('sandbox-001', encode(gen_random_bytes(12), 'hex'),
            'SANDBOX Test Mother One', 'ಪರೀಕ್ಷಾ ತಾಯಿ ೧', 26, 'Test Guardian',
            '+91 90000 00001', 'Halebeedu', 'ಹಳೇಬೀಡು', 'Hassan', 'ಹಾಸನ',
            'Halebeedu Sub-Centre', current_date - interval '217 days',
            2, 1, 2, 'O+', 158, false,
            'amber', '{"Blood pressure rising over the last two visits"}',
            phc_h, asha, asha, true, true);
  end if;

  if not exists (select 1 from public.mothers where thayi_card_number = 'sandbox-002') then
    insert into public.mothers
      (thayi_card_number, qr_token, name_en, name_kn, age, guardian_en, phone,
       village_en, village_kn, district_en, district_kn, sub_centre, lmp,
       gravida, para, delivery_number, blood_group, height_cm, is_bpl,
       risk_level, risk_reasons, phc_id, asha_worker_id, asha_id,
       is_sandbox, active)
    values ('sandbox-002', encode(gen_random_bytes(12), 'hex'),
            'SANDBOX Test Mother Two', 'ಪರೀಕ್ಷಾ ತಾಯಿ ೨', 31, 'Test Guardian',
            '+91 90000 00002', 'Konanur', 'ಕೊಣನೂರು', 'Hassan', 'ಹಾಸನ',
            'Konanur Sub-Centre', current_date - interval '154 days',
            1, 0, 1, 'B+', 152, true,
            'green', '{}', phc_h, asha, asha, true, true);
  end if;
end $$;

-- Nothing seeded above may be mistaken for a real record.
do $$
declare bad int;
begin
  select count(*) into bad from public.mothers
   where is_sandbox and name_en not like 'SANDBOX %';
  if bad > 0 then
    raise exception 'A sandbox mother is not named as one (% row(s))', bad;
  end if;
end $$;

commit;
