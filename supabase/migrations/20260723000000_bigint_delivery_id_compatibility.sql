-- MoneyFit's existing production tables use bigint primary keys. Keep those
-- keys unchanged and transport identifiers as validated text to the Function.
-- This migration corrects the initial UUID-only delivery draft atomically.

create or replace function private.enqueue_slack_delivery(
  p_table text,
  p_id text,
  p_event_type text default 'INSERT'
) returns void
language plpgsql
security definer
set search_path = pg_catalog
as $$
declare
  delivery_url text;
  delivery_secret text;
begin
  if p_table not in ('user_contact', 'app_feedback')
     or p_event_type not in ('INSERT', 'RETRY')
     or p_id is null
     or p_id !~ '^[0-9a-fA-F-]{1,64}$' then
    return;
  end if;

  select decrypted_secret into delivery_url
  from vault.decrypted_secrets
  where name = 'notify_slack_delivery_url'
  limit 1;

  select decrypted_secret into delivery_secret
  from vault.decrypted_secrets
  where name = 'delivery_notify_secret'
  limit 1;

  if delivery_url is null or delivery_secret is null then
    return;
  end if;

  perform net.http_post(
    url := delivery_url,
    headers := jsonb_build_object(
      'content-type', 'application/json',
      'x-delivery-notify-secret', delivery_secret
    ),
    body := jsonb_build_object(
      'schema', 'public',
      'table', p_table,
      'type', p_event_type,
      'record', jsonb_build_object('id', p_id)
    )
  );
exception
  when others then
    raise warning 'MoneyFit delivery enqueue failed for %, id %', p_table, left(p_id, 8);
end;
$$;

revoke all on function private.enqueue_slack_delivery(text, text, text)
  from public, anon, authenticated;

create or replace function private.enqueue_slack_delivery_on_insert()
returns trigger
language plpgsql
security definer
set search_path = pg_catalog
as $$
begin
  perform private.enqueue_slack_delivery(TG_TABLE_NAME, new.id::text, 'INSERT');
  return new;
end;
$$;

create or replace function private.enqueue_due_slack_deliveries()
returns void
language plpgsql
security definer
set search_path = pg_catalog
as $$
declare
  candidate record;
begin
  for candidate in
    select table_name, id
    from (
      select 'user_contact'::text as table_name, id::text as id, created_at
      from public.user_contact
      where slack_status = 'pending'
         or (
           slack_status = 'failed'
           and slack_attempts < 5
           and (slack_next_retry_at is null or slack_next_retry_at <= now())
         )
         or (
           slack_status = 'processing'
           and slack_processing_at <= now() - interval '10 minutes'
         )
      union all
      select 'app_feedback'::text as table_name, id::text as id, created_at
      from public.app_feedback
      where slack_status = 'pending'
         or (
           slack_status = 'failed'
           and slack_attempts < 5
           and (slack_next_retry_at is null or slack_next_retry_at <= now())
         )
         or (
           slack_status = 'processing'
           and slack_processing_at <= now() - interval '10 minutes'
         )
    ) as due_rows
    order by created_at asc
    limit 50
  loop
    perform private.enqueue_slack_delivery(candidate.table_name, candidate.id, 'RETRY');
  end loop;
end;
$$;

revoke all on function private.enqueue_due_slack_deliveries()
  from public, anon, authenticated;

-- The trigger and retry helper above no longer reference this UUID-only
-- overload. Remove it so a future caller cannot accidentally choose it.
drop function if exists private.enqueue_slack_delivery(text, uuid, text);

-- The original draft returned uuid although app_feedback.id is bigint.
drop function if exists public.submit_app_feedback(text, text, uuid, text, text, text, text);
create function public.submit_app_feedback(
  p_detail text, p_source text, p_client_submission_id uuid, p_locale text,
  p_platform text, p_app_version text, p_build_number text
) returns bigint
language plpgsql
security definer
set search_path = public
as $$
declare
  result_id bigint;
begin
  if auth.uid() is null then raise exception 'authentication required'; end if;
  if char_length(trim(p_detail)) not between 3 and 1000 then raise exception 'invalid detail'; end if;
  if p_source not in ('review_negative', 'proactive_prompt') then raise exception 'invalid source'; end if;
  if p_platform not in ('ios', 'android', 'other') then raise exception 'invalid platform'; end if;
  if p_locale not in ('ko', 'en', 'es', 'pl', 'uk', 'cs', 'de', 'it', 'ro', 'sk', 'bg', 'id', 'ms', 'fil') then
    raise exception 'invalid locale';
  end if;

  insert into public.app_feedback (
    uid, detail, source, client_submission_id, locale, platform, app_version, build_number
  ) values (
    auth.uid()::text, trim(p_detail), p_source, p_client_submission_id,
    left(p_locale, 16), left(p_platform, 16), left(p_app_version, 40), left(p_build_number, 40)
  )
  on conflict (uid, client_submission_id) where client_submission_id is not null
    do update set client_submission_id = excluded.client_submission_id
  returning id into result_id;

  return result_id;
end;
$$;

revoke all on function public.submit_app_feedback(text, text, uuid, text, text, text, text)
  from public;
grant execute on function public.submit_app_feedback(text, text, uuid, text, text, text, text)
  to authenticated;
