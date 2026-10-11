import { createApp } from './app.js';
import { env } from './config/env.js';
import { logger } from './utils/logger.js';

import { setupWebSocket } from './websocket/gemini.proxy.js';

const app = createApp();

const server = app.listen(env.PORT, () => {
  logger.info(`Translivo API listening on http://localhost:${env.PORT} (${env.NODE_ENV})`);
});

setupWebSocket(server);

/** Graceful shutdown: stop accepting connections, then exit. */
function shutdown(signal) {
  logger.info(`${signal} received, shutting down…`);
  server.close(() => {
    logger.info('HTTP server closed');
    process.exit(0);
  });
  // Force-exit if connections hang.
  setTimeout(() => process.exit(1), 10_000).unref();
}

process.on('SIGINT', () => shutdown('SIGINT'));
process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('unhandledRejection', (reason) => logger.error({ reason }, 'Unhandled promise rejection'));
