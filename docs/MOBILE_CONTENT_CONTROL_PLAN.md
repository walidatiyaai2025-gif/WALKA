# WALKA Backend-First Mobile Content Control Plan

Last updated: 2026-08-11
Owner direction: **Every mobile-facing value that can be changed safely without shipping a new app build should be controlled from the WALKA backend/dashboard.**
Tracking: #278

## 1. Target operating model

WALKA moves from a mostly code-authored Flutter storefront with a small remote catalog surface to a **backend-first mobile CMS/control plane**.

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
        +-- remote live content
        +-- last-known-good cache
        +-- bundled safe fallback
        |
        v
Amazon official purchase destination
```

The intended owner workflow is:

1. Open `/admin`.
2. Change mobile content or presentation settings.
3. Preview the effect.
4. Publish.
5. Flutter receives the new content without requiring an APK/App Store release where technically safe.
6. If a bad change is published, rollback to the previous revision from the dashboard.

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

- hero title, subtitle and supporting copy
- hero media
- CTA labels and destinations within the approved app navigation model
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

Every dynamic-content family must implement all applicable controls before it is considered production-ready:

- stable record keys
- optimistic revision/concurrency protection
- validation on write
- draft vs published state
- preview before publish
- immutable audit trail
- previous-version history
- one-click rollback
- safe defaults
- last-known-good mobile cache
- bundled fallback for critical screen availability
- additive/backward-compatible API v1 evolution
- schema/content versioning
- deterministic ordering
- explicit empty/null behavior
- no secret fields in public API responses
- server-side authorization
- production tests for Dashboard -> DB -> API -> Flutter propagation

## 5. Delivery priority

This program becomes a **P0 backend/mobile architecture priority**. New mobile presentation work should avoid hard-coding owner-changeable content when that content belongs to this plan.

### Phase A — CMS foundation and publication model

| ID | Priority | Scope | Status |
|---|---|---|---|
| CMS-001 | P0 | Generic content revision model: draft/published state, optimistic revision, audit, history | TODO |
| CMS-002 | P0 | Preview/publish/rollback service + dashboard controls | TODO |
| CMS-003 | P0 | Public API content-version envelope + Flutter last-known-good/bundled fallback contract | TODO |
| CMS-004 | P0 | Dashboard navigation/permissions for Content, Media, App Config | TODO |

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
| CMS-020 | P0 | Home hero CMS | TODO |
| CMS-021 | P0 | Home section block model and ordering | TODO |
| CMS-022 | P0 | Featured collections/products/variants | TODO |
| CMS-023 | P0 | Announcement/promo banners + scheduling | TODO |
| CMS-024 | P0 | Categories display metadata/order/visibility | TODO |
| CMS-025 | P0 | Search/discovery presentation copy and configurable merchandising | TODO |

### Phase D — Media library

| ID | Priority | Scope | Status |
|---|---|---|---|
| CMS-030 | P0 | Production media library storage model | TODO |
| CMS-031 | P0 | Upload validation: type, dimensions, file size, integrity | TODO |
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
| CMS-051 | P1 | Content diff view before publish | TODO |
| CMS-052 | P1 | Rollback UI and rollback audit events | TODO |
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

1. **Dynamic content** — should come from backend/CMS.
2. **Protected product truth** — comes from Product Master/governed data.
3. **Design-system constant** — spacing, typography, component behavior.
4. **Executable behavior** — requires code/release.

New owner-changeable copy, images, banners, ordering, visibility or merchandising must not be buried as new hard-coded Flutter constants unless it is explicitly a bundled fallback for a remote CMS field.

## 7. API strategy

Keep `/api/v1` backward compatible. Prefer additive endpoints/fields, for example:

```text
GET /api/v1/catalog
GET /api/v1/content/home
GET /api/v1/content/categories
GET /api/v1/content/information
GET /api/v1/app-config
```

The exact endpoint split is an implementation detail, but every response must carry enough version/revision metadata for deterministic caching and rollback-safe mobile behavior.

## 8. Definition of done for this program

The program is complete only when the owner can change all approved mutable mobile presentation/content surfaces from `/admin`, publish them, see them propagate to the live mobile/web client without a new app release, and safely rollback while protected Product Master/security/runtime invariants remain enforced.
