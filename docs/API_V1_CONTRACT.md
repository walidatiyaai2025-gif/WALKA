# WALKA API v1 Contract

Release baseline: `1.4.0`

The API extends the released Flutter experience without redefining the mobile information architecture or Product Master facts. API-004 adds a separate protected authoring surface while keeping the public API v1 response contract backward compatible with Flutter 1.2.

## Base namespace

`/api/v1`

All responses are JSON. Public catalog reads remain unauthenticated and database-backed. Public clients never receive backend administration credentials.

## GET /api/v1/health

Purpose: lightweight deployment/readiness contract. The release value is `1.4.0`; service and API-version keys are unchanged.

## GET /api/v1/config

Purpose: mobile-safe storefront configuration. It exposes `brand`, `release`, `api_version`, and `purchase_mode=amazon_redirect`. `WALKA_ADMIN_TOKEN` is never returned.

## GET /api/v1/catalog

Purpose: authoritative Product + Variant catalog for the mobile storefront.

The existing top-level success shape remains unchanged:

```json
{
  "data": [],
  "meta": {
    "release": "1.4.0",
    "api_version": "v1",
    "purchase_mode": "amazon_redirect"
  }
}
```

If migrations exist but the WALKA catalog has not been seeded, the endpoint returns HTTP `503` with `catalog_unavailable`.

### Product

Each public Product continues to contain:

- `id` — stable machine identifier.
- `name` — customer-facing WALKA product name.
- `category` — stable discovery family.
- `features` — ordered customer-facing feature list.
- `facts` — typed Product Master facts.
- `variants` — ordered sellable color variants.

Current product IDs remain `drawer-organizer` and `stainless-steel-bento-lunch-box`.

### Variant

Each public Variant continues to contain `id`, `color`, `asin`, nullable `pantone`, and derived official Amazon `purchase_url`.

Current variant IDs remain:

- `drawer-organizer:white`
- `drawer-organizer:gray`
- `lunch-box:blue`
- `lunch-box:pink`
- `lunch-box:green`

## Persistence and revision contract

Products and Product Variants remain relational records with stable string primary keys. API-004 adds an internal integer `revision`, defaulting to `1`, to each record. Revisions are administration metadata only and are deliberately absent from the public `/api/v1/catalog` payload.

The idempotent Product Master seeder now preserves explicitly authorable display copy (`Product.name`, `Product.features`, `Variant.color`) on existing rows while continuing to reconcile locked fields such as category, facts, product relationships, ASIN, Pantone and sort order from the repository seed blueprint.

## Protected catalog administration

Base: `/api/v1/admin/catalog`

Every admin route requires `Authorization: Bearer <WALKA_ADMIN_TOKEN>`. The configured token must be at least 32 characters. If it is absent/weak the admin API fails closed with HTTP `503` / `admin_auth_unconfigured`; missing or invalid credentials return HTTP `401` / `admin_unauthorized`.

Admin responses use `Cache-Control: no-store`.

### GET /api/v1/admin/catalog

Returns the same catalog records for administration plus `revision`, timestamps and authoring metadata. This route does not change the public catalog contract.

### PATCH /api/v1/admin/catalog/products/{product}

Required: current `revision`. Authorable fields: `name`, `features`.

Explicitly prohibited: `id`, `category`, `facts`, `sort_order`, nested `variants`.

### PATCH /api/v1/admin/catalog/variants/{variant}

Required: current `revision` and customer-facing `color`.

Explicitly prohibited: `id`, `product_id`, `pantone`, `asin`, `sort_order`, `purchase_url`.

A stale revision returns HTTP `409` / `catalog_revision_conflict` with expected/current revision metadata. This optimistic concurrency contract prevents one author from silently overwriting a newer edit.

### GET /api/v1/admin/catalog/audits

Returns newest-first immutable authoring audit rows. `limit` is clamped to 1–100. Effective mutations record target type/ID, revision transition, before/after changed fields, timestamp and a SHA-256 fingerprint of the authenticated token. Raw Bearer tokens are never persisted.

API-004 intentionally provides no create/delete endpoints, so stable catalog identity cannot be changed through the admin API.

## Product Master rule

`docs/PRODUCT_MASTER.md` remains the repository source of truth for product facts and approved usage/care language. Product facts, category, ASIN, Pantone, stable IDs and deterministic ordering remain non-authorable through API-004.

Current locked examples remain the verified Drawer specifications, Lunch SUS304/food-grade PP/care rules, approved spill-resistance language, and Blue/Pink/Green Pantones recorded in Product Master.

## Commerce boundary

`purchase_mode=amazon_redirect` remains unchanged. WALKA does not expose in-app cart, checkout, payment or order processing.

## Compatibility policy

Within API v1:

- Existing public IDs and response keys remain stable contracts.
- Admin-only revision/audit metadata is not added to public mobile payloads.
- Additive internal administration features must not force Flutter changes.
- Product/variant deletion or ID replacement requires an explicit migration plan and is unavailable in API-004.
- Flutter 1.2 can consume the 1.4 public payload because the Product/Variant public response shape is preserved.
