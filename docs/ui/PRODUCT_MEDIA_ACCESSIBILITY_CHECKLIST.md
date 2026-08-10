# WALKA Product Media Accessibility & Resilience Checklist

Parent batch: #244 · Tasks: VREL-071..080 · Parent visual blocker: #230

## Runtime requirements

| Task | Requirement | Current acceptance rule |
|---|---|---|
| VREL-071 | Meaningful product identity semantics | Every owner-visible product media instance exposes family/variant or screen-specific product identity; decorative fallback internals are excluded from duplicate semantics. |
| VREL-072 | White/light product separation on light/ivory backgrounds | **PENDING REAL-ASSET ACCEPTANCE.** Canonical White PNG must retain a visible edge/silhouette at reference scale without fake outline changing the product. |
| VREL-073 | Light product separation on navy/dark backgrounds | **PENDING REAL-ASSET ACCEPTANCE.** Transparent edge treatment must remain clean with no white matte/fringe/halo. |
| VREL-074 | Missing media never produces blank UI | Missing/unregistered or load-failed media must render deterministic `WalkaProductVisual` fallback with product semantics. |
| VREL-075 | Offline/catalog fallback preserves identity | Loading/offline catalog state must not erase the selected product/variant identity when product content is already known. |
| VREL-076 | Reduced motion is not required to understand selection | Gallery indicator selected semantics remain explicit; when `disableAnimations` is true, selection transition duration becomes zero. |
| VREL-077 | 1.3× text scale resilience | Product media labels/actions remain reachable and no owner-visible media module may overflow because copy expands. |
| VREL-078 | iOS SafeArea | Fullscreen/PDP media keeps notch/status/home-indicator safe-area behavior; media may extend visually only where chrome remains safe. |
| VREL-079 | Desktop pointer/focus-ready interactions | Tappable product media is inside Material `InkWell`/button semantics rather than raw gesture-only hit targets. |
| VREL-080 | Release checklist | This document plus automated tests forms the media accessibility/resilience gate; visual-only items remain pending until canonical PNGs exist. |

## Real-asset visual checks before PASS
1. Check Drawer White on white, ivory and light-gray stages at 320/430/1280 widths.
2. Check Gray and stainless/lighter Lunch edges on navy/dark stages for halos or baked matte backgrounds.
3. Zoom to 200% and inspect alpha perimeter, handles, clips, tray edges and narrow divider gaps.
4. Verify semantic product label remains the product identity, not a filename or generic "image".
5. Temporarily remove each canonical file and confirm visible deterministic fallback still occupies the media stage.
6. Enable reduced motion and 1.3× text scale, then exercise gallery selection, fullscreen, Favorites and Home cards.

## Status policy
- Automated runtime checks may be **PASS** before photography exists.
- VREL-072/VREL-073 visual separation remain **PENDING/BLOCKED** until actual canonical PNGs are admitted.
- A painted fallback can prove layout/resilience but can never prove alpha-edge quality of the future product asset.
