-- Run after applying the delivery migrations. This is read-only: it verifies
-- that the SQL wiring exists without inserting a contact or sending a request.
do $$
begin
  if to_regprocedure('private.enqueue_slack_delivery(text,text,text)') is null then
    raise exception 'missing private.enqueue_slack_delivery';
  end if;
  if to_regprocedure('private.enqueue_due_slack_deliveries()') is null then
    raise exception 'missing private.enqueue_due_slack_deliveries';
  end if;
  if not exists (
    select 1
    from pg_proc
    where oid = 'public.submit_app_feedback(text,text,uuid,text,text,text,text)'::regprocedure
      and prorettype = 'bigint'::regtype
  ) then
    raise exception 'submit_app_feedback must return bigint';
  end if;
  if not exists (
    select 1 from pg_trigger
    where tgname = 'notify_slack_delivery_after_insert'
      and tgrelid = 'public.user_contact'::regclass
      and not tgisinternal
  ) then
    raise exception 'missing user_contact insert trigger';
  end if;
  if not exists (
    select 1 from pg_trigger
    where tgname = 'notify_slack_delivery_after_insert'
      and tgrelid = 'public.app_feedback'::regclass
      and not tgisinternal
  ) then
    raise exception 'missing app_feedback insert trigger';
  end if;
  if exists (
    select 1 from pg_trigger
    where tgname = 'notify_slack_delivery_after_insert'
      and tgrelid in ('public.user_contact'::regclass, 'public.app_feedback'::regclass)
      and (tgtype & 16) <> 0
  ) then
    raise exception 'delivery trigger must not listen for UPDATE';
  end if;
  if not exists (
    select 1 from cron.job
    where jobname = 'moneyfit-notify-slack-delivery-retry'
      and schedule = '*/5 * * * *'
  ) then
    raise exception 'missing retry cron job';
  end if;
end;
$$;
