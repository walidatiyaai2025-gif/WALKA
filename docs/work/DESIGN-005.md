# DESIGN-005 — Favorites + Account + information consistency

Status: IN PROGRESS
Issue: #51
Parent: #46
Branch: `agent/design-005-secondary-premium`
Stable base: `de69377c8d419c4a61bc5cb1aa818203f270617a`

## Stable prerequisite receipt

DESIGN-004 is owner-visible stable before this slice begins:

- Final PR: #64.
- Final validated head: `aa202b69c9d14e59a561a2adf5e4c203aa721f5b`.
- PR Flutter run: `31345555110` / #350 — green.
- Candidate artifact: `9047257856`.
- DESIGN-004 squash merge: `757dc066fce56f9cb0c70c31208d2b27ddffbc22`.
- Stable-main Flutter run: `31345765442` / #352 — green.
- Stable APK publication commit: `de69377c8d419c4a61bc5cb1aa818203f270617a`.
- Stable APK bytes: `51014306`.
- Stable APK SHA-256: `f39963ece4d16042e19e10a926423f3ef4357c0fe0b62a87ce25a8ea2e12fc70`.

## Audit

### Favorites

Current public shell still imports `WalkaFavoritesV101` from the visual-freeze storefront. State/persistence is correct and must remain unchanged, but the surface is visually behind Home, discovery and PDP:

- header uses the legacy local `_Wordmark` instead of the DESIGN-002 shared shell wordmark;
- saved products are presented by legacy rows rather than the shared product-led visual language;
- empty state is centered utility content with limited hierarchy/context;
- Drawer Favorites behavior must remain device-local and continue opening the final V100→V110 Product Detail path.

### Account / information

`WalkaAccountV102` already groups destinations into cards and routes to corrected V102 information/legal content. DESIGN-005 should preserve those routes and copy while improving the owner-visible hierarchy:

- use shared WALKA shell primitives consistently;
- introduce clearer Support / Official destinations / Legal & app grouping;
- normalize section spacing, row touch targets, icon containers and dividers;
- retain About/FAQ/Contact/Amazon/Social/Privacy/Terms/App Information behavior;
- do not invent customer authentication/profile data.

### Product / architecture guardrails

- Keep `WalkaFavoritesController` and SharedPreferences persistence unchanged.
- Keep Product Master facts unchanged.
- Keep Amazon as the purchase destination; no cart/checkout/payment.
- Keep stable Product/Variant IDs unchanged.
- `Images/` untouched.
- No ZIP delivery.
- `main` remains stable-only.

## First implementation slice

1. Add a DESIGN-005 secondary premium surface module for Favorites and Account.
2. Route the public V102 shell to the new surfaces without changing the five-tab navigation contract.
3. Use `WalkaProductVisual` for saved Drawer variants.
4. Keep all V102 information destinations and legal copy intact.
5. Add compact 320×568 + 1.3× text-scale regressions for empty/saved Favorites and Account.
6. Run Analyze, full Flutter tests and Android release APK candidate before merge.

## Definition of done

- Secondary screens read as one WALKA premium system.
- Favorites persistence/removal/open behavior preserved.
- Account destinations remain complete and correct.
- Empty and utility states remain useful at compact width / elevated text scale.
- Analyze + full tests + Android release APK green on exact final PR head.
- After merge, stable-main CI republishes `Last verified APK/WALKA-latest.apk` from the DESIGN-005 merge commit.
