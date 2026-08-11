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

# QMEDIA admission guard: file presence is not production admission. Every PAV
# report/enforcement invocation first proves that the compile-time production
# resolver admission registry agrees with source admission + provenance. This
# keeps engineering builds available while preventing contradictory metadata
# from ever unlocking stable publication.
if [[ "${QMEDIA_SKIP_RUNTIME_ADMISSION:-0}" != "1" ]]; then
  dart run tool/verify_runtime_media_admission.dart \
    --json runtime-media-admission.json
fi

exec dart run tool/verify_production_assets.dart "$mode" "$@"
