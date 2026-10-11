import bcrypt from 'bcrypt';

/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> } 
 */
export async function seed(knex) {
  // Deletes ALL existing entries
  await knex('admins').del();
  
  const passwordHash = await bcrypt.hash('admin123', 10);
  
  await knex('admins').insert([
    {
      name: 'Owner Admin',
      email: 'admin@translivo.local',
      password_hash: passwordHash,
      role: 'owner',
      is_active: true,
    }
  ]);
}
