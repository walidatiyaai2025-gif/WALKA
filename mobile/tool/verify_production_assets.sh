#!/usr/bin/env bash
set -euo pipefail

mode="${1:---report}"
shift || true

case "$mode" in
  --report|--enforce) ;;
  *)
    echo "Usage: $0 [--report|--enforce] [--json <path>] [--root <path>] [--manifest <path>] [--strict-warnings]" >&2
    exit 2
    ;;
esac

args=("$@")
json_path='production-asset-readiness.json'
root_path='.'
for ((i = 0; i < ${#args[@]}; i += 1)); do
  case "${args[$i]}" in
    --json)
      if (( i + 1 < ${#args[@]} )); then
        json_path="${args[$((i + 1))]}"
      fi
      ;;
    --root)
      if (( i + 1 < ${#args[@]} )); then
        root_path="${args[$((i + 1))]}"
      fi
      ;;
  esac
done

# QMEDIA admission guard: file presence is not production admission. Every PAV
# report/enforcement invocation first proves that the compile-time production
# resolver admission registry agrees with source admission + provenance. This
# keeps engineering builds available while preventing contradictory metadata
# from ever unlocking stable publication.
if [[ "${QMEDIA_SKIP_RUNTIME_ADMISSION:-0}" != "1" ]]; then
  dart run tool/verify_runtime_media_admission.dart \
    --json runtime-media-admission.json
fi

dart run tool/verify_production_assets.dart "$mode" "$@"

# Stable owner-visible publication is bound to two deterministic scopes:
# - visual inputs: owner-visible Flutter code/media/product manifest;
# - release inputs: visual inputs plus dependency lock, branding/build recipe,
#   pinned toolchain contract and the release workflow itself.
# APK SHA remains the reviewed-artifact receipt; independent Android rebuilds
# are not assumed to be byte-for-byte reproducible.
visual_input_digest="$(
  git -C .. ls-tree -r HEAD -- mobile/lib mobile/assets mobile/pubspec.yaml \
    | LC_ALL=C sort \
    | sha256sum \
    | awk '{print $1}'
)"
release_input_digest="$(
  git -C .. ls-tree -r HEAD -- \
    mobile/lib \
    mobile/assets \
    mobile/pubspec.yaml \
    mobile/pubspec.lock \
    mobile/tool/apply_android_branding.sh \
    docs/ui/RELEASE_TOOLCHAIN_CONTRACT.json \
    .github/workflows/flutter-preview.yml \
    | LC_ALL=C sort \
    | sha256sum \
    | awk '{print $1}'
)"

if [[ "$mode" == '--enforce' ]]; then
  dart run tool/verify_visual_release_gate.dart \
    --root "$root_path" \
    --production-report "$json_path" \
    --visual-input-digest "$visual_input_digest" \
    --release-input-digest "$release_input_digest" \
    --json visual-release-gate-enforce.json \
    --report \
    --enforce
else
  dart run tool/verify_visual_release_gate.dart \
    --root "$root_path" \
    --production-report "$json_path" \
    --visual-input-digest "$visual_input_digest" \
    --release-input-digest "$release_input_digest" \
    --json visual-release-gate.json \
    --report
fi
