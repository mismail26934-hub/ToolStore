import 'dart:convert';

import 'package:tool_store_app/controller/api_url/post_list.dart';
import 'package:tool_store_app/model/repositories/mutating_list_fetch_result.dart';

List<dynamic> decodeJsonArray(dynamic data) {
  if (data is String) {
    final decoded = jsonDecode(data);
    if (decoded is! List) {
      throw FormatException('Expected a JSON array from server');
    }
    return decoded;
  }
  if (data is List) return data;
  throw FormatException('Unexpected response format from server');
}

PoFetchResult parseMutatingListFetchResponse({
  required dynamic data,
  required String param,
  required bool Function(Map<String, dynamic> map) isStatusEnvelope,
  required bool Function(String param) isMutatingParam,
}) {
  final raw = decodeJsonArray(data);
  String? statusValue;
  String? statusMessage;
  final dataRows = <Map<String, dynamic>>[];
  for (final item in raw) {
    if (item is! Map) continue;
    final m = Map<String, dynamic>.from(item);
    if (isStatusEnvelope(m)) {
      statusValue = m['value']?.toString();
      statusMessage = m['message']?.toString();
    } else {
      dataRows.add(m);
    }
  }

  final isMutating = isMutatingParam(param);
  if (isMutating) {
    if (statusValue == null) {
      throw Exception('Invalid server response (missing status)');
    }
    if (statusValue != '1') {
      final list = dataRows.map(PostList.fromJson).toList();
      return PoFetchResult(
        list: list,
        serverMessage: statusMessage?.trim(),
        statusValue: statusValue,
      );
    }
  }

  final list = dataRows.map(PostList.fromJson).toList();
  return PoFetchResult(
    list: list,
    serverMessage: isMutating ? statusMessage?.trim() : null,
    statusValue: isMutating ? statusValue : null,
  );
}

bool isPoApiStatusEnvelope(Map<String, dynamic> map) {
  if (!map.containsKey('value') || !map.containsKey('message')) return false;
  return !map.containsKey('id_po');
}

bool isSoApiStatusEnvelope(Map<String, dynamic> map) {
  if (!map.containsKey('value') || !map.containsKey('message')) return false;
  return !map.containsKey('id_so');
}

bool isToolDetailApiStatusEnvelope(Map<String, dynamic> map) {
  if (!map.containsKey('value') || !map.containsKey('message')) return false;
  return !map.containsKey('id_form_detail');
}

bool isRcvWhApiStatusEnvelope(Map<String, dynamic> map) {
  if (!map.containsKey('value') || !map.containsKey('message')) return false;
  return !map.containsKey('id_rcv_wh');
}

bool isRcvToolApiStatusEnvelope(Map<String, dynamic> map) {
  if (!map.containsKey('value') || !map.containsKey('message')) return false;
  return !map.containsKey('id_rcv_tool');
}
