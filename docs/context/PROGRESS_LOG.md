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

## ✅ C2 — Live Server Deployment & App Configuration — 2026-10-12
- Configured production backend and React admin dashboard on VPS (`translivo.d2home.com.au`).
- Updated Flutter `ApiClient.baseUrl` to production HTTPS endpoint (`https://translivo.d2home.com.au/api/v1`).
- Added `seed-practice-modes.js` and `backend/seeds/03_practice_modes.js` for initial conversation scenarios.
- Updated `PracticeModes.jsx` in React admin panel with friendly empty state handling.

## ✅ C3 — Live Translation Visual & 2-Way Language Enhancements — 2026-10-13
- Upgraded `LiveTranslationView` and `LiveTranslationController` with full 2-way conversation capabilities:
  - Interactive top pill allowing directly selecting source/target languages and instant swap (`⇄`).
  - Added visual speaker switcher tabs clearly identifying `You (আমি)` vs `Partner (অন্য পাশ)` with reactive active badges.
  - Added adaptive visual styling: Blue gradient theme for "You", Emerald gradient theme for "Partner" across animated waves, pulsing mic, status subtitle, and translation cards.
  - Added dual mic action buttons at the bottom: `[🎙️ You (English)]` and `[🎙️ Partner (Hindi)]` for seamless two-way translation.
  - Made translation cards speaker-aware with audio replay for both original input and translated output.
- Files: `lib/modules/live_translation/views/live_translation_view.dart`, `lib/modules/live_translation/controllers/live_translation_controller.dart`, `lib/modules/home/views/language_picker_sheet.dart`.
- Verification: `flutter analyze` 0 errors.

## ✅ C4 — Conversation Mode Visual & Speaker Identification — 2026-10-13
- Upgraded `ConversationView` and `ConversationController`:
  - Clean top language pill with `[Hindi ▾]` and `[English ▾]` and instant swap button (`⇄`) without text overflow.
  - Dedicated segmented turn switcher tab highlighting active speaker: `[👤 You (Hindi)]` vs `[👥 Partner (English)]`.
  - Upgraded chat bubble design: avatars display country flag badges, clear header `You (Hindi)` or `Partner (English)`, original speech, translation banner, and text-to-speech speaker button.
  - Added smooth auto-scrolling to latest conversation messages on each incoming speech/translation.
  - Added dual bottom mic buttons: `[🎙️ You (Hindi)]` and `[🎙️ Partner (English)]`.
- Files: `lib/modules/conversation/views/conversation_view.dart`, `lib/modules/conversation/controllers/conversation_controller.dart`.
- Verification: `flutter analyze` 0 errors.

## ✅ C5 — Device Token 401 Self-Healing & Live Chat Resilience — 2026-10-13
- Resolved `UNAUTHORIZED: Invalid or expired device token` issue caused by cached local dev tokens being sent to live server.
- Added automatic 401 interception, cache clearance, re-registration with live backend, and automatic retry in `ApiClient` (`getConfig`, `startLiveSession`, `sendLiveChatMessage`).
- Files: `lib/services/api_client.dart`.
- Verification: `flutter analyze` 0 errors.

## ✅ C6 — AI English Teacher Auto-Scroll & Word Highlight Badge — 2026-10-13
- Upgraded `EnglishTeacherView` and `EnglishTeacherController`:
  - Connected `ScrollController` to `ListView.builder` with bouncy physics and auto-scrolling on new messages, teacher thinking, voice recognition, and keyboard focus.
  - Implemented rich keyword parser `_buildMessageText` to detect `**word/phrase**` markdown from teacher responses.
  - Highlighted taught/corrected words with bold text (`FontWeight.bold`, vibrant golden color `0xFFFDE047`) inside a warm amber pill badge (`0xFFF59E0B` with rounded corners and border) or wrapped text highlight.
  - Replaced unsupported emoji with crisp vector icon (`Icons.school_rounded`) to fix `[?]` missing glyph boxes.
  - Cleaned asterisks from TTS audio so pronunciations stay natural.
- Files: `lib/modules/english_teacher/views/english_teacher_view.dart`, `lib/modules/english_teacher/controllers/english_teacher_controller.dart`.
- Verification: `flutter analyze lib/modules/english_teacher/` passed with 0 issues.

## ✅ C7 — AI Friend Live Voice & Text Companion — 2026-10-13
- Implemented **AI Friend** live chat companion feature:
  - Multi-lingual companion mode allowing user to switch to any supported language (English, Bengali, Hindi, Spanish, French, Arabic, German, Japanese, etc.).
  - Both **Voice** (STT via microphone) and **Text** (keyboard input) conversation modes.
  - Voice response via device TTS (`TranslationService.speak`) in the selected language with "Listen again" audio replay.
  - Interactive top bar language picker (`LanguagePickerSheet`) with instant language switching and localized greetings.
  - Rich conversation starters carousel, glowing voice wave mic button, glassmorphism chat bubbles, and auto-scrolling.
  - Integrated with Admin Panel: backend migration (`20261013150000_add_ai_friend_feature.js`) added `ai_friend` feature into database, controllable via Admin Panel Features toggle.
  - Server-side Gemini `/api/v1/live/chat` persona prompt tuned for warm, concise (1-3 sentences) friend companion responses in selected language.
- Files: `lib/modules/ai_friend/{bindings,controllers,views}/`, `lib/routes/app_pages.dart`, `lib/routes/app_routes.dart`, `lib/modules/home/views/home_view.dart`, `lib/services/api_client.dart`, `backend/migrations/20261013150000_add_ai_friend_feature.js`, `backend/seeds/02_settings.js`, `backend/src/modules/live/live.routes.js`.
## ✅ C8 — Short Text Length Enforcement & Strict Adult Content Filter — 2026-10-13
- Enforced strict brevity and family-friendly safety guardrails across AI chat endpoints (AI Friend & English Teacher):
  - **Always Short Text**: Set Gemini API `generationConfig.maxOutputTokens: 85` and explicit system prompt rules enforcing strictly 1 to 2 short sentences (max 15-25 words) for fast, natural conversation and audio playback.
  - **Strictly No Adult Content**: Added multi-layer protection:
    1. Gemini safety settings `BLOCK_LOW_AND_ABOVE` across sexually explicit, harassment, hate speech, and dangerous categories.
    2. Server-side keyword and intent regex filter (`containsAdultContent`) intercepting inappropriate input with polite, localized refusal messages without consuming tokens.
    3. Client-side validation in `AiFriendController` and `EnglishTeacherController` warning users and blocking inappropriate messages from sending.
    4. System instructions strictly forbidding adult, sexual, romantic, NSFW, or explicit discussions.
- Files: `backend/src/modules/live/live.routes.js`, `lib/modules/ai_friend/controllers/ai_friend_controller.dart`, `lib/modules/english_teacher/controllers/english_teacher_controller.dart`.
- Verification: `flutter analyze` 0 issues, backend health tests passed.

## ✅ C9 — Android Release Signing (.jks & key.properties) — 2026-10-17
- Generated Android Java Keystore `upload-keystore.jks` with requested password `Translivo@2026` (alias: `upload`, validity: 10,000 days).
- Created `android/key.properties` for production release signing.
- Updated `.gitignore` to prevent keystore and password leaks to git.
- Configured `android/app/build.gradle.kts` to automatically sign release builds with `signingConfigs.release`.
- Verification: Verified certificate via `keytool -list -v` and validated signing task with `./gradlew :app:validateSigningRelease` (Build Successful).

