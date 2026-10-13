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

function containsAdultContent(text) {
  if (!text) return false;
  const adultRegex = /\b(porn|porno|pornography|sex|sexy|sexual|erotic|nude|naked|nudity|nsfw|boobs|penis|vagina|blowjob|masturbat\w*|horny|orgasm|intercourse|fetish|xxx|choda|chuda|magi|bessha|randi|chudi|chudai)\b/i;
  return adultRegex.test(text);
}

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
      const payload = {
        contents,
        safetySettings: [
          { category: 'HARM_CATEGORY_SEXUALLY_EXPLICIT', threshold: 'BLOCK_LOW_AND_ABOVE' },
          { category: 'HARM_CATEGORY_HATE_SPEECH', threshold: 'BLOCK_LOW_AND_ABOVE' },
          { category: 'HARM_CATEGORY_HARASSMENT', threshold: 'BLOCK_LOW_AND_ABOVE' },
          { category: 'HARM_CATEGORY_DANGEROUS_CONTENT', threshold: 'BLOCK_LOW_AND_ABOVE' },
        ],
        generationConfig: {
          maxOutputTokens: 85, // Strictly caps response to be short (1-2 sentences)
          temperature: 0.7,
        }
      };
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
        const candidate = data.candidates?.[0];
        if (candidate?.finishReason === 'SAFETY' || data.promptFeedback?.blockReason) {
          return "I cannot discuss adult or inappropriate topics. Let's keep our conversation friendly, clean, and positive!";
        }
        const reply = candidate?.content?.parts?.[0]?.text;
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
    const { mode_key, message, history, sessionId, feature, language_name, language_code } = req.body;
    if (!message || !message.trim()) {
      throw AppError.badRequest('Message is required');
    }

    // Strict adult content filter check
    if (containsAdultContent(message)) {
      let refusal = "I cannot discuss adult or inappropriate topics. Let's keep our conversation friendly, safe, and positive!";
      if (language_code === 'bn') {
        refusal = "আমি কোনো প্রাপ্তবয়স্ক বা আপত্তিকর বিষয়ে কথা বলতে পারি না। চলো ভালো ও সুন্দর কোনো বিষয় নিয়ে কথা বলি!";
      } else if (language_code === 'hi') {
        refusal = "मैं किसी भी अनुचित या वयस्क विषय पर बात नहीं कर सकता। आइए अच्छी बातें करें!";
      }
      return res.json({
        reply: refusal,
        sessionId
      });
    }

    let systemPrompt = `You are a warm, supportive, conversational AI English teacher.
MANDATORY RULES:
1. STRICTLY SHORT TEXT: Always keep responses very short and concise (strictly 1 to 2 short sentences, maximum 20 words). Never write long paragraphs.
2. STRICTLY NO ADULT CONTENT: Under NO circumstances engage in adult, sexual, NSFW, or inappropriate topics. Keep the session educational, clean, and family-friendly.
3. If the user makes a grammar mistake, briefly show the correction before continuing.`;

    if (feature === 'ai_friend') {
      const featRow = await db('features').where({ key: 'ai_friend' }).first();
      if (featRow && !featRow.is_enabled) {
        throw AppError.forbidden('AI Friend feature is currently disabled by administrator');
      }

      const lang = language_name || 'English';
      systemPrompt = `You are a warm, kind, caring, and enthusiastic conversational AI companion named Translivo AI Friend. 
The user is speaking and chatting with you in ${lang}.
MANDATORY RULES YOU MUST STRICTLY FOLLOW:
1. STRICTLY SHORT TEXT: Always keep your response very short and concise (strictly 1 to 2 short sentences, maximum 15 to 25 words). Never write long paragraphs or long explanations. Every response MUST be brief and conversational.
2. STRICTLY NO ADULT CONTENT: Under NO circumstances engage in adult, sexual, romantic, NSFW, 18+, vulgar, or explicit conversations. If the user mentions or asks for anything adult or inappropriate, immediately refuse politely in ONE short sentence: "Let's keep our conversation clean, friendly, and respectful."
3. Language: Always converse, think, and reply entirely in ${lang}.
4. Tone: Friendly, polite, cheerful, and caring like a true friend.
5. No markdown: Do NOT use markdown symbols (** or * or #) because your message will be read aloud by text-to-speech.`;
    } else if (mode_key) {
      const mode = await db('practice_modes').where({ key: mode_key }).first();
      if (mode?.prompt) {
        systemPrompt = mode.prompt + ' MANDATORY RULES: Always keep responses strictly short (1-2 sentences maximum, under 20 words). Absolutely NO adult, sexual, or inappropriate content allowed under any circumstance.';
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

