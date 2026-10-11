# API Contract

Base URL (dev): `http://localhost:4000`
All errors: `{ "error": { "code": "STRING", "message": "Human friendly", "details"?: any } }`
Every response carries an `x-request-id` header.

Legend: ✅ implemented · 🕓 planned

## Public app API — `/api/v1`

| Status | Method | Path | Auth | Notes |
|---|---|---|---|---|
| ✅ | GET | `/api/v1/health` | none | `{ status, service, uptimeSec, time }` |
| ✅ | POST | `/api/v1/devices/register` | none (rate-limited) | → device token |
| ✅ | GET | `/api/v1/config` | device | features, languages, modes, levels, limits, maintenance; ETag |
| ✅ | POST | `/api/v1/live/sessions` | device | starts teacher practice session |
| ✅ | POST | `/api/v1/live/sessions/:id/end` | device | duration, scores, summary |
| ✅ | POST | `/api/v1/live/chat` | device | AI English Teacher conversation turn (`{ mode_key, message, history }` → `{ reply }`) |

## Admin API — `/api/admin`

| Status | Method | Path | Role |
|---|---|---|---|
| 🕓 | POST | `/api/admin/auth/login` · `/logout` · GET `/me` | — |
| 🕓 | * | `/api/admin/features`, `/languages`, `/practice-modes`, `/levels`, `/settings` | admin |
| 🕓 | * | `/api/admin/ai` (model, voice, limits, prompt, key set/test) | admin/owner |
| 🕓 | GET | `/api/admin/stats`, `/devices`, `/sessions`, `/audit-logs` | viewer+ |
| 🕓 | * | `/api/admin/admins` | owner |
