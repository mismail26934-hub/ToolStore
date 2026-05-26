import 'dart:convert';

import 'package:tool_store_app/controller/api_url/post_list.dart';
import 'package:tool_store_app/model/parsers/list_total_utils.dart';

/// Hasil parse list form dari `cont_form.php`.
class ParsedFormListResult {
  final List<PostList> items;
  final int? total;

  const ParsedFormListResult(this.items, this.total);
}

/// Mem-parse respons [cont_form.php] baik berupa array maupun objek dengan `total`.
ParsedFormListResult parseFormListResponse(dynamic responseBody) {
  final dynamic decoded = responseBody is String
      ? jsonDecode(responseBody)
      : responseBody;

  if (decoded is List) {
    final list = decoded
        .map((e) => PostList.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return ParsedFormListResult(list, null);
  }

  if (decoded is Map) {
    final m = Map<String, dynamic>.from(decoded);
    final total = readTotalFromMap(m);
    for (final key in ['data', 'rows', 'forms', 'records']) {
      final v = m[key];
      if (v is List) {
        final list = <PostList>[];
        for (final e in v) {
          if (e is Map) {
            list.add(PostList.fromJson(Map<String, dynamic>.from(e)));
          }
        }
        return ParsedFormListResult(list, total);
      }
    }
    return ParsedFormListResult([], total);
  }

  throw FormatException(
    'Unexpected form list response: ${decoded.runtimeType}',
  );
}
