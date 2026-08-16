# WALKA Creative Asset Manifest

Status: **ASSET-001 final source audit / protected-reference classification / production-source mapping**  
Tracking: #197 / #198 / #230  
Product truth: `docs/PRODUCT_MASTER.md`  
Executable source admission: `docs/ui/PRODUCTION_SOURCE_ADMISSION.json`  
Production provenance: `docs/ui/PRODUCTION_ASSET_PROVENANCE.json`

## Purpose and precedence

This manifest separates three things that must never be conflated:

1. protected full-screen/design references under `Images/`,
2. approved owner/source artwork used to create derivatives,
3. canonical runtime product assets under `mobile/assets/products/`.

`Images/` is read-only. A protected reference may guide composition, hierarchy, spacing, color language or crop intent, but it is **not** automatically admitted as product photography. Product geometry/facts come from `docs/PRODUCT_MASTER.md`; executable source/admission JSON controls current production eligibility.

## Current canonical product-media truth

Current stable-publication readiness is **3/5**. This table records the current source/admission truth rather than the historical placeholder state.

| Variant | Canonical production path | Source state | Canonical export | Current lifecycle / release status |
|---|---|---:|---:|---|
| Drawer Organizer / White | `mobile/assets/products/drawer/white.png` | APPROVED | yes | **ADMITTED / ready** |
| Drawer Organizer / Gray | `mobile/assets/products/drawer/gray.png` | BLOCKED | no | **BLOCKED** — real Gray source is collapsed; no synthetic expanded geometry |
| Lunch Box / Blue | `mobile/assets/products/lunch/blue.png` | APPROVED | yes | **ADMITTED / ready** |
| Lunch Box / Pink | `mobile/assets/products/lunch/pink.png` | APPROVED | no | **PENDING / not canonically admitted** — exact owner visual acceptance + reconciliation still required |
| Lunch Box / Green | `mobile/assets/products/lunch/green.png` | APPROVED | yes | **ADMITTED / ready** |

This 3/5 state is intentionally insufficient for stable publication. Gray/Pink and the final owner-visible release gate remain independent blockers.

## Owner/source admission matrix

| Product / variant | Approved/current source | Source type | Admission | Production use / blocker |
|---|---|---|---|---|
| Drawer Organizer / White | `51yxoCdmqrL._AC_SL1500_(1).jpg` | Clean listing product photo | **APPROVED** | Real expanded organizer; admitted canonical transparent primary cutout exists. |
| Drawer Organizer / Gray | `IMG-20250919-WA0035.jpg` | Owner product/packaging photo | **BLOCKED** | Faithful Gray material/color but collapsed presentation. Do not recolor White or reconstruct hidden expanded geometry. Unblock only with a faithful approved expanded source or explicit owner approval of collapsed presentation. |
| Lunch Box / Blue | `main new(3).jpg` | Clean listing product photo | **APPROVED** | Real 4-compartment set; admitted canonical primary cutout exists. |
| Lunch Box / Pink | `1000389975.jpg` | Owner listing screenshot with clean product panel | **APPROVED SOURCE / CANONICAL PENDING** | Only the approved product panel may be extracted. Review-only cleanup/VPROOF cannot substitute for explicit owner visual acceptance. Current production canonical export remains unconfirmed. |
| Lunch Box / Green | `WhatsApp Image 2026-02-24 at 11.22.34 PM.jpeg` | Clean owner product photo | **APPROVED** | Real Green set; admitted canonical primary cutout exists. |

### Source-admission rules

- Source approval never approves unsupported copy/claims visible elsewhere in a listing or screenshot.
- Real geometry is never rebuilt or recolored to manufacture parity between variants.
- Cropping, masking, alpha cleanup, non-destructive tonal cleanup and canvas normalization are allowed only when they preserve the approved source.
- No price, rating, review count, marketplace chrome, navigation or unsupported claim may be baked into reusable product media.
- Source/master files stay outside the Flutter runtime bundle.
- A technically clean file is not production-admitted until source/admission/provenance/owner gates reconcile.

## Protected reference inventory — 18/18 classified

All 18 protected references are now visually classified or explicitly dispositioned. None is an automatic product-photo source.

| Reference file | Family / platform | Creative use | Direct production admission |
|---|---|---|---|
| `Home for Android.png` | Home / Android | Composition, hierarchy, product prominence and mobile crop reference | NO — full-screen UI master |
| `Home for ios.png` | Home / iOS | iOS composition and safe-area visual reference | NO — full-screen UI master |
| `Home for pc.png` | Home / Desktop | Wide-layout composition and focal-area reference | NO — full-screen UI master |
| `Product page for Android.png` | PDP / Android | Gallery framing, product scale and PDP hierarchy reference | NO — full-screen UI master |
| `Product page for ios.png` | PDP / iOS | iOS PDP framing and spacing reference | NO — full-screen UI master |
| `About for Android.png` | About / Android | Editorial treatment/background reference only | NO — full-screen UI master |
| `About for ios.png` | About / iOS | Editorial treatment/background reference only | NO — full-screen UI master |
| `About page for PC.png` | About / Desktop | Wide editorial treatment/background reference only | NO — full-screen UI master |
| `Faivorets page for Android.png` | Favorites / Android | Saved-product scale and empty/saved-state composition reference | NO — full-screen UI master |
| `Faivorets page for ios.png` | Favorites / iOS | iOS saved-product scale/reference | NO — full-screen UI master |
| `Faivorets page for PC.png` | Favorites / Desktop | Wide saved-product presentation reference | NO — full-screen UI master |
| `Categories page for Android.png` | Categories / Android | Category-card/product-row composition reference | NO — full-screen UI master |
| `Categories page for ios.png` | Categories / iOS | iOS discovery composition reference | NO — full-screen UI master |
| `Account profile page for Android.png` | Account / Android | Account visual treatment; not product-media source | NO — full-screen UI master |
| `Account profile page for ios.png` | Account / iOS | Account visual treatment; not product-media source | NO — full-screen UI master |
| `Account profile page for PC.png` | Account / Desktop | Wide account treatment; not product-media source | NO — full-screen UI master |
| `ChatGPT Image Aug 9, 2026, 08_12_03 PM.png` | Duplicate of Account Android | Duplicate reference only; same Git blob as Account Android | NO — duplicate full-screen UI master |
| `f96465c7-d756-4409-9963-d96bb6b5893e.png` | **Design System / Web UI Foundation (non-route)** | **Style-board reference for WALKA palette, typography, surfaces/tokens, component language, tone and mini-page ideation. Product-showcase pixels are illustrative reference only.** | **NO — design-system/style-board reference; explicitly non-blocking for product-media production** |

### UUID visual-classification evidence

The UUID reference was classified from the actual protected pixels using a CI-only read-only evidence package; the protected source itself was never modified.

- CI-only branch/head: `agent/ci-ref-uuid-classify` / `f5515cd890f37efc1c6acf248d22c573949423db`
- Workflow run: `31975696395` — success
- Review artifact: `9270980184`
- Artifact digest: `sha256:12a3a0837d63b1dfc2ef6e03accc5450f0058c6b99e16fbf15860b7e36361c4f`
- Exact image dimensions observed by the runner: **1491×1055**
- Visible heading: **“WALKA Design System”**
- Visible subtitle: **“Premium Home Organization · Web UI Foundation”**
- Visible sections include core visual identity, typography, surfaces/tokens, component library, product showcase, tone/language and mini page mockup strips.

Disposition: this file is a **design-system reference board**, not Home/Categories/PDP/Favorites/Account/About route evidence and not an approved product-photo source.

### Important missing-reference conclusion

The protected set contains **no approved Categories / Desktop screenshot and no approved PDP / Desktop screenshot**. The UUID design-system board must not be repurposed to satisfy those reference-dependent tasks. Therefore existing CAT-014/PDP-016 reference blockers remain truthful until a real approved desktop reference is supplied or their acceptance contract is explicitly changed.

## Product geometry and color constraints

### Drawer Organizer

- 8 compartments.
- Approved colorways: White and Gray.
- Keep the expandable organizer identity truthful.
- Gray may not be fabricated from White when the required real presentation is unsupported by source imagery.

### Large Stainless Steel Bento Lunch Box

- 4-compartment SUS304 stainless tray.
- PP outer body.
- Approved colorways: Blue, Pink and Green.
- Preserve real product/accessory identity from approved sources.
- Do not create visual cues that imply unsupported liquid/leakproof behavior.

## Screen-to-asset need matrix

| Surface | Primary need | Secondary need | Current status |
|---|---|---|---|
| Home | Reusable Drawer/Lunch product media | Editorial composite only if separately source-approved | Primary media 3/5 ready; Gray/Pink blockers remain |
| Categories | Reusable product media | Optional category composite | Mobile/iOS references classified; **Desktop reference absent** |
| Search | Reusable variant media | None expected by default | Dynamic/current media contract in place |
| Favorites | Reusable saved-variant media | None expected | Dynamic Dashboard media contract in place |
| PDP | Primary variant media | Secondary gallery/detail views from approved sources | Primary Gray/Pink unresolved; **Desktop reference absent**; secondary source audit still required |
| About | No product asset required by default | Decorative/editorial art only if specifically approved | Android/iOS/Desktop references classified |
| Account | No product asset required by default | Decorative art only if specifically approved | Android/iOS/Desktop references classified |
| Splash / launcher | Existing branded launch assets | No duplicate work | Outside this product-media lane |

## Atomic production queue / current state

| ID | Issue | Deliverable | Current state |
|---|---|---|---|
| ASSET-001 | #198 | This manifest + complete protected-reference classification/source mapping | **READY TO CLOSE after merge of this finalization** |
| ASSET-002 | #199 | Master/export specification | COMPLETED |
| ASSET-003 | #200 | `drawer/white.png` | COMPLETED / ADMITTED |
| ASSET-004 | #201 | `drawer/gray.png` | BLOCKED — source/owner presentation decision |
| ASSET-005 | #202 | `lunch/blue.png` | COMPLETED / ADMITTED |
| ASSET-006 | #203 / #328 | Pink source/canonical production path | Historical source task complete; current canonical owner-review/admission remains PENDING under #328 |
| ASSET-007 | #204 | `lunch/green.png` | COMPLETED / ADMITTED |
| ASSET-008 | #205 | Optional editorial composites only where genuinely needed | P1 / separate |
| ASSET-009 | #206 | PDP secondary gallery/detail assets | P1 / source-dependent |
| ASSET-010 | #207 | Production file QA + final reference-composition QA | File-QA receipt merged; final screen comparison remains OPEN |

## Current blockers / decisions still required

1. Gray remains source/admission BLOCKED; do not fabricate an expanded view.
2. Pink approved source still lacks owner-accepted/reconciled canonical production admission.
3. Final owner-visible screen acceptance/stable publication remains blocked under #220/#230.
4. PDP secondary gallery/detail work must not invent unsupported views.
5. Categories Desktop and PDP Desktop reference screenshots are absent from the protected set; the design-system board is not a substitute.

## ASSET-001 exit criteria

ASSET-001 is complete when this finalization is merged because:

- all 18 protected references are visually classified or explicitly dispositioned;
- the UUID design-system board is explicitly non-blocking for product-media production;
- each primary product variant has either an approved source or an explicit BLOCKED/PENDING disposition;
- the final source-to-production mapping and current canonical readiness state are recorded here;
- remaining Gray/Pink/screen-reference blockers are delegated to their authoritative issues rather than hidden inside ASSET-001.

Closing ASSET-001 must **not** be interpreted as 5/5 media readiness or stable-release authorization.
