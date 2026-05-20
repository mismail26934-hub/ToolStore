import 'dart:convert';

import 'package:dio/dio.dart';

// #region agent log
/// Debug-mode NDJSON logger (session c77e50).
void agentDebugLog({
  required String hypothesisId,
  required String location,
  required String message,
  Map<String, dynamic>? data,
  String runId = 'pre-fix',
}) {
  final payload = <String, dynamic>{
    'sessionId': 'c77e50',
    'hypothesisId': hypothesisId,
    'location': location,
    'message': message,
    'data': data ?? <String, dynamic>{},
    'timestamp': DateTime.now().millisecondsSinceEpoch,
    'runId': runId,
  };
  try {
    Dio()
        .post(
          'http://127.0.0.1:7379/ingest/803f8a10-4374-4b48-a73d-d78622f7791c',
          data: jsonEncode(payload),
          options: Options(
            headers: {
              'Content-Type': 'application/json',
              'X-Debug-Session-Id': 'c77e50',
            },
            sendTimeout: const Duration(milliseconds: 800),
            receiveTimeout: const Duration(milliseconds: 800),
          ),
        )
        .ignore();
  } catch (_) {}
}
// #endregion
