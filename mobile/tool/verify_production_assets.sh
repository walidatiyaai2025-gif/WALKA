#!/usr/bin/env bash
set -euo pipefail

mode="${1:---report}"

required_assets=(
  "assets/products/drawer/white.png"
  "assets/products/drawer/gray.png"
  "assets/products/lunch/blue.png"
  "assets/products/lunch/pink.png"
  "assets/products/lunch/green.png"
)

missing=()
invalid=()

for asset in "${required_assets[@]}"; do
  if [[ ! -f "$asset" ]]; then
    missing+=("$asset")
    continue
  fi

  if [[ ! -s "$asset" ]]; then
    invalid+=("$asset (empty file)")
    continue
  fi

  # PNG signature: 89 50 4E 47 0D 0A 1A 0A
  signature="$(od -An -tx1 -N8 "$asset" | tr -d ' \n')"
  if [[ "$signature" != "89504e470d0a1a0a" ]]; then
    invalid+=("$asset (not a valid PNG signature)")
  fi
done

echo "WALKA production product asset gate"
echo "Required canonical assets: ${#required_assets[@]}"
echo "Present/valid: $(( ${#required_assets[@]} - ${#missing[@]} - ${#invalid[@]} ))"

if (( ${#missing[@]} > 0 )); then
  echo "Missing assets:"
  printf '  - %s\n' "${missing[@]}"
fi

if (( ${#invalid[@]} > 0 )); then
  echo "Invalid assets:"
  printf '  - %s\n' "${invalid[@]}"
fi

if (( ${#missing[@]} == 0 && ${#invalid[@]} == 0 )); then
  echo "PASS: all five production product assets are present and valid PNG files."
  exit 0
fi

if [[ "$mode" == "--enforce" ]]; then
  echo "FAIL: stable owner-visible APK publication is blocked until all five approved production assets are admitted." >&2
  exit 1
fi

echo "REPORT ONLY: production assets are incomplete; PR validation may continue, but stable main publication must enforce this gate."
