# MoneyFit 1.2.7 release checklist

This checklist records the operational handoff for `1.2.7+18`. It deliberately
does not perform a deployment, rotate a secret, or modify a store console.

## Repository gate

- Run `flutter pub get`, `flutter gen-l10n`, `dart format --set-exit-if-changed .`,
  `flutter analyze`, `flutter test`, and `git diff --check`.
- Run `npx deno@2.2.2 test supabase/functions/notify-slack-delivery/delivery_test.ts`.
- Run `dart run tool/validate_store_metadata.dart` and Ruby syntax checks for
  both Fastfiles.
- Confirm `pubspec.yaml` is `1.2.7+18` and that the intended store build code
  is available before a beta build.
- Confirm `.fastlane.env.local`, `supabase/.temp/`, secrets, IPA/dSYM files,
  and Fastlane reports are not staged.

## Supabase compatibility gate

The following migrations are already deployed and are historical records:

- `20260721000000_feedback_and_contact_delivery.sql`
- `20260722000000_notification_delivery_webhooks.sql`
- `20260723000000_bigint_delivery_id_compatibility.sql`

Do not edit, delete, re-run, or reset those migrations in the linked production
project. The deployed `notify-slack-delivery` Edge Function is v3, and its
payload IDs are text: only positive bigint or UUID IDs are accepted. A client
must use the bigint-returning `submit_app_feedback` RPC and preserve its
idempotency submission ID.

With an approved read-only project link, verify the remote state without a
deployment:

```sh
supabase migration list --linked
supabase db query --linked --file supabase/tests/notification_delivery_webhooks.sql
```

The SQL test verifies function signatures, INSERT-only triggers, and the
five-minute retry cron job without inserting a row or sending Slack traffic.
Consult `supabase/README.md` before any future staging deployment.

## Store and privacy gate

- Archive the current App Store Connect and Play Console metadata before an
  upload. Review a console draft rather than treating an internal track as
  metadata isolation.
- iOS uses 12 supported product locales plus `en-GB` fallback for Bulgarian
  and Filipino. Play uses all 14 app locales, with `ms-MY` (not duplicate
  `ms`) and `fil`.
- Verify the support, marketing, and privacy URLs are publicly reachable and
  approved. Complete trademark and privacy review before publication.
- Validate iOS binary localizations separately from the store metadata.
- Never run image-sync or release lanes until an operator has reviewed the
  remote diff and an explicit rollback owner is assigned.
