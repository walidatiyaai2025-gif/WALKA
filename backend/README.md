# WALKA Laravel Backend + Admin Dashboard

Laravel 13 backend for the WALKA Flutter storefront.

Backend release baseline: `1.4.0`.

## Runtime

- PHP 8.3+
- Composer 2
- Laravel 13.x (`laravel/framework` 13.8+ in the locked manifest)
- CI runtime: PHP 8.4

## Local setup

```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate
touch database/database.sqlite
php artisan migrate --seed
php artisan serve
```

The default local server is normally available at `http://127.0.0.1:8000`.

## WALKA Admin Dashboard

ADMIN-001 adds a protected, server-rendered dashboard. It deliberately has no browser-side admin token and does not require a Node/Vite build step.

Configure the dashboard in `.env`:

```dotenv
WALKA_ADMIN_DASHBOARD_USERNAME=admin
WALKA_ADMIN_DASHBOARD_PASSWORD=<unique-password-at-least-12-characters>
```

Then open:

```text
/admin/login
```

Dashboard surfaces:

- `/admin` — operational overview, release/API status, catalog metrics and recent audit activity.
- `/admin/catalog` — author customer-facing Product `name`/`features` and Variant `color`.
- `/admin/audits` — latest immutable catalog authoring events.

All internal dashboard pages require an authenticated Laravel session. Login attempts are rate-limited. Successful login regenerates the session ID, logout invalidates the session, and dashboard mutations remain protected by Laravel CSRF middleware.

The dashboard reuses `CatalogAuthoringService`, so optimistic revision protection and immutable audit logging are shared with the protected admin API instead of creating a second write model.

### What the dashboard cannot change

The following remain Product Master / commerce identity fields and are intentionally not editable in ADMIN-001:

- stable product/variant IDs
- product category and verified facts
- product/variant relationships
- ASIN
- Pantone
- deterministic sort order

Product Master changes must start in `../docs/PRODUCT_MASTER.md` and follow the repository governance flow.

## Public API v1

- `GET /api/v1/health` — service, API version and backend release contract.
- `GET /api/v1/config` — mobile-safe WALKA storefront configuration. Admin secrets are never exposed.
- `GET /api/v1/catalog` — database-backed typed Product + Variant catalog, verified Product Master facts, Pantone metadata, ASINs and official Amazon purchase destinations.

The public API contract remains backward compatible with Flutter 1.2. Flutter reads the backend URL from its `WALKA_API_BASE_URL` compile-time environment value and never connects directly to the database.

The WALKA Product/Variant catalog is database-backed. `DatabaseSeeder` calls the idempotent `WalkaCatalogSeeder`, which reconciles Product Master locked fields while preserving authenticated admin-authored display copy (`Product.name`, `Product.features`, `Variant.color`). Stable IDs and deterministic ordering remain fixed.

To reconcile locked catalog data again without rebuilding the database:

```bash
php artisan db:seed --class='Database\\Seeders\\WalkaCatalogSeeder'
```

If catalog tables are migrated but unseeded, `GET /api/v1/catalog` fails explicitly with HTTP `503` / `catalog_unavailable`; it never silently falls back to stale server config.

## Backend-only catalog administration API

The machine-oriented admin API remains separate from the browser dashboard. Configure a cryptographically random Bearer token of at least 32 characters:

```dotenv
WALKA_ADMIN_TOKEN=<strong-random-secret>
```

Protected endpoints:

- `GET /api/v1/admin/catalog`
- `PATCH /api/v1/admin/catalog/products/{product}`
- `PATCH /api/v1/admin/catalog/variants/{variant}`
- `GET /api/v1/admin/catalog/audits`

The raw token is never persisted. Admin API responses are `Cache-Control: no-store`.

## Commerce boundary

`purchase_mode=amazon_redirect` remains authoritative. WALKA does not provide an in-app cart, checkout, payment processor or order store. The mobile application reads the official variant purchase destination and sends the customer to Amazon.

## Production deployment checklist

Set production environment values on the host, never in Git:

```dotenv
APP_ENV=production
APP_DEBUG=false
APP_URL=https://<backend-domain>
WALKA_ADMIN_DASHBOARD_USERNAME=admin
WALKA_ADMIN_DASHBOARD_PASSWORD=<strong-unique-password>
WALKA_ADMIN_TOKEN=<strong-random-api-token-at-least-32-characters>
```

Then run the normal Laravel deployment sequence appropriate for the host. At minimum:

```bash
composer install --no-dev --optimize-autoloader
php artisan migrate --force
php artisan db:seed --class='Database\\Seeders\\WalkaCatalogSeeder' --force
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

Verify after deployment:

```text
GET /api/v1/health
GET /api/v1/catalog
GET /admin/login
```

Production must use HTTPS. Configure secure cookies/session settings according to the hosting topology and keep all WALKA admin secrets in the host secret/environment manager.

## Validation

```bash
composer validate --strict
composer install --no-interaction --prefer-dist
touch database/database.sqlite
php artisan migrate:fresh --seed --force
vendor/bin/pint --test
php artisan test
php artisan route:list --path=api/v1
php artisan route:list --path=admin
```

The backend workflow under `.github/workflows/backend-api.yml` runs the repository backend gates for pull requests and `main`.

See `../docs/ADMIN_DASHBOARD_PLAN.md` for the full dashboard delivery and production handoff plan.
