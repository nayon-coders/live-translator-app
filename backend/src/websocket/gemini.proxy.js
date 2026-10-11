import { WebSocketServer, WebSocket } from 'ws';
import { db } from '../db/index.js';
import { logger } from '../utils/logger.js';
import { getGeminiKey } from '../modules/admin/secrets.service.js';
import url from 'node:url';

export function setupWebSocket(server) {
  const wss = new WebSocketServer({ noServer: true });

  server.on('upgrade', (request, socket, head) => {
    const parsedUrl = url.parse(request.url, true);
    
    if (parsedUrl.pathname === '/ws/live') {
      wss.handleUpgrade(request, socket, head, (ws) => {
        wss.emit('connection', ws, request);
      });
    } else {
      socket.destroy();
    }
  });

  wss.on('connection', async (ws, request) => {
    const parsedUrl = url.parse(request.url, true);
    const token = parsedUrl.query.token;

    if (!token) {
      ws.close(1008, 'Token required');
      return;
    }

    try {
      // Validate token
      const session = await db('live_sessions').where({ proxy_token: token, status: 'pending' }).first();
      if (!session) {
        ws.close(1008, 'Invalid or expired token');
        return;
      }

      // Mark session active
      await db('live_sessions').where({ id: session.id }).update({ status: 'active' });

      // Get Gemini Key
      const geminiKey = await getGeminiKey();
      if (!geminiKey) {
        ws.close(1011, 'Server configuration error: Gemini key not set');
        return;
      }

      // Connect to Gemini
      const geminiWsUrl = `wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1alpha.GenerativeService.BidiGenerateContent?key=${geminiKey}`;
      const geminiWs = new WebSocket(geminiWsUrl);

      const messageBuffer = [];

      geminiWs.on('open', () => {
        while (messageBuffer.length > 0) {
          geminiWs.send(messageBuffer.shift());
        }
      });

      // Proxy App -> Gemini
      ws.on('message', (message) => {
        if (geminiWs.readyState === WebSocket.OPEN) {
          geminiWs.send(message);
        } else if (geminiWs.readyState === WebSocket.CONNECTING) {
          messageBuffer.push(message);
        }
      });

      // Proxy Gemini -> App
      geminiWs.on('message', (message) => {
        if (ws.readyState === WebSocket.OPEN) {
          ws.send(message);
        }
      });

      // Handle close
      ws.on('close', () => geminiWs.close());
      geminiWs.on('close', () => ws.close());

      geminiWs.on('error', (err) => {
        logger.error({ err }, 'Gemini WS Error');
        ws.close();
      });

      ws.on('error', (err) => {
        logger.error({ err }, 'Client WS Error');
        geminiWs.close();
      });

    } catch (err) {
      logger.error({ err }, 'WS Proxy setup failed');
      ws.close(1011, 'Internal error');
    }
  });
}
