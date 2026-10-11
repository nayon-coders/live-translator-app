import { ZodError } from 'zod';
import { AppError } from '../utils/app-error.js';
import { logger } from '../utils/logger.js';
import fs from 'node:fs';

export function notFoundHandler(req, _res, next) {
  next(AppError.notFound(`Route ${req.method} ${req.originalUrl} not found`));
}

/**
 * Central error handler. Always responds with:
 *   { error: { code, message, details? } }
 * Unexpected errors are logged with full stack but only a generic message is returned.
 */
// eslint-disable-next-line no-unused-vars
export function errorHandler(err, req, res, _next) {
  if (err instanceof ZodError) {
    err = AppError.badRequest('Validation failed', err.issues.map((i) => ({ path: i.path.join('.'), message: i.message })));
  }

  // Malformed JSON body from express.json()
  if (err?.type === 'entity.parse.failed') {
    err = AppError.badRequest('Malformed JSON body');
  }

  if (err instanceof AppError) {
    if (err.status >= 500) logger.warn({ code: err.code, path: req.originalUrl }, err.message);
    return res.status(err.status).json({
      error: { code: err.code, message: err.message, ...(err.details ? { details: err.details } : {}) },
    });
  }

  logger.error({ err, path: req.originalUrl, method: req.method }, 'Unhandled error');
  try { fs.writeFileSync('/tmp/translivo_error.log', (err.stack || err.message || err.toString()) + '\n'); } catch (e) {}
  return res.status(500).json({ error: { code: 'INTERNAL_ERROR', message: 'Something went wrong. Please try again.' } });
}
