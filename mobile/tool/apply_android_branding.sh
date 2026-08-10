#!/usr/bin/env bash
set -euo pipefail

manifest='android/app/src/main/AndroidManifest.xml'
drawable_dir='android/app/src/main/res/drawable'
icon_file="${drawable_dir}/walka_launcher_icon.xml"

if [[ ! -f "$manifest" ]]; then
  echo "AndroidManifest.xml was not generated: $manifest" >&2
  exit 1
fi

mkdir -p "$drawable_dir"
cat > "$icon_file" <<'VECTOR'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp"
    android:height="108dp"
    android:viewportWidth="108"
    android:viewportHeight="108">
    <path
        android:fillColor="#003366"
        android:pathData="M0,0h108v108h-108z" />
    <path
        android:fillColor="#D4AF37"
        android:pathData="M17,25 L28,83 L42,83 L54,49 L66,83 L80,83 L91,25 L76,25 L70,59 L62,25 L46,25 L38,59 L32,25 Z" />
    <path
        android:fillColor="#D4AF37"
        android:pathData="M44,91h20v2h-20z" />
</vector>
VECTOR

python3 - "$manifest" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()
old = 'android:icon="@mipmap/ic_launcher"'
new = 'android:icon="@drawable/walka_launcher_icon"'
if old not in text:
    raise SystemExit(f'Expected generated launcher icon reference not found in {path}')
path.write_text(text.replace(old, new, 1))
PY

echo 'Applied WALKA navy/gold launcher icon to generated Android runner.'
