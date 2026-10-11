import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { z } from 'zod';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
export const ROOT_DIR = path.resolve(__dirname, '../..');

// Load backend/.env (or .env.test when NODE_ENV=test) without overriding real env vars.
const envFile = path.join(ROOT_DIR, process.env.NODE_ENV === 'test' ? '.env.test' : '.env');
if (fs.existsSync(envFile)) {
  process.loadEnvFile(envFile);
}

const bool = z
  .enum(['true', 'false', '1', '0'])
  .transform((v) => v === 'true' || v === '1');

const schema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  PORT: z.coerce.number().int().positive().default(4000),
  LOG_LEVEL: z.enum(['fatal', 'error', 'warn', 'info', 'debug', 'trace', 'silent']).default('info'),
  TRUST_PROXY: bool.default(false),

  // Comma-separated list of allowed browser origins (dashboard dev server, etc.)
  CORS_ORIGINS: z.string().default('http://localhost:5173'),

  // MySQL
  DB_HOST: z.string().default('127.0.0.1'),
  DB_PORT: z.coerce.number().int().positive().default(3306),
  DB_USER: z.string().default('root'),
  DB_PASSWORD: z.string().default(''),
  DB_NAME: z.string().default('translivo'),

  // Secrets (required in production; dev fallbacks are generated per-process and NOT persistent)
  JWT_ADMIN_SECRET: z.string().min(32).optional(),
  JWT_DEVICE_SECRET: z.string().min(32).optional(),
  // 32-byte key, base64 encoded. Used for AES-256-GCM encryption of stored secrets (Gemini key).
  APP_ENCRYPTION_KEY: z.string().optional(),
});

const parsed = schema.safeParse(process.env);
if (!parsed.success) {
  const issues = parsed.error.issues.map((i) => `  - ${i.path.join('.')}: ${i.message}`).join('\n');
  // eslint-disable-next-line no-console
  console.error(`Invalid environment configuration:\n${issues}`);
  process.exit(1);
}

const raw = parsed.data;

if (raw.NODE_ENV === 'production') {
  const missing = ['JWT_ADMIN_SECRET', 'JWT_DEVICE_SECRET', 'APP_ENCRYPTION_KEY'].filter((k) => !raw[k]);
  if (missing.length) {
    // eslint-disable-next-line no-console
    console.error(`Missing required production secrets: ${missing.join(', ')}`);
    process.exit(1);
  }
}

export const env = Object.freeze({
  ...raw,
  isProd: raw.NODE_ENV === 'production',
  isTest: raw.NODE_ENV === 'test',
  corsOrigins: raw.CORS_ORIGINS.split(',').map((s) => s.trim()).filter(Boolean),
});
