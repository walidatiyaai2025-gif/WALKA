# WALKA Admin Dashboard — Production Deployment

Last updated: 2026-08-11
Tracking: ADMIN-002 / #268

## Deployment target

Deploy the repository `backend/` application as a normal Laravel application. The web server document root must point to `backend/public`; never expose the repository root, `.env`, `storage`, database files, or source files directly.

The expected owner-facing routes are:

- `/admin/login` — dashboard sign-in
- `/admin` — operational overview
- `/admin/catalog` — Product/Variant authoring
- `/admin/audits` — immutable catalog audit history
- `/api/v1/health` — public API health contract
- `/api/v1/config` — mobile-safe storefront configuration
- `/api/v1/catalog` — authoritative mobile catalog

## Required production environment

Use real secrets only on the host. Never commit them to Git.

```dotenv
APP_ENV=production
APP_DEBUG=false
APP_URL=https://your-backend-domain.example

SESSION_DRIVER=database
SESSION_ENCRYPT=true
SESSION_SECURE_COOKIE=true
SESSION_HTTP_ONLY=true
SESSION_SAME_SITE=lax

WALKA_ADMIN_DASHBOARD_USERNAME=admin
WALKA_ADMIN_DASHBOARD_PASSWORD=<unique-password-manager-generated-secret>
WALKA_ADMIN_TOKEN=<cryptographically-random-secret-at-least-32-characters>
```

Configure the production database, cache, logs and mail settings for the chosen host. `APP_KEY` must be generated once and then retained; changing it later invalidates encrypted application/session data.

## First deployment

From `backend/` on the production host:

```bash
composer install --no-dev --optimize-autoloader --no-interaction
php artisan key:generate --force   # first deployment only when APP_KEY is empty
php artisan migrate --force
php artisan db:seed --class='Database\\Seeders\\WalkaCatalogSeeder' --force
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan walka:production-check
```

Do not run `key:generate` on later deployments when a valid production `APP_KEY` already exists.

## Required readiness gate

`php artisan walka:production-check` must return exit code `0` before the dashboard is exposed publicly. The gate validates:

- production environment and disabled debug mode
- HTTPS `APP_URL`
- configured `APP_KEY`
- dashboard username/password strength baseline
- admin API token minimum length
- Secure, encrypted, HTTP-only session cookies
- SameSite session protection
- persistent session driver
- database connectivity and seeded Product/Variant records

A failed check is a deployment blocker, not a warning to ignore.

## Reverse proxy / TLS

Terminate TLS with a valid certificate and redirect plain HTTP to HTTPS at the load balancer or web server. The dashboard emits defensive browser headers on every `/admin` response and adds HSTS when Laravel receives a secure production request.

When a reverse proxy terminates TLS, configure the hosting stack so Laravel correctly receives/trusts the forwarded HTTPS scheme. Verify this from the final public URL before relying on HSTS or secure-cookie behavior.

## Deployment sequence for updates

```bash
git pull --ff-only origin main
composer install --no-dev --optimize-autoloader --no-interaction
php artisan migrate --force
php artisan db:seed --class='Database\\Seeders\\WalkaCatalogSeeder' --force
php artisan optimize:clear
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan walka:production-check
```

The Product Master seeder is idempotent and preserves the explicitly authorable display copy while reconciling locked product identity/facts.

## Production smoke test

After the readiness command passes, verify in this order:

1. `GET /api/v1/health` returns HTTP 200 and WALKA API metadata.
2. `GET /api/v1/catalog` returns the seeded catalog.
3. `GET /admin/login` renders over HTTPS and includes defensive security headers.
4. Invalid dashboard credentials are rejected.
5. Valid dashboard credentials create a server-side session and open `/admin`.
6. `/admin/catalog` shows the two Product families and five variants.
7. Save a harmless approved display-copy change, confirm the revision increments, and confirm it appears through `/api/v1/catalog`.
8. Confirm `/admin/audits` records that change without storing a raw credential.
9. Confirm locked ASIN, Pantone, Product Master facts and stable IDs cannot be authored through the dashboard.
10. Build Flutter with the final API base URL and verify catalog refresh plus Amazon handoff.

## Final handoff

Provide the final hosted URL in the form:

```text
https://your-backend-domain.example/admin
```

ADMIN-002 remains open until the real hosted URL passes the smoke-test matrix above.
