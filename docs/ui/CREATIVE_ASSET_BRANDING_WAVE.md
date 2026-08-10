# WALKA Branding / Splash / Icon Creative Asset Wave

Status: ASSET-071..080 execution receipt  
Parent: #217 / #209 / #197

Existing implementation already includes `mobile/assets/branding/walka_logo.svg`, `WalkaSplashBrandMark` and generated Android launcher branding. This wave audits and freezes the asset rules without duplicating delivered launcher/splash work.

## ASSET-071..080

| Task | Result | Contract / output |
|---|---|---|
| ASSET-071 — WALKA logo export inventory audit | **PASS** | Repository-owned canonical wordmark is `mobile/assets/branding/walka_logo.svg`. It contains white WALKA lettering and muted-gold `For You` treatment. No duplicate raster logo family is required for Flutter UI. |
| ASSET-072 — Logo light-surface rendering QA | **PASS WITH USAGE RULE** | Current white wordmark is intended for navy/dark use. On light surfaces, place it inside an approved navy brand container/header or use a future explicitly approved dark-logo variant; do not add ad-hoc stroke/drop-shadow to force readability. |
| ASSET-073 — Logo navy/dark-surface rendering QA | **PASS** | White wordmark + #D4AF37 accent is the preferred treatment on WALKA #003366. Preserve vector rendering and `BoxFit.contain`. |
| ASSET-074 — Splash brand-mark export QA | **PASS** | Splash uses the canonical SVG through `WalkaSplashBrandMark`, with bounded width and live radial gold accent. No bitmap splash wordmark is needed. |
| ASSET-075 — Android launcher adaptive-icon safe-zone QA | **PASS / CURRENT VECTOR CONTRACT** | Generated launcher art uses a 108×108 viewport, navy full-bleed background and centered gold `W` mark. Keep important mark geometry inside the central ~66% safe zone so launcher masks do not clip it. |
| ASSET-076 — iOS app-icon crop/safe-zone QA | **READY / IMPLEMENTATION FOLLOW-UP** | Future iOS icon export must be square, opaque and keep the gold `W` inside the same central safe zone. Do not pre-round corners; iOS applies the mask. |
| ASSET-077 — Define decorative gold accent asset policy | **PASS** | Use #D4AF37 as live vector/UI accent wherever possible. Raster decorative gold assets require a real visual need; no gradient PNGs for effects Flutter can render. |
| ASSET-078 — Define icon-vs-bitmap decision matrix | **PASS** | Navigation/actions/status → vector/icon. Brand mark → SVG. Product photography → PNG/WebP as specified. Decorative shapes → Flutter/vector. Bitmap only for photographic/editorial content that cannot be represented faithfully otherwise. |
| ASSET-079 — Define empty-state illustration style guide | **PASS** | Minimal WALKA line/shape language, navy/gold/neutral palette, no fake product details, no cartoon mascots unless owner-approved. Prefer vector/icon composition that survives dark/light and compact widths. |
| ASSET-080 — Branding/decorative asset release receipt | **PASS FOR CURRENT BRANDING** | Existing splash/logo/Android branding is production-ready under the current contract. iOS launcher delivery remains a platform implementation follow-up, not a blocker for current Android stable branding. |

## Canonical brand palette

- Navy: `#003366`
- Gold: `#D4AF37`
- Logo on navy: white WALKA + gold `For You`
- Avoid secondary gold shades unless produced by live opacity/gradient treatment from the canonical gold.

## Logo usage

### Dark/navy surfaces

Use the canonical SVG directly. Maintain clear space of at least 8% of rendered logo width around the mark where layout permits.

### Light/ivory surfaces

Do not render the white wordmark directly on white/ivory. Preferred solutions in order:

1. approved navy header/container,
2. approved future dark-logo vector variant,
3. text-based WALKA wordmark only when the existing design system explicitly owns that treatment.

Do not create a rasterized logo with artificial dark outline solely to solve contrast.

## Launcher icon contract

Current generated Android icon uses:

- 108×108 vector viewport,
- full-bleed WALKA navy background,
- centered muted-gold `W`,
- no tiny text,
- no photographic content.

Safe-zone QA should test circular, squircle and rounded-square masks. Gold geometry must not touch the outer 17% on any side.

## Decorative asset decision matrix

| Need | Preferred format | Reason |
|---|---|---|
| WALKA wordmark | SVG | exact scalable brand geometry |
| navigation/action icon | Flutter/Lucide/Material vector | state/semantic/size flexibility |
| gold glow/accent line | Flutter paint/gradient | no raster scaling artifact |
| product photo | optimized PNG/WebP | photographic detail |
| simple empty-state illustration | vector/Flutter composition | responsive and theme-safe |
| lifestyle/editorial photo | optimized raster | photography cannot be recreated as vector |

## Empty-state illustration language

- Thin/medium navy strokes with restrained gold accent.
- Rounded geometry consistent with WALKA cards.
- No embedded copy; title/body/CTA stay Flutter-rendered.
- No unsupported product structure or fake commerce state.
- Must remain recognizable at 96–160 logical px.
- Must survive White/Ivory/Navy QA without losing focus hierarchy.

## Release QA

1. SVG renders without clipping at compact and standard splash widths.
2. White logo is never placed on a light background without an approved navy/dark container.
3. Android launcher mark survives common launcher masks.
4. Decorative gold never replaces accessible focus/selection semantics.
5. No duplicate bitmap branding inflates the bundle without a documented use case.
