# WALKA API

Laravel 13 API backend for the WALKA mobile storefront.

API-004 release: `1.4.0`.

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

The WALKA Product/Variant catalog is database-backed. `DatabaseSeeder` calls the idempotent `WalkaCatalogSeeder`, which reconciles Product Master locked fields while preserving authenticated admin-authored display copy (`Product.name`, `Product.features`, `Variant.color`). Stable IDs and deterministic ordering remain fixed.

To reconcile locked catalog data again without rebuilding the database:

```bash
php artisan db:seed --class='Database\\Seeders\\WalkaCatalogSeeder'
```

If the catalog tables are migrated but unseeded, `GET /api/v1/catalog` fails explicitly with HTTP `503` and `catalog_unavailable`; it never silently falls back to stale server config.

## Public API v1

- `GET /api/v1/health` — service, API version and backend release contract.
- `GET /api/v1/config` — mobile-safe WALKA storefront configuration. The admin token is never exposed.
- `GET /api/v1/catalog` — database-backed typed Product + Variant catalog, verified Product Master facts, Pantone metadata, ASINs and official Amazon purchase destinations.

The public API v1 catalog response shape remains backward compatible with Flutter 1.2. Product facts are contract-tested against `../docs/PRODUCT_MASTER.md` and must be changed there first.

## Backend-only catalog administration

Catalog administration is disabled by default. Set a cryptographically random Bearer token of at least 32 characters:

```dotenv
WALKA_ADMIN_TOKEN=<strong-random-secret>
```

Protected endpoints:

- `GET /api/v1/admin/catalog` — inspect catalog plus optimistic `revision` values.
- `PATCH /api/v1/admin/catalog/products/{product}` — author `name` and/or ordered `features`; requires the current `revision`.
- `PATCH /api/v1/admin/catalog/variants/{variant}` — author the customer-facing `color`; requires the current `revision`.
- `GET /api/v1/admin/catalog/audits` — read the latest immutable authoring audit entries (`limit` is clamped to 1–100).

Example:

```bash
curl -X PATCH http://localhost/api/v1/admin/catalog/products/drawer-organizer \
  -H "Authorization: Bearer $WALKA_ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"revision":1,"name":"WALKA Expandable Drawer Organizer"}'
```

A stale revision returns HTTP `409` with `catalog_revision_conflict`, preventing lost updates. Stable IDs, category, Product Master facts, ASIN, Pantone, sort order and product/variant relationships are explicitly prohibited from authoring. No create/delete endpoint exists in API-004.

Every effective mutation writes an audit row containing only a SHA-256 token fingerprint, target, revision transition and before/after changed fields. The raw token is never persisted, and admin responses are marked `Cache-Control: no-store`.

All purchase destinations remain external Amazon listings. API-004 adds no web Admin UI/CMS, customer authentication, account sync, remote Favorites, cart, checkout, payment or order storage.

## Validation

```bash
composer validate --strict
composer install --no-interaction --prefer-dist
touch database/database.sqlite
php artisan migrate:fresh --seed --force
vendor/bin/pint --test
php artisan test
php artisan route:list --path=api/v1
```

The same gates run in `.github/workflows/backend-api.yml` for API branches, pull requests and `main`.
