#!/usr/bin/env bash
# Regenerate app link artifacts from config/app_links.json
set -euo pipefail
cd "$(dirname "$0")/.."
dart run scripts/sync_app_links_config.dart
