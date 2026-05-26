import 'package:tool_store_app/controller/api_url/api.dart';
import 'package:tool_store_app/model/api_client.dart';
import 'package:tool_store_app/model/parsers/user_list_parser.dart';
import 'package:tool_store_app/view/var/var.dart';

/// Page size for user list lazy loading (matches PHP default in cont_user.php).
const int kUserPageSize = 20;

/// Larger fetch when the full user list is needed (dropdowns, app preload).
const int kUserFullFetchLimit = 1000;

Future<ParsedUserListResult> fetchUserList(Map<String, dynamic> body) async {
  final response = await apiPost(ApiUrl.contDataUser, body);
  return parseUserListResponse(response.data);
}

/// Fetches users for picker dialogs without updating Redux [UserState].
Future<ParsedUserListResult> fetchUsersForPicker({
  String keyword = '',
  String searchField = 'all',
  String levelFilter = '',
  int page = 1,
  int limit = kUserPageSize,
}) async {
  final body = <String, dynamic>{
    'param': paramViewDataUser,
    'username': '',
    'password': '',
    'nama_user': '',
    'foto': '',
    'id_tu': '',
    'no_telp': '',
    'token': '',
    'level': levelFilter.trim(),
    'status': '',
    'superior_id': '',
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
  return fetchUserList(body);
}
