import jwt from 'jsonwebtoken';
import { env } from '../config/env.js';
import { AppError } from '../utils/app-error.js';

/**
 * Middleware to verify the admin_token cookie.
 * Injects `req.admin` { id, role } if valid.
 */
export function requireAdmin(req, _res, next) {
  const token = req.cookies?.admin_token;
  if (!token) {
    return next(AppError.unauthorized('Not logged in'));
  }

  try {
    const payload = jwt.verify(token, env.JWT_ADMIN_SECRET);
    req.admin = payload;
    next();
  } catch (err) {
    return next(AppError.unauthorized('Session expired or invalid'));
  }
}

/**
 * Middleware to restrict access to specific roles.
 */
export function requireRole(allowedRoles) {
  return (req, _res, next) => {
    if (!req.admin) {
      return next(AppError.unauthorized('Not logged in'));
    }
    if (!allowedRoles.includes(req.admin.role)) {
      return next(AppError.forbidden(`Requires one of: ${allowedRoles.join(', ')}`));
    }
    next();
  };
}
