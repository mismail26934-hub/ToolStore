// ignore_for_file: avoid_print
//
// Sync deep-link / app-link settings from config/app_links.json to Dart, native,
// server, and shell artifacts. Run from project root:
//   dart run scripts/sync_app_links_config.dart

import 'dart:convert';
import 'dart:io';

const _generatedHeader = '''
// GENERATED CODE - DO NOT EDIT BY HAND.
// Source: config/app_links.json
// Regenerate: dart run scripts/sync_app_links_config.dart
''';

void main() {
  final root = _projectRoot();
  final configPath = File('${root.path}/config/app_links.json');
  if (!configPath.existsSync()) {
    stderr.writeln('Missing ${configPath.path}');
    exit(1);
  }

  final raw = jsonDecode(configPath.readAsStringSync()) as Map<String, dynamic>;
  final config = _AppLinksConfig.fromJson(raw);

  _write(
    '${root.path}/lib/config/app_links_config.g.dart',
    _dartFile(config),
  );
  _write('${root.path}/config/app_links.env.sh', _envSh(config));
  _write(
    '${root.path}/hostinger-well-known/.well-known/assetlinks.json',
    '${_prettyJson(_assetLinksJson(config))}\n',
  );
  _write(
    '${root.path}/hostinger-well-known/.well-known/apple-app-site-association',
    '${_prettyJson(_aasaJson(config))}\n',
  );
  _patchEntitlements('${root.path}/ios/Runner/Runner.entitlements', config);
  _patchAndroidManifest(
    '${root.path}/android/app/src/main/AndroidManifest.xml',
    config,
  );
  _patchHtaccess('${root.path}/web/.htaccess', config);

  print('Synced app links config from config/app_links.json');
  print('  webBase:     ${config.webBase}');
  print('  pathPrefix:  ${config.pathPrefix}');
  print('  baseHref:    ${config.baseHref}');
}

Directory _projectRoot() {
  final script = File(Platform.script.toFilePath());
  return script.parent.parent;
}

void _write(String path, String content) {
  final file = File(path);
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(content);
}

class _AppLinksConfig {
  _AppLinksConfig({
    required this.webBase,
    required this.host,
    required this.pathPrefix,
    required this.formNoQueryParam,
    required this.androidPackageName,
    required this.iosBundleId,
    required this.appleTeamId,
    required this.androidSha256Fingerprints,
  });

  factory _AppLinksConfig.fromJson(Map<String, dynamic> json) {
    final webBase = _normalizeWebBase(json['webBase'] as String? ?? '');
    final pathPrefix = _normalizePathPrefix(
      json['pathPrefix'] as String? ?? Uri.parse(webBase).path,
    );
    final host = (json['host'] as String? ?? Uri.parse(webBase).host).trim();
    final fingerprints = (json['androidSha256Fingerprints'] as List<dynamic>? ??
            const <dynamic>[])
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return _AppLinksConfig(
      webBase: webBase,
      host: host,
      pathPrefix: pathPrefix,
      formNoQueryParam:
          (json['formNoQueryParam'] as String? ?? 'form_no').trim(),
      androidPackageName:
          (json['androidPackageName'] as String? ?? '').trim(),
      iosBundleId: (json['iosBundleId'] as String? ?? '').trim(),
      appleTeamId: (json['appleTeamId'] as String? ?? '').trim(),
      androidSha256Fingerprints: fingerprints,
    );
  }

  final String webBase;
  final String host;
  final String pathPrefix;
  final String formNoQueryParam;
  final String androidPackageName;
  final String iosBundleId;
  final String appleTeamId;
  final List<String> androidSha256Fingerprints;

  String get baseHref =>
      pathPrefix.endsWith('/') ? pathPrefix : '$pathPrefix/';

  String get iosAppId => '$appleTeamId.$iosBundleId';

  String get sampleFormLink =>
      Uri.parse(webBase)
          .replace(queryParameters: {formNoQueryParam: 'F-00123'})
          .toString();
}

String _normalizeWebBase(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    throw ArgumentError('webBase must not be empty');
  }
  return trimmed.endsWith('/') ? trimmed : '$trimmed/';
}

String _normalizePathPrefix(String value) {
  var path = value.trim();
  if (!path.startsWith('/')) path = '/$path';
  if (path.endsWith('/')) path = path.substring(0, path.length - 1);
  return path.isEmpty ? '/' : path;
}

String _dartLiteral(String value) =>
    "'${value.replaceAll('\\', '\\\\').replaceAll("'", "\\'")}'";

String _dartFile(_AppLinksConfig c) {
  final fingerprints = c.androidSha256Fingerprints
      .map((f) => "    ${_dartLiteral(f)},")
      .join('\n');

  return '''
$_generatedHeader

/// Generated from [config/app_links.json]. Use [FormDeepLinkConfig] for runtime overrides.
abstract final class AppLinksConfig {
  static const String webBase = ${_dartLiteral(c.webBase)};
  static const String host = ${_dartLiteral(c.host)};
  static const String pathPrefix = ${_dartLiteral(c.pathPrefix)};
  static const String formNoQueryParam = ${_dartLiteral(c.formNoQueryParam)};
  static const String androidPackageName = ${_dartLiteral(c.androidPackageName)};
  static const String iosBundleId = ${_dartLiteral(c.iosBundleId)};
  static const String appleTeamId = ${_dartLiteral(c.appleTeamId)};
  static const String baseHref = ${_dartLiteral(c.baseHref)};
  static const String sampleFormLink = ${_dartLiteral(c.sampleFormLink)};

  static const List<String> androidSha256Fingerprints = <String>[
$fingerprints
  ];
}
''';
}

String _envSh(_AppLinksConfig c) {
  return '''
# GENERATED - DO NOT EDIT BY HAND
# Source: config/app_links.json
# Regenerate: dart run scripts/sync_app_links_config.dart
# @sync-app-links:env
export WEB_BASE="${c.webBase}"
export WEB_HOST="${c.host}"
export WEB_PATH_PREFIX="${c.pathPrefix}"
export WEB_BASE_HREF="${c.baseHref}"
export FORM_NO_QUERY_PARAM="${c.formNoQueryParam}"
# @end-sync-app-links:env
''';
}

List<Map<String, dynamic>> _assetLinksJson(_AppLinksConfig c) => [
      {
        'relation': ['delegate_permission/common.handle_all_urls'],
        'target': {
          'namespace': 'android_app',
          'package_name': c.androidPackageName,
          'sha256_cert_fingerprints': c.androidSha256Fingerprints,
        },
      },
    ];

Map<String, dynamic> _aasaJson(_AppLinksConfig c) => {
      'applinks': {
        'apps': <dynamic>[],
        'details': [
          {
            'appIDs': [c.iosAppId],
            'paths': [c.pathPrefix, '${c.pathPrefix}/*'],
          },
        ],
      },
    };

String _prettyJson(Object value) {
  const encoder = JsonEncoder.withIndent('  ');
  return encoder.convert(value);
}

void _patchEntitlements(String path, _AppLinksConfig c) {
  final content = '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<!-- GENERATED - DO NOT EDIT BY HAND. Source: config/app_links.json -->
<plist version="1.0">
<dict>
\t<key>com.apple.developer.associated-domains</key>
\t<array>
\t\t<string>applinks:${c.host}</string>
\t</array>
</dict>
</plist>
''';
  _write(path, content);
}

void _patchAndroidManifest(String path, _AppLinksConfig c) {
  final file = File(path);
  if (!file.existsSync()) {
    stderr.writeln('Missing $path');
    exit(1);
  }
  final block = '''
            <!-- @sync-app-links:intent-filter -->
            <!-- App Links: ${c.sampleFormLink} -->
            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.VIEW"/>
                <category android:name="android.intent.category.DEFAULT"/>
                <category android:name="android.intent.category.BROWSABLE"/>
                <data
                    android:scheme="https"
                    android:host="${c.host}"
                    android:pathPrefix="${c.pathPrefix}"/>
            </intent-filter>
            <!-- @end-sync-app-links:intent-filter -->''';

  final updated = _replaceMarkedBlock(
    file.readAsStringSync(),
    'intent-filter',
    block,
    startPrefix: '<!--',
    endPrefix: '<!--',
  );
  file.writeAsStringSync(updated);
}

void _patchHtaccess(String path, _AppLinksConfig c) {
  final file = File(path);
  if (!file.existsSync()) {
    stderr.writeln('Missing $path');
    exit(1);
  }
  final block = '''
  # @sync-app-links:rewrite-base
  RewriteBase ${c.baseHref}
  # @end-sync-app-links:rewrite-base''';

  final updated = _replaceMarkedBlock(
    file.readAsStringSync(),
    'rewrite-base',
    block,
    startPrefix: '#',
    endPrefix: '#',
  );
  file.writeAsStringSync(updated);
}

String _replaceMarkedBlock(
  String content,
  String markerId,
  String block, {
  required String startPrefix,
  required String endPrefix,
}) {
  final start = '$startPrefix @sync-app-links:$markerId';
  final end = '$endPrefix @end-sync-app-links:$markerId';

  final startIndex = content.indexOf(start);
  final endIndex = content.indexOf(end);

  if (startIndex == -1 || endIndex == -1 || endIndex < startIndex) {
    stderr.writeln(
      'Marker @$markerId not found in file. '
      'Expected "$start" ... "$end"',
    );
    exit(1);
  }

  final endLine = content.indexOf('\n', endIndex);
  final after = endLine == -1 ? content.length : endLine + 1;
  return content.replaceRange(startIndex, after, '$block\n');
}
