# WALKA Final Owner Visual Review Checklist

Task: **VREL-098**  
Parent batch: #244  
Parent visual-release blocker: #230

Use this checklist only with a build whose receipt identifies the exact source commit, workflow run and APK SHA-256. Product-photo checks require real canonical PNGs; painted fallback is not acceptance evidence.

## Global preconditions

- [ ] Production readiness report says `READY` for all 5 canonical variants.
- [ ] Drawer White and Gray map to the correct canonical files.
- [ ] Lunch Blue, Pink and Green map to the correct canonical files.
- [ ] Product Master facts/claims remain unchanged and truthful.
- [ ] No price, rating, review count, coupon, marketplace chrome, cart, checkout or payment UI is baked into product imagery.
- [ ] Protected `Images/` masters are unchanged.
- [ ] Alpha edges pass white, ivory and navy stage inspection at normal scale and 200% zoom.

## Home / Landing

- [ ] Hero media shows the intended real product identity and balanced framing.
- [ ] Drawer/Lunch collection media uses the production resolver rather than screen-local files.
- [ ] Small Changes media uses the expected canonical identity.
- [ ] White product remains legible on light/ivory backgrounds without fake geometry-altering outlines.
- [ ] Compact 320px + 1.3× text scale remains overflow-free.
- [ ] Desktop Home preserves product prominence and pointer/focus behavior.

## Categories / Search / Discovery

- [ ] Drawer and Lunch category cards preserve correct family/variant identity.
- [ ] Search results show the selected variant rather than a sibling color.
- [ ] Card-scale crops do not cut side wings, tray edges, clips or accessories.
- [ ] Missing/corrupt media falls back visibly and semantically instead of showing a blank card.
- [ ] iOS safe areas and desktop layouts remain usable where approved references exist.

## Product Detail

- [ ] Primary gallery media updates when the selected variant changes.
- [ ] Fullscreen viewer preserves the same selected production-media identity.
- [ ] Zoom reveals clean alpha edges without white matte, dark fringe or halo.
- [ ] Secondary gallery views remain explicitly illustrative/source-dependent where approved photography does not exist.
- [ ] Lunch tray remains the real 4-compartment SUS304 geometry; accessories/details are not erased by masking.
- [ ] Drawer geometry remains truthful; Gray is never synthesized from White.
- [ ] Official Amazon destination remains external; no in-app checkout is introduced.

## Favorites

- [ ] Persisted White/Gray Drawer favorites show the correct production media.
- [ ] Remove/edit overlays do not obscure product identity.
- [ ] Empty state remains truthful and does not depend on product photography.
- [ ] Desktop pointer/focus and keyboard traversal remain usable.

## Account / About

- [ ] Account remains free from unnecessary product-media dependency.
- [ ] About story media uses production resolver where products are shown.
- [ ] Dual-product compositions preserve visual balance without recoloring/reconstructing sibling photography.
- [ ] No fake account/VIP/order/payment data appears.

## Release decision

Mark a screen **PASS** only after all applicable checks above pass with real canonical assets. Mark it **BLOCKED** with the exact unblock action if source/export/visual evidence is missing. Use **REOPEN** whenever a previously accepted asset regresses. Do not publish a new stable owner-visible APK while any required production-media acceptance remains blocked.
