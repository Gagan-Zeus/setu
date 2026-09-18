-- Earlier per-app seeds each inserted their own ASHA workers, leaving
-- duplicates by name. Harmless while only the apps resolved them by id, but
-- the public directory shows the list to a pregnant woman choosing who to
-- call, so the duplicates became visible.
--
-- Keep the oldest row per name, repoint everything at it, delete the rest.

do $$
declare r record;
begin
  for r in
    select name_en,
           min(created_at) as first_seen,
           (array_agg(id order by created_at))[1] as keep_id
      from public.asha_workers
     group by name_en
    having count(*) > 1
  loop
    update public.mothers
       set asha_worker_id = r.keep_id
     where asha_worker_id in (select id from public.asha_workers
                               where name_en = r.name_en and id <> r.keep_id);

    update public.mothers
       set asha_id = r.keep_id
     where asha_id in (select id from public.asha_workers
                        where name_en = r.name_en and id <> r.keep_id);

    update public.tasks
       set assigned_to_asha_id = r.keep_id
     where assigned_to_asha_id in (select id from public.asha_workers
                                    where name_en = r.name_en and id <> r.keep_id);

    delete from public.asha_workers
     where name_en = r.name_en and id <> r.keep_id;

    raise notice 'collapsed duplicates for %', r.name_en;
  end loop;
end $$;

-- Stop it happening again.
create unique index if not exists asha_workers_name_unique
  on public.asha_workers (name_en);
