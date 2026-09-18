-- A photograph of the paper prescription the doctor writes at a visit.
--
-- Prescriptions in a PHC are handwritten on paper she carries home and loses.
-- Photographing it at the counter means she still has it at the chemist, at
-- the next visit, and when a different doctor sees her.
--
-- The image lives in Storage; this table is the record of it. Access follows
-- the same rule as the rest of her clinical data — she always sees her own,
-- her ASHA sees her sub-centre, a doctor needs a grant.

create table if not exists public.prescriptions (
  id            uuid primary key default gen_random_uuid(),
  mother_id     uuid not null references public.mothers (id) on delete cascade,
  visit_id      uuid references public.anc_visits (id),
  -- Path inside the prescriptions bucket, not a public URL.
  storage_path  text not null,
  note          text,
  prescribed_by text,
  taken_at      timestamptz not null default now(),
  created_at    timestamptz not null default now()
);

create index if not exists prescriptions_mother_idx
  on public.prescriptions (mother_id, taken_at desc);

alter table public.prescriptions enable row level security;

drop policy if exists "read prescriptions" on public.prescriptions;
create policy "read prescriptions" on public.prescriptions
  for select to authenticated using (public.can_access_mother(mother_id));

drop policy if exists "write prescriptions" on public.prescriptions;
create policy "write prescriptions" on public.prescriptions
  for insert to authenticated
  with check (public.can_access_mother(mother_id));

grant select, insert on public.prescriptions to authenticated;

-- ------------------------------------------------------------ the images

insert into storage.buckets (id, name, public)
values ('prescriptions', 'prescriptions', false)
on conflict (id) do nothing;

-- Objects are filed under <mother_id>/<file>, so the folder name is the key
-- that the same can_access_mother rule is applied to.
drop policy if exists "read prescription images" on storage.objects;
create policy "read prescription images" on storage.objects
  for select to authenticated
  using (
    bucket_id = 'prescriptions'
    and public.can_access_mother((storage.foldername(name))[1]::uuid)
  );

drop policy if exists "write prescription images" on storage.objects;
create policy "write prescription images" on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'prescriptions'
    and public.can_access_mother((storage.foldername(name))[1]::uuid)
  );
