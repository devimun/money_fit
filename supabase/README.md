# Supabase Slack Delivery Runbook

`notify-slack-delivery` is one shared Edge Function for `user_contact` and
`app_feedback`. It receives an INSERT Database Webhook or a scheduled retry,
re-reads the canonical row with the service role, conditionally claims it, and
then posts a Slack `plain_text` Block Kit message. A successful database write
is therefore never coupled to Slack availability.

## Preconditions

Do not apply the migration until a read-only export has confirmed both tables'
primary keys, existing columns, RLS policies, grants, and the 1.2.6 direct
`user_contact` INSERT payload. The migration is additive and suppresses
historical rows, but it intentionally does not guess or replace a production
RLS policy.

The reviewed production policy/grant end state is:

- RLS is enabled on `user_contact` and `app_feedback`.
- `authenticated` can insert `user_contact` only with `auth.uid() = uid` and
  only into client-owned columns (`uid`, `inquiry_type`, `email`, `details`,
  `platform`, `locale`, `app_version`, `build_number`). It has no SELECT,
  UPDATE, or DELETE access and cannot write `slack_*` columns.
- Direct `app_feedback` table access is not granted to application roles.
  `authenticated` can only execute `submit_app_feedback`, which owns the UID
  and validates the fixed source, locale, platform, content, and idempotency
  identifier.
- The service role alone can read rows and update delivery fields.

Test those rules with two anonymous-auth users before enabling any webhook.

## CLI Deploy Order

1. Link the intended staging project and save a schema/RLS/grant backup. Check
   the remote migration history and planned DDL before changing it:

   ```sh
   supabase link --project-ref "$PROJECT_REF"
   supabase migration list --linked
   supabase db push --linked --dry-run
   ```

2. Create two Vault secrets for this project. The values must be unique per
   environment and `delivery_notify_secret` must exactly equal the Function
   secret in the next step. Use a local, untracked SQL file with mode `0600`;
   do not commit it or put the values in a migration.

   ```sh
   chmod 600 "$VAULT_SQL_FILE"
   ```

   ```sql
   select vault.create_secret(
     '<DELIVERY_NOTIFY_SECRET_VALUE>',
     'delivery_notify_secret',
     'Shared secret for notify-slack-delivery database calls'
   );
   select vault.create_secret(
     'https://<PROJECT_REF>.supabase.co/functions/v1/notify-slack-delivery',
     'notify_slack_delivery_url',
     'MoneyFit notify-slack-delivery endpoint'
   );
   ```

   Apply that local file without echoing it to logs:

   ```sh
   supabase db query --linked --file "$VAULT_SQL_FILE"
   rm -f "$VAULT_SQL_FILE"
   ```

   If a Vault name already exists, use `vault.update_secret` with its `id`
   rather than adding a duplicate. Never query or print `decrypted_secret`.

3. Set Function secrets outside source control:

   ```sh
   supabase secrets set --project-ref "$PROJECT_REF" \
     DELIVERY_NOTIFY_SECRET="$DELIVERY_NOTIFY_SECRET" \
     SLACK_INQUIRY_WEBHOOK_URL="$SLACK_INQUIRY_WEBHOOK_URL" \
     SLACK_FEEDBACK_WEBHOOK_URL="$SLACK_FEEDBACK_WEBHOOK_URL"
   ```

   Omit either Slack URL to intentionally suppress that table's notifications.
   Never use a mobile app key, `.env`, migration, or shell history as a secret
   store.
4. Deploy and test the function with a fixture row in the staging channel:

   ```sh
   supabase functions deploy notify-slack-delivery --project-ref "$PROJECT_REF" --no-verify-jwt
   ```

5. Apply all pending migrations. The delivery trigger migration creates the two
   **INSERT-only** `pg_net` triggers and an idempotently named five-minute
   `pg_cron` job. The following bigint compatibility migration transports row
   IDs as text and corrects the feedback RPC return type without changing any
   table primary key. They read only `delivery_notify_secret` and
   `notify_slack_delivery_url` from Vault; no UPDATE trigger is created.

   ```sh
   supabase db push --linked
   supabase db query --linked --file supabase/tests/notification_delivery_webhooks.sql
   ```

6. Verify 1.2.6-style inserts, a 429/5xx retry, stale-processing recovery,
   duplicate event no-op behavior, and literal `@channel` text in the staging
   Slack channel. Only then repeat migration, function, webhook, and Cron in
   production.

## Operations And Rollback

- Check both tables' `slack_status`, `slack_attempts`, `slack_next_retry_at`,
  Function logs, and Cron history. Logs must contain only delivery IDs and
  status, never detail, email, JWT, or a webhook URL.
- Delivery is at-least-once. The claim prevents normal duplicates; a crash
  after Slack accepts a message but before the database update can duplicate a
  notification. The short delivery ID in Slack makes that case auditable.
- Slack 429/5xx/network failures retry with bounded exponential backoff up to
  five attempts. 400/403/404 and per-user flood protection are suppressed for
  operator review rather than retried forever.
- To stop delivery immediately, unschedule `moneyfit-notify-slack-delivery-retry`
  and disable the two named INSERT triggers. Then revoke or rotate Slack URLs
  and Function secrets. Do not drop the additive columns during an incident:
  old clients remain compatible and rows preserve the support record.
