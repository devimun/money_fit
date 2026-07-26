-- Additive draft: inspect the production user_contact/app_feedback DDL, RLS,
-- grants and primary keys before applying. This file deliberately contains no
-- secret and must be deployed only after the external setup checklist.
create extension if not exists pgcrypto;

alter table public.user_contact add column if not exists id uuid default gen_random_uuid();
alter table public.user_contact add column if not exists created_at timestamptz not null default now();
alter table public.user_contact add column if not exists locale text;
alter table public.user_contact add column if not exists app_version text;
alter table public.user_contact add column if not exists build_number text;
-- Add the delivery state without a default first. PostgreSQL materializes an
-- ADD COLUMN default for existing rows, which would otherwise make historic
-- 1.2.6 inquiries look like newly pending deliveries.
alter table public.user_contact add column if not exists slack_status text;
alter table public.user_contact add column if not exists slack_attempts integer not null default 0;
alter table public.user_contact add column if not exists slack_processing_at timestamptz;
alter table public.user_contact add column if not exists slack_notified_at timestamptz;
alter table public.user_contact add column if not exists slack_next_retry_at timestamptz;
alter table public.user_contact add column if not exists slack_last_error_code text;

-- Existing rows must never be replayed when delivery is enabled.
update public.user_contact set slack_status = 'suppressed'
where slack_status is null;
alter table public.user_contact alter column slack_status set default 'pending';
alter table public.user_contact alter column slack_status set not null;
create index if not exists user_contact_slack_retry_idx
  on public.user_contact (slack_status, slack_next_retry_at, created_at);
create index if not exists user_contact_uid_created_idx
  on public.user_contact (uid, created_at);

alter table public.app_feedback add column if not exists id uuid default gen_random_uuid();
alter table public.app_feedback add column if not exists created_at timestamptz not null default now();
alter table public.app_feedback add column if not exists source text;
alter table public.app_feedback add column if not exists client_submission_id uuid;
alter table public.app_feedback add column if not exists locale text;
alter table public.app_feedback add column if not exists app_version text;
alter table public.app_feedback add column if not exists build_number text;
alter table public.app_feedback add column if not exists slack_status text;
alter table public.app_feedback add column if not exists slack_attempts integer not null default 0;
alter table public.app_feedback add column if not exists slack_processing_at timestamptz;
alter table public.app_feedback add column if not exists slack_notified_at timestamptz;
alter table public.app_feedback add column if not exists slack_next_retry_at timestamptz;
alter table public.app_feedback add column if not exists slack_last_error_code text;
update public.app_feedback set slack_status = 'suppressed' where slack_status is null;
alter table public.app_feedback alter column slack_status set default 'pending';
alter table public.app_feedback alter column slack_status set not null;
create unique index if not exists app_feedback_uid_submission_id_idx
  on public.app_feedback (uid, client_submission_id) where client_submission_id is not null;
create index if not exists app_feedback_slack_retry_idx
  on public.app_feedback (slack_status, slack_next_retry_at, created_at);

-- This SECURITY DEFINER RPC is the 1.2.7 client path. Validate table column
-- names and existing grants in staging before enabling it in production.
create or replace function public.submit_app_feedback(
  p_detail text, p_source text, p_client_submission_id uuid, p_locale text,
  p_platform text, p_app_version text, p_build_number text
) returns uuid language plpgsql security definer set search_path = public as $$
declare result_id uuid;
begin
  if auth.uid() is null then raise exception 'authentication required'; end if;
  if char_length(trim(p_detail)) not between 3 and 1000 then raise exception 'invalid detail'; end if;
  if p_source not in ('review_negative', 'proactive_prompt') then raise exception 'invalid source'; end if;
  insert into app_feedback (uid, detail, source, client_submission_id, locale, platform, app_version, build_number)
  values (auth.uid(), trim(p_detail), p_source, p_client_submission_id, left(p_locale, 16), left(p_platform, 16), left(p_app_version, 40), left(p_build_number, 40))
  on conflict (uid, client_submission_id) where client_submission_id is not null do update set client_submission_id = excluded.client_submission_id
  returning id into result_id;
  return result_id;
end $$;
revoke all on function public.submit_app_feedback(text,text,uuid,text,text,text,text) from public;
grant execute on function public.submit_app_feedback(text,text,uuid,text,text,text,text) to authenticated;

-- Do not add guessed RLS policies here. Production policy/column grants must
-- first be exported and reviewed to preserve the 1.2.6 direct INSERT path.
