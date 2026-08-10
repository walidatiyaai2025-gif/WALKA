#!/usr/bin/env bash
set -euo pipefail

root="${1:-assets/products}"
total_limit=$((6 * 1024 * 1024))
apk_warning=$((60 * 1024 * 1024))
apk_hard=$((95 * 1024 * 1024))

if [[ ! -d "$root" ]]; then
  echo "Product asset root missing: $root" >&2
  exit 1
fi

mapfile -t runtime_files < <(find "$root" -type f ! -name '.gitkeep' -print | sort)
mapfile -t png_files < <(find "$root" -type f -name '*.png' -print | sort)
mapfile -t source_files < <(find "$root" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.psd' -o -iname '*.tif' -o -iname '*.tiff' -o -iname '*.raw' -o -iname '*.heic' \) -print | sort)

if (( ${#source_files[@]} > 0 )); then
  echo 'FAIL: source/master artwork must not be bundled under runtime product asset folders:' >&2
  printf ' - %s\n' "${source_files[@]}" >&2
  exit 1
fi

total_bytes=0
for file in "${png_files[@]}"; do
  bytes="$(stat -c%s "$file")"
  total_bytes=$((total_bytes + bytes))
done

if (( total_bytes > total_limit )); then
  echo "FAIL: production product PNG bundle is ${total_bytes} bytes; hard budget is ${total_limit}." >&2
  exit 1
fi

duplicate_count=0
if (( ${#png_files[@]} > 1 )); then
  duplicate_count="$(sha256sum "${png_files[@]}" | awk '{print $1}' | sort | uniq -d | wc -l | tr -d ' ')"
fi
if (( duplicate_count > 0 )); then
  echo 'FAIL: duplicate canonical production PNG content detected.' >&2
  sha256sum "${png_files[@]}" | sort >&2
  exit 1
fi

apk_bytes='unknown'
receipt='../Last verified APK/VERIFIED_BUILD.md'
if [[ -f "$receipt" ]]; then
  parsed="$(sed -n 's/^- APK bytes: `\([0-9][0-9]*\)`.*/\1/p' "$receipt" | head -n1)"
  if [[ -n "$parsed" ]]; then
    apk_bytes="$parsed"
    if (( parsed > apk_hard )); then
      echo "FAIL: verified APK is ${parsed} bytes; hard repository threshold is ${apk_hard}." >&2
      exit 1
    fi
  fi
fi

echo 'WALKA product media performance audit'
echo "Runtime files: ${#runtime_files[@]}"
echo "Canonical PNG count: ${#png_files[@]}"
echo "Canonical PNG bytes: ${total_bytes}/${total_limit}"
echo "Duplicate PNG checksums: ${duplicate_count}"
echo "Verified APK bytes: ${apk_bytes}"
if [[ "$apk_bytes" != 'unknown' ]] && (( apk_bytes > apk_warning )); then
  echo "WARNING: verified APK exceeds the ${apk_warning}-byte review threshold."
else
  echo "APK review threshold: ${apk_warning} bytes"
fi
