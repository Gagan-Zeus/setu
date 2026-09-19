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

-- The same over the Kannada columns, which is not optional: Kannada is the
-- app's default language, so most questions arrive in it. Searching only the
-- English columns meant every one of them retrieved nothing and the assistant
-- answered "ask your ASHA worker" to questions this table already answers.
--
-- 'simple' is the right configuration, not a compromise. Postgres ships no
-- Kannada one, and 'simple' does what is actually wanted here: lowercase and
-- split on punctuation, with no stemming and no stopword list. An English
-- stemmer let loose on Kannada would cut real characters off real words.
create index if not exists pregnancy_faqs_fts_kn
  on public.pregnancy_faqs
  using gin (to_tsvector('simple',
    coalesce(question_kn, '') || ' ' || coalesce(answer_kn, '')));

alter table public.pregnancy_faqs enable row level security;

-- Published answers are health education, readable by any signed-in user.
-- Unpublished drafts are not.
drop policy if exists "read published faqs" on public.pregnancy_faqs;
create policy "read published faqs" on public.pregnancy_faqs
  for select to anon, authenticated using (is_published);

grant select on public.pregnancy_faqs to anon, authenticated;

-- Any of her words, not all of them.
--
-- plainto_tsquery joins terms with AND, which is the wrong shape for a spoken
-- question. "ನಾನು ಗರ್ಭಿಣಿ, ಏನು ತಿನ್ನಬೇಕು?" carries words no FAQ row contains,
-- and one of those is enough to make an AND query match nothing at all. OR
-- plus ts_rank is what retrieval wants: a row matching three of her words
-- outranks one matching a single word, and the assistant is handed the best
-- five rather than an empty list.
--
-- Rewriting the parsed tsquery is safe. plainto_tsquery has already stripped
-- punctuation and quoted every lexeme, so no '&' can survive inside a token
-- and nothing here is open to injection.
create or replace function public.faq_any_tsquery(
  p_config regconfig, p_query text)
returns tsquery
language sql immutable parallel safe as $$
  select nullif(
           replace(plainto_tsquery(p_config, p_query)::text, '&', '|'),
           '')::tsquery
$$;

-- Retrieval used by the assistant: best matches, published only.
--
-- Both languages are searched on every call. Which one she typed in is not
-- known here and does not need to be — a Kannada question simply scores zero
-- against the English vector, and an English one zero against the Kannada.
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
         @@ faq_any_tsquery('english', p_query)
       or to_tsvector('simple',
            coalesce(f.question_kn, '') || ' ' || coalesce(f.answer_kn, ''))
          @@ faq_any_tsquery('simple', p_query)
       or f.question ilike '%' || p_query || '%'
       or f.question_kn ilike '%' || p_query || '%'
     )
   order by greatest(
     coalesce(ts_rank(
       to_tsvector('english', f.question || ' ' || f.answer),
       faq_any_tsquery('english', p_query)), 0),
     coalesce(ts_rank(
       to_tsvector('simple',
         coalesce(f.question_kn, '') || ' ' || coalesce(f.answer_kn, '')),
       faq_any_tsquery('simple', p_query)), 0)
   ) desc
   limit greatest(1, least(p_limit, 8))
$$;

grant execute on function public.search_pregnancy_faqs(text, int)
  to anon, authenticated;
grant execute on function public.faq_any_tsquery(regconfig, text)
  to anon, authenticated;
