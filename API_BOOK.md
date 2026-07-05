# MIRA Backend — API Book

> **For Flutter client (`mira_app`)** — contract to implement HTTP integration.
> **Source of truth**: `C:\Users\User\Desktop\mira-backend\src\mira\**\router.py`
> Last updated: 2026-06-25 (graph v2 mutations + daily brief task API)

**Base URL (production)**: `https://api.miramind.io`

**Base URL (dev)**: `http://localhost:8000`

| Platform | Base URL |
|----------|----------|
| **Production (release builds)** | `https://api.miramind.io` |
| iOS Simulator / desktop (dev) | `http://localhost:8000` |
| Android Emulator (dev) | `http://10.0.2.2:8000` |
| Physical device (LAN, dev) | `http://<your-pc-ip>:8000` |

**OpenAPI**: https://api.miramind.io/docs (dev: http://localhost:8000/docs)

**Super Admin**: https://admin.miramind.io/admin/login

**Auth header** (protected routes):

```
Authorization: Bearer <access_token>
```

**Error envelope** (all errors):

```json
{ "detail": "Human-readable message" }
```

**Content-Type**: `application/json` for all POST bodies (except multipart capture routes).

---

## App endpoints (quick reference)

Bearer auth unless noted. Flutter repos in `lib/features/` / `lib/core/`.

| Method | Path | Flutter consumer | Purpose |
|--------|------|------------------|---------|
| `GET` | `/health/ready` | `settings_repository.dart` | Dev connectivity check |
| `GET` | `/app/version` | `app_release_repository.dart` | Latest mobile build (no auth) |
| `GET` | `/auth/config` | `auth_repository.dart` | Onboarding flags (referral, Google) |
| `POST` | `/auth/email/start` | `auth_repository.dart` | Start passwordless flow |
| `POST` | `/auth/invite/verify` | `auth_repository.dart` | Verify invite code |
| `POST` | `/auth/email/verify` | `auth_repository.dart` | Verify OTP → tokens |
| `POST` | `/auth/google` | `auth_repository.dart` | Google Sign-In → tokens |
| `POST` | `/auth/refresh` | `api_client.dart` | Rotate access token |
| `GET` | `/auth/me` | `auth_repository.dart`, onboarding | Current user profile |
| `POST` | `/auth/onboarding` | `onboarding_repository.dart` | Complete onboarding wizard |
| `GET` | `/auth/settings` | `settings_repository.dart` | User preferences |
| `PATCH` | `/auth/settings` | `settings_repository.dart` | Update preferences |
| `POST` | `/captures` | `capture_repository.dart` | Text capture |
| `POST` | `/captures/transcribe` | `capture_repository.dart` | STT only (onboarding) |
| `POST` | `/captures/voice` | `capture_repository.dart` | Voice capture (home) |
| `GET` | `/captures/{id}/stream` | `capture_repository.dart` | SSE pipeline events |
| `POST` | `/captures/{id}/confirm-time` | `capture_repository.dart` | Resolve ambiguous time |
| `POST` | `/captures/{id}/clarify-intent` | `capture_repository.dart` | Resolve ambiguous question-vs-save intent |
| `POST` | `/captures/{id}/follow-up` | `capture_repository.dart` | Continue or revise a pending approval draft |
| `POST` | `/captures/{id}/confirm-entity-equivalence` | `capture_repository.dart` | Confirm cross-language same person |
| `POST` | `/captures/{id}/approve` | `capture_repository.dart` | Ingest approved capture into graph v2 |
| `POST` | `/captures/{id}/dismiss` | `capture_repository.dart` | Discard capture |
| `GET` | `/v2/graph` | `graph_repository.dart` | Knowledge / evidence / hybrid / tasks graph |
| `PUT` | `/v2/graph/layout` | `graph_repository.dart` | Persist interactive layout |
| `GET` | `/v2/entities/{id}` | `graph_repository.dart` | Entity detail + assertions |
| `GET` | `/v2/tasks` | `graph_repository.dart` | Open tasks list |
| `PATCH` | `/v2/tasks/{id}` | `graph_repository.dart` | Update task status/title/due |
| `DELETE` | `/v2/captures/{id}` | `graph_repository.dart` | Archive capture + cascade |
| `PATCH` | `/v2/captures/{id}` | `graph_repository.dart` | Display title-only edit |
| `POST` | `/v2/captures/{id}/correct` | `graph_repository.dart` | Semantic correction (re-ingest) |
| `POST` | `/v2/assertions/{id}/reject` | `graph_repository.dart` | Reject assertion from entity sheet |
| `GET` | `/v2/search` | — | Hybrid entity + capture search |
| `GET` | `/v2/ontology` | — | Predicate catalog + entity types |
| `GET` | `/daily-update` | `daily_brief_repository.dart` | Daily brief feed |
| `POST` | `/canvas` | `canvas_repository.dart` | Create a visual workspace board |
| `GET` | `/canvas` | `canvas_repository.dart` | List user's visual workspace boards |
| `GET` | `/canvas/{id}` | `canvas_repository.dart` | Fetch a visual board |
| `PATCH` | `/canvas/{id}` | `canvas_repository.dart` | Persist nodes, edges, and viewport |
| `GET` | `/library/import-sources` | `library_repository.dart` | Fabric-style import source manifest |
| `POST` | `/library/imports/link` | `library_repository.dart` | Import web/video/social URL metadata |
| `POST` | `/library/imports/text` | `library_repository.dart` | Import pasted text, exports, HTML, notes |
| `POST` | `/library/search-v2` | `library_repository.dart` | Chunk-level Library search with snippets/citations |
| `POST` | `/library/meetings` | `library_repository.dart` | Import meeting transcript or meeting media |
| `GET` | `/library/items/{id}/chunks` | `library_repository.dart` | Extracted text/transcript/OCR chunks |
| `POST` | `/library/items/{id}/save-to-graph` | `library_repository.dart` | Send extracted Library text into Graph V2 via save capture |
| `GET` | `/library/items/{id}/annotations` | `library_repository.dart` | Reader annotations for an item |
| `POST` | `/library/items/{id}/annotations` | `library_repository.dart` | Create a chunk/page/timestamp annotation |
| `PATCH` | `/library/annotations/{id}` | `library_repository.dart` | Update annotation |
| `DELETE` | `/library/annotations/{id}` | `library_repository.dart` | Delete annotation |
| `POST` | `/publish` | `publish_repository.dart` | Create private publish link |
| `GET` | `/p/{token}` | Browser / API clients | Resolve private publish link as HTML or JSON |
| `GET` | `/plugins` | `plugin_repository.dart` | Connector registry and status |
| `POST` | `/plugins/{id}/connect` | `plugin_repository.dart` | Configure connector adapter |
| `POST` | `/plugins/{id}/sync` | `plugin_repository.dart` | Manual connector sync into Library |
| `POST` | `/waitlist` | Landing (Next.js) | Waitlist signup — public, no auth |

---

## Table of Contents

1. [Health](#health)
2. [Auth](#auth)
3. [Captures](#captures)
4. [Graph & Daily Update](#graph--daily-update)
5. [Workspace Library & Connectors](#workspace-library--connectors)
6. [Waitlist (Landing)](#waitlist-landing)
7. [Super Admin](#super-admin)
8. [Flutter integration notes](#flutter-integration-notes)
9. [Planned — Phase 4+](#planned--phase-4)

App-facing routes summary: [App endpoints (quick reference)](#app-endpoints-quick-reference).

---

## Health

### Liveness
`GET /health`

No auth. Returns `200` if process is up.

**Response** `200`
```json
{ "status": "ok" }
```

---

### Readiness
`GET /health/ready`

No auth. Pings database.

**Response** `200`
```json
{ "status": "ready" }
```

**Response** `503`
```json
{ "status": "not_ready", "detail": "database unavailable" }
```

---

## Mobile app version

### Latest release metadata
`GET /app/version`

No auth. Used by the Flutter app on startup to prompt users when a newer APK is available. Reads `https://miramind.io/downloads/version.json` (uploaded by mobile CI), with GitHub Releases as fallback.

**Response** `200`
```json
{
  "versionName": "1.1.0",
  "buildNumber": 42,
  "minBuildNumber": 1,
  "downloadUrl": "https://miramind.io/downloads/mira-latest.apk",
  "optional": true
}
```

| Field | Type | Notes |
|-------|------|-------|
| `versionName` | string | Semantic version shown to users |
| `buildNumber` | int | Monotonic build id — compare with `package_info.buildNumber` |
| `minBuildNumber` | int | Installs below this must update (non-dismissible dialog) |
| `downloadUrl` | string | APK download link opened in browser |
| `optional` | boolean | When `true`, user may dismiss until next build |

**Errors**: `503` when release metadata cannot be loaded

---

## Auth

JWT access token TTL: **15 minutes**. Refresh token TTL: **30 days** (rotated on refresh).

### Register
`POST /auth/register`

**Request Body**
```json
{
  "email": "user@example.com",
  "password": "securepass123",
  "display_name": "Sara"
}
```

| Field | Type | Rules |
|-------|------|-------|
| `email` | string | required, valid email |
| `password` | string | required, min 8, max 128 |
| `display_name` | string | required, min 1, max 255 |

**Response** `201`
```json
{
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "user@example.com",
    "display_name": "Sara",
    "role": null,
    "gender": null,
    "bio": null,
    "onboarding_completed": false,
    "voice_intro_completed": false,
    "is_active": true,
    "created_at": "2026-06-19T12:00:00+00:00"
  },
  "tokens": {
    "access_token": "<jwt>",
    "refresh_token": "<opaque>",
    "token_type": "bearer",
    "expires_in": 900
  }
}
```

**Errors**: `409` email already exists

---

### Login
`POST /auth/login`

**Request Body**
```json
{
  "email": "user@example.com",
  "password": "securepass123"
}
```

**Response** `200` — same shape as Register (`user` + `tokens`)

**Errors**: `401` invalid credentials · `403` inactive account

---

### Auth config (public)
`GET /auth/config`

Client-safe onboarding auth settings. No auth required.

**Response** `200`
```json
{
  "referral_required": true,
  "google_sign_in_enabled": false
}
```

`referral_required` is toggled from Super Admin → **Referral** (`PATCH /admin/api/referral/settings`). When `false`, new users skip the invite step and receive the email OTP immediately.

`google_sign_in_enabled` is `true` when the server has `GOOGLE_OAUTH_CLIENT_IDS` configured.

---

### Google Sign-In
`POST /auth/google`

Exchange a Google Sign-In **ID token** (from Flutter `google_sign_in`) for MIRA JWT tokens. No auth required.

**Request Body**
```json
{
  "id_token": "eyJhbGciOiJSUzI1NiIs..."
}
```

**Response** `200` — same shape as email verify, plus signup hint:
```json
{
  "user": { "id": "...", "email": "user@gmail.com", "display_name": "User", "onboarding_completed": false, "is_active": true, "created_at": "..." },
  "tokens": { "access_token": "...", "refresh_token": "...", "token_type": "bearer", "expires_in": 900 },
  "is_new_user": true
}
```

**Errors:** `401` invalid/expired Google token · `401` Google email not verified · `401` when Google Sign-In disabled on server

New Google users skip the email OTP and referral invite flow. Existing accounts with the same verified email are linked automatically.

---

### Start email auth
`POST /auth/email/start`

Starts the passwordless login/sign-up flow.

**Request Body**
```json
{
  "email": "user@example.com"
}
```

**Response** `200`
```json
{
  "email": "user@example.com",
  "existing_user": false,
  "invite_required": true,
  "code_sent": false,
  "dev_code": null
}
```

Existing users skip invite and receive an email code immediately.

---

### Verify invite code
`POST /auth/invite/verify`

Used only for new users before email code verification.

**Request Body**
```json
{
  "email": "user@example.com",
  "invite_code": "424242"
}
```

**Response** `200`
```json
{
  "email": "user@example.com",
  "accepted": true,
  "code_sent": true,
  "dev_code": "424242"
}
```

**Errors**: `401` invalid invite code

---

### Verify email code
`POST /auth/email/verify`

Completes passwordless auth. If the email is new and invite was verified, this creates the user.

**Request Body**
```json
{
  "email": "user@example.com",
  "code": "424242"
}
```

**Response** `200` - same shape as Register (`user` + `tokens`)

**Errors**: `401` invalid code / invite required

---

### Refresh tokens
`POST /auth/refresh`

Rotates refresh token (old token revoked).

**Request Body**
```json
{
  "refresh_token": "<opaque refresh token>"
}
```

**Response** `200`
```json
{
  "access_token": "<new jwt>",
  "refresh_token": "<new opaque>",
  "token_type": "bearer",
  "expires_in": 900
}
```

**Errors**: `401` invalid / expired / revoked refresh token

---

### Logout
`POST /auth/logout`

Revokes refresh token.

**Request Body**
```json
{
  "refresh_token": "<opaque refresh token>"
}
```

**Response** `204` — empty body

**Errors**: `401` invalid refresh token

---

### Current user
`GET /auth/me`

Requires `Authorization: Bearer <access_token>`.

**Response** `200`
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "user@example.com",
  "display_name": "Sara",
  "role": "Engineer",
  "gender": "Female",
  "bio": "Building Mira.",
  "onboarding_completed": true,
  "voice_intro_completed": true,
  "is_active": true,
  "created_at": "2026-06-19T12:00:00+00:00"
}
```

**Errors**: `401` missing/invalid/expired access token

---

### Update current user
`PATCH /auth/me`

Requires `Authorization: Bearer <access_token>`.

**Request Body** (partial)
```json
{
  "display_name": "Sara",
  "role": "Engineer",
  "gender": "Female",
  "bio": "Building Mira."
}
```

**Response** `200` — same shape as `GET /auth/me`.

**Errors**: `401` · `422` validation

---

### User settings
`GET /auth/settings`

Requires `Authorization: Bearer <access_token>`.

**Response** `200`
```json
{
  "preferred_language": "en",
  "theme_mode": "system",
  "notifications_enabled": true,
  "daily_brief_enabled": true,
  "memory_insights_enabled": true,
  "analytics_enabled": false
}
```

---

### Update user settings
`PATCH /auth/settings`

Requires `Authorization: Bearer <access_token>`.

**Request Body** (partial)
```json
{
  "preferred_language": "fa",
  "theme_mode": "dark",
  "notifications_enabled": false,
  "daily_brief_enabled": true,
  "memory_insights_enabled": true,
  "analytics_enabled": false
}
```

| Field | Type | Rules |
|-------|------|-------|
| `preferred_language` | string | optional, enum: `en`, `fa` |
| `theme_mode` | string | optional, enum: `system`, `light`, `dark` |
| `notifications_enabled` | boolean | optional |
| `daily_brief_enabled` | boolean | optional |
| `memory_insights_enabled` | boolean | optional |
| `analytics_enabled` | boolean | optional |

**Response** `200` — same shape as `GET /auth/settings`.

**Errors**: `401` · `422` validation

---

### Onboarding status
`GET /auth/onboarding/status`

Requires auth. Returns whether the user has finished the onboarding wizard.

**Response** `200`
```json
{
  "onboarding_completed": false,
  "voice_intro_completed": false,
  "display_name": "Sara"
}
```

---

### Complete onboarding
`POST /auth/onboarding`

Requires auth. Saves profile answers from the onboarding wizard (Figma 659:3546).

**Request Body**
```json
{
  "display_name": "Sara",
  "role": null,
  "gender": null,
  "bio": "First memory text, if the user added one.",
  "voice_intro_completed": true
}
```

**Response** `200` — same shape as `GET /auth/me` with `onboarding_completed: true`.

**Errors**: `401` · `422` validation

---

## Captures

All capture endpoints require `Authorization: Bearer <access_token>`.

Phase 2 supports **`type: "text"`**, **`POST /captures/voice`**, **`POST /captures/link`**, **`POST /captures/image`**, and **`POST /captures/file`**. Voice/image/link require admin flags `capture_voice` / `capture_image` / `capture_link`. Raw audio/image bytes are never persisted.

When admin flag **`multimodal_embed`** is on, image captures compute a transient multimodal vector at upload time (used on approve for Neo4j; not returned in API proposals).

### Create capture
`POST /captures`

Accepts text, enqueues processing. With worker running, poll `GET /captures/{id}` or use SSE stream.

**Request Body**
```json
{
  "type": "text",
  "text": "Task: send deck to Sara by Friday",
  "channel": "mobile"
}
```

| Field | Type | Rules |
|-------|------|-------|
| `type` | string | required, enum: `text` (phase 2) |
| `text` | string | required, min 1, max 10000 |
| `channel` | string | optional, default `mobile` — `mobile`, `web`, `telegram`, `whatsapp`, `bale` |

**Response** `202`
```json
{
  "capture_id": "550e8400-e29b-41d4-a716-446655440000",
  "state": "awaiting_approval",
  "capture_type": "text",
  "proposal": {
    "summary": "Task: send deck to Sara by Friday",
    "node_type": "Task",
    "title": "Task: send deck to Sara by Friday",
    "related_nodes": [],
    "deadline": null
  },
  "answer": null,
  "created_at": "2026-06-19T12:00:00+00:00"
}
```

States: `processing` → `awaiting_approval` (save) · `question_answered` (question) · `clarification_needed` (ambiguous intent or ambiguous time).

**Proposal shape** (when `state` is `awaiting_approval` or `clarification_needed`):

```json
{
  "summary": "Task: send deck to Sara by Friday",
  "node_type": "Task",
  "title": "Send deck to Sara",
  "related_nodes": [
    {"type": "Person", "title": "Sara", "summary": "شخص: Sara"}
  ],
  "relationships": [
    {"target_title": "Beta launch", "relationship": "RELATES_TO", "label": "supports"}
  ],
  "deadline": "Friday 15:00",
  "time": {
    "raw": "Friday afternoon",
    "resolved": "Friday 15:00",
    "ambiguous": false,
    "suggestion": null
  },
  "source": {
    "capture_type": "image",
    "filename": "pricing.png",
    "stored_raw": false
  }
}
```

| Proposal field | Type | Notes |
|----------------|------|-------|
| `summary` | string | Short description shown in approval UI |
| `node_type` | string | `Task`, `Note`, `Idea`, `Event`, `Person`, `Project`, `Resource`, `Reminder`, … |
| `title` | string | Primary node title |
| `related_nodes` | array | Secondary entities materialized as extra graph nodes on approve |
| `relationships` | array | Edges to existing or new nodes (`target_node_id` or `target_title`) |
| `deadline` | string \| null | Resolved time string when present |
| `time` | object \| null | Ambiguous-time block — triggers `time_clarification` SSE when `ambiguous: true` |
| `source` | object | Present for image/file/link captures — **no raw bytes** in API |

On approve, secondary entities from `related_nodes` / `relationships` (e.g. `Person`) become additional Neo4j nodes linked with `INVOLVES`, `PART_OF`, or `RELATES_TO`.

**Errors**: `401` · `422` unsupported type

---

### Transcribe voice (STT only)
`POST /captures/transcribe`

Multipart upload. Runs live or stub STT on transient audio — **no capture job** is created and audio is not stored. Use before showing/editing transcript in onboarding or composer UIs.

**Request** `multipart/form-data`

| Field | Type | Rules |
|-------|------|-------|
| `file` | file | required in **live** `ai_mode`; optional in stub (uses `duration_ms` only) |
| `duration_ms` | int | optional, default `0` |

**Response** `200`

```json
{
  "text": "سلام، این یک یادداشت تستی است",
  "source": "live_stt"
}
```

`source` is `live_stt` (OpenAI / OpenRouter / Gemini per admin `stt` route) or `stub_stt` (**stub `ai_mode` only**). In **live** mode the API never silently falls back to stub.

**Admin STT setup** (`/admin` → Per-feature routing → **Voice STT**):

| Provider | Example models | Notes |
|----------|----------------|-------|
| OpenAI | `whisper-1` | Direct Whisper API |
| OpenRouter | `openai/whisper-1`, audio-input chat models | Whisper uses `/audio/transcriptions`; others use multimodal chat |
| Gemini | `gemini-2.0-flash`, `gemini-2.5-flash` | Inline audio via `generateContent` |

**Errors**: `401` · `422` (empty transcript / no audio in live mode) · `413` file too large · `503` (no STT route, missing OpenAI key, provider error)

---

### Create voice capture
`POST /captures/voice`

Multipart upload. Audio is transcribed via **mock STT** (not persisted) then processed as text.

**Request** `multipart/form-data`

| Field | Type | Rules |
|-------|------|-------|
| `file` | file | optional audio (`m4a`, etc.); may be omitted in dev — STT uses `duration_ms` |
| `duration_ms` | int | optional, default `0` |
| `channel` | string | optional, default `mobile` |

**Response** `202` — same shape as text capture (`capture_type` reflects underlying text pipeline).

**Errors**: `401` · `422` (disabled flag or unsupported) · `413` file too large

---

### Create image capture
`POST /captures/image`

Multipart upload. Image bytes are analyzed via vision (stub metadata or live model), optionally embedded with **`multimodal_embed`**, then processed as text. Bytes are not stored.

**Request** `multipart/form-data`: `file` (required), optional `caption`, `channel`.

**Response** `202` — `capture_type: "image"`, proposal `node_type: "Resource"`. Proposal responses omit raw `multimodal_embedding` vectors.

**Errors**: `401` · `422` (`capture_image` off) · `413` file too large

---

### Create link capture
`POST /captures/link`

Submit a URL (+ optional note) for Resource-style processing. Page content is not fetched yet; the URL is stored in proposal metadata only.

**Request Body**
```json
{
  "url": "https://example.com/article",
  "note": "Read later",
  "channel": "mobile"
}
```

| Field | Type | Rules |
|-------|------|-------|
| `url` | string | required, max 2048 — `https://` added when scheme omitted |
| `note` | string | optional, max 2000 |
| `channel` | string | optional, default `mobile` |

**Response** `202` — `capture_type: "link"`, proposal `node_type: "Resource"`.

**Errors**: `401` · `422` (`capture_link` off or empty URL) · `404` · `403`

---

### Create file capture
`POST /captures/file`

Multipart upload. File bytes are used transiently for metadata only (filename, size, sha256); content is not persisted.

**Request** `multipart/form-data`: `file` (required), optional `caption`, `channel`.

**Response** `202` — `capture_type: "file"`, proposal `node_type: "Resource"`.

**Errors**: `401` · `413` file too large

---

### Confirm ambiguous time
`POST /captures/{capture_id}/confirm-time`

After SSE `time_clarification` or when `state` is `clarification_needed` with a `proposal.time` block.

**Request Body**
```json
{
  "accepted": true,
  "resolved_time": "Friday 15:00"
}
```

| Field | Type | Rules |
|-------|------|-------|
| `accepted` | boolean | default `true` — use suggested time when `resolved_time` omitted |
| `resolved_time` | string | optional override; required when `accepted` is `false` |

**Response** `200` — capture response with `state: awaiting_approval` and updated `proposal.time.resolved`.

**Errors**: `409` wrong state · `404` · `403`

---

### Clarify ambiguous intent
`POST /captures/{capture_id}/clarify-intent`

Use when capture state is `clarification_needed` and backend asks:
`Could you clarify — is this a question or something to save?`

**Request Body**
```json
{
  "intent": "question"
}
```

| Field | Type | Rules |
|-------|------|-------|
| `intent` | string | required, enum: `question`, `save` |

**Response** `200` — capture response in one of:
- `question_answered` + `answer`
- `awaiting_approval` + `proposal`
- `clarification_needed` (if still ambiguous)

**Errors**: `409` wrong state · `404` · `403` · `422` invalid intent

---

### Follow up on pending approval
`POST /captures/{capture_id}/follow-up`

Use when a capture is already awaiting approval and the user keeps chatting before saving, e.g. `not tomorrow, Friday` or `why did you make this a task?`.

**Request Body**
```json
{
  "message": "Actually make it Friday"
}
```

| Field | Type | Rules |
|-------|------|-------|
| `message` | string | required, 1-4000 chars |

**Response** `200` — same `capture_id`, capture response in one of:
- `awaiting_approval` + updated `proposal`
- `question_answered` + `answer`
- `clarification_needed` if more input is required

Backend rebuilds transient `raw_text` from the original user input plus the follow-up, clears the old proposal, and re-runs capture processing. Nothing enters Graph V2 until `POST /captures/{capture_id}/approve`.

**Errors**: `409` wrong state · `404` · `403` · `422` invalid message

---

### Confirm entity equivalence (cross-language same person)
`POST /captures/{capture_id}/confirm-entity-equivalence`

Use when capture state is `clarification_needed` and `proposal.entityEquivalence.status` is `pending`, or after SSE `entity_clarification`.

Typical prompt: `Are فاطمه and Fatemeh the same person in your memory?`

**Request Body**
```json
{
  "same": true,
  "targetEntityId": "ent_09958ec81926"
}
```

| Field | Type | Rules |
|-------|------|-------|
| `same` | boolean | required — `true` merges aliases; `false` keeps separate people |
| `targetEntityId` | string | optional — canonical entity to keep when `same` is `true` |

**Response** `200` — capture response with `state: awaiting_approval` and updated `proposal` (equivalence resolved, ready for approval).

**Errors**: `409` wrong state · `404` · `403` · `422`

---

### Get capture status
`GET /captures/{capture_id}`

**Response** `200` — same shape as create response.

**Errors**: `404` · `403` (not owner)

---

### Stream capture events (SSE)
`GET /captures/{capture_id}/stream`

`Content-Type: text/event-stream`

Events:
```
event: status
data: {"state": "processing"}

event: proposal
data: {"summary": "...", "node_type": "Task", "title": "...", "related_nodes": [], "deadline": null}

event: question_answer
data: {"answer": "..."}

event: clarification
data: {"prompt": "..."}

event: entity_clarification
data: {"prompt": "Are فاطمه and Fatemeh the same person in your memory?", "entityEquivalence": {"status": "pending", "nameA": "فاطمه", "nameB": "Fatemeh", "candidates": [], "suggestedTargetEntityId": null}}

event: time_clarification
data: {"prompt": "Did you mean Friday at 3 PM?", "suggestion": "Friday 15:00", "time": {...}}

event: done
data: {"state": "awaiting_approval"}

event: error
data: {"detail": "..."}
```

---

### Approve proposal
`POST /captures/{capture_id}/approve`

Runs graph v2 ingest: creates `:Capture`, `:Entity`, `:Assertion`, tasks/preferences, and materialized edges per predicate registry. Purges capture from Redis. Raw text is persisted on the `:Capture` node at approve time only.

**Request Body** (optional edits) — legacy v1 fields are ignored; proposal v2 comes from Redis/SSE.

**Response** `200`
```json
{
  "captureId": "550e8400-e29b-41d4-a716-446655440000",
  "createdEntities": ["ent_a1b2c3d4"],
  "createdAssertions": ["asrt_e5f6g7h8"],
  "materializedEdges": ["edge_1"],
  "tasks": ["task_9abc"],
  "preferences": []
}
```

Use `createdEntities[0]` as `highlightNodeId` on `MemoryGraphScreen` after save.

**Errors**: `409` wrong state · `404` · `403`

---

### Dismiss capture
`POST /captures/{capture_id}/dismiss`

Nothing stored. Purges all transient data.

**Response** `204` — empty body

**Errors**: `409` · `404` · `403`

---

## Graph v2 & Daily Update

All endpoints require `Authorization: Bearer <access_token>`.

Graph v2 is evidence-first: **Capture → Mention → Entity → Assertion → Predicate Registry → materialized edges**. Vectors (768-dim) power GraphRAG server-side — not returned in API responses.

### Graph view
`GET /v2/graph?view=knowledge|evidence|hybrid|tasks`

Returns nodes, edges, and optional saved layout for the authenticated user.

**Query**

| Param | Default | Values |
|-------|---------|--------|
| `view` | `knowledge` | `knowledge`, `evidence`, `hybrid`, `tasks` |

**Response** `200`
```json
{
  "view": "knowledge",
  "nodes": [
    {
      "id": "b08d1048-31cf-4f2f-84c8-20264d1f6272",
      "kind": "USER",
      "labels": ["User"],
      "title": "You",
      "status": "ACTIVE"
    },
    {
      "id": "ent_a1b2c3",
      "kind": "ENTITY",
      "entityType": "Person",
      "labels": ["Entity", "Person"],
      "title": "Alex",
      "subtitle": null,
      "status": "ACTIVE"
    }
  ],
  "edges": [
    {
      "id": "edge-1",
      "kind": "DOMAIN",
      "type": "HAS_ROLE_RELATION",
      "sourceId": "b08d1048-31cf-4f2f-84c8-20264d1f6272",
      "targetId": "ent_a1b2c3",
      "confidence": 0.91,
      "evidenceCount": 1
    }
  ],
  "layout": {
    "positions": [{"nodeId": "ent_a1b2c3", "x": 0.42, "y": 0.55}],
    "panX": 0,
    "panY": 0,
    "scale": 1.0
  }
}
```

| Field | Type | Notes |
|-------|------|-------|
| `nodes[].id` | string | `ent_*`, `task_*`, `cap_*`, … |
| `nodes[].kind` | string | `USER` (knowledge hub), `ENTITY`, `TASK`, `CAPTURE`, … |
| `nodes[].entityType` | string \| null | `Person`, `Activity`, `Organization`, … |
| `edges[].type` | string | Materialized rel (`AFFILIATED_WITH`, `HAS_ROLE_RELATION`, …) |
| `layout` | object \| null | Omitted until first `PUT /v2/graph/layout` |

**Errors**: `401`

---

### Save graph layout
`PUT /v2/graph/layout`

Persists node positions (normalized `0.0`–`1.0`) and viewport pan/zoom. Node IDs are v2 graph ids (`ent_*`, `task_*`).

**Request**
```json
{
  "positions": [{"nodeId": "ent_a1b2c3", "x": 0.42, "y": 0.55}],
  "panX": 12.0,
  "panY": -8.0,
  "scale": 1.1
}
```

**Response** `200` — same shape as `layout` in `GET /v2/graph`

**Errors**: `401` · `422`

---

### Entity detail
`GET /v2/entities/{entity_id}`

Returns entity metadata, assertions (with capture citations), and mention snippets.

**Errors**: `401` · `404`

---

### Tasks
`GET /v2/tasks?status=OPEN&entityId={entity_id}`

Returns task nodes for the tasks graph view / daily brief integration. Optional `entityId` filters tasks linked to that project/entity via `ABOUT` or `INVOLVES` edges.

Each task response includes `dueAt` when the capture contained a resolvable deadline/date/time. `duePrecision` is `datetime` for explicit times and `date` for date-only reminders.

**Errors**: `401`

---

### Update task
`PATCH /v2/tasks/{task_id}`

Update task lifecycle or metadata. Typical client use: mark `DONE` or `CANCELLED` from graph sheet or daily brief checkbox.

**Request**
```json
{
  "status": "DONE",
  "title": "Optional new title",
  "dueAt": "2026-06-25T18:00:00+00:00"
}
```

All fields optional; send only what changes.

**Response** `200`
```json
{
  "taskId": "task_abc",
  "title": "Call Alex",
  "actionType": "CALL",
  "status": "DONE",
  "createdAt": "2026-06-20T10:00:00+00:00",
  "dueAt": "2026-06-25T18:00:00+00:00",
  "duePrecision": "datetime",
  "dueText": "Friday at 6 PM",
  "captureId": "cap_xyz"
}
```

**Errors**: `400` (invalid transition) · `401`

---

### Archive capture
`DELETE /v2/captures/{capture_id}`

Soft-delete: sets capture `ARCHIVED`, rejects its assertions, cancels its tasks, demotes materialized edges supported only by this capture. **Shared entities stay** when referenced by other captures.

**Response** `200`
```json
{
  "archived": true,
  "captureId": "cap_xyz",
  "assertionsRejected": 3,
  "tasksCancelled": 1,
  "edgesDemoted": 2
}
```

**Errors**: `401` · `404`

---

### Patch capture title
`PATCH /v2/captures/{capture_id}`

Display-only title edit (no re-LLM). Use when user tweaks wording without changing meaning.

**Request**
```json
{ "title": "Mobbina is 39 years old" }
```

**Response** `200`
```json
{ "captureId": "cap_xyz", "title": "Mobbina is 39 years old" }
```

**Errors**: `401` · `404` · `422`

---

### Correct capture (semantic edit)
`POST /v2/captures/{capture_id}/correct`

Archives the old capture subgraph, ingests corrected text as a **new** `capture_id`, and links `(new)-[:CORRECTS]->(old)`.

**Request**
```json
{ "text": "Mobbina turned 40 this year" }
```

**Response** `200` — same shape as graph ingest (`captureId`, `createdEntities`, `tasks`, …) plus optional `correctsCaptureId`.

**Errors**: `400` · `401` · `404` · `422`

---

### Reject assertion
`POST /v2/assertions/{assertion_id}/reject`

Marks an assertion `REJECTED` (entity detail sheet).

**Response** `200` — `{ "status": "REJECTED" }`

**Errors**: `401` · `404`

---

### Hybrid search
`GET /v2/search?q=<query>&limit=10`

Returns matching entities (full-text + vector) and captures.

**Errors**: `401` · `422`

---

### Ontology catalog
`GET /v2/ontology`

Public predicate registry, entity types, and ontology version for client rendering.

**Errors**: none (no auth required in dev; Bearer optional)

---

### Daily update
`GET /daily-update`

Returns up to **20 open task items** for the Daily Brief screen (`DailyBriefRepository.fetchDailyUpdate()`). Tasks with `due_at` include timing metadata so the client can show and schedule reminders from the actual deadline instead of creation time.

No query parameters.

**Response** `200`
```json
{
  "items": [
    {
      "id": "660e8400-e29b-41d4-a716-446655440001",
      "node_type": "Task",
      "title": "Send deck to Sara",
      "summary": "Follow up deck delivery",
      "created_at": "2026-06-14T12:01:00+00:00",
      "due_at": "2026-06-15T17:00:00+00:00",
      "due_precision": "datetime",
      "capture_type": "text"
    },
    {
      "id": "770e8400-e29b-41d4-a716-446655440002",
      "node_type": "Resource",
      "title": "pricing.png",
      "summary": "Pricing screenshot",
      "created_at": "2026-06-13T09:30:00+00:00",
      "capture_type": "image",
      "thumbnail_b64": "<jpeg-base64>"
    }
  ]
}
```

| Field | Type | Notes |
|-------|------|-------|
| `items[].id` | string | Memory node id (same as graph node id) |
| `items[].node_type` | string | `Task`, `Note`, `Resource`, `Idea`, … |
| `items[].title` | string | Display title |
| `items[].summary` | string | Body / preview text |
| `items[].created_at` | datetime (ISO 8601) | Approval timestamp — client groups into Today / Yesterday |
| `items[].due_at` | datetime (ISO 8601) \| null | Actual task deadline/reminder time when known |
| `items[].due_precision` | string \| null | `datetime` or `date` depending on source timing specificity |
| `items[].capture_type` | string \| null | Original capture channel: `text`, `voice`, `image`, `file`, `link` — from approved payload `source.capture_type`; `null` for legacy nodes |
| `items[].thumbnail_b64` | string \| null | JPEG display thumb (~168px) for `capture_type: image`; full upload bytes are never stored |

**Flutter mapping** (`DailyBriefData.fromDailyUpdateItems`):

- `node_type` `Task` / `Reminder` → task card; time label and notification scheduling prefer `due_at` over `created_at`
- `capture_type` `image` → `ImageBriefCard` (`Image.memory` when `thumbnail_b64` present; placeholder otherwise)
- otherwise → expandable note card

**Errors**: `401`

---

## Workspace Library & Connectors

All routes below require Bearer auth except `GET /.well-known/mira-mcp.json`.
Bearer auth may be either an app JWT access token or a scoped developer API key for workspace/MCP/clipper tooling.

### Canvas boards

Canvas v1 stores an infinite-ish visual board as JSON nodes, edges, and viewport. Flutter renders sticky notes, text boxes, library reference cards, shapes, and arrows, then persists changes through `PATCH /canvas/{id}`.

`POST /canvas`
```json
{ "title": "Mira canvas", "spaceId": null }
```

`GET /canvas`

Returns the user's boards ordered by `updatedAt` descending.

`GET /canvas/{id}`

Fetches one board owned by the current user.

`PATCH /canvas/{id}`
```json
{
  "nodes": [
    {
      "id": "local-1",
      "type": "sticky",
      "x": 260,
      "y": 210,
      "width": 210,
      "height": 150,
      "text": "Map the main idea",
      "color": 4294906280,
      "metadata": {}
    }
  ],
  "edges": [],
  "viewport": { "x": -80, "y": -60, "scale": 0.86 }
}
```

**Response** `200`
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "title": "Mira canvas",
  "spaceId": null,
  "nodes": [],
  "edges": [],
  "viewport": {},
  "createdAt": "2026-07-05T12:00:00Z",
  "updatedAt": "2026-07-05T12:00:00Z"
}
```

Canvas node `type` values include `sticky`, `text`, `shape`, `arrow`, `library_item`, `chunk_reference`, `annotation`, and `embed`. The backend normalizes legacy `library` nodes to `library_item` and keeps `viewport.schemaVersion = "canvas.v1"`.

### List connectors
`GET /plugins`

Returns provider connectors only. Manual-only sources such as WhatsApp, Telegram, Bale, PDFs, local files, and social video links are not plugins; they appear in `GET /library/import-sources`.

Google connectors report `implementationStatus: "native_sync"` and can connect/sync in v1. Other provider manifests may report `implementationStatus: "adapter_ready"` for future rollout, but direct connect/sync returns `409` until provider auth is enabled.

**Response** `200`
```json
[
  {
    "id": "notion",
    "kind": "connector",
    "name": "Notion",
    "description": "Pages, databases, and project knowledge.",
    "category": "Knowledge",
    "implementationStatus": "adapter_ready",
    "authType": "oauth2",
    "scopes": ["pages.read", "databases.read"],
    "capabilities": ["import", "search", "link_objects"],
    "syncModes": ["manual", "scheduled"],
    "enabled": true,
    "configured": false,
    "connected": false,
    "lastSyncAt": null
  }
]
```

### Connect connector
`POST /plugins/{id}/connect`

Creates or updates the user's connector configuration for enabled native-sync connectors. OAuth/API-token exchange remains provider-specific; v1 accepts an optional token and stores connector state for sync.

**Request**
```json
{ "token": "<optional-provider-token>" }
```

**Response** `200`
```json
{ "pluginId": "gmail", "configured": true }
```

**Errors**: `404` unknown connector, `409` connector manifest exists but direct sync is not enabled.

### Sync connector
`POST /plugins/{id}/sync`

Runs a manual native connector sync and creates a provenance-tagged `LibraryItem` with `source: "plugin:{id}"`.

**Response** `200`
```json
{
  "status": "ok",
  "pluginId": "gmail",
  "adapter": "native_sync",
  "imported": 1,
  "item_id": "550e8400-e29b-41d4-a716-446655440000"
}
```

**Errors**: `404` unknown connector, `409` connector manifest exists but direct sync is not enabled.

### Import sources
`GET /library/import-sources`

Returns the Library Import Hub manifest for Fabric-style content sources and manual exports.

**Response** `200`
```json
[
  {
    "id": "whatsapp_export",
    "name": "WhatsApp exports",
    "category": "Messaging",
    "action": "share_or_upload_export",
    "status": "ready",
    "extensions": [".txt", ".zip"],
    "description": "Export a chat as .txt or share selected messages/files to Mira."
  }
]
```

Actions: `upload_file`, `paste_link`, `upload_or_paste_text`, `share_or_upload_export`, `connect_provider`, `create_note`.

### Import link
`POST /library/imports/link`

Creates a Library item from a URL. YouTube, TikTok, and Instagram/Reels links use honest `metadata_ready` status unless transcript extraction is available.

```json
{
  "url": "https://www.youtube.com/watch?v=abc",
  "sourceId": "youtube",
  "title": "Optional title",
  "note": "Optional user note"
}
```

**Response**: `LibraryItem` with `source: "import:{sourceId}"`.

### Import text
`POST /library/imports/text`

Creates a Library item from pasted/shared text, message exports, HTML, Markdown, meeting notes, JSON, or CSV-like text.

```json
{
  "sourceId": "meeting_notes",
  "title": "Weekly sync",
  "text": "Decision: ship import hub.",
  "mimeType": "text/plain"
}
```

**Response**: `LibraryItem` with `extractionStatus: "ready"`.

### Search Library v2
`POST /library/search-v2`

Runs chunk-level semantic search when the admin `embed` route is configured; otherwise uses lexical scoring. Response is citation-ready and does not replace the legacy `/library/search` list endpoint.

```json
{
  "q": "founder pricing",
  "type": "note",
  "source": "import:meeting_notes",
  "tags": ["meeting"],
  "status": "ready",
  "limit": 20
}
```

**Response** `200`
```json
{
  "query": "founder pricing",
  "matches": [
    {
      "item": { "id": "550e8400-e29b-41d4-a716-446655440000" },
      "chunk": {
        "id": "660e8400-e29b-41d4-a716-446655440000",
        "itemId": "550e8400-e29b-41d4-a716-446655440000",
        "chunkType": "text",
        "chunkIndex": 0,
        "text": "Atlas should use invited onboarding and founder pricing.",
        "startMs": null,
        "endMs": null,
        "locator": null,
        "metadata": {},
        "createdAt": "2026-07-05T12:00:00Z"
      },
      "score": 1.25,
      "snippet": "Atlas should use invited onboarding and founder pricing.",
      "matchType": "lexical"
    }
  ]
}
```

### Assistant over Library
`POST /assistant/run`

Uses `/library/search-v2` context. The legacy `citations` array remains item-level for compatibility; new UI should prefer `sourceCitations`.

```json
{ "prompt": "What did I save about founder pricing?", "action": "ask" }
```

**Response** `200`
```json
{
  "answer": "Answer from your Mira Library...",
  "citations": [],
  "sourceCitations": [],
  "createdItem": null,
  "createdSpace": null
}
```

### Meeting notes
`POST /library/meetings`

Multipart form. Send `title` plus either `transcript` or `file`.

```text
title=Weekly sync
transcript=Decision: ship annotations.
```

Text transcript imports return a ready `LibraryItem`; audio/video files are stored securely and queued for media-worker transcription.

### Library chunks
`GET /library/items/{id}/chunks`

Returns extracted text chunks for ready documents, transcripts, OCR, or imported text. Chunk load failures should not hide already available item metadata.

### Save Library item to Graph
`POST /library/items/{id}/save-to-graph`

Requires auth. Converts the item's extracted chunks/content into a save-intent capture, runs the normal capture processor, and auto-approves into Graph V2 when a proposal is ready. This is the explicit bridge from Library to the memory graph; importing a PDF into Library alone does not add graph nodes.

**Response** `200`
```json
{
  "itemId": "550e8400-e29b-41d4-a716-446655440000",
  "captureId": "660e8400-e29b-41d4-a716-446655440000",
  "state": "saved",
  "message": "Saved extracted Library insights to the memory graph.",
  "graphIngest": {
    "captureId": "660e8400-e29b-41d4-a716-446655440000",
    "createdEntities": [],
    "createdAssertions": [],
    "materializedEdges": [],
    "tasks": [],
    "preferences": [],
    "correctsCaptureId": null
  }
}
```

If the item was already sent to Graph, `state` is `already_saved`. If there is no extracted text/content yet, the API returns `409`.

### Annotations
`GET /library/items/{id}/annotations`

Lists reader annotations for an item.

`POST /library/items/{id}/annotations`
```json
{
  "chunkId": "660e8400-e29b-41d4-a716-446655440000",
  "anchorType": "chunk",
  "quote": "founder pricing",
  "note": "Important launch line",
  "color": "yellow",
  "tags": []
}
```

`PATCH /library/annotations/{id}` accepts the same body shape. `DELETE /library/annotations/{id}` returns `204`.

### Publish
`POST /publish`

Creates a private link for a Library item or workspace target.

```json
{
  "targetType": "item",
  "targetId": "550e8400-e29b-41d4-a716-446655440000"
}
```

**Response** `201`
```json
{
  "id": "770e8400-e29b-41d4-a716-446655440000",
  "targetType": "item",
  "targetId": "550e8400-e29b-41d4-a716-446655440000",
  "token": "private-token",
  "url": "/p/private-token",
  "viewCount": 0
}
```

`GET /p/{token}` returns JSON for API clients (`Accept: application/json`) and a readable HTML page for browsers (`Accept: text/html`). HTML item pages render the Library title, metadata, summary, and extracted chunks.

### Developer API keys, MCP, CLI, Web Clipper

`GET /developer/api-keys`, `POST /developer/api-keys`, `DELETE /developer/api-keys/{id}` manage scoped tokens. Create returns the raw `token` once.

`POST /mcp/tools/{tool_name}` executes authenticated tools such as `library.search`, `assistant.ask`, `library.create_item`, and `spaces.list`.

CLI: backend package exposes `mira`; set `MIRA_API_BASE` and `MIRA_API_TOKEN`, then run `mira ask`, `mira search`, `mira note`, `mira link`, `mira upload`, or `mira sync-folder`.

Web Clipper: Chrome MV3 extension is in `../mira-backend/tools/web-clipper-extension/` and sends clipped links/text to the Library endpoints using a developer API key.

---

## Waitlist (Landing)

Public signup for **miramind.io** landing. No auth. CORS enabled for origins in `CORS_ALLOWED_ORIGINS` (default: `localhost:3000`, `miramind.io`, `www.miramind.io`).

### Join waitlist
`POST /waitlist`

**Landing signup (miramind.io)**

```json
{
  "email": "you@email.com",
  "role": "engineering",
  "reason": "I want Mira to remember my meetings and follow-ups."
}
```

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `email` | string | yes | unique per signup |
| `role` | string | yes | one of `founder`, `product`, `engineering`, `research`, `creative`, `student`, `other` |
| `reason` | string | yes | min 8 chars |

**Legacy mobile signup** (still accepted)

```json
{
  "mobile": "09123456789",
  "first_name": "علی",
  "last_name": "احمدی",
  "email": "ali@example.com"
}
```

**Response** `201`
```json
{
  "id": "uuid",
  "email": "you@email.com",
  "role": "engineering",
  "reason": "I want Mira to remember my meetings and follow-ups.",
  "mobile": null,
  "first_name": null,
  "last_name": null,
  "created_at": "2026-06-26T12:00:00+00:00"
}
```

**Errors**
- `409` — email or mobile already registered
- `422` — validation error

### Admin — list waitlist
`GET /admin/api/waitlist`

Admin Bearer. Query: `limit` (default 100, max 500), `offset` (default 0).

**Response** `200`
```json
{
  "count": 42,
  "items": [
    {
      "id": "uuid",
      "email": "you@email.com",
      "role": "engineering",
      "reason": "I want Mira to remember my meetings.",
      "mobile": null,
      "first_name": null,
      "last_name": null,
      "created_at": "2026-06-26T12:00:00+00:00"
    }
  ]
}
```

### Admin — delete waitlist entry
`DELETE /admin/api/waitlist/{entry_id}`

Admin Bearer. **Response** `200` `{ "deleted": true }` · **404** when not found.

---

## Super Admin

Separate super-admin auth (`role=superadmin` JWT). Enabled when `ADMIN_ENABLED=true`.

| URL | Description |
|-----|-------------|
| `GET /admin/login` | HTML login page |
| `POST /admin/auth/login` | JSON login |
| `GET /admin` | HTML dashboard (AI mode, flags, providers) |
| `POST /admin/api/settings/ai-mode` | Set `stub` or `live` |
| `PATCH /admin/api/feature-flags/{key}` | Toggle feature flag |
| `POST /admin/api/providers/{kind}/api-key` | Save encrypted provider key |
| `POST /admin/api/flush-captures` | Purge Redis captures |

### Admin login
`POST /admin/auth/login`

**Request Body**
```json
{ "email": "admin@example.com", "password": "..." }
```

**Response** `200`
```json
{
  "access_token": "<jwt>",
  "refresh_token": "<opaque>",
  "token_type": "bearer",
  "expires_in": 900
}
```

Protected admin routes: `Authorization: Bearer <admin_access_token>`.

### AI mode

`ai_mode` in MariaDB `app_settings`: `stub` (default, hash embeddings + heuristic adapters) or `live` (DB routing → OpenRouter/Gemini).

---

## Flutter integration notes

### Suggested Dart models

Mirror these in `lib/models/api/`:

```dart
class AuthTokens {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
}

class UserProfile {
  final String id;
  final String email;
  final String displayName;
  final bool isActive;
  final DateTime createdAt;
}
```

### Token storage

- Persist `refresh_token` in `flutter_secure_storage`
- Keep `access_token` in memory or secure storage
- Refresh proactively when `expires_in` elapsed or on `401`

### HTTP client flow

```
POST /auth/login → save tokens
GET  /auth/me    → Authorization: Bearer access
401              → POST /auth/refresh → retry original request
refresh fails    → clear tokens → show login
```

### Recommended package

`dio` or `http` + interceptors for auth header and refresh retry.

### Capture flow (Flutter)

Implemented in `lib/features/capture/`:

```
User types in prompt bar (AppBottomShell)
  → POST /captures { type: "text", text, channel: "mobile" }
  → GET /captures/{id}/stream (SSE via dio ResponseType.stream)
  → time_clarification → TimeClarificationSheet → POST /captures/{id}/confirm-time
  → proposal → ApprovalSheet → POST /captures/{id}/approve
  → question_answer → SnackBar + Home answer capsule
```

Voice (home): long-press → `POST /captures/voice` → same SSE path. On STT/upload/SSE error → in-place `VoiceCaptureFailurePanel` (retry or text fallback).

Onboarding first capture: `POST /captures/transcribe` → edit transcript → optional `POST /captures`.

Base URL: `lib/core/config/api_config.dart` (`10.0.2.2` on Android emulator).

Packages: `dio`, `flutter_secure_storage`.

### Daily Brief flow (Flutter)

Implemented in `lib/features/daily_brief/` + `lib/screens/daily_brief/`:

```
DailyBriefScreen init
  → GET /daily-update
  → DailyUpdateResponse → DailyBriefData.fromDailyUpdateItems()
  → section grouping (Today / Yesterday / date) client-side from created_at
```

Models: `lib/models/api/daily_update_models.dart`.

### Memory graph flow (Flutter)

Implemented in `lib/features/graph/`:

```
MemoryGraphScreen
  → GET /v2/graph?view=knowledge|evidence|hybrid|tasks
  → radial layout + InteractiveViewer (local physics)
  → debounced PUT /v2/graph/layout (2s after drag/zoom settles)
  → tap node → GraphNodeDetailSheet
```

Models: `lib/models/api/graph_models.dart`, `lib/features/graph/graph_layout_models.dart`, `lib/features/graph_v2/widgets/graph_view_mode_switcher.dart`.

Pass `highlightNodeId` (first `createdEntities` id from approve response) after save.

### Suggested Dart models (extended)

Also mirror in `lib/models/api/`:

```dart
class DailyUpdateItem {
  final String id;
  final String nodeType;
  final String title;
  final String summary;
  final DateTime createdAt;
  final String? captureType;
}

class GraphNode {
  final String id;
  final String nodeType;
  final String title;
  final String summary;
  final String? captureId;
  final DateTime createdAt;
}

class GraphEdge {
  final String id;
  final String sourceId;
  final String targetId;
  final String relationship;
}
```

---

## Planned — Phase 4

Not implemented yet.

| Method | Path | Description |
|--------|------|-------------|
| — | — | Real Anthropic LLM adapter |
| — | — | Bots, billing, subscription UI |

---

## Sync protocol

When `mira-backend` routes change:

1. Update this file from router + Pydantic schemas
2. Update `Last updated` date in header
3. Add/remove TOC entries
4. Update Flutter `lib/models/api/` to match
