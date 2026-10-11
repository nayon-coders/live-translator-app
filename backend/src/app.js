import express from 'express';
import helmet from 'helmet';
import cors from 'cors';
import cookieParser from 'cookie-parser';
import { pinoHttp } from 'pino-http';
import { randomUUID } from 'node:crypto';

import { env } from './config/env.js';
import { logger } from './utils/logger.js';
import { errorHandler, notFoundHandler } from './middleware/error-handler.js';
import { authRouter } from './modules/auth/auth.routes.js';
import { adminSettingsRouter } from './modules/admin/admin.settings.routes.js';
import { adminSecretsRouter } from './modules/admin/admin.secrets.routes.js';
import { adminStatsRouter } from './modules/admin/admin.stats.routes.js';
import { appRouter } from './modules/app/app.routes.js';
import { liveRouter } from './modules/live/live.routes.js';

const startedAt = Date.now();

/**
 * Builds the Express application (no network listening here, so tests can
 * use supertest against the same instance).
 */
export function createApp() {
  const app = express();

  app.disable('x-powered-by');
  if (env.TRUST_PROXY) app.set('trust proxy', 1);

  app.use(
    pinoHttp({
      logger,
      genReqId: (req, res) => {
        const id = req.headers['x-request-id'] || randomUUID();
        res.setHeader('x-request-id', id);
        return id;
      },
      autoLogging: { ignore: (req) => req.url === '/api/v1/health' },
    }),
  );

  app.use(helmet());
  app.use(
    cors({
      // Mobile apps send no Origin header; browsers must be on the allow-list.
      origin: (origin, cb) => cb(null, !origin || env.corsOrigins.includes(origin)),
      credentials: true,
    }),
  );
  app.use(express.json({ limit: '256kb' }));
  app.use(cookieParser());

  // ---- Routes -------------------------------------------------------------
  app.get('/api/v1/health', (_req, res) => {
    res.json({
      status: 'ok',
      service: 'translivo-api',
      uptimeSec: Math.round((Date.now() - startedAt) / 1000),
      time: new Date().toISOString(),
    });
  });

  app.use('/api/admin/auth', authRouter);
  app.use('/api/admin', adminSettingsRouter);
  app.use('/api/admin', adminSecretsRouter);
  app.use('/api/admin', adminStatsRouter);
  app.use('/api/v1', appRouter);
  app.use('/api/v1/live', liveRouter);

  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
}
