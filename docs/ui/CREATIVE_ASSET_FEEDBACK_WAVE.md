# WALKA Empty / Loading / Offline Feedback Creative Asset Wave

Status: ASSET-081..090 execution receipt  
Parent: #218 / #209 / #197

The repository already owns a shared `WalkaEmptyState` primitive with a navy icon inside a restrained gold treatment. This wave therefore favors shared Flutter/vector presentation and adds bitmap artwork only when a visual communicates something materially better than the existing primitive.

## ASSET-081..090

| Task | Result | Contract / output |
|---|---|---|
| ASSET-081 — Favorites empty-state visual spec | **PASS** | Reuse shared empty-state composition. Preferred visual: heart/bookmark/favorite outline using navy with restrained gold accent. No fake saved product, account identity or order state. CTA text remains live Flutter UI. |
| ASSET-082 — Search empty-state visual spec | **PASS** | Reuse shared primitive with search/discovery icon treatment. Visual must be query-neutral; result-specific copy remains caller-owned and query-aware. No decorative product-count bitmap. |
| ASSET-083 — Offline/catalog-fallback visual spec | **PASS** | Use connectivity/cloud-off or catalog-sync vector treatment plus live status copy. Do not use product photography to imply data freshness. Painted product fallback can still render separately when catalog media is missing. |
| ASSET-084 — Loading/skeleton asset policy | **PASS** | Loading is a live layout/state treatment, not a bitmap. Use shared skeleton/surface placeholders and reduced-motion-safe opacity behavior. Never create PNG shimmer strips or GIF loaders. |
| ASSET-085 — Missing-product-media fallback visual spec | **PASS** | Existing deterministic `WalkaProductVisual` remains the required semantic fallback for missing/corrupt production media. Do not replace it with a generic broken-image icon on product surfaces. |
| ASSET-086 — Error-state illustration usage policy | **PASS** | Use a small vector/icon composition only when it helps distinguish an actual error from empty/offline state. Error details and retry action remain live UI. No alarming red full-screen artwork for recoverable states. |
| ASSET-087 — Reduced-motion-friendly feedback visual policy | **PASS** | Core feedback meaning must survive with all non-essential animation disabled. Prefer static shape/icon changes over looping decorative motion. |
| ASSET-088 — Empty-state compact-width crop QA | **PASS** | Shared visual target 64–88 logical px; no essential visual detail outside central 80%. Must fit 320px-wide devices with title/body/CTA at 1.3× text scale. |
| ASSET-089 — Empty-state dark/light contrast QA | **PASS** | Navy icon + gold ring works on light/ivory shared surface. On navy surface use a light/ivory container or an explicitly inverted vector treatment; never rely on dark navy icon directly on navy. |
| ASSET-090 — Feedback visual release receipt | **PASS / NO NEW BITMAP REQUIRED** | Current shared primitives are sufficient. This wave intentionally creates no new runtime raster asset, avoiding bundle bloat and duplicated semantics. |

## State-to-visual matrix

| State | Primary visual language | Product photography? | Action |
|---|---|---:|---|
| Favorites empty | favorite/heart outline | no | Continue Shopping |
| Search empty | search/discovery outline | no | Clear/reset query |
| Offline | connectivity/offline outline | no | Retry where supported |
| Loading | skeleton/live layout | no | none |
| Missing product media | deterministic product painter | fallback only | none |
| Recoverable error | warning/info vector | no | Retry or deterministic navigation |

## Visual style

- Navy icon/stroke is the default information carrier.
- Gold is accent, not the only state signal.
- Neutral/ivory surface preserves premium tone.
- No baked copy, buttons, counts or network-error codes.
- Visuals should remain meaningful at grayscale/high-contrast viewing.
- Avoid cute mascot/cartoon language that would weaken the premium WALKA design system without explicit owner approval.

## Reduced-motion policy

- Empty-state illustrations are static by default.
- Loading may use subtle live animation only when platform motion settings allow it; layout must remain understandable when animation is disabled.
- Error/offline transitions may fade/replace state, but never require movement to communicate the outcome.
- Product fallback visual is deterministic and static.

## Compact QA

At 320×568 / 1.3× text scale:

1. visual remains fully visible;
2. title/body do not overlap illustration;
3. optional action remains finite-width and reachable;
4. card padding can reduce before shrinking the visual below useful recognition size;
5. no visual asset causes horizontal overflow.

## Dark/light QA

- Light/Ivory page: current gold-ring/navy-icon treatment is preferred.
- Navy page: place empty-state content on an ivory/light surface card or use an approved inverted vector; keep text contrast WCAG-safe.
- Do not generate separate bitmap versions solely for theme changes when vector/UI treatment can adapt.
