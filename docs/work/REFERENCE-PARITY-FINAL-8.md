# HOME-011..013 + CAT-013/015 + FAV-009..011 — Cross-platform parity wave

Status: IN PROGRESS
Issue: #229
Parent Batch: #121
Branch: `agent/reference-parity-final-8`

## Atomic tasks
- HOME-011 ✅ candidate — representative iOS safe-area/notch/home-indicator + 1.3× reference coverage.
- HOME-012 ✅ candidate — Home uses shared 1200px desktop content tier instead of a phone-only 560px frame; 1280/1440 coverage.
- HOME-013 ✅ candidate — compact/actions/catalog-truth regression matrix.
- CAT-013 ✅ candidate — Categories iOS safe-area/1.3× and search-action coverage.
- CAT-014 ⛔ BLOCKED — no approved/classified PC Categories reference exists; desktop fidelity is not invented.
- CAT-015 ✅ candidate — compact/large Categories regression matrix and truth guardrails.
- FAV-009 ✅ candidate — Favorites representative iOS safe-area/1.3× coverage with persisted Drawer variants.
- FAV-010 ✅ candidate — Favorites shared 1200px desktop tier + two-card PC composition at 1280/1440.
- FAV-011 ✅ candidate — local persistence/remove/empty/truth regression matrix plus existing full suite.

## Guardrails
- No fake prices, ratings, account/order/payment state.
- Existing catalog/navigation/Favorites persistence preserved.
- Amazon boundary unchanged.
- Protected `Images/` unchanged.

## Required validation
- [ ] Flutter Analyze Green.
- [ ] Full Flutter tests Green.
- [ ] Android runner / branding Green.
- [ ] Android release APK Green.
- [ ] PR merged to stable `main`.
- [ ] Stable-main verified APK publication.
- [ ] `TASKS.md` reconciled; batch #121 records 98 complete + CAT-014/PDP-016 blocked.
