# CATALOG-DYNAMIC — Dashboard / DB as sole runtime catalog source

Parent requirement: #386

## Runtime source of truth

The production catalog path is now:

`WALKA Dashboard -> database -> /api/v1/catalog -> Flutter remote snapshot -> last-known-good cache`

There is no compiled product/category/color fallback in the production catalog repository. A fresh install with no reachable API and no validated cache renders an unavailable state instead of inventing catalog entities.

## Dashboard-authorable catalog

The Dashboard owns first-class categories, products and variants/colors.

- Categories: create, rename, order, show/hide, delete when empty.
- Products: create, rename, move category, features, facts, order, show/hide, delete.
- Variants/colors: create, color label, swatch hex, Pantone, ASIN, order, show/hide, delete.
- Stable entity keys are immutable after create so URLs, media assignments, favorites and audit history remain referentially stable.
- Every mutation is revision-checked and audited.

## Public API behavior

`/api/v1/catalog` derives membership and ordering from database state only.

- hidden category -> its products are not published;
- hidden product -> not published;
- product with no visible variants -> not published;
- hidden/deleted variant -> not published;
- category names/order and variant swatches are returned by the API;
- no visible catalog -> explicit `503 catalog_unavailable`.

## Flutter behavior

- Remote catalog wins and becomes the LKG snapshot.
- Remote failure can use only a previously validated LKG cache.
- No Remote + no LKG -> catalog unavailable UI.
- Home, Search, Categories, Favorites and generic PDP membership use the dynamic snapshot.
- Product names, categories, colors, swatches, features, facts, ASINs and Amazon purchase URLs are read from the snapshot.
- Favorites resolve arbitrary variant IDs against the current snapshot; removed variants are not resurrected.
- Production commerce source contains no ASIN literals.

## Bootstrap seed boundary

The existing seed blueprint remains only to initialize the existing WALKA deployment/database. It uses non-destructive `firstOrCreate` semantics and cannot overwrite Dashboard-authored values or delete Dashboard-created entities. Application runtime repositories do not read `WalkaCatalogSeed`.

Legacy current-product data required by historical visual/reference widget tests lives under `mobile/test/` only. It is not under `mobile/lib/` and is not a production runtime source.

## Separate visual-release gate

This catalog architecture does not fabricate owner visual acceptance or bypass the existing production-media gate. Pink/Gray/final owner visual decisions remain separate from catalog authoring, and stable owner-visible publication stays fail-closed until those release conditions are satisfied.
