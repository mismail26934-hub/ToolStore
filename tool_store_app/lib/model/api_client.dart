import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tool_store_app/view/var/var.dart';

/// Credentials loaded from [SharedPreferences] after login.
class AuthCredentials {
  const AuthCredentials({required this.token, required this.idUsers});

  final String token;
  final String idUsers;

  bool get isAuthenticated => token.isNotEmpty || idUsers.isNotEmpty;
}

/// Result of mapping a [DioException] to user-facing copy.
class DioErrorResolution {
  const DioErrorResolution({
    required this.label,
    required this.throwMessage,
    this.detail = '',
  });

  final String label;
  final String throwMessage;
  final String detail;
}

Future<AuthCredentials> loadAuthCredentials() async {
  final prefs = await SharedPreferences.getInstance();
  final authToken = prefs.getString('token')?.trim() ?? '';
  final userId = prefs.getString('idUsersApp')?.trim() ?? '';
  token = authToken;
  idUsersApp = userId;
  return AuthCredentials(token: authToken, idUsers: userId);
}

void _applyAuthField(
  Map<String, dynamic> merged,
  String key,
  String value,
) {
  if (value.isEmpty) return;
  final current = merged[key];
  if (current == null || current.toString().trim().isEmpty) {
    merged[key] = value;
  }
}

/// Merges session credentials into POST bodies (PHP `api_auth.php` convention).
///
/// Uses [auth_id_users] for token validation. Do not auto-fill [id_users]: on
/// `VIEW DATA USER` that field is the row filter (non-empty → single user).
Future<Map<String, dynamic>> withAuthFields(Map<String, dynamic> body) async {
  final creds = await loadAuthCredentials();
  final merged = Map<String, dynamic>.from(body);
  _applyAuthField(merged, 'token', creds.token);
  _applyAuthField(merged, 'auth_id_users', creds.idUsers);
  _applyAuthField(merged, 'id_users_app', creds.idUsers);
  return merged;
}

Dio? _sharedApiDio;

/// Shared [Dio] for app API calls (20s connect/receive, Bearer from session).
///
/// Reuses one client instance instead of allocating per [apiPost].
Dio createApiDio() {
  final existing = _sharedApiDio;
  if (existing != null) return existing;

  final dio = Dio();
  dio.options.connectTimeout = const Duration(seconds: 20);
  dio.options.receiveTimeout = const Duration(seconds: 20);
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final creds = await loadAuthCredentials();
        if (creds.token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer ${creds.token}';
        }
        handler.next(options);
      },
    ),
  );
  _sharedApiDio = dio;
  return dio;
}

/// Clears the cached client (unit/widget tests only).
@visibleForTesting
void resetSharedApiDio() {
  _sharedApiDio = null;
}

/// POST [FormData] with auth fields and optional Bearer header.
Future<Response<dynamic>> apiPost(
  String url,
  Map<String, dynamic> body, {
  bool attachAuth = true,
}) async {
  final payload = attachAuth ? await withAuthFields(body) : body;
  return createApiDio().post(url, data: FormData.fromMap(payload));
}

DioErrorResolution resolveDioException(DioException e) {
  if (e.type == DioExceptionType.connectionError ||
      e.error is SocketException ||
      e.type == DioExceptionType.connectionTimeout) {
    return DioErrorResolution(
      label: cekInternet,
      throwMessage: cekInternet,
      detail: e.message ?? '',
    );
  }

  final status = e.response?.statusCode;
  if (status == 401 || status == 403) {
    return DioErrorResolution(
      label: sessionExpired,
      throwMessage: sessionExpired,
      detail: e.message ?? '',
    );
  }

  if (status != null && status >= 500) {
    return DioErrorResolution(
      label: serverDown,
      throwMessage: serverDown,
      detail: e.message ?? '',
    );
  }

  return DioErrorResolution(
    label: serverDown,
    throwMessage: serverDown,
    detail: e.message ?? '',
  );
}

/// Updates global [errors]/[messages] and returns message for [Exception].
String applyDioError(DioException e) {
  final resolved = resolveDioException(e);
  errors = resolved.label;
  messages = resolved.detail.isEmpty ? '' : ' (${resolved.detail})';
  return resolved.throwMessage;
}

/// User-facing message for login and other API calls (not only network errors).
String messageForApiError(Object e) {
  if (e is DioException) {
    return applyDioError(e);
  }
  if (e is FormatException) {
    return serverDown;
  }
  if (e is Exception) {
    final text = e.toString();
    const prefix = 'Exception: ';
    if (text.startsWith(prefix)) {
      final msg = text.substring(prefix.length);
      if (msg.startsWith('Server Error:')) {
        return serverDown;
      }
      return msg;
    }
  }
  return serverDown;
}
