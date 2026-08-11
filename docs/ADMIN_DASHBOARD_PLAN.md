# WALKA Admin Dashboard Delivery Plan

Last updated: 2026-08-11
Owner: WALKA
Repository: `walidatiyaai2025-gif/WALKA`

## Mission

Ship a production-grade web Admin Dashboard on top of the existing Laravel backend while keeping the Flutter application on the stable public `/api/v1` contract. The dashboard is a server-side control plane; the mobile app never receives dashboard credentials or `WALKA_ADMIN_TOKEN`.

## Architecture

```text
WALKA Admin Browser
        |
        | HTTPS + server session
        v
Laravel /admin ----------------------+
        |                             |
        | CatalogAuthoringService     | public JSON
        v                             v
Database <---------------------- /api/v1/* <----- Flutter Android/iOS
        |
        +---- immutable catalog audits

Purchase remains: Flutter -> Amazon official product URL
```

## Delivery lanes

| ID | Status | Scope | Tracking |
|---|---|---|---|
| ADMIN-001 | COMPLETED | Protected premium dashboard foundation, overview, catalog editor, API status, audits, tests | #267 / PR #269 / `ed795817f64564940c870c1d876ddbedcc984bbb` |
| ADMIN-002 | IN PROGRESS | Production security hardening, readiness gate, deployment runbook, hosted `/admin` verification and owner URL handoff | #268 |
| ADMIN-003 | TODO | Media library and product-image authoring with storage validation | Future issue |
| ADMIN-004 | TODO | Home/featured-content CMS blocks consumed by Flutter through additive API v1 fields | Future issue |
| ADMIN-005 | TODO | Admin users/roles, password rotation and least-privilege permissions | Future issue |
| ADMIN-006 | TODO | Operational observability: request errors, API latency, deployment metadata and backup status | Future issue |
| ADMIN-007 | TODO | Production smoke-test matrix for dashboard + Flutter API compatibility | Future issue |

## ADMIN-001 delivered

- `/admin/login` is reachable without exposing secrets.
- `/admin` and all dashboard data routes require an authenticated server-side session.
- Dashboard password is configured only through environment variables.
- Dashboard reuses `CatalogAuthoringService`; it does not create a competing write path.
- Product authoring remains limited to `name` and ordered `features`.
- Variant authoring remains limited to customer-facing `color`.
- Product Master identity, facts, ASIN, Pantone and ordering stay locked.
- Existing optimistic `revision` protection remains active.
- Every effective catalog edit writes the existing immutable audit row.
- Overview surfaces backend release, API version, purchase mode, catalog counts and recent audit activity.
- Dashboard works without a Node/Vite build step so deployment is simple.
- Public `/api/v1/config`, `/api/v1/catalog` and `/api/v1/health` contracts stay backward compatible with Flutter.
- Feature tests cover login, access control, rendering and authoring.

## ADMIN-002 implementation

The production-hardening slice adds:

- defensive security headers on every `/admin` response
- no-store/no-cache behavior for dashboard responses
- frame blocking, MIME sniffing protection, strict referrer policy and restricted browser permissions
- dashboard Content Security Policy compatible with the current server-rendered UI
- HSTS on secure production requests
- explicit secure/encrypted/HTTP-only/SameSite session requirements
- `php artisan walka:production-check` as a fail-closed readiness gate
- database/catalog readiness checks before public handoff
- production deployment and smoke-test runbook in `docs/ADMIN_DEPLOYMENT.md`

ADMIN-002 remains open after code merge until the real hosted URL is supplied and passes the production smoke test.

## Production handoff

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

The command must PASS before `/admin` is considered production-ready. After deployment, verify `/api/v1/health`, `/api/v1/catalog`, `/admin/login`, Overview, Catalog and Audit Log and provide the final hosted `/admin` URL.

## Non-goals / boundaries

- No in-app WALKA checkout or payments. `purchase_mode=amazon_redirect` remains authoritative.
- No mobile storage of dashboard credentials.
- No direct Flutter-to-database connection.
- No create/delete catalog identity actions until an explicit migration and Product Master policy exists.
- No production secret committed to Git.
