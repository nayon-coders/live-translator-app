# Translivo — Master Plan (Backend + Admin Dashboard + AI English Teacher)

> Single source of truth for the full system plan. Progress is tracked in
> [PROGRESS_LOG.md](./PROGRESS_LOG.md), decisions in [DECISIONS.md](./DECISIONS.md).
> Work is executed **one step at a time**; each step ends with verification + a log entry.

---

## 1. System Overview

```
┌────────────────────────┐        HTTPS (REST)        ┌──────────────────────────────┐
│  Flutter App (GetX)    │ ─────────────────────────▶ │  Node.js API (Express 5)     │
│  • Remote config       │   config / device / token  │  • Public app API  /api/v1   │
│  • Feature flags       │ ◀───────────────────────── │  • Admin API       /api/admin│
│  • Languages from API  │                            │  • Gemini token minting      │
│  • AI English Teacher  │                            └──────┬───────────────┬───────┘
└──────────┬─────────────┘                                   │               │
           │  WebSocket (audio, realtime)                    │ SQL           │ REST (API key,
           │  using EPHEMERAL TOKEN only                     ▼               ▼  server-side only)
           │                                         ┌─────────────┐  ┌──────────────────┐
           └───────────────────────────────────────▶ │   MySQL     │  │ Gemini auth_tokens│
                        Gemini Live API              └─────────────┘  └──────────────────┘
                                                            ▲
                                       ┌────────────────────┴──────┐
                                       │ Admin Dashboard (React SPA)│
                                       │ served by the API at /admin│
                                       └────────────────────────────┘
```

**Key security win:** the Gemini API key lives **only on the server** (encrypted in MySQL).
The app receives a **single-use, short-lived ephemeral token** whose model + system
instruction are **locked server-side** (`liveConnectConstraints`). Audio still streams
directly app ⇄ Gemini (low latency, no audio proxy cost on our server).

---

## 2. Repository Layout (monorepo)

```
live_translator/
├── AGENTS.md                  ← agent rule: read/update docs/context every step
├── docs/context/              ← MASTER_PLAN, PROGRESS_LOG, DECISIONS, API_CONTRACT
├── lib/                       ← existing Flutter app (GetX)
└── backend/
    ├── src/                   ← Express API
    │   ├── config/  db/  middleware/  modules/<domain>/  services/  utils/
    │   ├── app.js  server.js
    ├── migrations/  seeds/    ← Knex
    ├── tests/
    └── dashboard/             ← Vite + React + vanilla CSS (built → served at /admin)
```

---

## 3. Tech Stack

| Layer | Choice | Reason |
|---|---|---|
| Runtime | Node.js (ESM JavaScript) | Small project, fast iteration |
| HTTP | Express 5 | Mature, simple |
| DB | MySQL 9 + `mysql2` + **Knex** (migrations/seeds/query builder) | No heavy ORM, versioned schema |
| Validation | Zod | Typed request validation |
| Auth (admin) | bcrypt + JWT in **httpOnly cookie** + CSRF-safe SameSite | Dashboard security |
| Auth (app) | Device registration → device JWT (revocable via DB status) | Anonymous app users |
| Security | helmet, cors allow-list, express-rate-limit, AES-256-GCM secret encryption | |
| Logging | pino (structured, secrets redacted) | |
| Tests | `node:test` + supertest (separate test DB) | Zero extra runner |
| Dashboard | Vite + React + React Router + vanilla CSS design system + Recharts | Premium SPA |

---

## 4. Database Schema (MySQL)

| Table | Purpose / key columns |
|---|---|
| `admins` | id, name, email, password_hash, role (`owner`/`admin`/`viewer`), is_active, last_login_at |
| `settings` | `key` PK, `value` JSON — app settings (maintenance, min version, AI limits, teacher base prompt…) |
| `secrets` | name PK, ciphertext, iv, auth_tag, last4 — **encrypted Gemini API key** |
| `features` | key, name, description, icon, is_enabled, sort_order, config JSON (live_translation, conversation, text_translation, camera_translation, english_teacher) |
| `languages` | code, name, native_name, iso3, flag, stt_locale, tts_locale, is_enabled, sort_order (seeded from the app's current list) |
| `practice_modes` | key, title, description, icon, is_enabled, sort_order, prompt TEXT, opening_line |
| `english_levels` | code (A1–C2), name, description, prompt_hint, is_enabled |
| `devices` | install_id (unique), platform, app_version, os_version, status (`active`/`blocked`), first_seen_at, last_seen_at |
| `live_sessions` | id (UUID), device_id, mode_key, level_code, model, status, started_at, ended_at, duration_sec, total_words, scores…, summary JSON, end_reason |
| `audit_logs` | admin_id, action, entity, entity_id, changes JSON, ip, created_at |

---

## 5. API Surface (summary — full contract in API_CONTRACT.md)

**Public app API `/api/v1`**
- `GET  /health`
- `POST /devices/register` → device token
- `GET  /config` → features, enabled languages, modes, levels, limits, maintenance (ETag cached)
- `POST /live/sessions` → creates session + mints ephemeral token (quota checked) →
  `{ sessionId, token, wsUrl, model, voice, expiresAt, maxSessionSeconds }`
- `POST /live/sessions/:id/end` → duration, scores, summary (for analytics)

**Admin API `/api/admin`** (cookie JWT, role-based)
- auth: login / logout / me / change-password
- dashboard: KPIs + time-series
- features, languages (toggle, bulk, reorder), practice-modes (CRUD), levels
- ai-settings: model, voice, limits, base prompt; set/rotate API key; **test connection**
- devices (list, block/unblock), sessions (list/detail), audit logs, admins (owner only)

---

## 6. Dashboard Pages

Login · Overview (KPIs, sessions/minutes chart, mode & platform breakdown) · Features ·
Languages · English Teacher (modes, levels, base prompt editor) · AI / Gemini (key, model,
voice, limits, test) · Devices · Sessions · Audit Log · Admins · Settings (maintenance, min app version).
Design: dark, glassmorphism, blue→purple brand gradient matching the app, Inter font,
micro-animations.

---

## 7. Step-by-Step Execution Plan

### Part A — Backend
| Step | Work | Done when |
|---|---|---|
| **A0** | Context system (`AGENTS.md`, `docs/context/*`) | Files exist |
| **A1** | Backend scaffold: Express app, config/env validation, logger, error handling, `/health` | `npm run dev` + `/health` OK |
| **A2** | MySQL: Knex config, migrations for all tables, seeds (languages from app, features, modes, levels, owner admin) | `migrate` + `seed` run cleanly |
| **A3** | Admin auth (login/logout/me, roles, rate-limited login) + audit log helper | Tests pass |
| **A4** | Admin CRUD: features, languages, modes, levels, settings | Tests pass |
| **A5** | Secrets: AES-GCM encryption, Gemini key set/rotate/test | Key never returned/logged |
| **A6** | Public app API: device register, `/config` with ETag | Tests pass |
| **A7** | Gemini ephemeral token minting with locked constraints + quota (daily minutes/device, concurrent sessions) + session end reporting | Real token minted |
| **A8** | Dashboard stats endpoints, devices/sessions/audit/admins endpoints | Tests pass |

### Part B — Admin Dashboard
| Step | Work |
|---|---|
| **B1** | Design mockup → approval; Vite + React scaffold; design system (`index.css`) |
| **B2** | Auth flow + layout shell (sidebar, topbar) |
| **B3** | Overview page with charts |
| **B4** | Features + Languages pages |
| **B5** | English Teacher (modes/levels/prompt) + AI/Gemini pages |
| **B6** | Devices, Sessions, Audit, Admins, Settings pages |
| **B7** | Build + serve from Express at `/admin`, browser verification |

### Part C — Flutter Integration
| Step | Work |
|---|---|
| **C1** | `ApiClient` + `BackendConfig` (base URL via `--dart-define`), device registration |
| **C2** | `RemoteConfigService` (GetX): features + languages from backend, offline cache fallback to bundled list; hide disabled features on Home |
| **C3** | Dependencies: `record`, PCM player, `web_socket_channel`, `audio_session`, `shared_preferences` |
| **C4** | `GeminiLiveService` (token from backend, setup, resumption, GoAway, reconnect) |
| **C5** | Audio input/output pipeline + echo gate + barge-in |
| **C6** | Session state machine + transcript buffer |
| **C7** | Teacher home (level/mode/goal) + Live session UI |
| **C8** | LearningAnalyzer + SessionSummary + local history/progress/daily goal |
| **C9** | Lifecycle, errors, reconnect, session end → backend reporting |
| **C10** | Tests, performance, cleanup, docs |

---

## 8. Security Notes
- Gemini API key: encrypted at rest (AES-256-GCM, master key from `APP_ENCRYPTION_KEY` env), only last 4 chars ever shown.
- Ephemeral tokens: `uses: 1`, `newSessionExpireTime` ≈ 1 min, `expireTime` = max session + margin, constraints lock model + system instruction.
- Device JWT can be revoked by blocking the device. Quotas stop cost abuse.
- `.env` never committed; `.env.example` documents every variable.
- Residual risk: anyone can register a device (anonymous app). Mitigated by rate limits + quotas; future: Play Integrity / App Attest.
