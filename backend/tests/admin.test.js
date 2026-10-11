import { test } from 'node:test';
import assert from 'node:assert/strict';
import request from 'supertest';
import jwt from 'jsonwebtoken';
import { createApp } from '../src/app.js';
import { env } from '../src/config/env.js';

const app = createApp();

function generateToken(role = 'owner') {
  return jwt.sign({ id: 1, role }, env.JWT_ADMIN_SECRET, { expiresIn: '1h' });
}

test('Admin API requires auth', async () => {
  const res = await request(app).get('/api/admin/features');
  assert.equal(res.status, 401);
});

test('GET /api/admin/features returns data', async () => {
  const token = generateToken();
  const res = await request(app)
    .get('/api/admin/features')
    .set('Cookie', [`admin_token=${token}`]);
  
  assert.equal(res.status, 200);
  assert.ok(Array.isArray(res.body.data));
});

test('PATCH /api/admin/features requires owner/admin', async () => {
  const viewerToken = generateToken('viewer');
  const res = await request(app)
    .patch('/api/admin/features/english_teacher')
    .set('Cookie', [`admin_token=${viewerToken}`])
    .send({ name: 'Updated' });
    
  assert.equal(res.status, 403);
});
