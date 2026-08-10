# WALKA Cross-Device QA Acceptance Matrix

This matrix is the execution source for QA-001 through QA-018. A row is accepted only when its named automated coverage passes in the same full Flutter suite used by the PR/stable-main release gate.

| QA | Contract | Automated evidence |
|---|---|---|
| QA-001 | Deterministic golden/capture harness | `mobile/test/support/walka_golden_harness.dart`, `qa_001_010_device_accessibility_test.dart` |
| QA-002 | Android compact 320×568 | `WalkaTestDevice.androidCompact`; QA matrix + existing `design_007_cross_device_matrix_test.dart` |
| QA-003 | Android standard phone | `WalkaTestDevice.androidStandard`; QA matrix + DESIGN-007 |
| QA-004 | Android large/comfortable phone | `WalkaTestDevice.androidComfortable`; QA matrix + DESIGN-007 |
| QA-005 | 1.3× text scale | QA matrix + DESIGN-007 compact/standard 1.3× cases |
| QA-006 | iOS phone safe area | `WalkaTestDevice.iosPhone`; notch/home-indicator assertions |
| QA-007 | Desktop 1280 | `WalkaTestDevice.desktop1280`; adaptive wide-shell assertion |
| QA-008 | Desktop 1440 | `WalkaTestDevice.desktop1440`; adaptive wide-shell assertion |
| QA-009 | Reduced motion | `WalkaGoldenHarness(disableAnimations: true)` + `WalkaMotion.duration == Duration.zero` |
| QA-010 | Semantics/touch targets | `WalkaTouchTarget >= 48px` + semantic label assertion |
| QA-011 | Navigation smoke | `qa_011_014_behavior_regression_test.dart` wiring audit plus existing runtime shell/navigation tests |
| QA-012 | Product truth | Production PDP vs `docs/PRODUCT_MASTER.md`, including prohibited leakproof exclusion |
| QA-013 | Favorites persistence | Controller write/reload/remove regression + existing Favorites V131 tests |
| QA-014 | Amazon boundary | Five official Amazon `/dp/` URLs + `LaunchMode.externalApplication`; no checkout/payment path |
| QA-015 | Analyze + full tests | `qa_015_017_release_contract_test.dart` validates workflow gate commands |
| QA-016 | Android release APK | Release contract validates build/stage/upload steps |
| QA-017 | Stable verified APK | Publication guard + receipt format + checked-in APK byte-size match |
| QA-018 | Reference acceptance matrix | This document |

## Visual-reference coverage

| Screen family | Android | iOS | PC/Desktop | Current acceptance route |
|---|---|---|---|---|
| Home | `Images/Home for Android.png` | `Images/Home for ios.png` | `Images/Home for pc.png` | Android stable; iOS/desktop parity tasks must use QA-006/007/008 |
| Categories | `Images/Categories page for Android.png` | `Images/Categories page for ios.png` | Not classified | Android stable; iOS uses QA-006; PC remains blocked |
| Product Detail | `Images/Product page for Android.png` | `Images/Product page for ios.png` | Not classified | Android stable; iOS uses QA-006; PC remains blocked |
| Favorites | `Images/Faivorets page for Android.png` | `Images/Faivorets page for ios.png` | `Images/Faivorets page for PC.png` | Android stable; FAV parity must run QA-006/007/008/013 |
| Account | `Images/Account profile page for Android.png` | `Images/Account profile page for ios.png` | `Images/Account profile page for PC.png` | Android stable; parity runs QA-006/007/008/011 |
| About | `Images/About for Android.png` | `Images/About for ios.png` | `Images/About page for PC.png` | Android stable; parity runs QA-006/007/008/011/012 |

## Acceptance rules

1. Product truth and Amazon destination safety override mock content visible in references.
2. `Images/` remains protected/read-only.
3. No owner-visible feature branch is accepted with Analyze or full-test failures.
4. Mobile-affecting stable merges require a successful Android release APK build.
5. Stable APK publication is valid only when the workflow stale-main guard approves the same validated source commit.
6. PC Product Detail and PC Categories remain blocked until REF-003 or another source is explicitly classified/approved.
