import knex from 'knex';
import config from '../../knexfile.js';
import { env } from '../config/env.js';

export const db = knex(config[env.NODE_ENV]);
