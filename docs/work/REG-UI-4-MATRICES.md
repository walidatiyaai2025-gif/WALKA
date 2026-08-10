# REG-UI — Home / Discovery / PDP / Favorites regression matrices

Status: IN PROGRESS
Issue: #224
Branch: `agent/reg-ui-4-matrices`
Parent: #85 UI Task Master

## Tasks covered

- HOME-013 — Home regression matrix across compact, standard, comfortable, iOS, desktop 1280 and desktop 1440 viewports; compact uses 1.3× text scale and primary scroll is swept for overflow.
- CAT-015 — Categories and Search matrix across compact, standard, iOS and desktop 1280; verifies released title/search-field presence and no visual exceptions while scrolling.
- PDP-017 — Drawer/Lunch PDP matrix across compact, standard, iOS and desktop; verifies sticky Amazon CTA, share action, fullscreen affordance, gallery count, Drawer favorite persistence and variant selection.
- FAV-011 — Favorites empty/saved matrix across compact, iOS and desktop plus removal persistence through controller reload.

## Guardrails

- Uses stable public V122/V123/V100/V131 surfaces and shared ADAPT test devices.
- Does not claim blocked PC Categories/PDP pixel parity; those remain blocked until a valid reference is classified.
- No feature production code or Product Master changes in this wave.
- Protected `Images/` untouched.

## Required validation

- [ ] `flutter analyze` Green.
- [ ] Full Flutter tests Green.
- [ ] Android runner / WALKA branding Green.
- [ ] Release APK Green.
- [ ] PR merged to stable `main`.
- [ ] HOME-013 / CAT-015 / PDP-017 / FAV-011 reconciled to ✅ after stable validation.
