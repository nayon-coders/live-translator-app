import { Router } from 'express';
import jwt from 'jsonwebtoken';
import { z } from 'zod';
import crypto from 'node:crypto';
import { db } from '../../db/index.js';
import { env } from '../../config/env.js';
import { AppError } from '../../utils/app-error.js';

export const appRouter = Router();

// Middleware to verify device token
export function requireDevice(req, _res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return next(AppError.unauthorized('Device token required'));
  }

  const token = authHeader.split(' ')[1];
  try {
    const payload = jwt.verify(token, env.JWT_DEVICE_SECRET);
    req.device = payload;
    next();
  } catch (err) {
    return next(AppError.unauthorized('Invalid or expired device token'));
  }
}

// ==========================================
// DEVICE REGISTRATION
// ==========================================
appRouter.post('/devices/register', async (req, res, next) => {
  try {
    const schema = z.object({
      install_id: z.string().min(1),
      platform: z.string().optional(),
      app_version: z.string().optional(),
      os_version: z.string().optional(),
    });
    
    const data = schema.parse(req.body);
    let deviceId;

    await db.transaction(async (trx) => {
      const existing = await trx('devices').where({ install_id: data.install_id }).first();
      
      if (existing) {
        if (existing.status === 'blocked') {
          throw AppError.forbidden('Device is blocked');
        }
        await trx('devices').where({ id: existing.id }).update({
          platform: data.platform,
          app_version: data.app_version,
          os_version: data.os_version,
          last_seen_at: trx.fn.now()
        });
        deviceId = existing.id;
      } else {
        const [id] = await trx('devices').insert({
          install_id: data.install_id,
          platform: data.platform,
          app_version: data.app_version,
          os_version: data.os_version,
        });
        deviceId = id;
      }
    });

    const token = jwt.sign(
      { id: deviceId, install_id: data.install_id },
      env.JWT_DEVICE_SECRET,
      { expiresIn: '30d' }
    );

    res.json({ token, device_id: deviceId });
  } catch (err) { next(err); }
});

// ==========================================
// APP CONFIG
// ==========================================
appRouter.get('/config', requireDevice, async (req, res, next) => {
  try {
    // Check if device is blocked
    const device = await db('devices').where({ id: req.device.id }).first();
    if (!device || device.status === 'blocked') {
      throw AppError.forbidden('Device is blocked');
    }
    
    await db('devices').where({ id: req.device.id }).update({ last_seen_at: db.fn.now() });

    const [settings, features, languages, modes, levels] = await Promise.all([
      db('settings').select('*'),
      db('features').where({ is_enabled: true }).orderBy('sort_order', 'asc'),
      db('languages').where({ is_enabled: true }).orderBy('sort_order', 'asc'),
      db('practice_modes').where({ is_enabled: true }).orderBy('sort_order', 'asc'),
      db('english_levels').where({ is_enabled: true }).orderBy('code', 'asc'),
    ]);

    const settingsMap = settings.reduce((acc, row) => {
      acc[row.key] = row.value;
      return acc;
    }, {});

    const configData = {
      settings: settingsMap,
      features,
      languages,
      modes,
      levels,
    };

    // Calculate ETag
    const configString = JSON.stringify(configData);
    const hash = crypto.createHash('md5').update(configString).digest('hex');
    const etag = `"${hash}"`;

    if (req.headers['if-none-match'] === etag) {
      return res.status(304).send();
    }

    res.setHeader('ETag', etag);
    res.json(configData);
  } catch (err) { next(err); }
});
