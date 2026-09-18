-- Approved answers the assistant is allowed to draw on.
--
-- The model is never the source of a medical fact. It only rephrases rows from
-- this table in her language. That way an answer can be corrected by editing
-- one row, with no retraining and no redeploy — which matters, because
-- pregnancy guidance changes and has to stay clinician-reviewed.

create table if not exists public.pregnancy_faqs (
  id          uuid primary key default gen_random_uuid(),
  category    text not null,
  stage       text not null,
  question    text not null,
  answer      text not null,
  question_kn text,
  answer_kn   text,
  source_name text not null,
  source_url  text,
  urgency     text not null default 'normal',
  reviewed_by text,
  reviewed_at date,
  is_published boolean not null default false,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  constraint pregnancy_faqs_urgency_check
    check (urgency in ('normal', 'contact_clinician', 'emergency')),
  constraint pregnancy_faqs_category_check
    check (category in ('food','first_trimester','second_trimester',
                        'third_trimester','labour','postpartum_mother',
                        'newborn','mental_health')),
  constraint pregnancy_faqs_stage_check
    check (stage in ('pregnancy','postpartum','newborn'))
);

create index if not exists pregnancy_faqs_lookup
  on public.pregnancy_faqs (category, stage) where is_published;

-- Full-text search over the question and answer, so retrieval is not a LIKE.
create index if not exists pregnancy_faqs_fts
  on public.pregnancy_faqs
  using gin (to_tsvector('english', question || ' ' || answer));

alter table public.pregnancy_faqs enable row level security;

-- Published answers are health education, readable by any signed-in user.
-- Unpublished drafts are not.
drop policy if exists "read published faqs" on public.pregnancy_faqs;
create policy "read published faqs" on public.pregnancy_faqs
  for select to anon, authenticated using (is_published);

grant select on public.pregnancy_faqs to anon, authenticated;

-- Retrieval used by the assistant: best matches, published only.
create or replace function public.search_pregnancy_faqs(
  p_query text, p_limit int default 5)
returns table (
  question text, answer text, question_kn text, answer_kn text,
  source_name text, urgency text, category text
)
language sql stable security definer set search_path = public as $$
  select f.question, f.answer, f.question_kn, f.answer_kn,
         f.source_name, f.urgency, f.category
    from public.pregnancy_faqs f
   where f.is_published
     and (
       to_tsvector('english', f.question || ' ' || f.answer)
         @@ plainto_tsquery('english', p_query)
       or f.question ilike '%' || p_query || '%'
     )
   order by ts_rank(
     to_tsvector('english', f.question || ' ' || f.answer),
     plainto_tsquery('english', p_query)) desc
   limit greatest(1, least(p_limit, 8))
$$;

grant execute on function public.search_pregnancy_faqs(text, int)
  to anon, authenticated;
