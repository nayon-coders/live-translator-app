import { db } from './src/db/index.js';

const defaultModes = [
  {
    key: 'teacher',
    title: 'General Teacher',
    description: 'Have a casual conversation to practice English',
    icon: 'graduation-cap',
    is_enabled: true,
    sort_order: 1,
    prompt: 'You are a friendly, patient English teacher. Help the user improve their conversational English, correct mistakes gently, and keep answers concise (1-3 sentences).',
    opening_line: 'Hello! I am your AI English teacher. What would you like to talk about today?',
  },
  {
    key: 'interviewer',
    title: 'Job Interview',
    description: 'Practice a formal job interview',
    icon: 'briefcase',
    is_enabled: true,
    sort_order: 2,
    prompt: 'You are a professional HR interviewer conducting a job interview in English. Ask realistic interview questions one at a time and give constructive feedback on user answers.',
    opening_line: 'Welcome to the interview. Could you please introduce yourself and tell me about your background?',
  },
  {
    key: 'waiter',
    title: 'Restaurant',
    description: 'Order food and drinks in a restaurant scenario',
    icon: 'utensils',
    is_enabled: true,
    sort_order: 3,
    prompt: 'You are a polite restaurant waiter taking an order from a customer in English. Respond naturally, suggest menu items, and keep it interactive.',
    opening_line: 'Good day! Welcome to our restaurant. Here is the menu—what can I get started for you today?',
  },
  {
    key: 'travel',
    title: 'Travel & Airport',
    description: 'Practice airport check-in, customs, and asking for directions',
    icon: 'plane',
    is_enabled: true,
    sort_order: 4,
    prompt: 'You are an airline customer service agent and travel guide. Help travelers navigate check-in, flights, and directions clearly in English.',
    opening_line: 'Hello and welcome to airport check-in! Where are you flying to today?',
  },
];

async function seedModes() {
  console.log('Seeding practice modes...');
  for (const mode of defaultModes) {
    const exists = await db('practice_modes').where({ key: mode.key }).first();
    if (!exists) {
      await db('practice_modes').insert(mode);
      console.log(`Inserted: ${mode.title}`);
    } else {
      console.log(`Already exists: ${mode.title}`);
    }
  }
  console.log('Done!');
  process.exit(0);
}

seedModes().catch((err) => {
  console.error('Failed to seed practice modes:', err);
  process.exit(1);
});
