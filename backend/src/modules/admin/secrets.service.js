import { db } from '../../db/index.js';
import { decryptSecret } from '../../utils/crypto.js';

export async function getGeminiKey() {
  const row = await db('secrets').where({ name: 'gemini_api_key' }).first();
  if (!row) {
    return null;
  }
  
  return decryptSecret(row.ciphertext, row.iv, row.auth_tag);
}
