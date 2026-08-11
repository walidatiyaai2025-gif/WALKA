# WALKA Backend-First Mobile Content Control Plan

Last updated: 2026-08-12
Owner direction: **Every mobile-facing value that can be changed safely without shipping a new app build should be controlled from the WALKA backend/dashboard.**
Tracking: #278

## 1. Target operating model

WALKA is moving from a mostly code-authored Flutter storefront to a **backend-first mobile CMS/control plane**.

```text
WALKA Admin Dashboard
        |
        | draft / validate / preview / publish / restore
        v
Laravel CMS + Catalog + Media + Remote Config
        |
        | versioned, allowlisted public API v1
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

Owner workflow:

1. Open `/admin`.
2. Change supported mobile content or presentation settings.
3. Save a private draft.
4. Preview draft versus published state.
5. Publish explicitly.
6. Compatible Flutter clients receive the new content without an APK/App Store release where technically safe.
7. Restore an immutable historical revision into a new draft when rollback is needed, review it, then publish again.

### Current implementation milestone

The backend-first foundation and first Home controls are now stable on `main`:

- **CMS-001 completed** — stable content keys/types, draft/published snapshots, optimistic revisions, immutable history and restore primitives. #284 / PR #286.
- **CMS-002 completed** — protected `/admin/content` registry, draft editor, preview, explicit publish, history and restore controls. #287 / PR #288.
- **CMS-003 completed** — allowlisted published Home Hero API plus Flutter remote -> last-known-good cache -> bundled fallback and live Home rendering. #289 / PR #290.
- **CMS-020 completed** — typed owner-friendly Home Hero editor with safe first-use defaults and strict public field allowlisting. #292 / PR #293.
- **CMS-021 completed** — typed Home section manifest: owner-controlled approved section order, optional visibility and safe Collection/Editorial copy; Flutter maps only known compiled section IDs and retains LKG/bundled fallback. #294 / PR #295.
- **CMS-022 next** — backend-controlled featured Product/Variant membership and merchandising order using existing stable catalog IDs only. #296.

## 2. What must become backend-controlled

### Product / catalog presentation

- customer-facing product names
- feature bullets / highlights
- short descriptions and editorial copy
- customer-facing color labels
- display ordering of products and variants
- visibility / enabled state where safe
- featured / recommended state
- policy-safe badges/campaign labels
- product image/media assignments and gallery ordering
- related-product relationships
- optional supporting copy around the Amazon handoff

### Home / Landing

- hero title, eyebrow/subtitle, supporting copy and safe CTA labels
- approved Home section order and optional visibility
- Collection and editorial section display copy
- hero/editorial media
- featured products / variants and merchandising order
- trust/benefit display configuration where factual claims stay governed
- promotional/announcement banners
- campaign start/end scheduling

### Categories / Search

- category display names/descriptions/media
- category ordering and compatible visibility
- filter display labels
- empty/supporting copy
- discovery/editorial merchandising blocks

### Product Detail Page

- non-protected presentation copy
- highlights/editorial copy
- media/gallery assignment and order
- related items
- approved usage guidance where Product Master validation permits authoring
- display labels and section visibility/order within compiled layout contracts

### Information / support

- About / Story
- FAQ
- support contact display information and approved links
- privacy/terms/legal links and informational copy
- maintenance and customer-service notices

### Remote presentation/configuration

- non-security feature flags
- safe section enable/disable switches
- announcement/banner enable state
- campaign scheduling
- safe UI copy variants
- content refresh/version metadata

### Media library

- upload approved mobile images
- metadata / alt text / semantics labels
- assign media to product/variant/screen/section
- reorder galleries
- file/integrity/dimension validation
- draft/published replacement and immutable history

## 3. Protected / not freely editable

Backend-first does **not** mean every database field becomes an unrestricted text box.

These remain locked unless a dedicated governed workflow explicitly changes policy:

- stable Product/Variant IDs
- released identity relationships
- verified Product Master facts/dimensions
- Pantone identities
- ASIN identity
- factual/compliance-sensitive claims
- purchase architecture (`amazon_redirect`)
- executable Flutter business logic and arbitrary widget types
- secrets, credentials, authentication/security policy
- arbitrary external URLs
- arbitrary HTML/JavaScript/code injection
- app permissions/native capabilities requiring a release

Amazon destinations may become dashboard-managed only through a governed Amazon-domain allowlisted workflow with stable variant mapping, audit and rollback; they must never become unrestricted URL fields.

## 4. Mandatory CMS safety contract

Every dynamic-content family must implement all applicable controls before it is production-ready:

- stable record keys/types
- explicit public allowlisting of keys/types/fields
- optimistic revision/concurrency protection
- validation on write and again at public delivery
- private draft vs published state
- preview before publish
- immutable audit/history snapshots
- restore-to-new-draft rather than silent history rewrite
- safe defaults
- revision-aware last-known-good mobile cache
- bundled fallback for critical availability
- additive/backward-compatible API v1 evolution
- schema/content versioning
- deterministic ordering
- explicit empty/null behavior
- no secret/admin/draft fields in public responses
- server-side authorization
- Dashboard -> DB -> API -> Flutter propagation tests

## 5. Delivery priority

This program is a **P0 backend/mobile architecture priority**. New owner-changeable copy, images, banners, ordering, visibility or merchandising must not be introduced as hard-coded Flutter values except as explicit bundled fallback.

### Phase A — CMS foundation and publication model

| ID | Priority | Scope | Status |
|---|---|---|---|
| CMS-001 | P0 | Generic draft/published revision + immutable history foundation | ✅ COMPLETED · #284 / PR #286 |
| CMS-002 | P0 | Protected Content workspace: preview/publish/history/restore | ✅ COMPLETED · #287 / PR #288 |
| CMS-003 | P0 | Public content envelope + Flutter LKG/bundled fallback proof path | ✅ COMPLETED · #289 / PR #290 |
| CMS-004 | P0 | Dashboard roles/navigation/permissions for Content, Media, App Config | TODO |

### Phase B — Product and PDP control

| ID | Priority | Scope | Status |
|---|---|---|---|
| CMS-010 | P0 | Product descriptions/highlights/visibility/order/featured state | TODO |
| CMS-011 | P0 | Variant display order/visibility + safe customer metadata | TODO |
| CMS-012 | P0 | PDP section content/order/visibility model | TODO |
| CMS-013 | P0 | Related-product authoring | TODO |
| CMS-014 | P0 | Dashboard -> API -> live PDP regression matrix | TODO |

### Phase C — Home / discovery control

| ID | Priority | Scope | Status |
|---|---|---|---|
| CMS-020 | P0 | Typed Home Hero editor | ✅ COMPLETED · #292 / PR #293 |
| CMS-021 | P0 | Typed Home section order/visibility + safe section copy | ✅ COMPLETED · #294 / PR #295 |
| CMS-022 | P0 | Featured products/variants and merchandising order | 🔵 NEXT · #296 |
| CMS-023 | P0 | Announcement/promo banners + scheduling | TODO |
| CMS-024 | P0 | Categories display metadata/order/visibility | TODO |
| CMS-025 | P0 | Search/discovery presentation + merchandising | TODO |

### Phase D — Media library

| ID | Priority | Scope | Status |
|---|---|---|---|
| CMS-030 | P0 | Production media storage model | TODO |
| CMS-031 | P0 | Upload validation: type/dimensions/size/integrity | TODO |
| CMS-032 | P0 | Product/variant gallery assignment/order | TODO |
| CMS-033 | P0 | Home/category/editorial media assignment | TODO |
| CMS-034 | P0 | Media revision/audit/replacement/restore | TODO |
| CMS-035 | P0 | Flutter remote media cache/failure fallback/semantics | TODO |

### Phase E — Information, support and remote config

| ID | Priority | Scope | Status |
|---|---|---|---|
| CMS-040 | P1 | About / Story CMS | TODO |
| CMS-041 | P1 | FAQ CMS | TODO |
| CMS-042 | P1 | Support/contact configuration | TODO |
| CMS-043 | P1 | Legal/privacy/terms links and copy | TODO |
| CMS-044 | P1 | Maintenance/announcement notices | TODO |
| CMS-045 | P1 | Safe non-security feature flags/presentation switches | TODO |

### Phase F — Operational quality

| ID | Priority | Scope | Status |
|---|---|---|---|
| CMS-050 | P1 | Scheduled publish/unpublish | TODO |
| CMS-051 | P1 | Rich content diff before publish | TODO |
| CMS-052 | P1 | Owner rollback shortcuts/audit UX | TODO |
| CMS-053 | P1 | API/content freshness/cache/publication observability | TODO |
| CMS-054 | P1 | Backup/restore validation for CMS/catalog/media metadata | TODO |
| CMS-055 | P1 | Full production smoke matrix across Admin/API/Flutter | TODO |

### Phase G — governed commerce configuration

| ID | Priority | Scope | Status |
|---|---|---|---|
| CMS-060 | P1 | Governed Amazon destination editor | TODO |
| CMS-061 | P1 | Destination verification/audit/rollback | TODO |
| CMS-062 | P1 | Flutter dynamic Amazon destinations with bundled Product Master fallback | TODO |

## 6. Mobile implementation rule

Every user-visible value must be classified as:

1. **Dynamic content** — backend/CMS controlled.
2. **Protected product truth** — Product Master/governed data.
3. **Design-system constant** — visual primitives/component behavior.
4. **Executable behavior** — code/release required.

Remote configuration may select/order/hide only **known compiled UI components**; it may not deliver executable widgets or arbitrary runtime code.

## 7. API strategy

Keep `/api/v1` backward compatible. Current and planned additive surfaces include:

```text
GET /api/v1/catalog
GET /api/v1/content/home         # CMS-003: Home Hero
GET /api/v1/content/home-layout  # CMS-021: typed Home manifest
GET /api/v1/content/categories   # planned
GET /api/v1/content/information  # planned
GET /api/v1/app-config           # planned
```

Every dynamic response must carry enough schema/revision metadata for deterministic validation, caching and rollback-safe mobile behavior.

## 8. Production deployment rule

A merged CMS slice is not considered **live** until both production halves are updated:

1. Laravel code/migrations are deployed to `api.walkastore.com` and `walka:production-check` remains green.
2. Any Flutter consumption change is deployed to the target client/web channel using the production API base URL.

**Current warning:** CMS-001 through CMS-021 are stable in GitHub `main`, but the new CMS stack is not considered live on cPanel/mobile web until the production backend is redeployed/migrated and the Flutter production branch is reconciled/deployed.

## 9. Definition of done for this program

The program is complete only when the owner can change all approved mutable mobile presentation/content surfaces from `/admin`, publish them, see them propagate to live clients without a new app release where technically safe, and safely restore prior revisions while Product Master/security/runtime invariants remain enforced.
