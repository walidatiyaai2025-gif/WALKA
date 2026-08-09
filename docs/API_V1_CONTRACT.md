# WALKA API v1 Contract

Release baseline: `1.3.0`

The API extends the released Flutter experience without redefining the mobile information architecture or product facts. API-003 changes server-side persistence only; the API v1 response contract remains backward compatible with Flutter 1.2.

## Base namespace

`/api/v1`

All responses are JSON. The catalog is read-only to public clients and database-backed. Authentication, cart, checkout, payment, order and admin dependencies remain outside this release.

## GET /api/v1/health

Purpose: lightweight deployment/readiness contract.

```json
{
  "data": {
    "status": "ok",
    "service": "walka-api",
    "release": "1.3.0",
    "api_version": "v1"
  }
}
```

## GET /api/v1/config

Purpose: mobile-safe storefront configuration.

```json
{
  "data": {
    "brand": "WALKA",
    "release": "1.3.0",
    "api_version": "v1",
    "purchase_mode": "amazon_redirect"
  }
}
```

`purchase_mode=amazon_redirect` is the explicit commerce boundary. WALKA does not expose an in-app checkout or payment flow.

## GET /api/v1/catalog

Purpose: authoritative read-only Product + Variant catalog for the mobile storefront.

Top-level success shape remains unchanged:

```json
{
  "data": [],
  "meta": {
    "release": "1.3.0",
    "api_version": "v1",
    "purchase_mode": "amazon_redirect"
  }
}
```

If migrations exist but the WALKA catalog has not been seeded, the endpoint fails explicitly instead of returning an empty catalog:

```json
{
  "error": {
    "code": "catalog_unavailable",
    "message": "WALKA catalog is not seeded."
  }
}
```

HTTP status: `503 Service Unavailable`.

### Product

Each Product contains:

- `id` — stable machine identifier.
- `name` — customer-facing WALKA product name.
- `category` — stable discovery family.
- `features` — ordered customer-facing feature list.
- `facts` — typed Product Master facts.
- `variants` — ordered sellable color variants.

Current product IDs:

- `drawer-organizer`
- `stainless-steel-bento-lunch-box`

### Variant

Each Variant contains:

- `id` — stable machine identifier.
- `color` — customer-facing color name.
- `asin` — official Amazon ASIN.
- `pantone` — approved Pantone when applicable; `null` for Drawer variants.
- `purchase_url` — official selected-variant Amazon destination derived from the ASIN.

Current variant IDs:

- `drawer-organizer:white`
- `drawer-organizer:gray`
- `lunch-box:blue`
- `lunch-box:pink`
- `lunch-box:green`

## Persistence contract

API-003 stores Products and Product Variants in relational tables using stable string primary keys. Ordered `features`, typed `facts`, nullable Pantone metadata and variant order are preserved. The idempotent WALKA catalog seeder reconciles the database to the Product-Master-aligned seed blueprint and is safe to rerun.

The runtime `/api/v1/catalog` endpoint reads the database through a catalog repository. It does not read the legacy server config product array.

## Product Master rule

`docs/PRODUCT_MASTER.md` is the repository source of truth for product facts and approved usage/care language. Database seed and API tests intentionally bind persisted catalog data to that document. A product fact must be verified there before it is changed in the database seed.

Current locked examples include:

- Drawer Organizer: plastic, 8 compartments, `13 × 15 × 2 in`, expands to `22.4 in`, non-slip base, White/Gray. The current Product Master explicitly forbids publishing Drawer weight or packaging dimensions until a verified owner value is added.
- Lunch Box: SUS304 food tray, food-grade PP outer body, `1200 ml`, 4 compartments, insulated bag, stainless sauce cup with lid, spoon and fork.
- Lunch care rules: SUS304 tray dishwasher safe/not microwave safe; lid + silicone gasket top-rack dishwasher safe/not microwave safe; PP outer body microwave safe only after removing the stainless tray, lid and silicone gasket.
- Approved Lunch language: `Secure Lock | Helps Prevent Spills`, `SPILL-RESISTANT DESIGN`, `Best suited for dry meals & snacks.`, `Not intended for liquids. Best for dry & semi-wet foods.`, and carry upright.
- Approved Lunch Pantones: Blue `PANTONE 4155 U`, Pink `PANTONE 9242 U`, Green `PANTONE 6198 U`.

## Compatibility policy

Within API v1:

- Existing IDs and response keys are stable contracts.
- Persistence changes must not alter client-visible shape without an explicit API version change.
- Additive fields are preferred over destructive shape changes.
- Product/variant deletion or ID replacement requires an explicit Flutter migration plan.
- Flutter 1.2 may consume either a 1.1 or 1.3 API payload because the Product/Variant response contract is preserved.
