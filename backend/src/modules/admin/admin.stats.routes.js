import { Router } from 'express';
import { db } from '../../db/index.js';
import { requireAdmin, requireRole } from '../../middleware/auth.js';

export const adminStatsRouter = Router();

adminStatsRouter.use(requireAdmin);

adminStatsRouter.get('/stats', requireRole(['owner', 'admin']), async (req, res, next) => {
  try {
    const today = new Date().toISOString().split('T')[0];

    const [
      totalDevicesRes,
      totalSessionsRes,
      todaySessionsRes,
      todayDurationRes
    ] = await Promise.all([
      db('devices').count('* as count').first(),
      db('live_sessions').count('* as count').first(),
      db('live_sessions').where('started_at', '>=', today).count('* as count').first(),
      db('live_sessions').where('started_at', '>=', today).sum('duration_sec as total_sec').first(),
    ]);

    const recentSessions = await db('live_sessions')
      .select('id', 'device_id', 'status', 'started_at', 'duration_sec')
      .orderBy('started_at', 'desc')
      .limit(10);

    res.json({
      metrics: {
        total_devices: Number(totalDevicesRes?.count || 0),
        total_sessions: Number(totalSessionsRes?.count || 0),
        today_sessions: Number(todaySessionsRes?.count || 0),
        today_duration_minutes: Math.round((todayDurationRes?.total_sec || 0) / 60),
      },
      recent_sessions: recentSessions,
    });
  } catch (err) { next(err); }
});
