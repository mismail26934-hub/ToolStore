#!/usr/bin/env bash
# Zip .well-known files for Hostinger domain root (NOT under Tool-Monitoring/).
set -euo pipefail
cd "$(dirname "$0")/.."

SRC="hostinger-well-known/.well-known"
OUT="dist/well-known-hostinger.zip"

if [[ ! -f "$SRC/assetlinks.json" ]]; then
  echo "Missing $SRC/assetlinks.json"
  exit 1
fi

mkdir -p dist
rm -f "$OUT"

if command -v zip >/dev/null 2>&1; then
  (cd hostinger-well-known && zip -r "../$OUT" .well-known)
elif command -v powershell.exe >/dev/null 2>&1; then
  powershell -Command "Compress-Archive -Path 'hostinger-well-known/.well-known' -DestinationPath '$OUT' -Force"
else
  echo "Install zip or use PowerShell"
  exit 1
fi

echo ""
echo "Created: $OUT"
echo ""
echo "Before upload, edit:"
echo "  hostinger-well-known/.well-known/assetlinks.json"
echo "    -> bash scripts/print_android_sha256.sh"
echo "  hostinger-well-known/.well-known/apple-app-site-association"
echo "    -> replace REPLACE_WITH_APPLE_TEAM_ID with your Apple Team ID"
echo ""
echo "Hostinger File Manager:"
echo "  public_html/.well-known/  (domain root https://strakin.tech/)"
echo ""
echo "Verify:"
echo "  curl -s https://strakin.tech/.well-known/assetlinks.json"
echo "  curl -s https://strakin.tech/.well-known/apple-app-site-association"
