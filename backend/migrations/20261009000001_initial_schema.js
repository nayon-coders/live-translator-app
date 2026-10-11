/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
export async function up(knex) {
  await knex.schema.createTable('admins', (table) => {
    table.increments('id').primary();
    table.string('name').notNullable();
    table.string('email').notNullable().unique();
    table.string('password_hash').notNullable();
    table.enum('role', ['owner', 'admin', 'viewer']).notNullable().defaultTo('viewer');
    table.boolean('is_active').notNullable().defaultTo(true);
    table.timestamp('last_login_at');
    table.timestamps(true, true); // created_at, updated_at
  });

  await knex.schema.createTable('settings', (table) => {
    table.string('key').primary();
    table.json('value').notNullable();
    table.timestamps(true, true);
  });

  await knex.schema.createTable('secrets', (table) => {
    table.string('name').primary();
    table.text('ciphertext').notNullable();
    table.string('iv').notNullable();
    table.string('auth_tag').notNullable();
    table.string('last4', 4).notNullable();
    table.timestamps(true, true);
  });

  await knex.schema.createTable('features', (table) => {
    table.string('key').primary();
    table.string('name').notNullable();
    table.text('description');
    table.string('icon');
    table.boolean('is_enabled').notNullable().defaultTo(true);
    table.integer('sort_order').notNullable().defaultTo(0);
    table.json('config');
    table.timestamps(true, true);
  });

  await knex.schema.createTable('languages', (table) => {
    table.string('code').primary();
    table.string('name').notNullable();
    table.string('native_name').notNullable();
    table.string('iso3', 3).notNullable();
    table.string('flag').notNullable();
    table.string('stt_locale');
    table.string('tts_locale');
    table.boolean('is_enabled').notNullable().defaultTo(true);
    table.integer('sort_order').notNullable().defaultTo(0);
    table.timestamps(true, true);
  });

  await knex.schema.createTable('practice_modes', (table) => {
    table.string('key').primary();
    table.string('title').notNullable();
    table.text('description');
    table.string('icon');
    table.boolean('is_enabled').notNullable().defaultTo(true);
    table.integer('sort_order').notNullable().defaultTo(0);
    table.text('prompt');
    table.string('opening_line');
    table.timestamps(true, true);
  });

  await knex.schema.createTable('english_levels', (table) => {
    table.string('code').primary(); // A1, A2, B1, etc.
    table.string('name').notNullable();
    table.text('description');
    table.text('prompt_hint');
    table.boolean('is_enabled').notNullable().defaultTo(true);
    table.timestamps(true, true);
  });

  await knex.schema.createTable('devices', (table) => {
    table.increments('id').primary();
    table.string('install_id').notNullable().unique();
    table.string('platform');
    table.string('app_version');
    table.string('os_version');
    table.enum('status', ['active', 'blocked']).notNullable().defaultTo('active');
    table.timestamp('first_seen_at').defaultTo(knex.fn.now());
    table.timestamp('last_seen_at').defaultTo(knex.fn.now());
  });

  await knex.schema.createTable('live_sessions', (table) => {
    table.uuid('id').primary();
    table.integer('device_id').unsigned().references('id').inTable('devices').onDelete('CASCADE');
    table.string('mode_key').references('key').inTable('practice_modes').onDelete('SET NULL');
    table.string('level_code').references('code').inTable('english_levels').onDelete('SET NULL');
    table.string('model').notNullable();
    table.string('status').notNullable(); // 'active', 'completed', 'failed'
    table.timestamp('started_at').notNullable().defaultTo(knex.fn.now());
    table.timestamp('ended_at');
    table.integer('duration_sec');
    table.integer('total_words');
    table.integer('fluency_score');
    table.integer('grammar_score');
    table.integer('vocabulary_score');
    table.json('summary');
    table.string('end_reason');
  });

  await knex.schema.createTable('audit_logs', (table) => {
    table.increments('id').primary();
    table.integer('admin_id').unsigned().references('id').inTable('admins').onDelete('SET NULL');
    table.string('action').notNullable();
    table.string('entity').notNullable();
    table.string('entity_id');
    table.json('changes');
    table.string('ip');
    table.timestamp('created_at').notNullable().defaultTo(knex.fn.now());
  });
}

/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
export async function down(knex) {
  await knex.schema.dropTableIfExists('audit_logs');
  await knex.schema.dropTableIfExists('live_sessions');
  await knex.schema.dropTableIfExists('devices');
  await knex.schema.dropTableIfExists('english_levels');
  await knex.schema.dropTableIfExists('practice_modes');
  await knex.schema.dropTableIfExists('languages');
  await knex.schema.dropTableIfExists('features');
  await knex.schema.dropTableIfExists('secrets');
  await knex.schema.dropTableIfExists('settings');
  await knex.schema.dropTableIfExists('admins');
}
