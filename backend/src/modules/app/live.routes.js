import { Router } from 'express';
import { z } from 'zod';
import { randomUUID } from 'node:crypto';
import { db } from '../../db/index.js';
import { AppError } from '../../utils/app-error.js';
import { requireDevice } from './app.routes.js';
import { decryptSecret } from '../../utils/crypto.js';

export const liveRouter = Router();

liveRouter.use(requireDevice);

// ==========================================
// START LIVE SESSION (MINT TOKEN)
// ==========================================
liveRouter.post('/sessions', async (req, res, next) => {
  try {
    const schema = z.object({
      mode_key: z.string().optional(),
      level_code: z.string().optional(),
    });
    const { mode_key, level_code } = schema.parse(req.body);

    // 1. Fetch configured limits & settings
    const [apiKeyRow, settingsRow, featureRow, modeRow] = await Promise.all([
      db('secrets').where({ name: 'gemini_api_key' }).first(),
      db('settings').where({ key: 'daily_limit_minutes' }).first(),
      db('features').where({ key: 'english_teacher' }).first(),
      mode_key ? db('practice_modes').where({ key: mode_key }).first() : Promise.resolve(null),
    ]);

    if (!featureRow || !featureRow.is_enabled) {
      throw AppError.forbidden('English Teacher feature is currently disabled');
    }
    if (!apiKeyRow) {
      throw AppError.unavailable('AI services are temporarily unavailable (API key not set)');
    }

    const apiKey = decryptSecret(apiKeyRow.ciphertext, apiKeyRow.iv, apiKeyRow.auth_tag);

    // 2. Enforce quotas (simplified: check today's usage for this device)
    const limitMinutes = settingsRow ? parseInt(settingsRow.value, 10) : 30;
    
    const [usageResult] = await db('live_sessions')
      .where({ device_id: req.device.id })
      .andWhere('started_at', '>=', db.raw('CURDATE()'))
      .sum('duration_sec as total_sec');
      
    const usedSeconds = usageResult?.total_sec || 0;
    const maxSessionSeconds = (limitMinutes * 60) - usedSeconds;
    
    if (maxSessionSeconds <= 0) {
      throw AppError.tooMany('Daily usage limit reached');
    }

    // 3. Create Session Record
    const sessionId = randomUUID();
    const model = 'models/gemini-3.8-live';

    await db('live_sessions').insert({
      id: sessionId,
      device_id: req.device.id,
      mode_key: mode_key || null,
      level_code: level_code || null,
      model,
      status: 'active',
    });

    // 4. Mint Ephemeral Token from Gemini API
    // See: https://ai.google.dev/gemini-api/docs/live-api/ephemeral-tokens
    const now = new Date();
    // Maximum token duration is 30 mins, but we cap it at remaining daily quota (max 30 mins)
    const tokenMinutes = Math.min(Math.ceil(maxSessionSeconds / 60), 30);
    
    const expireTime = new Date(now.getTime() + tokenMinutes * 60 * 1000).toISOString();
    const newSessionExpireTime = new Date(now.getTime() + 1 * 60 * 1000).toISOString();

    const tokenResponse = await fetch('https://generativelanguage.googleapis.com/v1beta/auth_tokens', {
      method: 'POST',
      headers: {
        'x-goog-api-key': apiKey,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        uses: 1, // Token can only be used once to establish a session
        expireTime,
        newSessionExpireTime,
        liveConnectConstraints: {
          model: model,
          config: {
            sessionResumption: {},
            responseModalities: ["AUDIO"],
            // System instruction would be attached here if needed:
            // systemInstruction: { parts: [{ text: modeRow?.prompt || '' }] }
          }
        }
      })
    });

    if (!tokenResponse.ok) {
      const errorData = await tokenResponse.json().catch(() => ({}));
      // Clean up session if token minting fails
      await db('live_sessions').where({ id: sessionId }).update({ status: 'failed', end_reason: 'token_mint_failed' });
      throw AppError.unavailable('Failed to provision AI token', errorData);
    }

    const tokenData = await tokenResponse.json();

    // 5. Return token to client
    res.json({
      sessionId,
      token: tokenData.name,
      wsUrl: `wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1beta.GenerativeService.BidiGenerateContentConstrained?access_token=${tokenData.name}`,
      model,
      expiresAt: expireTime,
      maxSessionSeconds,
    });
  } catch (err) { next(err); }
});

// ==========================================
// END LIVE SESSION (REPORTING)
// ==========================================
liveRouter.post('/sessions/:id/end', async (req, res, next) => {
  try {
    const schema = z.object({
      duration_sec: z.number().int().min(0),
      total_words: z.number().int().min(0).optional(),
      fluency_score: z.number().int().min(0).max(100).optional(),
      grammar_score: z.number().int().min(0).max(100).optional(),
      vocabulary_score: z.number().int().min(0).max(100).optional(),
      summary: z.any().optional(),
      end_reason: z.string().optional(),
    });
    
    const data = schema.parse(req.body);
    const { id } = req.params;

    const session = await db('live_sessions').where({ id, device_id: req.device.id }).first();
    if (!session) {
      throw AppError.notFound('Session not found');
    }

    if (data.summary !== undefined) data.summary = JSON.stringify(data.summary);

    await db('live_sessions').where({ id }).update({
      ...data,
      status: 'completed',
      ended_at: db.fn.now(),
    });

    res.json({ message: 'Session updated' });
  } catch (err) { next(err); }
});
