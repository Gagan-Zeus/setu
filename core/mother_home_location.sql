-- Where she actually lives.
--
-- An ASHA finding a house in a village works from landmarks and memory. A
-- pinned location captured on the first visit means the second visit — and any
-- ASHA covering for her — can navigate straight there.
--
-- Captured silently at registration and never required: rural GPS fails often,
-- and a registration must never be blocked by it.

alter table public.mothers
  add column if not exists home_lat double precision,
  add column if not exists home_lng double precision,
  add column if not exists home_note text,
  add column if not exists home_located_at timestamptz;
