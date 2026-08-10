# WALKA Categories / Search Creative Asset Wave

Status: ASSET-051..060 execution receipt  
Parent: #215 / #209 / #197  
References: `Images/Categories page for Android.png`, `Images/Categories page for ios.png`

Search has no dedicated protected reference and therefore inherits the released Categories visual grammar. PC Categories remains reference-blocked; this wave defines responsive media behavior without inventing a missing desktop screenshot target.

## ASSET-051..060

| Task | Result | Contract / output |
|---|---|---|
| ASSET-051 — Audit Categories Android media requirements | **PASS** | Category cards and product rows need reusable Drawer/Lunch product media. Page title, support copy, filter/source state and navigation remain Flutter UI. |
| ASSET-052 — Audit Categories iOS media requirements | **PASS** | Same product binaries as Android. iOS differences are safe-area/layout behavior only; no duplicated iOS photography set. |
| ASSET-053 — Define Categories desktop media requirements from responsive composition | **PASS WITH REFERENCE BLOCKER** | Use the same canonical media under the shared desktop content tier and wide grid. Exact PC-reference parity cannot be claimed until a real PC Categories reference is identified. |
| ASSET-054 — Category Drawer hero/card media spec | **PASS** | Use canonical Drawer White as representative media; Gray may appear when variant-specific state or an approved Gray canonical image exists. Full side wings/8-compartment identity must remain visible. |
| ASSET-055 — Category Lunch hero/card media spec | **PASS** | Use canonical Blue representative unless selected variant dictates Pink/Green. Preserve real 4-compartment tray and set identity; no leakproof/liquid implication. |
| ASSET-056 — Search Drawer result thumbnail spec | **PASS** | 1:1 media box, `BoxFit.contain`, compact visual padding 8–12%, semantic product label, stable resolver ID. No bitmap text. |
| ASSET-057 — Search Lunch result thumbnail spec | **PASS** | 1:1 media box, `BoxFit.contain`, preserve accessory silhouette at small size, stable resolver ID, no crop of bag/tray/lid. |
| ASSET-058 — Search/category consistent visual-scale matrix | **PASS** | Representative category media and result thumbnails use equal perceived visual weight by product family, not equal raw pixel bbox. Drawer target occupancy ~76–84%; Lunch set ~72–82%, adjusted to keep all components visible. |
| ASSET-059 — Discovery thumbnail decode/file-size budget | **PASS** | Reuse canonical 1024px masters; decode request should be surface-appropriate rather than bundling extra thumbnail binaries. Target product PNG <= 1.2 MB each; discovery runtime cache width should typically stay in the 320–600 physical-pixel range when the shared resolver evolves to surface hints. |
| ASSET-060 — Discovery visual QA/release receipt | **BLOCKED ON PRIMARY ASSETS / PC REFERENCE** | Android/iOS layout contract is ready. Final PASS requires approved canonical product assets, APK comparison and no normal-path fallback. Exact PC Categories reference parity remains separately blocked. |

## Category-card media contract

- Only released families: Drawer Organizer and Lunch Box.
- Product images carry no product count, price, rating, sale badge or CTA copy.
- Category cards may use WALKA ivory/navy/gold UI surfaces around the product media; those surfaces should stay Flutter-rendered.
- Product cutouts must remain portable between category card, search row, favorites card and PDP without screen-specific destructive crops.

## Search-row media contract

| Property | Drawer | Lunch |
|---|---|---|
| Source | canonical variant PNG | canonical variant PNG |
| Aspect | 1:1 box | 1:1 box |
| Fit | contain | contain |
| Small-size priority | full expandable silhouette | tray + bag/lid/accessory-set identity |
| Background | transparent source; UI owns surface | transparent source; UI owns surface |
| Baked copy | prohibited | prohibited |

## Discovery scale matrix

- 320px phone: media box 72–88 logical px depending row density.
- 390/430px phones: media box 84–104 logical px.
- Tablet: 112–160 logical px where cards move to multi-column composition.
- Desktop: 140–220 logical px in card/grid views; line-list variants may remain smaller.
- Never upscale a low-resolution derivative when the canonical master is available.

## QA gate

1. All five released variant IDs resolve correctly.
2. Drawer White/Gray never swap; Lunch Blue/Pink/Green never swap.
3. Media is legible at compact thumbnail size without clipping.
4. Empty/loading/offline states do not depend on product photography to communicate system state.
5. Query text, filters and counts remain live UI—not baked artwork.
6. Android and iOS reference compositions remain visually coherent at 1.3× text scale.
7. PC exact-reference sign-off remains blocked until an approved PC Categories visual exists.
