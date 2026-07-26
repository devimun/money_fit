import { assertEquals, assertMatch } from 'https://deno.land/std@0.224.0/assert/mod.ts';
import { deliver, safePlainText, slackPayload, type DeliveryRow, type DeliveryStore, type DeliveryTable } from './delivery.ts';

const id = '123e4567-e89b-12d3-a456-426614174000';
const now = new Date('2026-07-21T00:00:00.000Z');

class MemoryStore implements DeliveryStore {
  constructor(readonly row: DeliveryRow) {}
  claimed = false;
  updates: Record<string, unknown>[] = [];
  recent = 0;
  async read(_table: DeliveryTable, _id: string) { return this.row; }
  async recoverStale(_table: DeliveryTable, _id: string, _before: string) { if (this.row.slack_status === 'processing') this.row.slack_status = 'failed'; }
  async claim(_table: DeliveryTable, _id: string, attempts: number, _processingAt: string) { if (this.claimed || !['pending', 'failed'].includes(this.row.slack_status ?? '')) return false; this.claimed = true; this.row.slack_attempts = attempts; this.row.slack_status = 'processing'; return true; }
  async update(_table: DeliveryTable, _id: string, values: Record<string, unknown>) { this.updates.push(values); Object.assign(this.row, values); }
  async recentForUid(_table: DeliveryTable, _uid: string, _since: string) { return this.recent; }
}

function store(status: DeliveryRow['slack_status'] = 'pending') {
  return new MemoryStore({ id, uid: 'u', details: '@channel <danger>\nhello', slack_status: status, slack_attempts: 0, created_at: now.toISOString() });
}

Deno.test('safe payload is plain text and never puts user content in fallback text', () => {
  const payload = slackPayload('user_contact', store().row);
  assertEquals(payload.text, 'MoneyFit delivery 123e4567');
  const blocks = payload.blocks as Array<Record<string, unknown>>;
  assertEquals(((blocks[2].text as Record<string, unknown>).type), 'plain_text');
  assertEquals(safePlainText('a\u0000\nb'), 'a b');
});

for (const [status, expectedStatus, expectedCode] of [
  [200, 'sent', null], [400, 'suppressed', 'http_400'], [403, 'suppressed', 'http_403'], [404, 'suppressed', 'http_404'], [429, 'failed', 'http_429'], [500, 'failed', 'http_500'],
] as const) {
  Deno.test(`Slack ${status} records ${expectedStatus}`, async () => {
    const memory = store();
    await deliver('user_contact', id, { store: memory, now: () => now, webhookFor: () => 'https://example.test', postSlack: async () => ({ status, body: status === 200 ? 'ok' : 'error', retryAfter: '120' }) });
    assertEquals(memory.row.slack_status, expectedStatus);
    assertEquals(memory.row.slack_last_error_code, expectedCode);
    if (status === 429 || status === 500) assertMatch(memory.row.slack_next_retry_at as string, /^2026-/);
  });
}

Deno.test('timeout, exhausted retries, stale rows and concurrent claims are bounded', async () => {
  const timeout = store();
  await deliver('user_contact', id, { store: timeout, now: () => now, webhookFor: () => 'https://example.test', postSlack: async () => { throw new Error('timeout'); } });
  assertEquals(timeout.row.slack_last_error_code, 'timeout_or_network');
  const exhausted = store(); exhausted.row.slack_attempts = 5;
  await deliver('user_contact', id, { store: exhausted, now: () => now, webhookFor: () => 'https://example.test', postSlack: async () => ({ status: 200, body: 'ok' }) });
  assertEquals(exhausted.row.slack_last_error_code, 'retry_exhausted');
  const stale = store('processing'); stale.row.slack_processing_at = '2026-07-20T00:00:00.000Z';
  await deliver('user_contact', id, { store: stale, now: () => now, webhookFor: () => 'https://example.test', postSlack: async () => ({ status: 200, body: 'ok' }) });
  assertEquals(stale.row.slack_status, 'sent');
  const concurrent = store(); let posts = 0;
  await Promise.all([deliver('user_contact', id, { store: concurrent, now: () => now, webhookFor: () => 'https://example.test', postSlack: async () => ({ status: 200, body: (++posts, 'ok') }) }), deliver('user_contact', id, { store: concurrent, now: () => now, webhookFor: () => 'https://example.test', postSlack: async () => ({ status: 200, body: (++posts, 'ok') }) })]);
  assertEquals(posts, 1);
});
