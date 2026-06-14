#!/usr/bin/env bash
# Zip .well-known files for Hostinger domain root (NOT under app path prefix).
set -euo pipefail
cd "$(dirname "$0")/.."

dart run scripts/sync_app_links_config.dart
# shellcheck source=config/app_links.env.sh
source config/app_links.env.sh

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
echo "Before upload, edit config/app_links.json:"
echo "  androidSha256Fingerprints -> bash scripts/print_android_sha256.sh"
echo "  appleTeamId               -> your Apple Team ID"
echo "Then: dart run scripts/sync_app_links_config.dart"
echo ""
echo "Hostinger File Manager:"
echo "  public_html/.well-known/  (domain root https://${WEB_HOST}/)"
echo ""
echo "Verify:"
echo "  curl -s https://${WEB_HOST}/.well-known/assetlinks.json"
echo "  curl -s https://${WEB_HOST}/.well-known/apple-app-site-association"
