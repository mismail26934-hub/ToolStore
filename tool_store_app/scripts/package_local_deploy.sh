#!/usr/bin/env bash
# Zip build/web for upload to server web/ folder.
set -euo pipefail
cd "$(dirname "$0")/.."

if [[ ! -f build/web/main.dart.js ]]; then
  echo "Run: bash scripts/build_web_local.sh"
  exit 1
fi

OUT="dist/tool-monitoring-local-web.zip"
mkdir -p dist
rm -f "$OUT"
if command -v zip >/dev/null 2>&1; then
  (cd build/web && zip -r "../../$OUT" .)
elif command -v powershell.exe >/dev/null 2>&1; then
  powershell -Command "Compress-Archive -Path 'build/web/*' -DestinationPath '$OUT' -Force"
else
  echo "Install zip or use PowerShell to create archive"
  exit 1
fi

echo ""
echo "Created: $OUT"
echo "Extract to server folder: web/ (document root on 10.40.102.69:8080)"
echo "MD5: $(md5sum build/web/main.dart.js 2>/dev/null || md5 -q build/web/main.dart.js)"
