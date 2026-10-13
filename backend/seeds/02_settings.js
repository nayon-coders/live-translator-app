/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> } 
 */
export async function seed(knex) {
  await knex('settings').del();
  await knex('features').del();

  await knex('settings').insert([
    { key: 'maintenance_mode', value: JSON.stringify(false) },
    { key: 'min_app_version', value: JSON.stringify('1.0.0') },
    { key: 'daily_limit_minutes', value: JSON.stringify(30) },
  ]);

  await knex('features').insert([
    { key: 'live_translation', name: 'Live Voice Translation', is_enabled: true, sort_order: 1 },
    { key: 'conversation', name: 'Conversation Mode', is_enabled: true, sort_order: 2 },
    { key: 'text_translation', name: 'Text Translation', is_enabled: true, sort_order: 3 },
    { key: 'camera_translation', name: 'Camera Translation', is_enabled: true, sort_order: 4 },
    { key: 'english_teacher', name: 'AI English Teacher', is_enabled: true, sort_order: 5 },
    { key: 'ai_friend', name: 'AI Friend', is_enabled: true, sort_order: 6 },
  ]);
}
