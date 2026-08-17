# Legacy release tests

These files preserve historical QA evidence from the pre-CMS mobile architecture. They are intentionally stored as `.legacy.txt` so `flutter test` and the Dart analyzer do not treat them as current executable contracts.

## local_product_media

These tests required product PNGs to be bundled in `assets/products/...` and validated the old local admission/provenance pipeline. CMS-014 intentionally removes those binaries from the application artifact and uses backend-delivered remote media instead. The active CI now scans the built APK and AAB and fails if bundled product media returns.

## static_information

These tests asserted compiled Account / Story / FAQ / Contact / legal copy. CMS-014 moves that mutable information into the published `storefront.copy.information_json` contract. Current tests must validate remote/cache content and fail-closed behavior instead of compiled copy.

Do not move these files back into `mobile/test` unless the architecture itself is intentionally reverted.
