# WALKA Responsive Media / Performance QA Wave

Status: ASSET-091..100 execution receipt  
Parent: #219 / #209 / #197  
Adaptive contract: `WalkaPlatformAdaptive` + `WalkaContentWidthMetrics`

Current width policy:
- compact mobile: < 360 px,
- mobile: 360–719 px,
- tablet: 720–1023 px,
- desktop: >= 1024 px,
- max content widths: 560 / 840 / 1200 px.

## ASSET-091..100

| Task | Result | Contract / output |
|---|---|---|
| ASSET-091 — 320×568 compact presentation QA matrix | **PASS / MATRIX DEFINED** | Product media must fit compact cards without crop, preserve semantic identity, remain clear at 1.3× text scale and never force horizontal overflow. Use 16px WALKA compact gutter policy. |
| ASSET-092 — 390×844 standard presentation QA matrix | **PASS / MATRIX DEFINED** | Standard mobile uses 20px horizontal gutter; product media may scale up from compact while retaining 8–12% internal safe padding. |
| ASSET-093 — 430×932 large-phone presentation QA matrix | **PASS / MATRIX DEFINED** | Large phone remains mobile tier. Media may expand vertically but should not alter hierarchy or become larger than PDP/hero intent. |
| ASSET-094 — iOS safe-area asset/crop QA matrix | **PASS / MATRIX DEFINED** | Product pixels must not depend on notch/home-indicator insets. Safe area is layout-owned by Flutter; no iOS-specific baked crop. Fullscreen media keeps close/back affordance outside product focal area. |
| ASSET-095 — tablet media composition QA matrix | **PASS / MATRIX DEFINED** | 720–1023 px uses 840 max-width tier with wider gutters. Media may move into 2-column layouts; canonical product assets are reused, not duplicated as tablet binaries. |
| ASSET-096 — desktop wide-layout media QA matrix | **PASS / MATRIX DEFINED** | >=1024 px uses up to 1200px content width. Home/Favorites/Account/About can use approved wide compositions. Product media remains bounded and does not stretch from phone canvas. |
| ASSET-097 — @2x/@3x necessity audit | **PASS / NO DUPLICATE SET REQUIRED** | Flutter logical-pixel rendering plus 1024px canonical product masters is sufficient for current owner-visible product surfaces. Do not create iOS-style @2x/@3x duplicate product files unless measurement proves a quality gap. |
| ASSET-098 — Flutter decode-cache width audit by surface | **PASS WITH FOLLOW-UP RECOMMENDATION** | Current resolver defaults to 1200 physical px for every asset. Safe now, but future optimization should allow caller/surface hints: ~320–600 for discovery, ~800–1200 for Home/PDP cards, full approved source only for fullscreen zoom if needed. |
| ASSET-099 — duplicate/near-duplicate asset audit | **PASS / POLICY DEFINED** | Canonical product variants are single-source assets reused across Home/Discovery/Favorites/PDP. Avoid per-screen copies and duplicate high-DPI files. Existing duplicate protected reference remains reference-only, not runtime media. |
| ASSET-100 — production media bundle size budget | **PASS / BUDGET DEFINED** | Five canonical product primaries target <= 6 MB combined, with a preferred <= 1.2 MB per PNG. Secondary PDP/editorial media requires documented need; total new creative-media bundle target <= 12 MB before compression/decode review. |

## Device QA matrix

| Viewport | Window class | Media requirements |
|---|---|---|
| 320×568 | compact mobile | No clipping; 16px outer gutter; compact thumbnail identity preserved; 1.3× text does not squeeze media into unusable size. |
| 390×844 | mobile | 20px outer gutter; normal hero/card scale; safe product padding. |
| 430×932 | mobile | 20px outer gutter through comfortable breakpoint; large-phone media should grow modestly, not dominate page copy. |
| iPhone-like safe area | mobile | Layout absorbs top/bottom system insets; bitmap remains platform-neutral. |
| 768–1024 tablet | tablet | Up to 840px content max; multi-column media allowed; same canonical binaries. |
| 1280/1440 desktop | desktop | Up to 1200px content max; wide composition and pointer/keyboard UI around media; product itself stays aspect-safe. |

## Surface decode targets

These are optimization targets, not new asset filenames:

| Surface | Typical rendered media | Recommended physical decode target |
|---|---:|---:|
| Search/product row | 72–104 logical px | 320–480 px |
| Categories/Favorites card | 96–180 logical px | 400–700 px |
| Home collection/hero | 160–360 logical px | 700–1200 px |
| PDP primary | 280–560 logical px | 900–1400 px where source supports |
| Fullscreen zoom | viewport-dependent | approved source derivative; avoid arbitrary 1200 cap if real zoom requires more detail |

Current shared resolver's 1200px default is acceptable for correctness, but it over-decodes small discovery thumbnails. A later Flutter performance slice may add per-surface cache-width hints without changing canonical asset paths.

## Duplicate audit rules

An asset is a duplicate if it differs only by:

- screen destination,
- mobile/tablet/desktop filename suffix,
- @2x/@3x suffix without measured need,
- background color that Flutter can render,
- crop that `BoxFit.contain`/layout can safely produce,
- baked UI copy/CTA that should remain live UI.

Approved derivatives are justified when they represent a genuinely different real source view (for example open tray vs primary set) or an editorial photographic composition that cannot be reproduced safely from the canonical cutouts.

## Bundle budget

- Five primary PNGs: preferred <= 6 MB total.
- Individual primary: preferred <= 1.2 MB.
- Secondary/detail images: preferred <= 800 KB each at app-ready dimensions unless visible quality requires more.
- Total incremental production creative media: target <= 12 MB before release acceptance.
- Never bundle PSD/source masters.
- SVG/vector assets are preferred for branding/decorative/feedback visuals.

## Responsive release gate

1. 320×568 / 390×844 / 430×932 screenshots remain overflow-free.
2. iOS safe-area screenshots show no product or gallery controls beneath system insets.
3. Tablet and desktop do not reuse the old 560px phone frame.
4. No duplicate product binaries exist solely for breakpoint changes.
5. Product media uses `contain` unless a specific approved editorial crop contract says otherwise.
6. Memory/decode behavior remains bounded on list surfaces.
7. APK bundle growth is recorded when production media is added.
