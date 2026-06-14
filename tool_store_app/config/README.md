# App links configuration (single source of truth)

Edit **`app_links.json`** only, then regenerate all targets:

```bash
dart run scripts/sync_app_links_config.dart
```

This updates:

- `lib/config/app_links_config.g.dart` (Dart constants)
- `config/app_links.env.sh` (shell variables for build scripts)
- `android/app/src/main/AndroidManifest.xml` (App Links intent filter)
- `ios/Runner/Runner.entitlements` (Associated Domains)
- `web/.htaccess` (`RewriteBase`)
- `hostinger-well-known/.well-known/assetlinks.json`
- `hostinger-well-known/.well-known/apple-app-site-association`

Before production deploy:

1. Set `appleTeamId` in `app_links.json`
2. Set `androidSha256Fingerprints` via `bash scripts/print_android_sha256.sh`
3. Run sync, upload `.well-known` to `public_html/.well-known/` on Hostinger

`WEB_APP_BASE` dart-define still overrides `webBase` at runtime for local web builds.
