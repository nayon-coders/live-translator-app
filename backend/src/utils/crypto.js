import crypto from 'node:crypto';
import { env } from '../config/env.js';
import { AppError } from './app-error.js';

const ALGORITHM = 'aes-256-gcm';

/**
 * Returns the encryption key buffer.
 * In dev/test, falls back to a generated key if not set.
 */
function getKey() {
  if (env.APP_ENCRYPTION_KEY) {
    const key = Buffer.from(env.APP_ENCRYPTION_KEY, 'base64');
    if (key.length !== 32) throw new Error('APP_ENCRYPTION_KEY must be exactly 32 bytes (base64)');
    return key;
  }
  // This fallback only happens in development/test since env.js enforces it for production.
  // We hash an empty string to get a stable 32-byte key for local dev if they didn't set one.
  return crypto.createHash('sha256').update('dev-key-fallback').digest();
}

/**
 * Encrypts a plaintext string using AES-256-GCM.
 * @param {string} plaintext
 * @returns {{ ciphertext: string, iv: string, auth_tag: string, last4: string }}
 */
export function encryptSecret(plaintext) {
  if (!plaintext || typeof plaintext !== 'string') {
    throw AppError.badRequest('Invalid secret');
  }

  const iv = crypto.randomBytes(12);
  const cipher = crypto.createCipheriv(ALGORITHM, getKey(), iv);

  let ciphertext = cipher.update(plaintext, 'utf8', 'base64');
  ciphertext += cipher.final('base64');
  const authTag = cipher.getAuthTag();

  const last4 = plaintext.length >= 4 ? plaintext.slice(-4) : '****';

  return {
    ciphertext,
    iv: iv.toString('base64'),
    auth_tag: authTag.toString('base64'),
    last4,
  };
}

/**
 * Decrypts a ciphertext back to plaintext.
 * @param {string} ciphertext
 * @param {string} ivBase64
 * @param {string} authTagBase64
 * @returns {string}
 */
export function decryptSecret(ciphertext, ivBase64, authTagBase64) {
  try {
    const decipher = crypto.createDecipheriv(
      ALGORITHM,
      getKey(),
      Buffer.from(ivBase64, 'base64')
    );
    decipher.setAuthTag(Buffer.from(authTagBase64, 'base64'));

    let plaintext = decipher.update(ciphertext, 'base64', 'utf8');
    plaintext += decipher.final('utf8');

    return plaintext;
  } catch (error) {
    throw AppError.unavailable('Failed to decrypt stored secret');
  }
}
