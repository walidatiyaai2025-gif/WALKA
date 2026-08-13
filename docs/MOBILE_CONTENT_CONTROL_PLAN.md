# WALKA Backend-First Mobile Content Control Plan

Last updated: 2026-08-13
Owner direction: **Every mobile-facing value that can be changed safely without shipping a new app build should be controlled from the WALKA backend/dashboard.**
Tracking: #278

## 1. Target operating model

WALKA is moving from a mostly code-authored Flutter storefront with a small remote catalog surface to a **backend-first mobile CMS/control plane**.

```text
WALKA Admin Dashboard
        |
        | draft / validate / preview / publish / rollback
        v
Laravel CMS + Catalog + Media + Remote Config
        |
        | versioned public API v1 (additive/backward compatible)
        v
Flutter Android / iOS / Web
        |
        +-- validated remote published content
        +-- revision-aware last-known-good cache
        +-- bundled safe fallback
        |
        v
Amazon official purchase destination
```

The owner workflow is:

1. Open `/admin`.
2. Change mobile content or presentation settings.
3. Save a private draft.
4. Preview draft versus published state.
5. Publish explicitly.
6. Compatible Flutter clients receive the new content without an APK/App Store release where technically safe.
7. If a bad change is published, restore a previous immutable revision into a new draft, review it, then publish again.

### Current implementation milestone

The generic CMS foundation plus governed Home, Categories and Search control planes are delivered through CMS-025. The production-media control plane now includes the CMS-030 storage/lifecycle foundation and CMS-031 byte-validated private upload quarantine; CMS-032 product/variant gallery assignment is the next planned media slice. These controls do not bypass #230 production-asset admission truth:

- **CMS-001 completed** — stable content keys/types, draft/published snapshots, optimistic revisions, immutable history and restore primitives.
- **CMS-002 completed** — protected `/admin/content` registry, draft editor, preview, explicit publish, history and restore controls.
- **CMS-003 completed** — allowlisted published Home content API plus Flutter remote -> last-known-good cache -> bundled fallback and live Home Hero rendering.
- **CMS-020 completed** — owner-friendly typed Home Hero editor (#292 / PR #293).
- **CMS-021 completed** — owner-controlled approved Home section ordering/visibility with compiled Flutter components only (#294 / PR #295).
- **CMS-022 completed** — owner-controlled featured product/variant membership and ordering using stable catalog IDs with runtime catalog validation (#296 / PR #311).
- **CMS-023 completed** — one governed Home announcement/promo banner with enabled state, UTC start/end schedule, compiled CTA routing and offline schedule enforcement (#313 / PR #314).
- **CMS-024 completed** — governed category display metadata, ordering and visibility while protected catalog membership remains immutable (#315 / PR #316).
- **CMS-025 completed** — governed Search/discovery copy, filter labels and complete-catalog Featured ordering (#317 / PR #318).
- **CMS-030 completed** — governed production-media source/derivative storage and lifecycle model (#319 / PR #320).
- **CMS-031 completed** — protected byte-validated PNG/JPEG/WebP upload quarantine with server-derived integrity metadata and Draft-only registration (#322 / PR #325).

## 2. What must become backend-controlled

### Product / catalog presentation

- customer-facing product names
- feature bullets / highlights
- short descriptions and editorial copy
- customer-facing color labels
- display ordering of products and variants
- visibility / enabled state where hiding an item is safe
- featured / recommended state
- badges such as `New`, `Featured`, or campaign labels when policy-safe
- product image/media assignments
- gallery ordering
- related-product relationships
- optional CTA/supporting copy around the Amazon handoff

### Home / Landing

- hero title, eyebrow/subtitle and supporting copy
- hero media
- safe CTA labels; navigation behavior remains executable Flutter logic
- featured collections
- featured products / variants
- editorial blocks
- trust/benefit blocks
- promotional/announcement banners
- section ordering
- section visibility
- campaign start/end scheduling

### Categories / Search presentation

- category display names
- category descriptions
- category hero/media
- category ordering
- category visibility when compatible with stable identifiers
- filter display labels
- empty-state/supporting copy
- discovery/editorial blocks

### Product Detail Page

- presentation copy that is not a protected verified fact
- highlights/editorial copy
- media/gallery assignments and ordering
- related items
- approved usage guidance text where Product Master validation permits authoring
- display labels and section visibility/order where layout contracts allow it

### Information / support surfaces

- About / Story content
- FAQ questions and answers
- support email/phone/display information
- support links
- privacy/terms/legal document links and display copy
- app informational messages
- maintenance notices
- generic customer-service notices

### Remote presentation/configuration

- non-security feature flags
- optional section enable/disable switches
- announcement/banner enable state
- campaign scheduling
- safe UI copy variants
- content refresh TTL/version metadata
- minimum-content-version gates where fallback behavior is defined

### Media library

- upload approved mobile images
- image metadata / alt text / semantics label
- assign media to product/variant/screen/section
- reorder gallery images
- image validation and size/dimension limits
- publication state
- replacement without code change
- immutable media audit history

## 3. What remains protected / not freely editable

Backend-first does **not** mean every database field becomes an unrestricted text box.

The following remain locked unless a dedicated governed workflow explicitly changes the policy:

- stable Product/Variant IDs
- database relationships that define released identity
- verified Product Master facts and dimensions
- Pantone identities
- ASIN identity
- claims that require factual/compliance verification
- purchase architecture (`amazon_redirect`)
- executable Flutter business logic
- API secrets, session secrets and credentials
- authentication/security policy
- arbitrary external URLs
- arbitrary code / HTML / JavaScript injection
- app permissions
- native capabilities that require a mobile release

Amazon destinations may later become dashboard-managed **only through a validated commerce-destination workflow** with Amazon-domain allowlisting, stable product mapping, audit history and rollback. They must not become unrestricted URL fields.

## 4. Mandatory CMS safety contract

Every dynamic-content family must implement all applicable controls before it is production-ready:

- stable record keys
- explicit public allowlisting of content keys/types and fields
- optimistic revision/concurrency protection
- validation on write and again at public delivery boundaries
- draft vs published state
- preview before publish
- immutable audit/history snapshots
- previous-version history
- rollback by restoring into a new draft, never silent history rewrite
- safe defaults
- last-known-good mobile cache
- bundled fallback for critical screen availability
- additive/backward-compatible API v1 evolution
- schema/content versioning
- deterministic ordering
- explicit empty/null behavior
- no secret/admin/draft fields in public API responses
- server-side authorization
- production tests for Dashboard -> DB -> API -> Flutter propagation

## 5. Delivery priority

This program is a **P0 backend/mobile architecture priority**. New mobile presentation work must avoid hard-coding owner-changeable content when that content belongs to this plan; hard-coded values are acceptable only as explicit bundled fallbacks.

### Phase A — CMS foundation and publication model

| ID | Priority | Scope | Status |
|---|---|---|---|
| CMS-001 | P0 | Generic content revision model: draft/published state, optimistic revision, audit/history | ✅ COMPLETED · #284 / PR #286 |
| CMS-002 | P0 | Protected Content workspace: preview/publish/history/restore controls | ✅ COMPLETED · #287 / PR #288 |
| CMS-003 | P0 | Public content envelope + Flutter last-known-good/bundled fallback vertical slice | ✅ COMPLETED · #289 / PR #290 |
| CMS-004 | P0 | Dashboard roles/navigation/permissions for Content, Media and App Config | TODO |

### Phase B — Product and PDP control

| ID | Priority | Scope | Status |
|---|---|---|---|
| CMS-010 | P0 | Expand product authoring: descriptions, highlights, visibility, ordering, featured state | TODO |
| CMS-011 | P0 | Variant display ordering/visibility + safe customer-facing metadata | TODO |
| CMS-012 | P0 | PDP section content/order/visibility model | TODO |
| CMS-013 | P0 | Related-product authoring | TODO |
| CMS-014 | P0 | End-to-end dashboard edit -> public API -> live PDP regression coverage | TODO |

### Phase C — Home / discovery control

| ID | Priority | Scope | Status |
|---|---|---|---|
| CMS-020 | P0 | Typed Home Hero editor on CMS-001..003 foundation | ✅ COMPLETED · #292 / PR #293 |
| CMS-021 | P0 | Home section block model, ordering and visibility | ✅ COMPLETED · #294 / PR #295 |
| CMS-022 | P0 | Featured collections/products/variants | ✅ COMPLETED · #296 / PR #311 |
| CMS-023 | P0 | Announcement/promo banners + scheduling | ✅ COMPLETED · #313 / PR #314 |
| CMS-024 | P0 | Categories display metadata/order/visibility | ✅ COMPLETED · #315 / PR #316 |
| CMS-025 | P0 | Search/discovery presentation copy and configurable merchandising | ✅ COMPLETED · #317 / PR #318 |

### Phase D — Media library

| ID | Priority | Scope | Status |
|---|---|---|---|
| CMS-030 | P0 | Production media library storage model | ✅ COMPLETED · #319 / PR #320 |
| CMS-031 | P0 | Upload validation: type, dimensions, file size, integrity | ✅ COMPLETED · #322 / PR #325 |
| CMS-032 | P0 | Product/variant gallery assignment and ordering | TODO |
| CMS-033 | P0 | Home/category/editorial media assignment | TODO |
| CMS-034 | P0 | Media revision/audit/replacement/rollback | TODO |
| CMS-035 | P0 | Flutter remote-media loading, caching, failure fallback and semantics | TODO |

### Phase E — Information, support and remote app configuration

| ID | Priority | Scope | Status |
|---|---|---|---|
| CMS-040 | P1 | About / Story CMS | TODO |
| CMS-041 | P1 | FAQ CMS | TODO |
| CMS-042 | P1 | Support/contact configuration | TODO |
| CMS-043 | P1 | Legal/privacy/terms links and informational copy | TODO |
| CMS-044 | P1 | Maintenance/announcement notices | TODO |
| CMS-045 | P1 | Safe non-security feature flags and presentation switches | TODO |

### Phase F — Operational quality

| ID | Priority | Scope | Status |
|---|---|---|---|
| CMS-050 | P1 | Scheduled publish/unpublish | TODO |
| CMS-051 | P1 | Rich content diff view before publish | TODO |
| CMS-052 | P1 | Owner rollback shortcuts and rollback audit UX | TODO |
| CMS-053 | P1 | API/content freshness, cache and publication observability | TODO |
| CMS-054 | P1 | Backup/restore validation for CMS/catalog/media metadata | TODO |
| CMS-055 | P1 | Full production smoke matrix across Admin/API/Flutter | TODO |

### Phase G — governed commerce configuration

| ID | Priority | Scope | Status |
|---|---|---|---|
| CMS-060 | P1 | Governed Amazon destination editor with allowlist and stable variant mapping | TODO |
| CMS-061 | P1 | Destination verification + audit + rollback | TODO |
| CMS-062 | P1 | Flutter dynamic Amazon destination consumption with bundled Product Master fallback | TODO |

## 6. Mobile implementation rule from now on

When adding or polishing a Flutter screen, developers must classify every user-visible value as one of:

1. **Dynamic content** — backend/CMS controlled.
2. **Protected product truth** — Product Master/governed data.
3. **Design-system constant** — spacing, typography, component behavior.
4. **Executable behavior** — code/release required.

New owner-changeable copy, images, banners, ordering, visibility or merchandising must not be buried as new hard-coded Flutter constants unless it is explicitly a bundled fallback for a remote CMS field.

## 7. API strategy

Keep `/api/v1` backward compatible. Current and planned additive surfaces include:

```text
GET /api/v1/catalog
GET /api/v1/content/home           # CMS-003 / CMS-020
GET /api/v1/content/home-layout    # CMS-021
GET /api/v1/content/home-featured  # CMS-022
GET /api/v1/content/home-banner    # CMS-023
GET /api/v1/content/categories     # CMS-024
GET /api/v1/content/search         # CMS-025
GET /api/v1/content/information    # planned
GET /api/v1/app-config             # planned
```

Every dynamic response must carry enough schema/revision metadata for deterministic validation, caching and rollback-safe mobile behavior.

## 8. Production deployment rule

A merged CMS slice is not considered **live** until both production halves are updated:

1. Laravel code/migrations are deployed to `api.walkastore.com` and production readiness remains green.
2. Any Flutter consumption change is deployed to the target client build/web channel with the production API base URL.

Never report a newly merged CMS control as live merely because CI passed.

## 9. Definition of done for this program

The program is complete only when the owner can change all approved mutable mobile presentation/content surfaces from `/admin`, publish them, see them propagate to the live mobile/web client without a new app release where technically safe, and safely rollback while protected Product Master/security/runtime invariants remain enforced.