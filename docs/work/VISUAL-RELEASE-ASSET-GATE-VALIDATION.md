# Validation notes

Automated validation is delegated to the repository's existing `Flutter Preview` pull-request workflow.

Expected PR behavior:
- `flutter pub get`
- `flutter analyze`
- full `flutter test`
- production asset gate in `--report` mode
- Android runner generation + WALKA branding
- release APK build

Expected `main` behavior after merge:
- the same validation/build path runs,
- the APK candidate is still uploaded for engineering inspection,
- `mobile/tool/verify_production_assets.sh --enforce` runs before stable publication,
- `Last verified APK` is not updated while any of the five canonical production PNGs is absent or invalid.
