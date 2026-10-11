import { test } from 'node:test';
import assert from 'node:assert/strict';
import request from 'supertest';
import { createApp } from '../src/app.js';

const app = createApp();

test('GET /api/v1/health returns ok', async () => {
  const res = await request(app).get('/api/v1/health');
  assert.equal(res.status, 200);
  assert.equal(res.body.status, 'ok');
  assert.ok(res.headers['x-request-id']);
});

test('unknown route returns JSON 404 envelope', async () => {
  const res = await request(app).get('/api/v1/nope');
  assert.equal(res.status, 404);
  assert.equal(res.body.error.code, 'NOT_FOUND');
});

test('malformed JSON returns 400', async () => {
  const res = await request(app).post('/api/v1/health').set('content-type', 'application/json').send('{bad');
  assert.equal(res.status, 400);
  assert.equal(res.body.error.code, 'BAD_REQUEST');
});

test('security headers are set and x-powered-by is hidden', async () => {
  const res = await request(app).get('/api/v1/health');
  assert.equal(res.headers['x-powered-by'], undefined);
  assert.ok(res.headers['x-content-type-options']);
});
