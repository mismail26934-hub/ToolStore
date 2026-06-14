import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tool_store_app/config/app_links_config.g.dart';
import 'package:tool_store_app/model/api_client.dart';
import 'package:tool_store_app/navigation/root_navigator.dart';
import 'package:tool_store_app/view/custom/routes/page_routes.dart';

/// Runtime deep-link settings. Values default to [AppLinksConfig] (from config/app_links.json).
class FormDeepLinkConfig {
  FormDeepLinkConfig._();

  static String get defaultWebBase => AppLinksConfig.webBase;
  static String get androidPackageName => AppLinksConfig.androidPackageName;
  static String get iosBundleId => AppLinksConfig.iosBundleId;
  static String get formNoQueryParam => AppLinksConfig.formNoQueryParam;

  static String get webAppBase {
    const fromEnv = String.fromEnvironment('WEB_APP_BASE');
    if (fromEnv.isEmpty) return AppLinksConfig.webBase;
    return fromEnv.endsWith('/') ? fromEnv : '$fromEnv/';
  }

  static String get linkHost => Uri.parse(webAppBase).host;

  /// Normalized path prefix without trailing slash, e.g. `/Tool-Monitoring`.
  static String get linkPathPrefix {
    var path = Uri.parse(webAppBase).path;
    if (path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }
    return path.isEmpty ? '/' : path;
  }
}

/// Builds a shareable form deep link URL.
String buildFormLink(String formNo) {
  final no = formNo.trim();
  final base = FormDeepLinkConfig.webAppBase;
  if (no.isEmpty) return base;
  return Uri.parse(base).replace(
    queryParameters: {FormDeepLinkConfig.formNoQueryParam: no},
  ).toString();
}

/// Reads the form number from a URI query string.
String? parseFormNoFromUri(Uri uri) {
  final key = FormDeepLinkConfig.formNoQueryParam;
  final formNo = uri.queryParameters[key]?.trim();
  if (formNo == null || formNo.isEmpty) return null;
  return formNo;
}

/// True when [uri] matches this app's HTTPS App Link / Universal Link host and path.
bool matchesAppLinkUri(Uri uri) {
  final scheme = uri.scheme.toLowerCase();
  if (scheme != 'https' && scheme != 'http') return false;
  if (uri.host.toLowerCase() != FormDeepLinkConfig.linkHost.toLowerCase()) {
    return false;
  }
  final path = uri.path;
  final prefix = FormDeepLinkConfig.linkPathPrefix;
  return path == prefix || path.startsWith('$prefix/');
}

/// Holds a pending form number from URL or push notification until post-auth navigation.
class FormDeepLinkService {
  FormDeepLinkService._();

  static final FormDeepLinkService instance = FormDeepLinkService._();

  String? _pendingFormNo;
  StreamSubscription<Uri>? _linkSubscription;

  bool get hasPending {
    final pending = _pendingFormNo?.trim() ?? '';
    return pending.isNotEmpty;
  }

  /// Web: reads `Uri.base`. Mobile: App Links / Universal Links via [app_links].
  Future<void> initialize() async {
    if (kIsWeb) {
      captureFromCurrentUri();
      return;
    }

    final appLinks = AppLinks();
    try {
      final initial = await appLinks.getInitialLink();
      if (initial != null) {
        _handleIncomingUri(initial, navigateIfAuthenticated: false);
      }
    } catch (e, st) {
      debugPrint('FormDeepLinkService: getInitialLink failed: $e\n$st');
    }

    await _linkSubscription?.cancel();
    _linkSubscription = appLinks.uriLinkStream.listen(
      (uri) => _handleIncomingUri(uri, navigateIfAuthenticated: true),
      onError: (Object e, StackTrace st) {
        debugPrint('FormDeepLinkService: uriLinkStream error: $e\n$st');
      },
    );
  }

  void captureFromUri(Uri uri) {
    final formNo = parseFormNoFromUri(uri);
    if (formNo != null) _pendingFormNo = formNo;
  }

  void captureFromCurrentUri() => captureFromUri(Uri.base);

  void captureFromNotificationData(Map<String, dynamic> data) {
    final key = FormDeepLinkConfig.formNoQueryParam;
    final formNo = data[key]?.toString().trim() ?? '';
    if (formNo.isNotEmpty) _pendingFormNo = formNo;
  }

  String? peekPendingFormNo() {
    final pending = _pendingFormNo?.trim() ?? '';
    return pending.isEmpty ? null : pending;
  }

  String? consumePendingFormNo() {
    final pending = peekPendingFormNo();
    _pendingFormNo = null;
    return pending;
  }

  Future<void> navigateToPendingForm(BuildContext context) async {
    final formNo = consumePendingFormNo();
    if (formNo == null) return;
    if (!context.mounted) return;
    await PageRoutes.routeToolByFormNo(context, formNo: formNo);
  }

  Future<void> navigateToPendingFormFromRoot(GlobalKey<NavigatorState> key) async {
    final formNo = consumePendingFormNo();
    if (formNo == null) return;
    final context = key.currentContext;
    if (context == null || !context.mounted) {
      _pendingFormNo = formNo;
      return;
    }
    await PageRoutes.routeToolByFormNo(context, formNo: formNo);
  }

  void _handleIncomingUri(Uri uri, {required bool navigateIfAuthenticated}) {
    if (!matchesAppLinkUri(uri)) return;
    captureFromUri(uri);
    if (!navigateIfAuthenticated) return;
    unawaited(_navigateIfAuthenticated());
  }

  Future<void> _navigateIfAuthenticated() async {
    final creds = await loadAuthCredentials();
    if (!creds.isAuthenticated) return;
    await navigateToPendingFormFromRoot(rootNavigatorKey);
  }
}
