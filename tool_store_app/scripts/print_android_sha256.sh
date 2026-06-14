#!/usr/bin/env bash
# Print SHA-256 certificate fingerprints for Android App Links (assetlinks.json).
set -euo pipefail

KEYSTORE="${KEYSTORE:-${HOME:-$USERPROFILE}/.android/debug.keystore}"
ALIAS="${KEY_ALIAS:-androiddebugkey}"
STORE_PASS="${STORE_PASS:-android}"

echo "Keystore: $KEYSTORE"
echo "Alias:    $ALIAS"
echo ""
echo "Copy SHA256 fingerprint(s) into config/app_links.json -> androidSha256Fingerprints"
echo "Then run: dart run scripts/sync_app_links_config.dart"
echo "(colon-separated uppercase hex, e.g. AB:CD:...:12)"
echo ""

if [[ ! -f "$KEYSTORE" ]]; then
  echo "Keystore not found. For release, run:"
  echo "  KEYSTORE=/path/to/upload-keystore.jks KEY_ALIAS=upload STORE_PASS=*** bash scripts/print_android_sha256.sh"
  exit 1
fi

keytool -list -v -keystore "$KEYSTORE" -alias "$ALIAS" -storepass "$STORE_PASS" 2>/dev/null \
  | grep -E "SHA256:|SHA-256"
