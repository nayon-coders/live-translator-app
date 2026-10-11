import { test } from 'node:test';
import assert from 'node:assert/strict';
import request from 'supertest';
import { createApp } from '../src/app.js';
import { db } from '../src/db/index.js';

const app = createApp();

test('App API: device registration and config flow', async () => {
  // 1. Register a device
  const regRes = await request(app)
    .post('/api/v1/devices/register')
    .send({
      install_id: 'test-install-uuid-1234',
      platform: 'ios',
      app_version: '1.0.0',
    });
    
  assert.equal(regRes.status, 200);
  assert.ok(regRes.body.token);
  assert.ok(regRes.body.device_id);
  
  const token = regRes.body.token;
  
  // 2. Fetch config without token (should fail)
  const failRes = await request(app).get('/api/v1/config');
  assert.equal(failRes.status, 401);
  
  // 3. Fetch config with token (should succeed)
  const configRes = await request(app)
    .get('/api/v1/config')
    .set('Authorization', `Bearer ${token}`);
    
  assert.equal(configRes.status, 200);
  assert.ok(configRes.body.settings);
  assert.ok(Array.isArray(configRes.body.features));
  assert.ok(configRes.headers.etag);
  
  // 4. Test ETag caching
  const etagRes = await request(app)
    .get('/api/v1/config')
    .set('Authorization', `Bearer ${token}`)
    .set('If-None-Match', configRes.headers.etag);
    
  assert.equal(etagRes.status, 304); // Not Modified
  
  // Clean up
  await db('devices').where({ install_id: 'test-install-uuid-1234' }).del();
});
