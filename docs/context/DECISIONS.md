# Architecture Decisions Log

Each decision: date · decision · reason. Newest at the bottom.

| # | Date | Decision | Reason |
|---|---|---|---|
| D1 | 2026-10-06 | Flutter app keeps **GetX** (state, DI, routing) and the `lib/modules/<feature>/{bindings,controllers,views}` pattern | Existing convention; no rewrites |
| D2 | 2026-10-09 | Add a **Node.js backend** (Express 5, ESM JS) inside the repo at `backend/` | User request: manage features/languages/AI from a dashboard |
| D3 | 2026-10-09 | **MySQL** + Knex migrations/seeds (no heavy ORM) | Small project, user request, versioned schema |
| D4 | 2026-10-09 | Gemini API key stored **only on server**, AES-256-GCM encrypted in `secrets` table | Never ship API keys inside the app |
| D5 | 2026-10-09 | App connects to Gemini Live **directly** via WebSocket using **ephemeral tokens** minted by backend (`POST v1beta/auth_tokens`, `uses:1`, `liveConnectConstraints`) | Low latency, no audio proxying, key stays secret |
| D6 | 2026-10-09 | Live model default `gemini-3.8-live` (configurable in dashboard) | Current model in official Live API docs |
| D7 | 2026-10-09 | Dashboard = Vite + React + vanilla CSS, built and **served by Express at `/admin`** | One deployable, premium UI |
| D8 | 2026-10-09 | Admin auth = JWT in httpOnly SameSite cookie; app auth = anonymous **device JWT**, revocable | Two different trust levels |
| D9 | 2026-10-09 | AI English Teacher feature lives in `lib/modules/english_teacher/` (GetX style) | Consistency with existing app |
| D10 | 2026-10-09 | Local dev DB: `translivo` on local Homebrew MySQL 9.6 (root, no password); test DB `translivo_test` | Matches the dev machine |
| D11 | 2026-10-11 | AI English Teacher uses turn-based REST endpoint (`POST /api/v1/live/chat`) with device STT (`speech_to_text`) and device TTS (`flutter_tts`) via `TranslationService` | Replaces bidirectional WebSocket streaming to drastically save tokens, work on standard Gemini API keys, and maintain exact consistency with language translator module |
| D12 | 2026-10-13 | Live Translation adopts 2-way visual dual-speaker model (`You` vs `Partner`) with interactive in-place language picker, swap button, and dual mic controls | Solves ambiguity of who is speaking in which language and enables fluid 2-way translation right on the live translation screen |
| D13 | 2026-10-13 | AI Friend feature (`lib/modules/ai_friend/`) provides multi-lingual live voice & text companion chat controllable via admin panel feature toggle (`ai_friend`) | User request: conversational companion chatting and speaking in any user-selected language with voice & text |

