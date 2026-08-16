# STOREFRONT-DYNAMIC — Dashboard content and media presentation source

Parent requirement: #388

## Production source of truth

Mutable customer-facing storefront data now follows these governed paths:

- Catalog identity and facts: `Dashboard -> DB -> /api/v1/catalog -> Flutter remote -> validated LKG cache`.
- Typed presentation copy/merchandising: `Dashboard CMS draft/publish -> published content API -> Flutter remote -> revision-safe LKG cache`.
- Product and surface media metadata: `Dashboard media assignments -> DB -> media API -> Flutter verified metadata -> canonical media loader/cache`.

Compiled Flutter code remains responsible for executable navigation, widget composition, accessibility and security boundaries. It must not be used as a hidden source for mutable product identities, product media assignments or customer-facing business copy covered by an existing typed CMS contract.

## Generic storefront rendering

The production generic Home/Search/Categories/Product Detail flow consumes:

- Home Hero copy and CTA labels from `home.hero`.
- Home section order/visibility and section copy from `home.layout`.
- Featured product ordering from `home.featured`, validated against current visible Dashboard variants.
- Scheduled announcement copy from `home.banner`.
- Category display overlays from `categories.presentation`, validated against current visible Dashboard categories.
- Search copy, filter labels and merchandising order from `search.presentation`, validated against current visible Dashboard categories/variants.
- Shared Categories/PDP labels from the governed `storefront.copy` content family.
- Product/variant names, facts, colors, swatches, Pantone, ASIN and purchase URLs from the dynamic catalog snapshot.
- Product card/PDP images from verified Dashboard product media assignments.
- Category, Home Hero and editorial images from verified Dashboard surface-media assignments.

## Dashboard authoring is catalog-driven

Typed CMS editors no longer compile the current WALKA product/category/variant identities as bootstrap truth.

- **Categories** builds its editable rows from current visible `catalog_categories`, preserves existing CMS order/copy where the identity remains valid, appends newly-created categories in Dashboard order, and omits hidden/deleted categories from the current editor.
- **Search** keeps only text defaults in its content definition. Its Variant merchandising rows and Category filter identities are generated from the current visible Dashboard Catalog. Existing CMS ordering/labels are retained where valid; new variants/categories append automatically without a code change.
- **Home Featured** keeps only the structural rule of two collection slots plus one editorial slot. First-draft identities are selected from the first visible variants of the first two visible Dashboard product families; the editor only offers currently visible eligible variants. No Blue/Pink/Green/White/Gray or lunch/drawer identity is a Home Featured default in code.
- CMS presentation payloads remain validation overlays. They cannot invent an unknown catalog identity; public delivery revalidates against current visible Dashboard truth and fails closed when a referenced identity is no longer eligible.

## `storefront.copy`

`storefront.copy` is a typed and reserved CMS key with draft, optimistic revision, publish, immutable history restore and versioned public delivery.

Its server defaults only bootstrap a private first draft when the typed editor is opened. Defaults are not public runtime truth until an authorized owner explicitly publishes a revision. The generic JSON content creator cannot create this reserved key.

The public API exposes only the allowlisted copy fields and supports revision ETags. Unknown internal fields or URLs are never reflected by the public serializer.

## Media identity boundary

There is no compiled product/variant media identity list in production Flutter media parsing.

- Product media accepts arbitrary valid product and variant identities delivered by the current visible DB catalog.
- Product media public payload excludes hidden categories, hidden products and hidden variants.
- Category surface slots are derived from `catalog_categories` as `category:<id>` rather than a fixed lunch/drawer allowlist.
- Hidden categories retain assignment/history in Admin custody but their category media slots are excluded from public delivery.
- Structural surface keys `home.hero` and `home.editorial.small_changes` remain compiled because they are executable presentation slots, not catalog/business identities.
- Media metadata includes position, bytes, dimensions, MIME and SHA-256 so Flutter can verify canonical binary delivery.
- Runtime media fallback is Remote -> validated LKG -> unavailable/empty. It does not synthesize the old five product variant IDs.

## Fail-closed presentation behavior

The generic production storefront only renders CMS business copy from remote or cached published snapshots. Bundled compatibility snapshots do not resurrect catalog identities.

When verified product media is missing, product cards/PDP may show a neutral presentation derived from the current catalog variant swatch/color. No old product photograph or compiled product identity is resurrected.

## Regression coverage

Automated coverage protects the architecture by checking that:

- arbitrary Dashboard category/product/variant identities propagate into product and surface media contracts without code allowlist changes;
- hidden products/variants/categories are excluded from public presentation media;
- production media code contains no fixed current-product/current-category identity set;
- Categories, Search and Home Featured bootstrap from current DB catalog state rather than the current five variants/two categories;
- Search merchandising safely supports an owner-selected subset while query matching still uses the complete visible catalog;
- generic Search repository fixtures use arbitrary identities and bundled compatibility state contains no catalog identities;
- the generic storefront resolves typed Dashboard content and verified Dashboard media;
- the former generic hardcoded business copy is absent from production generic storefront source;
- `storefront.copy` remains private before Publish and public delivery is typed/versioned/allowlisted;
- current visual admission/release gates remain independent.

## Visual-release boundary

This work does not change production visual admission truth and does not fabricate owner acceptance.

- Pink remains **PENDING** until explicit owner visual acceptance for the governed candidate.
- Gray remains **BLOCKED** pending a truthful owner-approved source/presentation decision.
- Stable owner-visible publication remains fail-closed under the existing visual release gate.

No production-live deployment is claimed by this code/CI slice.
