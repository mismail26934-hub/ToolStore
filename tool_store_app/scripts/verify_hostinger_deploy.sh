#!/usr/bin/env bash
# Verify deployed web build matches local artifacts (URL from config/app_links.json).
set -euo pipefail
cd "$(dirname "$0")/.."

dart run scripts/sync_app_links_config.dart
# shellcheck source=config/app_links.env.sh
source config/app_links.env.sh

BASE_URL="${DEPLOY_URL:-${WEB_BASE%/}}"
LOCAL="build/web"

if [[ ! -f "$LOCAL/main.dart.js" ]]; then
  echo "Missing $LOCAL/main.dart.js — run: bash scripts/build_web_hostinger.sh"
  exit 1
fi

local_md5=$(md5sum "$LOCAL/main.dart.js" | awk '{print $1}')
short="${local_md5:0:8}"
versioned="main.dart.${short}.js"
remote_bootstrap=$(curl -fsSL "$BASE_URL/flutter_bootstrap.js")
remote_js=$(echo "$remote_bootstrap" | grep -oE 'mainJsPath":"main\.dart[^"]*\.js"' | head -1 | sed 's/mainJsPath":"//;s/"$//')
remote_md5=""
if [[ -n "$remote_js" ]]; then
  remote_md5=$(curl -fsSL "$BASE_URL/$remote_js" | md5sum | awk '{print $1}')
fi

echo "main.dart.js local      : $local_md5"
echo "versioned bundle        : $versioned"
echo "bootstrap loads remote  : ${remote_js:-<unknown>}"
echo "remote bundle MD5       : ${remote_md5:-<failed>}"

check_url() {
  local path="$1"
  local expect_js="${2:-}"
  local headers
  headers=$(curl -sI "$BASE_URL/$path")
  local code
  code=$(echo "$headers" | awk 'toupper($1) ~ /^HTTP/ {print $2; exit}')
  if [[ "$code" != "200" ]]; then
    echo "FAIL $path HTTP $code"
    return 1
  fi
  if [[ "$expect_js" == "js" ]]; then
    if ! echo "$headers" | grep -qi "application/x-javascript\|application/javascript\|text/javascript"; then
      echo "FAIL $path (not JavaScript — mungkin SPA fallback ke index.html)"
      return 1
    fi
  fi
  echo "OK   $path"
}

fail=0
if [[ -z "$remote_md5" || "$local_md5" != "$remote_md5" ]]; then
  echo ""
  echo "MISMATCH: server masih build LAMA — upload belum berhasil!"
  echo "  Local : $local_md5"
  echo "  Remote: $remote_md5"
  echo ""
  echo "Upload semua isi build/web/ ke public_html${WEB_PATH_PREFIX}/"
  echo "Atau: bash scripts/package_hostinger_deploy.sh lalu extract zip di Hostinger"
  fail=1
fi

check_url index.html || fail=1
check_url "$versioned" js || fail=1
check_url flutter_bootstrap.js js || fail=1
check_url canvaskit/canvaskit.js js || fail=1
check_url assets/AssetManifest.bin.json || fail=1

exit "$fail"
