# WALKA Admin Dashboard Delivery Plan

Last updated: 2026-08-11
Owner: WALKA
Repository: `walidatiyaai2025-gif/WALKA`
Tracking: #278

## Mission

The WALKA Admin Dashboard is now the **primary control plane for mutable mobile content**.

Owner direction is explicit: **every mobile-facing value that can be changed safely without shipping a new app build should be editable from the backend/dashboard and consumed dynamically by Flutter.**

The dashboard therefore expands beyond catalog copy into a controlled CMS covering products, PDP content, Home merchandising, categories/discovery, media, information/support content, safe remote configuration, publication history and rollback.

The detailed program backlog is authoritative in `docs/MOBILE_CONTENT_CONTROL_PLAN.md`.

## Architecture

```text
WALKA Admin Browser
        |
        | HTTPS + server session
        v
Laravel /admin
        |
        +-- Catalog authoring
        +-- Mobile content CMS
        +-- Media library
        +-- Remote presentation config
        +-- Draft / preview / publish / rollback
        +-- Immutable audit/history
        |
        v
Database + Media Storage
        |
        | versioned public JSON
        v
/api/v1/*  <---------------- Flutter Android / iOS / Web
        |                           |
        |                           +-- last-known-good cache
        |                           +-- bundled safe fallback
        |
        +--------------------------> Amazon official product URL
```

The mobile app never receives dashboard credentials or `WALKA_ADMIN_TOKEN`.

## Strategic rule

From this point forward, new Flutter work must avoid hard-coding owner-changeable content unless that value is explicitly the bundled fallback for a remote CMS field.

Every mobile-visible value must be classified as one of:

1. dynamic backend/CMS content;
2. protected Product Master truth;
3. design-system constant;
4. executable app behavior requiring a release.

## Delivery lanes

| ID | Status | Scope | Tracking |
|---|---|---|---|
| ADMIN-001 | COMPLETED | Protected premium dashboard foundation, overview, catalog editor, API status, audits, tests | #267 / PR #269 / `ed795817f64564940c870c1d876ddbedcc984bbb` |
| ADMIN-002 | CODE COMPLETE / HOSTED | Production security hardening, readiness gate, deployment runbook and hosted dashboard handoff | #268 |
| ADMIN-CMS | IN PROGRESS | Backend-first mobile content-control program and governance | #278 |
| CMS-001..004 | P0 TODO | Generic CMS revision model, draft/publish/rollback, content API envelope, dashboard Content/Media/App Config navigation | #278 follow-on issues |
| CMS-010..014 | P0 TODO | Product/PDP dynamic content expansion and end-to-end propagation tests | #278 follow-on issues |
| CMS-020..025 | P0 TODO | Home, featured merchandising, announcements, categories and discovery content control | #278 follow-on issues |
| CMS-030..035 | P0 TODO | Media library, assignment, validation, audit and Flutter remote-media path | #278 follow-on issues |
| CMS-040..045 | P1 TODO | About, FAQ, support, legal/information, notices and safe presentation switches | #278 follow-on issues |
| CMS-050..055 | P1 TODO | Scheduling, diffs, rollback UI, observability, backup and production smoke matrix | #278 follow-on issues |
| CMS-060..062 | P1 TODO | Governed Amazon destination management with allowlisting, audit and mobile fallback | #278 follow-on issues |
| ADMIN-005 | P1 TODO | Named admin users/roles, password rotation and least-privilege permissions | Future issue |
| ADMIN-006 | P1 TODO | Operational observability: request errors, API latency, deployment metadata and backup status | Future issue |

## What the owner should ultimately be able to change from `/admin`

### Product and PDP

- customer-facing names
- feature bullets/highlights
- descriptions/editorial copy
- display color labels
- product/variant ordering
- safe visibility/featured state
- gallery/media assignments and ordering
- related products
- policy-safe badges and supporting CTA copy
- section ordering/visibility where the released layout contract permits it

### Home / merchandising

- hero title/subtitle/media
- CTA labels
- featured products/variants/collections
- editorial blocks
- trust/benefit blocks
- announcement/promo banners
- section order and visibility
- campaign scheduling

### Categories / discovery

- display names and descriptions
- category media
- order/visibility using stable IDs
- filter labels
- empty-state/support copy
- configurable merchandising content

### Information and support

- About/Story
- FAQ
- support contact information and links
- privacy/terms/legal links and informational copy
- maintenance and customer notices

### Safe remote configuration

- non-security feature flags
- presentation enable/disable switches
- content refresh/version metadata
- campaign timing

### Media

- upload approved mobile media
- validate type/dimensions/size
- assign to screens/products/variants
- reorder galleries
- replace/publish/rollback with audit history

## Protected boundaries

Backend-first does not mean unrestricted editing.

The following remain locked unless a dedicated governed workflow explicitly changes their policy:

- stable Product/Variant IDs
- verified Product Master facts/dimensions
- Pantone identity
- ASIN identity
- compliance-sensitive claims
- database identity relationships
- purchase architecture (`amazon_redirect`)
- secrets/credentials/security controls
- executable Flutter behavior
- arbitrary external URLs/code/HTML/JavaScript
- native permissions/capabilities requiring a release

Amazon destinations can become dashboard-managed only through a validated allowlisted workflow with stable mapping, audit and rollback; they must never become unrestricted URL inputs.

## Mandatory content publication controls

Every dynamic-content family must implement the applicable controls before production release:

- optimistic revision/concurrency protection
- server-side validation
- draft vs published state
- preview before publish
- immutable audit trail
- revision history
- rollback
- deterministic ordering
- API/content revision metadata
- last-known-good Flutter cache
- bundled fallback
- additive/backward-compatible `/api/v1` evolution
- explicit null/empty behavior
- no secrets in public API
- Admin -> DB -> API -> Flutter integration tests

## Existing ADMIN-001 delivered foundation

- `/admin/login` is reachable without exposing secrets.
- `/admin` and dashboard data routes require an authenticated server-side session.
- Dashboard password is configured only through environment variables.
- Dashboard reuses the existing authoring service instead of creating competing write paths.
- Current Product authoring supports `name` and ordered `features`.
- Current Variant authoring supports customer-facing `color`.
- Product Master identity/facts/ASIN/Pantone/order are currently locked.
- Existing optimistic `revision` protection remains active.
- Every effective catalog edit writes the immutable audit ledger.
- Overview surfaces backend release, API version, purchase mode, catalog counts and recent audit activity.
- Dashboard works without a Node/Vite build step.
- Public `/api/v1/config`, `/api/v1/catalog` and `/api/v1/health` remain backward compatible with Flutter.

## Production handoff baseline

Configure at minimum:

```dotenv
APP_ENV=production
APP_DEBUG=false
APP_URL=https://<backend-domain>
SESSION_DRIVER=database
SESSION_ENCRYPT=true
SESSION_SECURE_COOKIE=true
SESSION_HTTP_ONLY=true
SESSION_SAME_SITE=lax
WALKA_ADMIN_DASHBOARD_USERNAME=admin
WALKA_ADMIN_DASHBOARD_PASSWORD=<strong-unique-password>
WALKA_ADMIN_TOKEN=<strong-random-api-token-at-least-32-characters>
```

Then install production dependencies, migrate/seed, cache Laravel configuration, and run:

```bash
php artisan walka:production-check
```

The command must PASS before `/admin` is considered production-ready.

## Definition of done for the dashboard program

The dashboard program is complete only when the owner can change every approved mutable mobile content/presentation surface from `/admin`, preview and publish it, see it propagate to the live client without a new app release where technically safe, and rollback safely while Product Master, security, commerce and runtime invariants remain protected.
