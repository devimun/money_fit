export const deliveryTables = new Set(['user_contact', 'app_feedback']);
export const maxDeliveryAttempts = 5;
export const staleProcessingMs = 10 * 60 * 1000;

export type DeliveryTable = 'user_contact' | 'app_feedback';
export type DeliveryStatus = 'pending' | 'processing' | 'sent' | 'failed' | 'suppressed';

export interface DeliveryRow {
  id: string;
  uid?: string | null;
  created_at?: string | null;
  inquiry_type?: string | null;
  source?: string | null;
  email?: string | null;
  details?: string | null;
  detail?: string | null;
  platform?: string | null;
  locale?: string | null;
  app_version?: string | null;
  build_number?: string | null;
  slack_status?: DeliveryStatus | null;
  slack_attempts?: number | null;
  slack_processing_at?: string | null;
  slack_next_retry_at?: string | null;
  slack_last_error_code?: string | null;
}

export interface DeliveryStore {
  read(table: DeliveryTable, id: string): Promise<DeliveryRow | null>;
  recoverStale(table: DeliveryTable, id: string, before: string): Promise<void>;
  claim(table: DeliveryTable, id: string, attempts: number, processingAt: string): Promise<boolean>;
  update(table: DeliveryTable, id: string, values: Record<string, unknown>): Promise<void>;
  recentForUid(table: DeliveryTable, uid: string, since: string): Promise<number>;
}

export interface SlackResponse {
  status: number;
  body: string;
  retryAfter?: string | null;
}

export interface DeliveryDependencies {
  store: DeliveryStore;
  webhookFor(table: DeliveryTable): string | undefined;
  postSlack(url: string, payload: Record<string, unknown>): Promise<SlackResponse>;
  now?: () => Date;
  uidLimit?: number;
}

export interface DeliveryResult {
  kind: 'sent' | 'noop' | 'not_found' | 'invalid' | 'disabled';
  status: number;
}

const uuidPattern = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const controlCharacters = /[\u0000-\u001f\u007f]/g;
const likelyPii = /(?:\b[\w.+-]+@[\w.-]+\.[A-Za-z]{2,}\b|\b(?:\d[ -]?){12,19}\b|\b\d{2,4}[ -]?\d{3,4}[ -]?\d{4}\b)/;

export function isUuid(value: string): boolean {
  return uuidPattern.test(value);
}

export function safePlainText(value: unknown, max = 1000): string {
  return String(value ?? '')
    .replace(controlCharacters, ' ')
    .replace(/\s+/g, ' ')
    .trim()
    .slice(0, max);
}

export function constantTimeEquals(left: string | null, right: string | null): boolean {
  const a = left ?? '';
  const b = right ?? '';
  const length = Math.max(a.length, b.length);
  let difference = a.length ^ b.length;
  for (let index = 0; index < length; index += 1) {
    difference |= (a.charCodeAt(index) || 0) ^ (b.charCodeAt(index) || 0);
  }
  return difference === 0;
}

export function retryAt(attempt: number, now: Date, retryAfter?: string | null): string {
  const retryAfterSeconds = Number.parseInt(retryAfter ?? '', 10);
  const exponentialMs = Math.min(60 * 60 * 1000, 60 * 1000 * 2 ** Math.max(0, attempt - 1));
  const requestedMs = Number.isFinite(retryAfterSeconds)
    ? Math.min(60 * 60 * 1000, Math.max(0, retryAfterSeconds * 1000))
    : 0;
  const jitterMs = Math.floor(Math.random() * 30 * 1000);
  return new Date(now.getTime() + Math.max(exponentialMs, requestedMs) + jitterMs).toISOString();
}

function plainText(text: string) {
  return { type: 'plain_text', text: safePlainText(text, 3000), emoji: true };
}

function inquiryLabel(value: unknown): string {
  switch (value) {
    case 'bug_report': return 'Bug report';
    case 'feature_suggestion': return 'Feature suggestion';
    case 'general_inquiry': return 'General inquiry';
    case 'other': return 'Other inquiry';
    default: return 'Legacy inquiry';
  }
}

export function slackPayload(table: DeliveryTable, row: DeliveryRow): Record<string, unknown> {
  const isInquiry = table === 'user_contact';
  const title = isInquiry ? `New MoneyFit inquiry · ${inquiryLabel(row.inquiry_type)}` : 'New MoneyFit feedback';
  const rawDetail = safePlainText(row.details ?? row.detail, 1000);
  const detail = !isInquiry && likelyPii.test(rawDetail)
    ? '[Potential personal information — review in Supabase]'
    : rawDetail || '(No message)';
  const metadata = [
    `ID ${row.id.slice(0, 8)}`,
    `received ${safePlainText(row.created_at, 40) || 'unknown'}`,
    `platform ${safePlainText(row.platform, 20) || 'unknown'}`,
    `locale ${safePlainText(row.locale, 16) || 'unknown'}`,
    `version ${safePlainText(row.app_version, 40) || 'unknown'}${row.build_number ? ` (${safePlainText(row.build_number, 40)})` : ''}`,
    !isInquiry && row.source ? `source ${safePlainText(row.source, 32)}` : '',
  ].filter(Boolean).join(' · ');
  const blocks: Record<string, unknown>[] = [
    { type: 'header', text: plainText(title) },
    { type: 'section', text: plainText(metadata) },
    { type: 'section', text: plainText(detail) },
  ];
  if (isInquiry && row.email) {
    blocks.push({ type: 'section', text: plainText(`Reply email: ${safePlainText(row.email, 254)}`) });
  }
  // Keep fallback text free of user content so Slack never interprets it.
  return { text: `MoneyFit delivery ${row.id.slice(0, 8)}`, blocks };
}

function isClaimable(row: DeliveryRow): boolean {
  return row.slack_status === 'pending' || row.slack_status === 'failed';
}

export async function deliver(
  table: DeliveryTable,
  id: string,
  dependencies: DeliveryDependencies,
): Promise<DeliveryResult> {
  if (!deliveryTables.has(table) || !isUuid(id)) return { kind: 'invalid', status: 400 };
  const now = dependencies.now?.() ?? new Date();
  const store = dependencies.store;
  let row = await store.read(table, id); // canonical server-side row, never webhook payload
  if (!row) return { kind: 'not_found', status: 404 };
  if (row.slack_status === 'processing') {
    await store.recoverStale(table, id, new Date(now.getTime() - staleProcessingMs).toISOString());
    row = await store.read(table, id);
    if (!row) return { kind: 'not_found', status: 404 };
  }
  if (!isClaimable(row) || (row.slack_attempts ?? 0) >= maxDeliveryAttempts) {
    if ((row.slack_attempts ?? 0) >= maxDeliveryAttempts && row.slack_status !== 'sent') {
      await store.update(table, id, { slack_status: 'failed', slack_next_retry_at: null, slack_last_error_code: 'retry_exhausted' });
    }
    return { kind: 'noop', status: 200 };
  }
  const attempt = (row.slack_attempts ?? 0) + 1;
  const claimed = await store.claim(table, id, attempt, now.toISOString());
  if (!claimed) return { kind: 'noop', status: 200 };

  const uidLimit = dependencies.uidLimit ?? 5;
  if (row.uid && await store.recentForUid(table, row.uid, new Date(now.getTime() - 10 * 60 * 1000).toISOString()) > uidLimit) {
    await store.update(table, id, { slack_status: 'suppressed', slack_last_error_code: 'rate_limited', slack_next_retry_at: null });
    return { kind: 'noop', status: 200 };
  }
  const webhook = dependencies.webhookFor(table);
  if (!webhook) {
    await store.update(table, id, { slack_status: 'suppressed', slack_last_error_code: 'webhook_not_configured', slack_next_retry_at: null });
    return { kind: 'disabled', status: 200 };
  }
  try {
    const response = await dependencies.postSlack(webhook, slackPayload(table, row));
    if (response.status === 200 && response.body.trim() === 'ok') {
      await store.update(table, id, { slack_status: 'sent', slack_notified_at: now.toISOString(), slack_next_retry_at: null, slack_last_error_code: null });
      return { kind: 'sent', status: 200 };
    }
    if (response.status === 429 || response.status >= 500) {
      await store.update(table, id, {
        slack_status: 'failed',
        slack_last_error_code: response.status === 429 ? 'http_429' : `http_${response.status}`,
        slack_next_retry_at: retryAt(attempt, now, response.retryAfter),
      });
    } else {
      await store.update(table, id, { slack_status: 'suppressed', slack_last_error_code: `http_${response.status}`, slack_next_retry_at: null });
    }
  } catch (_) {
    await store.update(table, id, { slack_status: 'failed', slack_last_error_code: 'timeout_or_network', slack_next_retry_at: retryAt(attempt, now) });
  }
  // Delivery is persisted and retried by Cron; a webhook invocation is complete.
  return { kind: 'noop', status: 200 };
}
