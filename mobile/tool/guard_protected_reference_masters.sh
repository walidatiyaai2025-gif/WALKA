#!/usr/bin/env bash
set -euo pipefail

if [[ "${WALKA_ALLOW_PROTECTED_IMAGES_MUTATION:-0}" == '1' ]]; then
  echo 'Protected Images mutation guard explicitly overridden.'
  exit 0
fi

base_sha="${1:-}"
if [[ -z "$base_sha" || "$base_sha" =~ ^0+$ ]]; then
  if git rev-parse HEAD^ >/dev/null 2>&1; then
    base_sha="$(git rev-parse HEAD^)"
  else
    echo 'No comparable base commit; protected Images guard has nothing to diff.'
    exit 0
  fi
fi

if ! git cat-file -e "${base_sha}^{commit}" 2>/dev/null; then
  echo "Base commit $base_sha is not available; checkout must use fetch-depth: 0." >&2
  exit 2
fi

mapfile -t protected_changes < <(
  git diff --name-only "$base_sha" HEAD -- ':(top)Images/' | sed '/^$/d'
)
if (( ${#protected_changes[@]} > 0 )); then
  echo 'FAIL: protected reference masters changed in normal CI:' >&2
  printf ' - %s\n' "${protected_changes[@]}" >&2
  echo 'Reference masters are read-only during normal development. Use explicit owner-approved workflow with WALKA_ALLOW_PROTECTED_IMAGES_MUTATION=1 only for intentional master updates.' >&2
  exit 1
fi

echo 'Protected reference masters unchanged.'
