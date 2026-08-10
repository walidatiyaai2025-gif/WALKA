# WALKA UI Reference Element Checklists

Scope: REF-004 through REF-010 under UI Task Master #85.

The protected files under `Images/` are visual masters only. This checklist translates those masters into implementation-review checkpoints while `docs/PRODUCT_MASTER.md` remains the source of truth for product facts, claims and destinations.

## REF-003 status — deliberately unresolved

`Images/f96465c7-d756-4409-9963-d96bb6b5893e.png` has a unique blob (`4926bb1...`) and cannot be classified from repository metadata alone. It must not be silently treated as a PC Product or PC Categories reference. Until a human-visible classification is recorded, PC Product and PC Categories parity remain blocked.

## REF-004 — Home reference checklist

Reference set: `Home for Android.png`, `Home for ios.png`, `Home for pc.png`.

- Brand/header chrome is visually distinct from page content.
- WALKA wordmark remains the primary brand anchor.
- Editorial hero has a clear visual/media area, eyebrow/title/body hierarchy and owner-visible CTA actions.
- Browse/Search actions remain finite-width and wrap safely on compact widths.
- Benefit band uses the navy/gold WALKA trust language and shared benefit atoms.
- Collection section has a heading plus truthful Drawer/Lunch category cards only.
- Collection cards preserve media, title/supporting text and clear tap affordance.
- “Small Changes” editorial module is visually separated from commerce cards.
- Trust strip is present near the lower page composition.
- Mobile references retain mobile navigation/safe-area behavior.
- PC reference must use wide content/grid strategy rather than a centered 560px phone canvas.
- No mock price/rating/product-count content from references may override Product Master truth.

## REF-005 — Categories/Search reference checklist

Reference set: `Categories page for Android.png`, `Categories page for ios.png`; Search inherits the released Categories visual grammar because no dedicated Search image exists.

- Reference top header/wordmark and Search affordance remain consistent.
- Page title and short supporting copy are separated from category content.
- Drawer and Lunch category cards are the only released category families.
- Category cards do not invent reference-only product counts or unsupported categories.
- Loading/offline/source feedback remains visible when catalog state requires it.
- Collection heading/count reflects the released catalog, not mock reference inventory.
- Product rows preserve media, family/title/variant metadata and a clear tap target.
- Search field exposes query entry, clear action and keyboard search semantics.
- Search filters expose All/Drawer/Lunch using the shared selectable chip language.
- Search empty state is query-aware and offers a deterministic reset path.
- Categories/Search reuse the same spacing, surfaces, navy/gold hierarchy and compact-width rules.
- PC Categories remains blocked until a valid PC reference is identified.

## REF-006 — Product Detail reference checklist

Reference set: `Product page for Android.png`, `Product page for ios.png`.

- App/header bar preserves default Back navigation, centered WALKA wordmark, Share and Favorite actions.
- Gallery viewport uses a stable aspect ratio, clipped surface, multiple product views and accessible media semantics.
- Gallery selection indicator is independently operable and communicates selected state.
- Fullscreen gallery route supports zoom/pan without altering product truth.
- Product identity block clearly separates family/eyebrow, title, verified facts and selected variant.
- Variant selector exposes color/finish swatches with selected semantics.
- Lunch usage language remains approved: adult lunch use, dry & semi-wet foods, not intended for liquids, carry upright.
- Drawer facts remain limited to released geometry/compartments/expandability/non-slip information.
- “Why WALKA” feature content does not introduce unsupported claims.
- Detail/specification rows remain readable at compact widths and 1.3x text scale.
- Official Amazon destination disclosure remains separate from the CTA itself.
- Sticky Amazon CTA remains SafeArea-aware and finite-width.
- No in-app cart, checkout or payment UI is introduced.
- PC PDP remains blocked until REF-003 or another approved source is classified as a PC PDP reference.

## REF-007 — Favorites reference checklist

Reference set: `Faivorets page for Android.png`, `Faivorets page for ios.png`, `Faivorets page for PC.png` (source filename typo retained).

- Header/title/count communicates Saved/Favorites state without inventing cloud/account state.
- Filter row is independent from persistence state and exposes selected semantics.
- Sort/edit controls remain clear and keyboard/touch accessible.
- Saved-product card owns media, identity, remove/edit/open affordances.
- Removing a favorite updates the device-local persisted state.
- Empty Favorites state reuses the shared empty-state primitive and offers Continue Shopping.
- Trust strip is shared rather than duplicated page-local markup.
- Mobile compositions remain safe at compact width and 1.3x text scale.
- iOS composition respects notch/home-indicator safe areas.
- PC composition uses wide layout, pointer hover/focus and keyboard traversal.

## REF-008 — Account and About reference checklist

Account references: Android/iOS/PC. About references: Android/iOS/PC.

### Account

- Shared reference top bar remains separate from page body.
- Profile/status hero is truthful; no fake signed-in identity, VIP, order or payment data.
- Overview metrics show only released/local state that the application can actually know.
- Destination groups use a consistent section-heading treatment.
- Destination tiles use shared icon/title/subtitle/trailing affordance atoms.
- Product & Support group covers Favorites, Our Story, FAQ and Contact destinations where released.
- Official Destinations clearly distinguish Amazon Store/social external links from in-app routes.
- Legal & App group covers Privacy, Terms and App Information without mock account data.

### About / Our Story

- Editorial hero is bounded and safe inside vertical scrolling.
- Story intro uses WALKA editorial typography hierarchy.
- Product-story block can pair Drawer/Lunch visuals with narrative without inventing claims.
- Value cards use reusable icon/title/body presentation.
- Values layout adapts from one column to wider multi-column composition.
- Design-principles section remains editorial, readable and reusable.
- Closing Amazon panel states the external destination boundary truthfully.

## REF-009 — iOS-only implementation deltas

The repository contains separate iOS references for Home, Categories, PDP, Favorites, Account and About; therefore Android screenshots must not be treated as exact iOS geometry.

- Respect top notch/status safe area and bottom home-indicator inset on every owner-visible screen.
- Keep platform-safe spacing policy in shared Flutter abstractions; do not scatter `Platform.isIOS` checks through feature files.
- Preserve minimum 48px interactive targets and accessible labels after safe-area adjustments.
- Mobile navigation must remain reachable above the home indicator.
- Fullscreen/media routes must keep their own safe-area close/back affordances.
- 1.3x text scale must not clip headers, chips, cards or sticky CTA content.
- Product facts, route behavior and Amazon boundary remain identical across Android/iOS; only platform composition/chrome may differ.

## REF-010 — PC-only implementation deltas

Explicit PC references exist for Home, Favorites, Account and About.

- Do not render desktop reference pages inside the legacy 560px phone frame.
- Use tablet/desktop content tiers, max-content widths and side gutters from the shared design system.
- Desktop shell/navigation must be a wide composition rather than stretched bottom navigation.
- Provide reusable desktop top chrome for reference pages that use top navigation.
- Allow multi-column cards/grids where the approved PC references call for them.
- Preserve readable line lengths inside wide layouts by bounding editorial content.
- Add pointer hover/focus treatment without making hover the only affordance.
- Keyboard traversal order must follow the visible reading/navigation order.
- Focus indicators must remain visible against ivory/white/navy surfaces.
- Test at both 1280px and 1440px desktop widths.
- PC PDP and PC Categories remain blocked until a valid visual reference is classified/approved.

## Review gate

A platform-parity PR should link the relevant section above and explicitly state any intentional deviation. Product truth always wins over mock content embedded in a visual reference.
