import 'dart:convert';

import 'package:tool_store_app/controller/api_url/post_list.dart';

/// Legacy parser: JSON array of row maps → [PostList].
List<PostList> parseResponse(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<PostList>((e) => PostList.fromJson(e)).toList();
}
