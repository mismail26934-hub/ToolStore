import 'dart:convert';

import 'package:tool_store_app/controller/api_url/post_list.dart';
import 'package:tool_store_app/model/parsers/list_total_utils.dart';

/// Hasil parse list user dari `cont_user.php`.
///
/// **Format lama (tetap didukung):** body JSON berupa array `[{...}, ...]`.
///
/// **Format disarankan (pagination + total):** objek JSON, misalnya:
/// `{"total": 150, "data": [{...}, ...]}` — kunci array boleh salah satu dari
/// `data`, `rows`, `users`, `records`; kunci total boleh `total`, `total_users`,
/// `total_count`, `recordsTotal`, `count`.
class ParsedUserListResult {
  final List<PostList> items;
  final int? total;

  const ParsedUserListResult(this.items, this.total);
}

/// Mem-parse respons [cont_user.php] baik berupa array maupun objek dengan `total`.
ParsedUserListResult parseUserListResponse(dynamic responseBody) {
  final dynamic decoded = responseBody is String
      ? jsonDecode(responseBody)
      : responseBody;

  if (decoded is List) {
    final list = decoded
        .map((e) => PostList.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return ParsedUserListResult(list, null);
  }

  if (decoded is Map) {
    final m = Map<String, dynamic>.from(decoded);
    final total = readTotalFromMap(m);
    for (final key in ['data', 'rows', 'users', 'records']) {
      final v = m[key];
      if (v is List) {
        final list = <PostList>[];
        for (final e in v) {
          if (e is Map) {
            list.add(PostList.fromJson(Map<String, dynamic>.from(e)));
          }
        }
        return ParsedUserListResult(list, total);
      }
    }
    return ParsedUserListResult([], total);
  }

  throw FormatException(
    'Unexpected user list response: ${decoded.runtimeType}',
  );
}

/// Mem-parse respons [cont_superior] baik berupa array maupun objek dengan `total`.
ParsedUserListResult parseSuperiorListResponse(dynamic responseBody) {
  final dynamic decoded = responseBody is String
      ? jsonDecode(responseBody)
      : responseBody;

  if (decoded is List) {
    final list = decoded
        .map((e) => PostList.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return ParsedUserListResult(list, null);
  }

  if (decoded is Map) {
    final m = Map<String, dynamic>.from(decoded);
    final total = readTotalFromMap(m);
    for (final key in ['data', 'rows', 'superiors', 'users', 'records']) {
      final v = m[key];
      if (v is List) {
        final list = <PostList>[];
        for (final e in v) {
          if (e is Map) {
            list.add(PostList.fromJson(Map<String, dynamic>.from(e)));
          }
        }
        return ParsedUserListResult(list, total);
      }
    }
    return ParsedUserListResult([], total);
  }

  throw FormatException(
    'Unexpected superior list response: ${decoded.runtimeType}',
  );
}
