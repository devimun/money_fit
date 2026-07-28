-- Queue asynchronous delivery calls after a successful insert and retry them
-- from pg_cron. Secrets stay in Vault and are intentionally not present here.
-- Apply only after 20260721000000_feedback_and_contact_delivery.sql.
create extension if not exists pg_net;
create extension if not exists pg_cron;

create schema if not exists private;

create or replace function private.enqueue_slack_delivery(
  p_table text,
  p_id uuid,
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
  select decrypted_secret into delivery_url
  from vault.decrypted_secrets
  where name = 'notify_slack_delivery_url'
  limit 1;

  select decrypted_secret into delivery_secret
  from vault.decrypted_secrets
  where name = 'delivery_notify_secret'
  limit 1;

  -- Missing external configuration must never make a customer submission fail.
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
    -- pg_net/Vault outages are delivery failures, not insert failures. Do not
    -- include a detail, email, secret, or full UID in the database log.
    raise warning 'MoneyFit delivery enqueue failed for %, id %', p_table, left(p_id::text, 8);
end;
$$;

revoke all on function private.enqueue_slack_delivery(text, uuid, text)
  from public, anon, authenticated;

create or replace function private.enqueue_slack_delivery_on_insert()
returns trigger
language plpgsql
security definer
set search_path = pg_catalog
as $$
begin
  perform private.enqueue_slack_delivery(TG_TABLE_NAME, new.id, 'INSERT');
  return new;
end;
$$;

revoke all on function private.enqueue_slack_delivery_on_insert()
  from public, anon, authenticated;

-- Recreate only these named INSERT triggers. There is intentionally no UPDATE
-- trigger because delivery status updates would otherwise recursively enqueue.
drop trigger if exists notify_slack_delivery_after_insert on public.user_contact;
create trigger notify_slack_delivery_after_insert
after insert on public.user_contact
for each row execute function private.enqueue_slack_delivery_on_insert();

drop trigger if exists notify_slack_delivery_after_insert on public.app_feedback;
create trigger notify_slack_delivery_after_insert
after insert on public.app_feedback
for each row execute function private.enqueue_slack_delivery_on_insert();

create or replace function private.enqueue_due_slack_deliveries()
returns void
language plpgsql
security definer
set search_path = pg_catalog
as $$
declare
  candidate record;
begin
  -- A single global batch prevents a large backlog from flooding pg_net or
  -- Slack. The Edge Function does the conditional claim before sending.
  for candidate in
    select table_name, id
    from (
      select 'user_contact'::text as table_name, id, created_at
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
      select 'app_feedback'::text as table_name, id, created_at
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

do $$
declare
  existing_job_id bigint;
begin
  select jobid into existing_job_id
  from cron.job
  where jobname = 'moneyfit-notify-slack-delivery-retry'
  limit 1;

  if existing_job_id is not null then
    perform cron.unschedule(existing_job_id);
  end if;

  perform cron.schedule(
    'moneyfit-notify-slack-delivery-retry',
    '*/5 * * * *',
    'select private.enqueue_due_slack_deliveries();'
  );
end;
$$;
