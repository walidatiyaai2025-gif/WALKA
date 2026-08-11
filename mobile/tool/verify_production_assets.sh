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

exec dart run tool/verify_production_assets.dart "$mode" "$@"
