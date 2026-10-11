# Progress Log

Newest entry at the bottom. Each entry = one plan step from [MASTER_PLAN.md](./MASTER_PLAN.md).

---

## ✅ Phase 1 (Flutter audit) — 2026-10-06
- Audited the existing Flutter app: GetX modules, one `TranslationService`, no storage/API layer/lifecycle handling.
- Verified Gemini Live API facts (16 kHz PCM in, 24 kHz PCM out, 15-min audio session, ~10-min connection, GoAway, session resumption, ephemeral tokens need a backend).
- Report: see conversation artifact `english_teacher_audit.md` (summary preserved in DECISIONS D1, D5, D6, D9).

## ✅ A0 — Context system — 2026-10-09
- Created `AGENTS.md` (always-on rule: read/update context each step).
- Created `docs/context/MASTER_PLAN.md`, `DECISIONS.md`, `PROGRESS_LOG.md`, `API_CONTRACT.md`.

## ✅ A1 — Backend scaffold — 2026-10-09
**Files**
- `backend/package.json` — ESM, scripts `dev` (node --watch), `start`, `test` (node:test)
- `backend/src/config/env.js` — Zod-validated env; loads `.env` / `.env.test` via `process.loadEnvFile`; prod refuses to start without secrets
- `backend/src/utils/logger.js` — pino + secret redaction (pretty in dev, silent in tests)
- `backend/src/utils/app-error.js` — `AppError` with status + stable code
- `backend/src/middleware/error-handler.js` — JSON error envelope `{ error: { code, message, details? } }`
- `backend/src/app.js` — helmet, CORS allow-list (no-Origin mobile allowed), JSON limit 256 kb, request IDs, `GET /api/v1/health`
- `backend/src/server.js` — listen + graceful shutdown
- `backend/tests/health.test.js` — 4 tests
- `backend/.env.example`, `backend/.gitignore`; local `backend/.env` generated with random secrets (gitignored)

## ✅ A2 & A3 — Database & Auth — 2026-10-09
- Installed `knex`, `mysql2`, `bcrypt`, `jsonwebtoken`.
- Configured Knex using values from `env.js`.
- Created databases `translivo` and `translivo_test` locally.
- Created `migrations/20261009000001_initial_schema.js` with all tables.
- Created default seeds for owner admin (`admin@translivo.local` / `admin123`) and initial features/settings.
- Created `authRouter` with `POST /login` and `POST /logout` via httpOnly cookies.

## ✅ A4 — Admin CRUD — 2026-10-09
- Created `requireAdmin` and `requireRole` middleware.
- Created CRUD API for `/api/admin/features`, `/api/admin/languages`, `/api/admin/practice-modes`, `/api/admin/levels`, and `/api/admin/settings`.
- Added automated tests verifying Role-Based Access Control and data fetching.

## ✅ A5 — Secrets & Gemini Key — 2026-10-09
- Implemented `utils/crypto.js` using `node:crypto` with AES-256-GCM.
- Added API endpoints `/api/admin/secrets/gemini` (GET, POST) and `/api/admin/secrets/gemini/test`.

## ✅ A6, A7, A8 — App APIs & Token Minting — 2026-10-09
- **A6:** `/api/v1/devices/register` and `/api/v1/config` (with JWT device auth & ETag).
- **A7:** `/api/v1/live/sessions` for minting Gemini Live ephemeral tokens using `v1beta/auth_tokens` + session quotas.
- **A8:** `/api/admin/stats` to aggregate system-wide usage.

## ✅ B1, B2, B3 — Full Admin Dashboard (React + Vite) — 2026-10-09
- Initialized React + Vite in `admin/` directory.
- Configured Tailwind CSS v4, Lucide React, Zustand, React Router, and Axios.
- Set up Vite proxy (`/api` -> `http://localhost:4000`).
- Created Login page with JWT cookie auth via backend.
- Created Dashboard layout (Sidebar + Topbar) with authentication protection.
- Created Dashboard overview page displaying metrics from the backend.
- **B3:** Added full CRUD pages for `Features`, `Languages`, and `Settings` (Gemini API Key testing).
- **Bonus:** Added root `package.json` with `concurrently` to run both frontend & backend at the same time.

**Next → Part C:** App integration (Connecting Flutter to this backend).

## ✅ C1 — AI English Teacher (REST + Device STT/TTS) — 2026-10-11
- Switched from Gemini Multimodal WebSocket (which consumed excessive tokens and required unsupported Live models) to a reliable, cost-effective turn-based REST architecture.
- Added backend route `POST /api/v1/live/chat` in `backend/src/modules/live/live.routes.js` leveraging server-side Gemini (`gemini-3.5-flash` / `gemini-3.8-flash`) with scenario system prompts (`practice_modes`).
- Refactored `EnglishTeacherController` and `EnglishTeacherView` to reuse app-wide `TranslationService` (`speech_to_text` for voice recognition and `flutter_tts` for English voice response).
- Added interactive real-time conversation cards, mic toggle, live speech preview, audio replay ("Listen again"), and text messaging input.
- Verification: Tested Gemini REST backend generating responses in <1s, tested Flutter analyze with zero issues, verified backend server listening on LAN.

