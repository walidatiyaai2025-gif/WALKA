# DESIGN-005 — Favorites + Account + information consistency

Status: COMPLETED
Issue: #51
Parent: #46
Implementation branch: `agent/design-005-secondary-premium`
Stable base: `de69377c8d419c4a61bc5cb1aa818203f270617a`
Final PR: #65
Stable merge: `be2fa40d1c154ea94cf6b4a6d64e6666180c7a79`
Stable APK publication: `fe5295b2663de683b8cd7c4ac771540890bfbda9`

## Stable prerequisite receipt

DESIGN-004 was owner-visible stable before this slice began:

- Final PR: #64.
- Final validated head: `aa202b69c9d14e59a561a2adf5e4c203aa721f5b`.
- PR Flutter run: `31345555110` / #350 — green.
- Candidate artifact: `9047257856`.
- DESIGN-004 squash merge: `757dc066fce56f9cb0c70c31208d2b27ddffbc22`.
- Stable-main Flutter run: `31345765442` / #352 — green.
- Stable APK publication commit: `de69377c8d419c4a61bc5cb1aa818203f270617a`.
- Stable APK bytes: `51,014,306`.
- Stable APK SHA-256: `f39963ece4d16042e19e10a926423f3ef4357c0fe0b62a87ce25a8ea2e12fc70`.

## Delivered

### Favorites

- Public shell now uses `WalkaFavoritesPremiumV130` rather than the legacy visual-freeze Favorites surface.
- Shared DESIGN-002 `WalkaWordmark` and shell spacing are used consistently.
- Empty Favorites is a product-led WALKA state with a Drawer Organizer visual and a useful Explore Collections action.
- Saved White/Gray Drawer variants use premium product-led cards with verified Drawer facts.
- Saved variants open the final V100→V110 premium Product Detail path.
- Remove behavior continues through the existing device-local `WalkaFavoritesController` / SharedPreferences contract.
- No remote Favorites/account model was introduced.

### Account / information

- Public shell now uses `WalkaAccountPremiumV130`.
- Account hierarchy is normalized into Product & Support, Official Destinations, and Legal & App groups.
- Our Story, FAQ, Contact, Amazon Store, Social, Privacy and Terms routes remain intact.
- Existing corrected V102 information/legal copy remains the source for those destinations.
- `WalkaAppInfoPremiumV130` replaces stale pre-backend presentation with the current connected `1.2.0+120` model, versioned WALKA API + local fallback, Amazon handoff, device-local Favorites and stable verified-APK delivery.
- No customer authentication/profile data was invented.

### Product / architecture guardrails

- `WalkaFavoritesController` and SharedPreferences persistence unchanged.
- Product Master facts unchanged.
- Amazon remains the purchase destination; no cart/checkout/payment.
- Stable Product/Variant IDs unchanged.
- `Images/` untouched.
- No ZIP delivery.
- `main` remained stable-only until exact PR-head CI was green.

## Validation and release receipt

- Final implementation head: `5583192ac200ef8e199a8faeaf812cdb9b812eff`.
- Branch workflow: `31346663707` / #361 — green.
- Branch APK candidate artifact: `9047608673`.
- Branch artifact SHA-256: `53a1325013ddeb4169f1913c41f86c388b432b7195e8e70bde07f08bdb6c27d6`.
- PR-context workflow: `31346813269` / #362 — green.
- PR synthetic-merge APK artifact: `9047655597`.
- PR artifact SHA-256: `dda255d88d00400484bdeec9e22d026791db4b1d2b3eb51b08f516fcd219ecbd`.
- Squash merge: `be2fa40d1c154ea94cf6b4a6d64e6666180c7a79`.
- Stable-main Flutter workflow: `31347074138` / #363 — green.
- Stable APK publication commit: `fe5295b2663de683b8cd7c4ac771540890bfbda9`.
- Published APK type: `universal-release`.
- Published APK bytes: `51,079,850`.
- Published APK SHA-256: `0e84156206943365294bd1d429aa31634ec8790ed2924ed960cf3a4f0bf4d46e`.

## Regression coverage

- [x] Empty Favorites on 320×568 at 1.3× text scale.
- [x] Saved Drawer product open behavior.
- [x] Saved Drawer remove + persistence behavior.
- [x] Account section readability on 320×568 at 1.3× text scale.
- [x] Current App Information release/catalog/Amazon copy.
- [x] Flutter Analyze.
- [x] Full Flutter test suite.
- [x] Android release APK build and artifact upload.
- [x] Stable-main rebuild and verified APK publication.

## Definition of done

- [x] Secondary screens read as one WALKA premium system.
- [x] Favorites persistence/removal/open behavior preserved.
- [x] Account destinations remain complete and correct.
- [x] Empty and utility states remain useful at compact width / elevated text scale.
- [x] Exact final PR head passed Analyze + full tests + Android release APK.
- [x] Stable-main CI republished `Last verified APK/WALKA-latest.apk` from the DESIGN-005 merge commit.

Next P0 design slice: **DESIGN-006 — motion, feedback, loading/offline state polish** (#52).
