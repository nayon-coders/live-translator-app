import { Router } from 'express';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { z } from 'zod';
import { db } from '../../db/index.js';
import { env } from '../../config/env.js';
import { AppError } from '../../utils/app-error.js';

export const authRouter = Router();

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(6),
});

authRouter.post('/login', async (req, res, next) => {
  try {
    const { email, password } = loginSchema.parse(req.body);

    const admin = await db('admins').where({ email }).first();
    if (!admin || !admin.is_active) {
      throw AppError.unauthorized('Invalid credentials');
    }

    const isMatch = await bcrypt.compare(password, admin.password_hash);
    if (!isMatch) {
      throw AppError.unauthorized('Invalid credentials');
    }

    const token = jwt.sign(
      { id: admin.id, role: admin.role },
      env.JWT_ADMIN_SECRET,
      { expiresIn: '1d' }
    );

    await db('admins').where({ id: admin.id }).update({ last_login_at: db.fn.now() });

    res.cookie('admin_token', token, {
      httpOnly: true,
      secure: env.isProd,
      sameSite: 'lax',
      maxAge: 24 * 60 * 60 * 1000,
    });

    res.json({
      message: 'Logged in successfully',
      admin: { id: admin.id, name: admin.name, email: admin.email, role: admin.role },
    });
  } catch (err) {
    next(err);
  }
});

authRouter.post('/logout', (req, res) => {
  res.clearCookie('admin_token');
  res.json({ message: 'Logged out successfully' });
});
