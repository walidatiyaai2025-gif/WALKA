# WALKA API

Laravel 13 API backend for the WALKA mobile storefront.

## Runtime

- PHP 8.3+
- Composer 2
- Laravel 13.x

## Local setup

```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate
php artisan serve
```

## API v1

- `GET /api/v1/health` — service and release health contract.
- `GET /api/v1/config` — mobile-safe storefront configuration.
- `GET /api/v1/catalog` — WALKA products, variants, ASINs and Amazon purchase destinations.

API-001 intentionally uses config-backed catalog data. Authentication, database-backed catalog management and Flutter HTTP integration are later release slices.

## Validation

```bash
composer validate --strict
php artisan test
php artisan route:list --path=api/v1
```
