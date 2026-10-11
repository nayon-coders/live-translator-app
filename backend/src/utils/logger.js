import pino from 'pino';
import { env } from '../config/env.js';

/**
 * Structured logger. Sensitive fields are redacted everywhere so API keys,
 * tokens and passwords never reach log output.
 */
export const logger = pino({
  level: env.isTest ? 'silent' : env.LOG_LEVEL,
  redact: {
    paths: [
      'req.headers.authorization',
      'req.headers.cookie',
      'req.headers["x-goog-api-key"]',
      'res.headers["set-cookie"]',
      '*.password',
      '*.passwordHash',
      '*.apiKey',
      '*.token',
      '*.accessToken',
    ],
    censor: '[REDACTED]',
  },
  transport: env.isProd || env.isTest ? undefined : { target: 'pino-pretty', options: { colorize: true, translateTime: 'SYS:HH:MM:ss' } },
});
