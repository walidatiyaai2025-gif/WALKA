# WALKA API

Laravel 13 API backend for the WALKA mobile storefront.

API-001 release: `1.1.0`.

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
php artisan serve
```

No database is required for the API-001 catalog contract. Product data is config-backed in this release so the mobile API can stabilize before database/admin work is introduced.

## API v1

- `GET /api/v1/health` — service, API version and backend release contract.
- `GET /api/v1/config` — mobile-safe WALKA storefront configuration.
- `GET /api/v1/catalog` — typed Product + Variant catalog, verified Product Master facts, Pantone metadata, ASINs and official Amazon purchase destinations.

The API catalog is contract-tested against `../docs/PRODUCT_MASTER.md`. Product facts must be changed in the repository Product Master first, then reconciled into the API contract.

All purchase destinations remain external Amazon listings. API-001 adds no cart, checkout, payment, authentication, account sync, database-backed catalog or order storage.

## Validation

```bash
composer validate --strict
composer install --no-interaction --prefer-dist
vendor/bin/pint --test
php artisan test
php artisan route:list --path=api/v1
```

The same gates run in `.github/workflows/backend-api.yml` for API branches, pull requests and `main`.
