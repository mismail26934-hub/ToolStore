import 'package:tool_store_app/controller/api_url/api.dart';
import 'package:tool_store_app/model/api_client.dart';
import 'package:tool_store_app/model/parsers/user_list_parser.dart';
import 'package:tool_store_app/model/repositories/user_repository.dart';
import 'package:tool_store_app/view/var/var.dart';

Future<ParsedUserListResult> fetchSuperiorList(
  Map<String, dynamic> body,
) async {
  final response = await apiPost(ApiUrl.contSuperrior, body);
  return parseSuperiorListResponse(response.data);
}

/// Fetches superiors for picker dialogs without updating Redux [SuperriorState].
Future<ParsedUserListResult> fetchSuperiorsForPicker({
  String keyword = '',
  String searchField = 'all',
  int page = 1,
  int limit = kUserPageSize,
}) async {
  final body = <String, dynamic>{
    'param': paramViewDataSuperrior,
    'superior_id': '',
    'nama_superior': '',
    'status_superior': '',
    'user_id_input_superior': '',
    'date_input_superior': '',
    'page': page.toString(),
    'limit': limit.toString(),
  };
  final kw = keyword.trim();
  if (kw.isNotEmpty) {
    body['keyword'] = kw;
    body['search_field'] = searchField.trim().isEmpty
        ? 'all'
        : searchField.trim();
  }
  return fetchSuperiorList(body);
}
