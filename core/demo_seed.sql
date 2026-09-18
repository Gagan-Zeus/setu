-- Demo data for the eight real logins.
--
-- The point is that every screen in all three apps has something real on it:
-- labs to read, alerts to act on, tasks to do, and a house on a map to
-- navigate to. Everything is dated relative to today so the demo does not go
-- stale between runs.

-- ------------------------------------------------------ houses on the map
-- Scattered around Nanjangud taluk, Mysuru district, each within a few hundred
-- metres of its village centre, so the ASHA app's directions are believable.
update public.mothers m set
  home_lat = v.lat + (random() - 0.5) * 0.006,
  home_lng = v.lng + (random() - 0.5) * 0.006,
  home_note = v.note,
  home_located_at = now() - (random() * 60 || ' days')::interval
from (values
  ('Hosahalli',    12.1210, 76.6890, 'Third house past the temple, blue door'),
  ('Kempanahalli', 12.1585, 76.6415, 'Behind the anganwadi, near the well'),
  ('Madapura',     12.0865, 76.7240, 'Last lane by the canal, green gate'),
  ('Beedanahalli', 12.1440, 76.7605, 'Opposite the bus stop, coconut tree in front')
) as v(village, lat, lng, note)
where m.village_en = v.village and m.home_lat is null;

-- ------------------------------------------------------------ routine labs
-- The standard panel every pregnant woman gets at registration. Haemoglobin
-- is carried over from her most recent ANC visit rather than invented, so the
-- lab card and the visit history agree with each other.
insert into public.labs (mother_id, type, value, unit, result_date, ordered_by)
select m.id, 'Haemoglobin', v.hb::text, 'g/dL', v.visit_date, 'PHC Hosahalli'
from public.mothers m
join lateral (
  select hb, visit_date from public.anc_visits a
   where a.mother_id = m.id and a.hb is not null
   order by a.visit_date desc limit 1
) v on true
where not exists (select 1 from public.labs l
                   where l.mother_id = m.id and l.type = 'Haemoglobin');

insert into public.labs (mother_id, type, value, unit, result_date, ordered_by)
select m.id, 'Blood group',
       (array['O+','A+','B+','AB+','O-','B-'])[1 + floor(random()*6)], null,
       current_date - (60 + floor(random() * 40))::int, 'PHC Hosahalli'
from public.mothers m
where not exists (select 1 from public.labs l
                   where l.mother_id = m.id and l.type = 'Blood group');

insert into public.labs (mother_id, type, value, unit, result_date, ordered_by)
select m.id, 'Urine albumin',
       (array['Nil','Nil','Nil','Trace'])[1 + floor(random()*4)], null,
       current_date - (30 + floor(random() * 20))::int, 'PHC Hosahalli'
from public.mothers m
where not exists (select 1 from public.labs l
                   where l.mother_id = m.id and l.type = 'Urine albumin');

insert into public.labs (mother_id, type, value, unit, result_date, ordered_by)
select m.id, 'Blood sugar (random)',
       round((78 + random() * 62)::numeric, 0)::text, 'mg/dL',
       current_date - (30 + floor(random() * 20))::int, 'PHC Hosahalli'
from public.mothers m
where not exists (select 1 from public.labs l
                   where l.mother_id = m.id and l.type = 'Blood sugar (random)');

insert into public.labs (mother_id, type, value, unit, result_date, ordered_by)
select m.id, 'HIV / VDRL', 'Non-reactive', null,
       current_date - (60 + floor(random() * 40))::int, 'PHC Hosahalli'
from public.mothers m
where not exists (select 1 from public.labs l
                   where l.mother_id = m.id and l.type = 'HIV / VDRL');

-- --------------------------------------------------------------- alerts
-- Raised from readings already in the record, not sprinkled at random: an
-- alert nobody can trace back to a measurement teaches health workers to
-- ignore alerts.
insert into public.alerts
  (mother_id, rule_id, severity, message_kn, message_en, visit_id)
select v.mother_id, 'hb_severe', 'red',
       'ರಕ್ತದ ಪ್ರಮಾಣ ತುಂಬಾ ಕಡಿಮೆ ಇದೆ (' || v.hb || ' g/dL). ತಕ್ಷಣ ವೈದ್ಯರನ್ನು ಕಾಣಿಸಿ.',
       'Severe anaemia: haemoglobin ' || v.hb || ' g/dL. Refer to the medical officer.',
       v.id
from public.anc_visits v
where v.hb is not null and v.hb < 9.0
  and v.visit_date = (select max(a.visit_date) from public.anc_visits a
                       where a.mother_id = v.mother_id)
  and not exists (select 1 from public.alerts al
                   where al.mother_id = v.mother_id and al.rule_id = 'hb_severe');

insert into public.alerts
  (mother_id, rule_id, severity, message_kn, message_en, visit_id)
select v.mother_id, 'bp_high', 'red',
       'ರಕ್ತದೊತ್ತಡ ಹೆಚ್ಚಿದೆ (' || v.bp_sys || '/' || v.bp_dia || '). ತಕ್ಷಣ ಆರೋಗ್ಯ ಕೇಂದ್ರಕ್ಕೆ ಕಳುಹಿಸಿ.',
       'Raised blood pressure ' || v.bp_sys || '/' || v.bp_dia || '. Refer the same day.',
       v.id
from public.anc_visits v
where (v.bp_sys >= 140 or v.bp_dia >= 90)
  and v.visit_date = (select max(a.visit_date) from public.anc_visits a
                       where a.mother_id = v.mother_id)
  and not exists (select 1 from public.alerts al
                   where al.mother_id = v.mother_id and al.rule_id = 'bp_high');

insert into public.alerts
  (mother_id, rule_id, severity, message_kn, message_en, visit_id)
select v.mother_id, 'hb_low', 'amber',
       'ರಕ್ತದ ಪ್ರಮಾಣ ಕಡಿಮೆ ಇದೆ (' || v.hb || ' g/dL). ಕಬ್ಬಿಣದ ಮಾತ್ರೆ ತಪ್ಪದೆ ಕೊಡಿ.',
       'Anaemia: haemoglobin ' || v.hb || ' g/dL. Reinforce iron and folic acid.',
       v.id
from public.anc_visits v
where v.hb is not null and v.hb >= 9.0 and v.hb < 11.0
  and v.visit_date = (select max(a.visit_date) from public.anc_visits a
                       where a.mother_id = v.mother_id)
  and not exists (select 1 from public.alerts al
                   where al.mother_id = v.mother_id and al.rule_id = 'hb_low');

-- ----------------------------------------------- risk follows the evidence
update public.mothers m set risk_level = 'amber',
       risk_reasons = array['Haemoglobin below 11 g/dL']
where m.risk_level = 'green'
  and exists (select 1 from public.alerts a
               where a.mother_id = m.id and a.severity = 'amber');

update public.mothers m set risk_level = 'red',
       risk_reasons = array(select distinct a.message_en from public.alerts a
                             where a.mother_id = m.id and a.severity = 'red')
where exists (select 1 from public.alerts a
               where a.mother_id = m.id and a.severity = 'red');

-- ------------------------------------------------------- work to be done
-- One open task per mother who has an unacknowledged alert, addressed to the
-- ASHA who actually covers her, so the ASHA app opens onto real work.
insert into public.tasks
  (mother_id, created_by, assigned_to_asha_id, assigned_to_asha_name, type,
   instruction_kn, instruction_en, due_date, priority, status, origin)
select m.id, 'Dr. Sridevi R', w.id, w.name_en,
       case when a.severity = 'red' then 'referral' else 'home_visit' end,
       case when a.severity = 'red'
            then 'ಇಂದೇ ಮನೆಗೆ ಹೋಗಿ, ಆರೋಗ್ಯ ಕೇಂದ್ರಕ್ಕೆ ಕರೆದುಕೊಂಡು ಹೋಗಿ.'
            else 'ಮನೆಗೆ ಭೇಟಿ ನೀಡಿ, ಕಬ್ಬಿಣದ ಮಾತ್ರೆ ತೆಗೆದುಕೊಳ್ಳುತ್ತಿದ್ದಾರೆಯೇ ಪರಿಶೀಲಿಸಿ.' end,
       case when a.severity = 'red'
            then 'Visit today and escort her to the health centre.'
            else 'Home visit: check she is taking her iron tablets.' end,
       current_date + case when a.severity = 'red' then 0 else 4 end,
       case when a.severity = 'red' then 'high' else 'normal' end,
       'open', 'alert'
from public.mothers m
join public.alerts a on a.mother_id = m.id and not a.acknowledged
join public.asha_workers w on w.id = m.asha_worker_id
where not exists (select 1 from public.tasks t
                   where t.mother_id = m.id and t.status = 'open'
                     and t.origin = 'alert');
