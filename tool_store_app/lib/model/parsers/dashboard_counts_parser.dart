import 'dart:convert';

import 'package:tool_store_app/controller/cont_crud/redux/state.dart';

FormDashboardCounts parseDashboardCountsResponse(dynamic responseBody) {
  final dynamic decoded = responseBody is String
      ? jsonDecode(responseBody)
      : responseBody;
  if (decoded is Map) {
    return FormDashboardCounts.fromJson(Map<String, dynamic>.from(decoded));
  }
  throw FormatException(
    'Unexpected dashboard counts response: ${decoded.runtimeType}',
  );
}
