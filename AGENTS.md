# AGENTS.md — Translivo Monorepo Rules

This repo contains the Flutter app (`lib/`) and the Node.js backend + admin dashboard (`backend/`).

## Persistent context (MANDATORY)
Before starting any work, read:
1. `docs/context/MASTER_PLAN.md` — full plan and step list
2. `docs/context/PROGRESS_LOG.md` — what is done, what is next
3. `docs/context/DECISIONS.md` — architecture decisions (do not contradict without logging a new decision)

After finishing each step:
- Append an entry to `docs/context/PROGRESS_LOG.md` (step id, files, verification, next step).
- Record any new architecture decision in `docs/context/DECISIONS.md`.
- Update `docs/context/API_CONTRACT.md` when an endpoint changes.

## Working rules
- Execute **one plan step at a time**; verify before moving on.
- Flutter: keep GetX patterns; do not rewrite existing modules.
- Backend: ESM JavaScript, Express 5, Knex migrations (never edit an applied migration — add a new one).
- Never commit secrets (`backend/.env`, API keys). Never log API keys, tokens, or passwords.
- The Gemini API key must only exist on the server.
