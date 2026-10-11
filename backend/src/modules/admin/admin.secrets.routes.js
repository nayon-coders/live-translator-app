import { Router } from 'express';
import { z } from 'zod';
import { db } from '../../db/index.js';
import { requireAdmin, requireRole } from '../../middleware/auth.js';
import { encryptSecret, decryptSecret } from '../../utils/crypto.js';

export const adminSecretsRouter = Router();

adminSecretsRouter.use(requireAdmin);

// ==========================================
// GEMINI API KEY
// ==========================================

adminSecretsRouter.get('/secrets/gemini', requireRole(['owner', 'admin']), async (req, res, next) => {
  try {
    const row = await db('secrets').where({ name: 'gemini_api_key' }).first();
    if (!row) {
      return res.json({ exists: false, last4: null, updated_at: null });
    }
    res.json({
      exists: true,
      last4: row.last4,
      updated_at: row.updated_at,
    });
  } catch (err) { next(err); }
});

adminSecretsRouter.post('/secrets/gemini', requireRole(['owner']), async (req, res, next) => {
  try {
    const schema = z.object({
      api_key: z.string().min(10, 'API key must be provided'),
    });
    
    const { api_key } = schema.parse(req.body);
    const encrypted = encryptSecret(api_key);
    
    await db.transaction(async (trx) => {
      const exists = await trx('secrets').where({ name: 'gemini_api_key' }).first();
      
      if (exists) {
        await trx('secrets')
          .where({ name: 'gemini_api_key' })
          .update({
            ciphertext: encrypted.ciphertext,
            iv: encrypted.iv,
            auth_tag: encrypted.auth_tag,
            last4: encrypted.last4,
          });
      } else {
        await trx('secrets').insert({
          name: 'gemini_api_key',
          ciphertext: encrypted.ciphertext,
          iv: encrypted.iv,
          auth_tag: encrypted.auth_tag,
          last4: encrypted.last4,
        });
      }
      
      await trx('audit_logs').insert({
        admin_id: req.admin.id,
        action: 'UPDATE_SECRET',
        entity: 'secrets',
        entity_id: 'gemini_api_key',
        ip: req.ip
      });
    });
    
    res.json({ message: 'Gemini API key saved securely' });
  } catch (err) { next(err); }
});

adminSecretsRouter.post('/secrets/gemini/test', requireRole(['owner', 'admin']), async (req, res, next) => {
  try {
    const row = await db('secrets').where({ name: 'gemini_api_key' }).first();
    if (!row) {
      throw AppError.badRequest('No Gemini API key configured');
    }
    
    const apiKey = decryptSecret(row.ciphertext, row.iv, row.auth_tag);
    
    // Call the models endpoint to test validity
    const response = await fetch(`https://generativelanguage.googleapis.com/v1beta/models?key=${apiKey}`);
    
    if (response.ok) {
      res.json({ success: true, message: 'Connection to Gemini API successful' });
    } else {
      const errorData = await response.json().catch(() => ({}));
      res.json({ 
        success: false, 
        message: 'Failed to connect to Gemini API', 
        details: errorData.error?.message || response.statusText 
      });
    }
  } catch (err) { next(err); }
});
