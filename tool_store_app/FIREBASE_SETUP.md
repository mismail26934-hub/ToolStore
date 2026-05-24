# Firebase Cloud Messaging — Setup ToolMonitoring

## 1. Firebase Console

1. Buka project **ToolMonitoring**.
2. Tambah app **Android** dengan package `com.example.tool_store_app`.
3. Tambah app **iOS** dengan bundle id `com.example.toolStoreApp`.
4. Tambah app **macOS** dengan bundle id `com.example.toolStoreApp` (atau app Apple terpisah).
5. Unduh `google-services.json` → `android/app/google-services.json`.
6. Unduh `GoogleService-Info.plist` → `ios/Runner/` dan `macos/Runner/`.
7. Tab **Cloud Messaging** → upload **APNs key** (wajib untuk push ke iPhone/iPad/Mac).

## 2. FlutterFire CLI (disarankan)

```bash
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
dart pub global run flutterfire_cli:flutterfire configure
```

## 3. Backend (PHP)

`POST {server}/api_tool/api_toolstore/v1/device/fcm`

| Field | Nilai |
|-------|--------|
| `param` | `SAVE FCM TOKEN` |
| `fcm_token` | token FCM |
| `platform` | `android`, `ios`, `web`, atau `macos` |
| `token` | session API user |
| `auth_id_users` | id user login |

## 4. Web (FCM)

1. Isi **Web appId** di `lib/firebase_options.dart` dan `web/firebase-messaging-sw.js`.
2. VAPID key: `lib/config/firebase_web_vapid.dart`.
3. Jalankan: `flutter run -d chrome` (HTTPS atau localhost).

## 5. macOS (FCM)

1. Firebase Console → tambah app **macOS** (bundle `com.example.toolStoreApp`).
2. Salin `GoogleService-Info.plist` ke `macos/Runner/GoogleService-Info.plist`.
3. Isi `GOOGLE_APP_ID` di `lib/firebase_options.dart` → `DefaultFirebaseOptions.macos.appId`.
4. Di Xcode (macOS): **Signing & Capabilities** → **Push Notifications**.
5. Entitlements sudah disiapkan (`aps-environment`, network client).
6. Jalankan: `flutter run -d macos` → login → token dikirim dengan `platform=macos`.

**Catatan:** Push Mac memerlukan APNs (sama seperti iOS) di Firebase Cloud Messaging.

## 6. Build

```bash
flutter pub get
flutter run
```

Tanpa config Firebase per platform, push di platform itu di-skip (app tetap jalan).
