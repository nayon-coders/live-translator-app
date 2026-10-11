import { Router } from 'express';
import { z } from 'zod';
import { db } from '../../db/index.js';
import { requireAdmin, requireRole } from '../../middleware/auth.js';

export const adminSettingsRouter = Router();

// Ensure all routes require at least 'admin' role, and 'owner' for sensitive operations.
adminSettingsRouter.use(requireAdmin);

// ==========================================
// SETTINGS
// ==========================================
adminSettingsRouter.get('/settings', async (req, res, next) => {
  try {
    const rows = await db('settings').select('*');
    // convert array of {key, value} to a key-value object
    const settings = rows.reduce((acc, row) => {
      acc[row.key] = row.value;
      return acc;
    }, {});
    res.json({ data: settings });
  } catch (err) { next(err); }
});

adminSettingsRouter.patch('/settings', requireRole(['owner', 'admin']), async (req, res, next) => {
  try {
    const schema = z.record(z.any());
    const updates = schema.parse(req.body);
    
    await db.transaction(async (trx) => {
      for (const [key, value] of Object.entries(updates)) {
        // Upsert setting
        const exists = await trx('settings').where({ key }).first();
        if (exists) {
          await trx('settings').where({ key }).update({ value: JSON.stringify(value) });
        } else {
          await trx('settings').insert({ key, value: JSON.stringify(value) });
        }
      }
      
      // Audit log
      await trx('audit_logs').insert({
        admin_id: req.admin.id,
        action: 'UPDATE',
        entity: 'settings',
        changes: JSON.stringify(updates),
        ip: req.ip
      });
    });
    
    res.json({ message: 'Settings updated' });
  } catch (err) { next(err); }
});

// ==========================================
// FEATURES
// ==========================================
adminSettingsRouter.get('/features', async (req, res, next) => {
  try {
    const features = await db('features').orderBy('sort_order', 'asc');
    res.json({ data: features });
  } catch (err) { next(err); }
});

adminSettingsRouter.patch('/features/:key', requireRole(['owner', 'admin']), async (req, res, next) => {
  try {
    const schema = z.object({
      name: z.string().optional(),
      description: z.string().optional(),
      icon: z.string().optional(),
      is_enabled: z.boolean().optional(),
      sort_order: z.number().int().optional(),
      config: z.any().optional(),
    });
    
    const updates = schema.parse(req.body);
    if (updates.config !== undefined) updates.config = JSON.stringify(updates.config);
    
    await db('features').where({ key: req.params.key }).update(updates);
    res.json({ message: 'Feature updated' });
  } catch (err) { next(err); }
});

// ==========================================
// LANGUAGES
// ==========================================
adminSettingsRouter.get('/languages', async (req, res, next) => {
  try {
    const languages = await db('languages').orderBy('sort_order', 'asc');
    res.json({ data: languages });
  } catch (err) { next(err); }
});

adminSettingsRouter.post('/languages', requireRole(['owner', 'admin']), async (req, res, next) => {
  try {
    const schema = z.object({
      code: z.string(),
      name: z.string(),
      native_name: z.string(),
      iso3: z.string().length(3),
      flag: z.string(),
      stt_locale: z.string().optional(),
      tts_locale: z.string().optional(),
      is_enabled: z.boolean().default(true),
      sort_order: z.number().int().default(0),
    });
    
    const data = schema.parse(req.body);
    await db('languages').insert(data);
    res.status(201).json({ message: 'Language created', data });
  } catch (err) { next(err); }
});

adminSettingsRouter.patch('/languages/:code', requireRole(['owner', 'admin']), async (req, res, next) => {
  try {
    const schema = z.object({
      name: z.string().optional(),
      native_name: z.string().optional(),
      iso3: z.string().length(3).optional(),
      flag: z.string().optional(),
      stt_locale: z.string().optional(),
      tts_locale: z.string().optional(),
      is_enabled: z.boolean().optional(),
      sort_order: z.number().int().optional(),
    });
    
    const updates = schema.parse(req.body);
    await db('languages').where({ code: req.params.code }).update(updates);
    res.json({ message: 'Language updated' });
  } catch (err) { next(err); }
});

// ==========================================
// PRACTICE MODES
// ==========================================
adminSettingsRouter.get('/practice-modes', async (req, res, next) => {
  try {
    const modes = await db('practice_modes').orderBy('sort_order', 'asc');
    res.json({ data: modes });
  } catch (err) { next(err); }
});

adminSettingsRouter.patch('/practice-modes/:key', requireRole(['owner', 'admin']), async (req, res, next) => {
  try {
    const schema = z.object({
      title: z.string().optional(),
      description: z.string().optional(),
      icon: z.string().optional(),
      is_enabled: z.boolean().optional(),
      sort_order: z.number().int().optional(),
      prompt: z.string().optional(),
      opening_line: z.string().optional(),
    });
    
    const updates = schema.parse(req.body);
    await db('practice_modes').where({ key: req.params.key }).update(updates);
    res.json({ message: 'Practice mode updated' });
  } catch (err) { next(err); }
});

// ==========================================
// ENGLISH LEVELS
// ==========================================
adminSettingsRouter.get('/levels', async (req, res, next) => {
  try {
    const levels = await db('english_levels').orderBy('code', 'asc');
    res.json({ data: levels });
  } catch (err) { next(err); }
});

adminSettingsRouter.patch('/levels/:code', requireRole(['owner', 'admin']), async (req, res, next) => {
  try {
    const schema = z.object({
      name: z.string().optional(),
      description: z.string().optional(),
      prompt_hint: z.string().optional(),
      is_enabled: z.boolean().optional(),
    });
    
    const updates = schema.parse(req.body);
    await db('english_levels').where({ code: req.params.code }).update(updates);
    res.json({ message: 'Level updated' });
  } catch (err) { next(err); }
});
