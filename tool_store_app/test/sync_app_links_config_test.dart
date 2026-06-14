import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tool_store_app/config/app_links_config.g.dart';

void main() {
  test('generated AppLinksConfig matches config/app_links.json', () {
    final jsonFile = File('config/app_links.json');
    expect(jsonFile.existsSync(), isTrue, reason: 'Run sync before tests');

    final json =
        jsonDecode(jsonFile.readAsStringSync()) as Map<String, dynamic>;
    final webBase = (json['webBase'] as String).trim();
    final normalizedBase = webBase.endsWith('/') ? webBase : '$webBase/';

    expect(AppLinksConfig.webBase, normalizedBase);
    expect(AppLinksConfig.host, json['host']);
    expect(AppLinksConfig.pathPrefix, json['pathPrefix']);
    expect(AppLinksConfig.formNoQueryParam, json['formNoQueryParam']);
    expect(AppLinksConfig.androidPackageName, json['androidPackageName']);
    expect(AppLinksConfig.iosBundleId, json['iosBundleId']);
    expect(AppLinksConfig.appleTeamId, json['appleTeamId']);
  });

  test('Android manifest contains synced host and path', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml')
        .readAsStringSync();
    expect(manifest, contains('android:host="${AppLinksConfig.host}"'));
    expect(
      manifest,
      contains('android:pathPrefix="${AppLinksConfig.pathPrefix}"'),
    );
  });

  test('well-known assetlinks uses configured package name', () {
    final assetLinks = jsonDecode(
      File('hostinger-well-known/.well-known/assetlinks.json').readAsStringSync(),
    ) as List<dynamic>;
    final target = (assetLinks.first as Map<String, dynamic>)['target']
        as Map<String, dynamic>;
    expect(target['package_name'], AppLinksConfig.androidPackageName);
  });
}
