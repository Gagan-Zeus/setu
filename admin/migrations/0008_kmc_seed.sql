-- Setu Admin Portal — ten invented KMC registrations.
--
-- These are NOT real doctors and NOT real registration numbers. Every one
-- carries the KMC-DEMO- prefix, which no council number has, and is_demo is
-- true on all of them, which the lookup returns so the portal can say on screen
-- where the answer came from.
--
-- They are shaped the way a Karnataka PHC roster actually looks rather than
-- being ten variations of the same person: mostly MBBS, a few with a
-- postgraduate degree, registration dates spread over twenty years, most from
-- RGUHS because that is who awards medical degrees in Karnataka. Two are
-- deliberately not in good standing — one expired, one suspended — because a
-- registry lookup that always succeeds tests nothing, and the portal has to
-- refuse those.
--
-- Safe to re-run.

insert into public.kmc_registry (
  registration_number, full_name, father_name, gender, date_of_birth,
  qualification, university, year_of_passing, registration_date,
  status, renewal_due, address, phone, email
) values
  ('KMC-DEMO-64821', 'Dr. Sridevi Rajanna', 'Rajanna Gowda', 'female', '1985-03-14',
   'MBBS, MD (Community Medicine)', 'Rajiv Gandhi University of Health Sciences', 2009,
   '2010-07-22', 'renewed', '2030-07-21',
   'No. 42, 3rd Cross, Vidyanagar, Hassan 573201', '+91 98450 22101', 'sridevi.rajanna@example.gov.in'),

  ('KMC-DEMO-71934', 'Dr. Manjunath Hegde', 'Ganapathi Hegde', 'male', '1979-11-02',
   'MBBS', 'Rajiv Gandhi University of Health Sciences', 2003,
   '2004-05-11', 'renewed', '2029-05-10',
   'Doctors Quarters, PHC Campus, Belur Road, Hassan 573115', '+91 98451 30288', 'm.hegde@example.gov.in'),

  ('KMC-DEMO-88207', 'Dr. Ayesha Fathima', 'Abdul Rahman Sheikh', 'female', '1990-06-28',
   'MBBS, DGO', 'Rajiv Gandhi University of Health Sciences', 2014,
   '2015-02-09', 'active', '2030-02-08',
   '18/2, Masjid Road, Arsikere, Hassan 573103', '+91 99801 44523', 'ayesha.f@example.gov.in'),

  ('KMC-DEMO-59416', 'Dr. Prakash Kumar B N', 'Nagaraj B', 'male', '1976-01-19',
   'MBBS, MD (General Medicine)', 'Bangalore University', 1999,
   '2000-09-30', 'renewed', '2028-09-29',
   '7th Main, Kuvempunagar, Mysuru 570023', '+91 98860 71145', 'prakash.bn@example.gov.in'),

  ('KMC-DEMO-93055', 'Dr. Lakshmi Narayan Achar', 'Subraya Achar', 'male', '1988-09-05',
   'MBBS, DCH', 'Manipal Academy of Higher Education', 2012,
   '2013-01-17', 'active', '2029-01-16',
   'Achar Nilaya, Car Street, Karkala, Udupi 574104', '+91 94481 60072', 'ln.achar@example.gov.in'),

  ('KMC-DEMO-47188', 'Dr. Shobha Patil', 'Basavaraj Patil', 'female', '1982-12-11',
   'MBBS, MS (Obstetrics and Gynaecology)', 'KLE Academy of Higher Education and Research', 2006,
   '2007-06-25', 'renewed', '2027-06-24',
   'Plot 22, Vidyanagar, Hubballi, Dharwad 580021', '+91 94491 83310', 'shobha.patil@example.gov.in'),

  ('KMC-DEMO-80673', 'Dr. Ravi Shankar Gowda', 'Chikkegowda', 'male', '1993-04-23',
   'MBBS', 'Rajiv Gandhi University of Health Sciences', 2017,
   '2018-03-06', 'active', '2033-03-05',
   'Gowda House, Konanur, Arkalgud Taluk, Hassan 573130', '+91 90084 11276', 'ravi.gowda@example.gov.in'),

  ('KMC-DEMO-36592', 'Dr. Nirmala Devi K S', 'Shivanna K', 'female', '1974-07-30',
   'MBBS, MD (Paediatrics)', 'University of Mysore', 1997,
   '1998-11-14', 'renewed', '2028-11-13',
   'No. 9, Saraswathipuram, Mysuru 570009', '+91 98455 90118', 'nirmala.ks@example.gov.in'),

  -- Not in good standing. A lookup that always says yes proves nothing, and the
  -- portal must refuse both of these with a reason rather than a shrug.
  ('KMC-DEMO-25840', 'Dr. Vinay Chandra Rao', 'Krishna Rao', 'male', '1968-02-08',
   'MBBS', 'Bangalore University', 1992,
   '1993-08-19', 'expired', '2023-08-18',
   'Rao Compound, Sira Road, Tumakuru 572101', '+91 98452 33907', 'vc.rao@example.gov.in'),

  ('KMC-DEMO-70219', 'Dr. Harish Kumar M', 'Mahadevappa', 'male', '1986-10-16',
   'MBBS, MD (Community Medicine)', 'Rajiv Gandhi University of Health Sciences', 2010,
   '2011-04-04', 'suspended', '2031-04-03',
   '4th Block, Jayanagar, Bengaluru 560011', '+91 99012 55840', 'harish.m@example.gov.in')

on conflict (registration_number) do update set
  full_name = excluded.full_name,
  father_name = excluded.father_name,
  gender = excluded.gender,
  date_of_birth = excluded.date_of_birth,
  qualification = excluded.qualification,
  university = excluded.university,
  year_of_passing = excluded.year_of_passing,
  registration_date = excluded.registration_date,
  status = excluded.status,
  renewal_due = excluded.renewal_due,
  address = excluded.address,
  phone = excluded.phone,
  email = excluded.email;

-- The existing demo doctor already has a staff row. Attach a registration to
-- it so the roster is consistent and the "already registered" path has
-- something real to find.
update public.staff
   set kmc_registration_number = 'KMC-DEMO-64821'
 where role = 'doctor'
   and lower(email) = 'dhrruwa@gmail.com'
   and kmc_registration_number is null;

-- Nothing here may pass for a council record.
do $$
declare bad int;
begin
  select count(*) into bad from public.kmc_registry
   where not is_demo or registration_number not like 'KMC-DEMO-%';
  if bad > 0 then
    raise exception 'A kmc_registry row is not marked as demo data (% row(s))', bad;
  end if;
end $$;
