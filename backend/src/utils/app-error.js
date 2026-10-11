/**
 * Operational error with an HTTP status and a stable machine-readable code.
 * Anything that is NOT an AppError is treated as an unexpected 500.
 */
export class AppError extends Error {
  /**
   * @param {number} status HTTP status code
   * @param {string} code   stable error code, e.g. 'NOT_FOUND'
   * @param {string} message human-friendly message (safe to show to clients)
   * @param {unknown} [details] optional extra info (validation issues, etc.)
   */
  constructor(status, code, message, details) {
    super(message);
    this.name = 'AppError';
    this.status = status;
    this.code = code;
    this.details = details;
  }

  static badRequest(message = 'Bad request', details) {
    return new AppError(400, 'BAD_REQUEST', message, details);
  }
  static unauthorized(message = 'Authentication required') {
    return new AppError(401, 'UNAUTHORIZED', message);
  }
  static forbidden(message = 'You do not have permission to do this') {
    return new AppError(403, 'FORBIDDEN', message);
  }
  static notFound(message = 'Resource not found') {
    return new AppError(404, 'NOT_FOUND', message);
  }
  static conflict(message = 'Conflict') {
    return new AppError(409, 'CONFLICT', message);
  }
  static tooMany(message = 'Too many requests') {
    return new AppError(429, 'RATE_LIMITED', message);
  }
  static unavailable(message = 'Service temporarily unavailable', code = 'UNAVAILABLE') {
    return new AppError(503, code, message);
  }
}
