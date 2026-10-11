import { Router } from 'express';
import crypto from 'node:crypto';
import { db } from '../../db/index.js';
import { AppError } from '../../utils/app-error.js';
import { requireDevice } from '../app/app.routes.js';
import { getGeminiKey } from '../admin/secrets.service.js';

export const liveRouter = Router();

liveRouter.post('/sessions', requireDevice, async (req, res, next) => {
  try {
    // 1. Check quotas (simplified for now: just ensure device is active)
    const device = await db('devices').where({ id: req.device.id }).first();
    if (!device || device.status === 'blocked') {
      throw AppError.forbidden('Device is blocked or invalid');
    }

    // 2. Mint an ephemeral session token that our own WS proxy will accept
    const sessionId = crypto.randomUUID();
    const token = crypto.randomBytes(32).toString('hex');
    
    const { mode_key, level_code } = req.body;

    // 3. Save the session to DB in 'pending' state with the token
    await db('live_sessions').insert({
      id: sessionId,
      device_id: device.id,
      mode_key: mode_key || null,
      level_code: level_code || null,
      model: 'gemini-2.0-flash-exp',
      status: 'pending',
      proxy_token: token,
      started_at: db.fn.now(),
    });

    // 4. Return the connection details
    res.json({
      sessionId,
      token,
      wsUrl: `ws://${req.get('host')}/ws/live`,
      model: 'gemini-2.0-flash-exp',
      expiresAt: new Date(Date.now() + 15 * 60000).toISOString(), // 15 mins
      maxSessionSeconds: 900
    });
  } catch (err) {
    next(err);
  }
});

liveRouter.post('/sessions/:id/end', requireDevice, async (req, res, next) => {
  try {
    const { id } = req.params;
    const { duration_sec, end_reason } = req.body;
    
    await db('live_sessions').where({ id, device_id: req.device.id }).update({
      status: 'completed',
      ended_at: db.fn.now(),
      duration_sec: duration_sec || 0,
      end_reason: end_reason || 'user_ended'
    });
    
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
});

async function callGeminiChat({ systemPrompt, history = [], message }) {
  const geminiKey = await getGeminiKey();
  if (!geminiKey) {
    throw AppError.internal('Gemini API key not configured on server');
  }

  const contents = [];
  if (Array.isArray(history)) {
    for (const h of history) {
      if (h.text && h.text.trim()) {
        contents.push({
          role: h.role === 'ai' || h.role === 'assistant' || h.role === 'model' ? 'model' : 'user',
          parts: [{ text: h.text }]
        });
      }
    }
  }
  contents.push({
    role: 'user',
    parts: [{ text: message }]
  });

  const modelsToTry = [
    'gemini-3.5-flash',
    'gemini-3.8-flash',
    'gemini-flash-latest',
    'gemini-3.1-flash-lite'
  ];

  let lastError = null;
  for (const model of modelsToTry) {
    try {
      const url = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${geminiKey}`;
      const payload = { contents };
      if (systemPrompt) {
        payload.systemInstruction = {
          parts: [{ text: systemPrompt }]
        };
      }

      const res = await fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      });

      if (res.ok) {
        const data = await res.json();
        const reply = data.candidates?.[0]?.content?.parts?.[0]?.text;
        if (reply) {
          return reply.trim();
        }
      } else {
        const errData = await res.text();
        lastError = new Error(`Gemini ${model} error (${res.status}): ${errData}`);
      }
    } catch (e) {
      lastError = e;
    }
  }

  throw lastError || new Error('Failed to generate response from Gemini');
}

liveRouter.post('/chat', requireDevice, async (req, res, next) => {
  try {
    const { mode_key, message, history, sessionId } = req.body;
    if (!message || !message.trim()) {
      throw AppError.badRequest('Message is required');
    }

    let systemPrompt = 'You are a warm, supportive, conversational AI English teacher. Keep responses concise (1-3 sentences) so the conversation is lively and easy to follow. If the user makes a grammar or pronunciation mistake, gently correct it before responding to the message.';
    if (mode_key) {
      const mode = await db('practice_modes').where({ key: mode_key }).first();
      if (mode?.prompt) {
        systemPrompt = mode.prompt + ' Keep your responses concise (1-3 sentences) suitable for spoken English conversation.';
      }
    }

    const reply = await callGeminiChat({ systemPrompt, history, message });

    res.json({
      reply,
      sessionId
    });
  } catch (err) {
    next(err);
  }
});

