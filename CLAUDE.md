# MIRA — Engineering Rules

> Cross-project rules for **mira_app** (Flutter) and **mira-backend** (FastAPI).
> Last updated: 2026-06-19

---

## Workspace Layout

```
Desktop/
├── Mira/           # Flutter client — UI, local state, API consumer
└── mira-backend/   # Python API — business logic, persistence, AI pipeline
```

**Never use Laravel.** Backend is **100% Python (FastAPI)**.

---

## Architecture Principles

### Backend (Python)

| Rule | Requirement |
|------|-------------|
| **Design patterns** | Repository, Adapter, Factory, Dependency Injection, Unit of Work |
| **Clean code** | Routers = HTTP only · Services = business logic · Repositories = SQL/ORM only |
| **ORM** | SQLAlchemy 2.0 async — no raw SQL in routers/services |
| **Tests** | Unit test every service/repository/security adapter; all tests must pass before merge |
| **Validation** | Pydantic schemas on all inputs; sanitize user data at API boundary |

### Data Stores

| Store | Purpose |
|-------|---------|
| **MariaDB** | Users, billing, quotas, notifications, link codes (relational) |
| **Neo4j** | Memory graph + **vector embeddings** (GraphRAG) — not MariaDB |
| **Redis** | Queues, cache, rate limits, transient capture payloads |

Vectors and graph traversal live in **Neo4j only**. Do not add pgvector/MariaDB vector columns unless explicitly approved.

### AI / Workers

- Heavy work (LLM, STT, embeddings) → **async workers** (ARQ/Celery), not request thread
- AI providers behind **Adapter** interface (swappable)
- Log every AI call: `user_id, feature, model, tokens, cost_estimate`

---

## Code Quality

- **SOLID**, **DRY**, meaningful names, type hints everywhere (Python)
- Comment **non-obvious** business logic and each public service/repository method
- Minimize diff scope — no drive-by refactors
- Offer refactoring when you find dirty code, but don't block features

### Flutter

- Consume backend via [`API_BOOK.md`](API_BOOK.md) — single source of API contract
- No business rules duplicated from backend (approval, quota, graph logic stays server-side)
- RTL for Persian UI; Jalali/locale semantics handled server-side for dates
- Match existing `lib/theme/` tokens and widget patterns

---

## API Contract

- Base URL dev: `http://localhost:8000`
- Auth: `Authorization: Bearer <access_token>`
- Errors: `{ "detail": "<message>" }`
- Keep [`API_BOOK.md`](API_BOOK.md) in sync when backend routes change

---

## Product Invariants (never violate)

1. Nothing enters memory without **explicit user approval**
2. **Raw input** is never persisted (voice, original text, snapshots — transient only)
3. User **questions** are never stored as memory
4. Questions flow through the same capture input — no separate search screen
5. No Inbox/Unprocessed screen — Approval sheet is the only triage surface

---

## Ports (dev)

| Port | Service |
|------|---------|
| 8000 | mira-backend (FastAPI) |
| 3306 | MariaDB |
| 6379 | Redis |
| 7687 | Neo4j (phase 2+) |

---

## Per-Project Docs

| Project | AGENTS.md | API |
|---------|-----------|-----|
| `Mira/` (Flutter) | [`AGENTS.md`](AGENTS.md) | Consumer: [`API_BOOK.md`](API_BOOK.md) |
| `mira-backend/` | `../mira-backend/AGENTS.md` | Source: FastAPI routers + OpenAPI |

---

## Phase Status

- **Phase 1** ✅ Backend foundation + auth · Flutter UI mock
- **Phase 2** 🔄 Capture pipeline (text) + Flutter HTTP/auth integration
