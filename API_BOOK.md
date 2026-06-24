# MIRA Backend — API Book

> **For Flutter client (`mira_app`)** — contract to implement HTTP integration.
> **Source of truth**: `C:\Users\User\Desktop\mira-backend\src\mira\**\router.py`
> Last updated: 2026-06-24 (production: `api.miramind.io`; admin: `admin.miramind.io`)

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
| `POST` | `/captures/{id}/approve` | `capture_repository.dart` | Ingest approved capture into graph v2 |
| `POST` | `/captures/{id}/dismiss` | `capture_repository.dart` | Discard capture |
| `GET` | `/v2/graph` | `graph_repository.dart` | Knowledge / evidence / hybrid / tasks graph |
| `PUT` | `/v2/graph/layout` | `graph_repository.dart` | Persist interactive layout |
| `GET` | `/v2/entities/{id}` | `graph_repository.dart` | Entity detail + assertions |
| `GET` | `/v2/tasks` | `graph_repository.dart` | Open tasks list |
| `GET` | `/v2/search` | — | Hybrid entity + capture search |
| `GET` | `/v2/ontology` | — | Predicate catalog + entity types |
| `GET` | `/daily-update` | `daily_brief_repository.dart` | Daily brief feed |

---

## Table of Contents

1. [Health](#health)
2. [Auth](#auth)
3. [Captures](#captures)
4. [Graph & Daily Update](#graph--daily-update)
5. [Super Admin](#super-admin)
6. [Flutter integration notes](#flutter-integration-notes)
7. [Planned — Phase 4+](#planned--phase-4)

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
      "sourceId": "ent_user",
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
| `nodes[].kind` | string | `ENTITY`, `TASK`, `CAPTURE`, … |
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
`GET /v2/tasks?status=OPEN`

Returns task nodes for the tasks graph view / daily brief integration.

**Errors**: `401`

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

Returns the **20 most recent** approved memory nodes for the Daily Brief screen (`DailyBriefRepository.fetchDailyUpdate()`). Ordered by `created_at` descending.

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
| `items[].capture_type` | string \| null | Original capture channel: `text`, `voice`, `image`, `file`, `link` — from approved payload `source.capture_type`; `null` for legacy nodes |
| `items[].thumbnail_b64` | string \| null | JPEG display thumb (~168px) for `capture_type: image`; full upload bytes are never stored |

**Flutter mapping** (`DailyBriefData.fromDailyUpdateItems`):

- `node_type` `Task` / `Reminder` → task card
- `capture_type` `image` → `ImageBriefCard` (`Image.memory` when `thumbnail_b64` present; placeholder otherwise)
- otherwise → expandable note card

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
