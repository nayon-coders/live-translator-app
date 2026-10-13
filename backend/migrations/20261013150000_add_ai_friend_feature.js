/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
export async function up(knex) {
  const exists = await knex('features').where({ key: 'ai_friend' }).first();
  if (!exists) {
    await knex('features').insert({
      key: 'ai_friend',
      name: 'AI Friend',
      is_enabled: true,
      sort_order: 6,
    });
  }
}

/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
export async function down(knex) {
  await knex('features').where({ key: 'ai_friend' }).del();
}
