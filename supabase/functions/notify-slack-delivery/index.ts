// Shared delivery endpoint for Database Webhooks/Cron. Secrets are supplied by
// Supabase Function secrets only; no Flutter code or migration contains them.
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import {
  constantTimeEquals,
  deliver,
  type DeliveryStore,
  type DeliveryTable,
} from './delivery.ts';

const maxRequestBytes = 16 * 1024;

function response(body: string, status = 200) {
  return new Response(body, { status, headers: { 'content-type': 'text/plain; charset=utf-8' } });
}

function parseDeliveryEvent(body: Record<string, unknown>): { table: DeliveryTable; id: string } | null {
  const record = (body.record ?? body) as Record<string, unknown>;
  const table = String(body.table ?? body.table_name ?? '');
  const eventType = String(body.type ?? body.event ?? 'RETRY');
  const schema = String(body.schema ?? body.schema_name ?? 'public');
  const id = String(record.id ?? body.id ?? '');
  if (schema !== 'public' || !['INSERT', 'RETRY'].includes(eventType)) return null;
  if (table !== 'user_contact' && table !== 'app_feedback') return null;
  return { table, id };
}

Deno.serve(async (request) => {
  if (request.method !== 'POST') return response('method not allowed', 400);
  const expectedSecret = Deno.env.get('DELIVERY_NOTIFY_SECRET');
  if (!expectedSecret || !constantTimeEquals(request.headers.get('x-delivery-notify-secret'), expectedSecret)) {
    return response('forbidden', 403);
  }
  const raw = await request.text();
  if (raw.length > maxRequestBytes) return response('bad request', 400);
  let body: Record<string, unknown>;
  try { body = JSON.parse(raw) as Record<string, unknown>; } catch { return response('bad request', 400); }
  const event = parseDeliveryEvent(body);
  if (!event) return response('bad request', 400);

  const db = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
  );
  const store: DeliveryStore = {
    async read(table, id) {
      const columns = table === 'user_contact'
        ? 'id,uid,created_at,inquiry_type,email,details,platform,locale,app_version,build_number,slack_status,slack_attempts,slack_processing_at'
        : 'id,uid,created_at,source,detail,platform,locale,app_version,build_number,slack_status,slack_attempts,slack_processing_at';
      const { data } = await db.from(table).select(columns).eq('id', id).maybeSingle();
      return data;
    },
    async recoverStale(table, id, before) {
      await db.from(table).update({ slack_status: 'failed', slack_last_error_code: 'stale_processing', slack_processing_at: null }).eq('id', id).eq('slack_status', 'processing').lt('slack_processing_at', before);
    },
    async claim(table, id, attempts, processingAt) {
      const { data } = await db.from(table).update({ slack_status: 'processing', slack_attempts: attempts, slack_processing_at: processingAt, slack_next_retry_at: null }).eq('id', id).in('slack_status', ['pending', 'failed']).select('id').maybeSingle();
      return data != null;
    },
    async update(table, id, values) { await db.from(table).update(values).eq('id', id); },
    async recentForUid(table, uid, since) {
      const { count } = await db.from(table).select('id', { count: 'exact', head: true }).eq('uid', uid).gte('created_at', since);
      return count ?? 0;
    },
  };
  const result = await deliver(event.table, event.id, {
    store,
    webhookFor: (table) => Deno.env.get(table === 'user_contact' ? 'SLACK_INQUIRY_WEBHOOK_URL' : 'SLACK_FEEDBACK_WEBHOOK_URL'),
    postSlack: async (url, payload) => {
      const result = await fetch(url, { method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify(payload), signal: AbortSignal.timeout(5000) });
      return { status: result.status, body: await result.text(), retryAfter: result.headers.get('retry-after') };
    },
  });
  return response(result.kind, result.status);
});
