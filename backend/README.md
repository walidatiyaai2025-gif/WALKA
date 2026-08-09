# WALKA API

Laravel 13 API backend for the WALKA mobile storefront.

## Runtime

- PHP 8.3+
- Composer 2
- Laravel 13.x (`laravel/framework` 13.8+)
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

- `GET /api/v1/health` — service, API version and release health contract.
- `GET /api/v1/config` — mobile-safe storefront configuration.
- `GET /api/v1/catalog` — WALKA products, variants, ASINs and Amazon purchase destinations.

All purchase destinations remain external Amazon listings. API-001 adds no cart, checkout, payment, authentication or order storage.

## Validation

```bash
composer validate --strict
composer install --no-interaction --prefer-dist
vendor/bin/pint --test
php artisan test
php artisan route:list --path=api/v1
```

The same gates run in `.github/workflows/backend-api.yml` for API branches, pull requests and `main`.
