# WALKA API

Laravel 13 API backend for the WALKA mobile storefront.

API-003 release: `1.3.0`.

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

The WALKA Product/Variant catalog is database-backed. `DatabaseSeeder` calls the idempotent `WalkaCatalogSeeder`, which reconciles the database to the Product-Master-aligned seed blueprint while preserving stable string IDs and deterministic ordering.

To reconcile catalog data again without rebuilding the database:

```bash
php artisan db:seed --class='Database\\Seeders\\WalkaCatalogSeeder'
```

If the catalog tables are migrated but unseeded, `GET /api/v1/catalog` fails explicitly with HTTP `503` and `catalog_unavailable`; it never silently falls back to stale server config.

## API v1

- `GET /api/v1/health` — service, API version and backend release contract.
- `GET /api/v1/config` — mobile-safe WALKA storefront configuration.
- `GET /api/v1/catalog` — database-backed typed Product + Variant catalog, verified Product Master facts, Pantone metadata, ASINs and official Amazon purchase destinations.

The API v1 catalog response shape remains backward compatible with Flutter 1.2. Product facts are contract-tested against `../docs/PRODUCT_MASTER.md` and must be changed there first.

All purchase destinations remain external Amazon listings. API-003 adds no cart, checkout, payment, authentication, account sync, remote Favorites, admin CMS or order storage.

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
