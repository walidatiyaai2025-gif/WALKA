# WALKA API v1 Contract

Release baseline: `1.1.0`

The API extends the released Flutter `1.0.0` visual freeze. It does not redefine the mobile information architecture or product facts.

## Base namespace

`/api/v1`

All API-001 responses are JSON. The first foundation slice is read-only and config-backed; no database, authentication, cart, checkout, payment, order or admin dependency is required.

## GET /api/v1/health

Purpose: lightweight deployment/readiness contract.

```json
{
  "data": {
    "status": "ok",
    "service": "walka-api",
    "release": "1.1.0",
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
    "release": "1.1.0",
    "api_version": "v1",
    "purchase_mode": "amazon_redirect"
  }
}
```

`purchase_mode=amazon_redirect` is an explicit commerce boundary. API-001 does not expose a WALKA checkout or payment flow.

## GET /api/v1/catalog

Purpose: authoritative read-only Product + Variant catalog for the released mobile storefront.

Top-level shape:

```json
{
  "data": [],
  "meta": {
    "release": "1.1.0",
    "api_version": "v1",
    "purchase_mode": "amazon_redirect"
  }
}
```

### Product

Each Product contains:

- `id` — stable machine identifier.
- `name` — customer-facing WALKA product name.
- `category` — stable discovery family.
- `features` — compact customer-facing feature list.
- `facts` — typed Product Master facts used for detailed UI and later integration.
- `variants` — sellable color variants.

Current product IDs:

- `drawer-organizer`
- `stainless-steel-bento-lunch-box`

### Variant

Each Variant contains:

- `id` — stable machine identifier.
- `color` — customer-facing color name.
- `asin` — official Amazon ASIN.
- `pantone` — approved Pantone when applicable; `null` for Drawer variants.
- `purchase_url` — official selected-variant Amazon destination.

Current variant IDs:

- `drawer-organizer:white`
- `drawer-organizer:gray`
- `lunch-box:blue`
- `lunch-box:pink`
- `lunch-box:green`

## Product Master rule

`docs/PRODUCT_MASTER.md` is the repository source of truth for product facts and approved usage/care language. API tests intentionally bind the catalog to that document. A product fact must be verified there before it is changed in the API.

Important locked examples include:

- Drawer Organizer product weight `1.72 lb` and packaging `13.46 × 15.16 × 2.36 in`.
- Lunch Box SUS304 food tray, BPA-free PP outer body, `1200 ml`, 4 compartments and included accessories.
- Lunch care rules: SUS304 tray top-rack dishwasher safe/not microwave safe; lid + gasket hand wash; PP outer body microwave safe without the steel tray.
- Approved Lunch language: `Secure Lock | Helps Prevent Spills`, `Best for dry & semi-wet foods`, `Not intended for liquids`, `Carry upright`.

## Compatibility policy

Within API v1:

- Existing IDs and response keys are treated as stable contracts.
- Additive fields are preferred over destructive shape changes.
- Product/variant deletion or ID replacement requires an explicit migration plan for the Flutter client.
- API-002 may replace local Flutter mock catalog data with this contract, but must preserve the released `1.0.0` visual behavior.
