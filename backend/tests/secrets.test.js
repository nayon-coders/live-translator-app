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

test('Secrets API requires owner role to save key', async () => {
  const adminToken = generateToken('admin');
  const res = await request(app)
    .post('/api/admin/secrets/gemini')
    .set('Cookie', [`admin_token=${adminToken}`])
    .send({ api_key: 'fake_key_1234567890' });
    
  assert.equal(res.status, 403);
});

test('Owner can save Gemini API key and read status', async () => {
  const ownerToken = generateToken('owner');
  
  const saveRes = await request(app)
    .post('/api/admin/secrets/gemini')
    .set('Cookie', [`admin_token=${ownerToken}`])
    .send({ api_key: 'AIzaSyA_fake_test_key_for_translivo' });
    
  assert.equal(saveRes.status, 200);
  assert.equal(saveRes.body.message, 'Gemini API key saved securely');
  
  const getRes = await request(app)
    .get('/api/admin/secrets/gemini')
    .set('Cookie', [`admin_token=${ownerToken}`]);
    
  assert.equal(getRes.status, 200);
  assert.equal(getRes.body.exists, true);
  assert.equal(getRes.body.last4, 'livo');
});
