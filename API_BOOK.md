# MIRA Backend — API Book

> **For Flutter client (`mira_app`)** — contract to implement HTTP integration.
> **Source of truth**: `C:\Users\User\Desktop\mira-backend\src\mira\**\router.py`
> Last updated: 2026-06-23 (production: `api.miramind.io`; admin: `admin.miramind.io`)

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

**Content-Type**: `application/json` for all POST bodies.

---

## Table of Contents

1. [Health](#health)
2. [Auth](#auth)
3. [Captures](#captures)
4. [Graph & Daily Update](#graph--daily-update)
5. [Super Admin](#super-admin)
6. [Flutter integration notes](#flutter-integration-notes)
7. [Planned — Phase 4+](#planned--phase-4)

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
  "referral_required": true
}
```

`referral_required` is toggled from Super Admin → **Referral** (`PATCH /admin/api/referral/settings`). When `false`, new users skip the invite step and receive the email OTP immediately.

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

Phase 2 supports **`type: "text"`**, **`POST /captures/voice`**, **`POST /captures/image`**, and **`POST /captures/file`**. Voice/image require admin flags `capture_voice` / `capture_image`. Raw audio/image bytes are never persisted.

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

Persists approved structured node to memory graph (Neo4j) and interim MariaDB table. Purges capture from Redis.

**Request Body** (optional edits)
```json
{
  "title": "Send deck to Sara",
  "summary": "Follow up deck delivery",
  "node_type": "Task",
  "relationships": [
    {
      "target_node_id": "neo4j-memory-node-uuid",
      "target_title": "Beta launch",
      "relationship": "RELATES_TO",
      "label": "supports"
    }
  ]
}
```

`target_node_id` is preferred. When admin flag `entity_resolution` is enabled, `target_title` resolves to a single exact title match among approved graph nodes.

**Response** `200`
```json
{
  "id": "660e8400-e29b-41d4-a716-446655440001",
  "capture_id": "550e8400-e29b-41d4-a716-446655440000",
  "node_type": "Task",
  "title": "Send deck to Sara",
  "summary": "Follow up deck delivery",
  "payload": {
    "graph_node_id": "neo4j-memory-node-uuid"
  },
  "created_at": "2026-06-19T12:01:00+00:00"
}
```

**Errors**: `409` wrong state · `404` · `403`

---

### Dismiss capture
`POST /captures/{capture_id}/dismiss`

Nothing stored. Purges all transient data.

**Response** `204` — empty body

**Errors**: `409` · `404` · `403`

---

## Graph & Daily Update

All endpoints require `Authorization: Bearer <access_token>`.

### Memory graph
`GET /graph`

Returns nodes and edges for the authenticated user's memory graph (Neo4j).

**Response** `200`
```json
{
  "nodes": [
    {
      "id": "660e8400-e29b-41d4-a716-446655440001",
      "node_type": "Task",
      "title": "Send deck to Sara",
      "summary": "Follow up deck delivery",
      "capture_id": "550e8400-e29b-41d4-a716-446655440000",
      "created_at": "2026-06-14T12:01:00+00:00"
    }
  ],
  "edges": []
}
```

**Errors**: `401`

---

### Daily update
`GET /daily-update`

Returns recent memory items for the daily brief screen.

**Response** `200`
```json
{
  "items": [
    {
      "id": "660e8400-e29b-41d4-a716-446655440001",
      "node_type": "Task",
      "title": "Send deck to Sara",
      "summary": "Follow up deck delivery",
      "created_at": "2026-06-14T12:01:00+00:00"
    }
  ]
}
```

**Errors**: `401`

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

Base URL: `lib/core/config/api_config.dart` (`10.0.2.2` on Android emulator).

Packages: `dio`, `flutter_secure_storage`.
  → if proposal: show ApprovalBottomSheet
  → POST /approve or POST /dismiss
```

---

## Planned — Phase 4

Not implemented yet.

| Method | Path | Description |
|--------|------|-------------|
| — | — | Link / image capture types |
| — | — | Real STT + LLM adapters (Anthropic) |
| — | — | Bots, billing |

---

## Sync protocol

When `mira-backend` routes change:

1. Update this file from router + Pydantic schemas
2. Update `Last updated` date in header
3. Add/remove TOC entries
4. Update Flutter `lib/models/api/` to match
