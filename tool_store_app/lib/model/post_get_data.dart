import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tool_store_app/controller/api_url/api.dart';
import 'package:tool_store_app/controller/api_url/post_list.dart';
import 'package:tool_store_app/model/api_client.dart';
import 'package:tool_store_app/controller/cont_crud/redux/action.dart';
import 'package:tool_store_app/debug/agent_log.dart';
import 'package:tool_store_app/controller/cont_crud/redux/state.dart';
import 'package:tool_store_app/controller/cont_crud/redux/store.dart';
import 'package:tool_store_app/view/var/var.dart';

/// Page size for user list lazy loading (matches PHP default in cont_user.php).
const int kUserPageSize = 20;

/// Larger fetch when the full user list is needed (dropdowns, app preload).
const int kUserFullFetchLimit = 1000;

/// Preloads Redux data after login. Skips when no session token is stored.
Future<void> preloadAuthenticatedData() async {
  final creds = await loadAuthCredentials();
  if (!creds.isAuthenticated) return;

  store.dispatch(
    getDataUser(
      param: paramViewDataUser,
      idUsers: '',
      username: '',
      password: '',
      namaUser: '',
      foto: '',
      idTU: '',
      noTelp: '',
      token: creds.token,
      level: '',
      status: '',
      superiorId: '',
      limit: kUserFullFetchLimit,
    ),
  );

  store.dispatch(
    getDataTool(
      param: paramViewDataForm,
      idForm: '',
      formNo: '',
      formServName: '',
      formCheckBy: '',
      formDateCheckBy: '',
      formDateServName: '',
      formServComment: '',
      formSuperiorAprd: '',
      formSuperiorComment: '',
      formSadminComment: '',
      formMilestone: '',
      formStatusOrder: '',
      formSheadAprd: '',
      formSheadComment: '',
      fromDateUpdate: '',
      formUserUpdate: '',
    ),
  );

  store.dispatch(
    getDataToolDetail(
      param: paramViewDataTool,
      idFormDetail: '',
      idFrom: '',
      formComment: '',
      pnGroup: '',
      pnDesc: '',
      qty: '',
      explan: '',
      actionNote: '',
      valType: '',
      partValue: '',
      formDetailDate: '',
      formDetailUser: '',
    ),
  );

  store.dispatch(
    getDataPO(
      param: paramViewDataPO,
      idPO: '',
      idFormDetail: '',
      poNO: '',
      dateUpdatePO: '',
      userUpdatePO: '',
    ),
  );

  store.dispatch(
    getDataSO(
      param: paramViewDataSO,
      idSo: '',
      idFormDetail: '',
      so: '',
      eta: '',
      noteSo: '',
      dateUpdateSo: '',
      idUpdateSo: '',
    ),
  );

  store.dispatch(
    getDataSuperrior(
      param: paramViewDataSuperrior,
      superiorId: '',
      namaSuperior: '',
      statusSuperior: '',
      userIdInputSuperior: '',
      dateInputSuperior: '',
    ),
  );

  store.dispatch(
    getDataRcvWh(
      param: paramViewDataRcvWh,
      idRcvWh: '',
      idFormDetail: '',
      rcvWhDate: '',
      rcvWhIdInput: '',
      rcvWhDateInput: '',
    ),
  );

  store.dispatch(
    getDataRcvTool(
      param: paramViewDataRcvTool,
      idRcvTool: '',
      idFormDetail: '',
      rcvToolDate: '',
      rcvToolIdInput: '',
      rcvToolDateInput: '',
    ),
  );

  store.dispatch(getDashboardFormCounts());
}

/// Fetches users for picker dialogs without updating [UserState] in Redux.
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
  final response = await apiPost(ApiUrl.contDataUser, body);
  return parseUserListResponse(response.data);
}

// DATA USER
ThunkAction<AppState> getDataUser({
  required String param,
  required String idUsers,
  required String username,
  required String password,
  required String namaUser,
  required String foto,
  required String idTU,
  required String noTelp,
  required String token,
  required String level,
  required String status,
  required String superiorId,
  int page = 1,
  int limit = kUserPageSize,
  bool append = false,

  /// Server-side list filter for [paramViewDataUser] (sent as POST `keyword` / `search_field`).
  String viewKeyword = '',
  String viewSearchField = 'all',
}) {
  return (Store<AppState> store) async {
    final isView = param == paramViewDataUser;
    if (isView) {
      if (append) {
        store.dispatch(FetchUsersMoreAction());
      } else if (store.state.userState.users.isNotEmpty) {
        store.dispatch(FetchUsersRefreshAction());
      } else {
        store.dispatch(FetchUsersAction());
      }
    }
    final body = <String, dynamic>{
      'param': param,
      'username': username,
      'password': password,
      'nama_user': namaUser,
      'foto': foto,
      'id_tu': idTU,
      'no_telp': noTelp,
      'token': token,
      'level': level,
      'status': status,
      'superior_id': superiorId,
      'page': page.toString(),
      'limit': limit.toString(),
    };
    final idUsersTrim = idUsers.trim();
    if (idUsersTrim.isNotEmpty) {
      body['id_users'] = idUsersTrim;
    }
    final kw = viewKeyword.trim();
    if (isView && kw.isNotEmpty) {
      body['keyword'] = kw;
      body['search_field'] = viewSearchField.trim().isEmpty
          ? 'all'
          : viewSearchField.trim();
    }
    try {
      final response = await apiPost(ApiUrl.contDataUser, body);
      final parsed = parseUserListResponse(response.data);
      final listUser = parsed.items;
      final int? apiTotal = parsed.total;

      final bool hasMore;
      if (isView) {
        final mergedCount = append
            ? _mergeUsersPreview(store.state.userState.users, listUser).length
            : listUser.length;
        if (apiTotal != null) {
          hasMore = mergedCount < apiTotal;
        } else {
          hasMore = listUser.length >= limit;
        }
      } else {
        hasMore = false;
      }

      if (isView) {
        if (append) {
          store.dispatch(
            UsersAppendAction(listUser, hasMore: hasMore, totalUsers: apiTotal),
          );
        } else {
          store.dispatch(
            UsersLoadedAction(listUser, hasMore: hasMore, totalUsers: apiTotal),
          );
        }
      }
      return listUser;
    } on DioException catch (e) {
      final msg = applyDioError(e);
      if (isView) store.dispatch(UsersErrorAction(msg));
      throw Exception(msg);
    } catch (e) {
      if (isView) store.dispatch(UsersErrorAction(e.toString()));
      throw Exception(e);
    }
  };
}

/// Page size for tool form list lazy loading (matches PHP default in cont_form.php).
const int kToolFormPageSize = 20;

/// Larger fetch for dashboard milestone counts (legacy; dashboard uses COUNT API).
const int kToolFormDashboardFetchLimit = 1000;

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

/// COUNT milestone dashboard dari `cont_form.php` (param DASHBOARD COUNT FORM).
ThunkAction<AppState> getDashboardFormCounts() {
  return (Store<AppState> store) async {
    if (store.state.formsState.dashboardCounts != null) {
      store.dispatch(FetchDashboardCountsRefreshAction());
    } else {
      store.dispatch(FetchDashboardCountsAction());
    }
    try {
      final response = await apiPost(ApiUrl.contDataTool, {
        'param': paramDashboardCountForm,
      });
      final counts = parseDashboardCountsResponse(response.data);
      store.dispatch(DashboardCountsLoadedAction(counts));
      return counts;
    } on DioException catch (e) {
      final msg = applyDioError(e);
      store.dispatch(DashboardCountsErrorAction(errors));
      throw Exception(msg);
    } catch (e) {
      store.dispatch(DashboardCountsErrorAction(e.toString()));
      throw Exception(e);
    }
  };
}

// DATA TOOL
ThunkAction<AppState> getDataTool({
  required String param,
  required String idForm,
  required String formNo,
  required String formServName,
  required String formCheckBy,
  required String formDateCheckBy,
  required String formDateServName,
  required String formServComment,
  required String formSuperiorAprd,
  required String formSuperiorComment,
  required String formSadminComment,
  required String formMilestone,
  required String formStatusOrder,
  required String formSheadAprd,
  required String formSheadComment,
  required String fromDateUpdate,
  required String formUserUpdate,
  int page = 1,
  int limit = kToolFormPageSize,
  bool append = false,

  /// Server-side list filter for [paramViewDataForm] (POST `keyword` / `search_field`).
  String viewKeyword = '',
  String viewSearchField = 'all',
}) {
  return (Store<AppState> store) async {
    final isView = param == paramViewDataForm;
    if (isView) {
      if (append) {
        store.dispatch(FetchDatasMoreAction());
      } else if (store.state.formsState.forms.isNotEmpty) {
        store.dispatch(FetchDatasRefreshAction());
      } else {
        store.dispatch(FetchDatasAction());
      }
    }
    final body = <String, dynamic>{
      'param': param,
      'id_form': idForm,
      'form_no': formNo,
      'form_serv_name': formServName,
      'form_check_by': formCheckBy,
      'form_date_check_by': formDateCheckBy,
      'form_date_serv_name': formDateServName,
      'form_serv_comment': formServComment,
      'form_superior_aprd': formSuperiorAprd,
      'form_superior_comment': formSuperiorComment,
      'form_sadmin_comment': formSadminComment,
      'form_milestone': formMilestone,
      'form_status_order': formStatusOrder,
      'form_shead_aprd': formSheadAprd,
      'form_shead_comment': formSheadComment,
      'from_date_update': fromDateUpdate,
      'form_user_update': formUserUpdate,
      'page': page.toString(),
      'limit': limit.toString(),
    };
    final kw = viewKeyword.trim();
    if (isView && kw.isNotEmpty) {
      body['keyword'] = kw;
      body['search_field'] = viewSearchField.trim().isEmpty
          ? 'all'
          : viewSearchField.trim();
    }
    try {
      final response = await apiPost(ApiUrl.contDataTool, body);
      final parsed = parseFormListResponse(response.data);
      final listTool = parsed.items;
      final int? apiTotal = parsed.total;

      // #region agent log
      if (isView) {
        agentDebugLog(
          hypothesisId: 'C',
          location: 'post_get_data.dart:getDataTool',
          message: 'API view response',
          data: {
            'page': page,
            'limit': limit,
            'append': append,
            'itemsCount': listTool.length,
            'apiTotal': apiTotal,
            'viewKeyword': viewKeyword,
            'viewSearchField': viewSearchField,
            'sampleMilestones': listTool
                .take(5)
                .map((f) => f.formMilestone.trim())
                .toList(),
          },
        );
      }
      // #endregion

      final bool hasMore;
      if (isView) {
        final mergedCount = append
            ? _mergeFormsPreview(store.state.formsState.forms, listTool).length
            : listTool.length;
        if (apiTotal != null) {
          hasMore = mergedCount < apiTotal;
        } else {
          hasMore = listTool.length >= limit;
        }
      } else {
        hasMore = false;
      }

      if (isView) {
        if (append) {
          store.dispatch(
            DatasAppendAction(listTool, hasMore: hasMore, totalForms: apiTotal),
          );
        } else {
          store.dispatch(
            DatasLoadedAction(listTool, hasMore: hasMore, totalForms: apiTotal),
          );
        }
      }
      return listTool;
    } on DioException catch (e) {
      final msg = applyDioError(e);
      if (isView) store.dispatch(DatasErrorAction(msg));
      throw Exception(msg);
    } catch (e) {
      if (isView) store.dispatch(DatasErrorAction(e.toString()));
      throw Exception(e);
    }
  };
}

//responseBody All Class Get
List<PostList> parseResponse(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<PostList>((e) => PostList.fromJson(e)).toList();
}

List<PostList> _mergeFormsPreview(
  List<PostList> existing,
  List<PostList> incoming,
) {
  if (incoming.isEmpty) return existing;
  final ids = existing.map((f) => f.idForm.trim()).toSet();
  final merged = List<PostList>.from(existing);
  for (final form in incoming) {
    final id = form.idForm.trim();
    if (id.isEmpty || !ids.contains(id)) {
      merged.add(form);
      if (id.isNotEmpty) ids.add(id);
    }
  }
  return merged;
}

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
    final total = _readTotalFromMap(m);
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

List<PostList> _mergeUsersPreview(
  List<PostList> existing,
  List<PostList> incoming,
) {
  if (incoming.isEmpty) return existing;
  final ids = existing.map((u) => u.idUsers.trim()).toSet();
  final merged = List<PostList>.from(existing);
  for (final user in incoming) {
    final id = user.idUsers.trim();
    if (id.isEmpty || !ids.contains(id)) {
      merged.add(user);
      if (id.isNotEmpty) ids.add(id);
    }
  }
  return merged;
}

int? _readTotalFromMap(Map<String, dynamic> m) {
  for (final key in [
    'total',
    'total_users',
    'total_count',
    'recordsTotal',
    'count',
  ]) {
    if (!m.containsKey(key)) continue;
    final v = m[key];
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v.trim());
  }
  return null;
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
    final total = _readTotalFromMap(m);
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

// LOGIN
Future login(String usernameApp, String passwordApp) async {
  try {
    final response = await apiPost(ApiUrl.contLogin, {
      'param': 'LOGIN',
      'username': usernameApp.toString(),
      'password': passwordApp.toString(),
    }, attachAuth: false);
    if (response.statusCode == 200) {
      final listUser = response.data;
      if (listUser is String) {
        return jsonDecode(listUser);
      }
      return listUser;
    } else {
      throw Exception("Server Error: ${response.statusCode}");
    }
  } catch (e) {
    // Re-throw agar ditangkap oleh catch di onPressed (cekInternet)
    rethrow;
  }
}

Future writeSR(
  String value,
  String idUsers,
  String username,
  String password,
  String namaUser,
  String foto,
  String idTU,
  String noTelp,
  String token,
  String level,
  String status,
) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs;
}

Future getPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs;
}

// DATA DETAIL TOOL
ThunkAction<AppState> getDataToolDetail({
  required String param,
  required String idFormDetail,
  required String idFrom,
  required String formComment,
  required String pnGroup,
  required String pnDesc,
  required String qty,
  required String explan,
  required String actionNote,
  required String valType,
  required String partValue,
  required String formDetailDate,
  required String formDetailUser,
}) {
  return (Store<AppState> store) async {
    final isView = param == paramViewDataTool;
    if (isView && store.state.formsDetailState.formsDetail.isNotEmpty) {
      store.dispatch(FetchDataToolsRefreshAction());
    } else if (isView) {
      store.dispatch(FetchDataToolsAction());
    }
    final body = <String, dynamic>{
      'param': param,
      'id_form_detail': idFormDetail,
      'id_form': idFrom,
      'idFrom': idFrom,
      'idForm': idFrom,
      'form_comment': formComment,
      'pn_group': pnGroup,
      'pn_desc': pnDesc,
      'qty': qty,
      'explan': explan,
      'action_note': actionNote,
      'val_type': valType,
      'part_value': partValue,
      'form_detail_date': formDetailDate,
      'formDetailDate': formDetailDate,
      'form_detail_user': formDetailUser,
      'formDetailUser': formDetailUser,
    };

    try {
      final response = await apiPost(ApiUrl.contDataToolDetail, body);
      final ToolDetailFetchResult result = _parseToolDetailFetchResponse(
        response.data,
        param,
      );
      store.dispatch(DataToolsLoadedAction(result.list));
      return result;
    } on DioException catch (e) {
      final msg = applyDioError(e);
      store.dispatch(DataToolsErrorAction(errors));
      throw Exception(msg);
    } catch (e) {
      final msg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      store.dispatch(DataToolsErrorAction(msg));
      rethrow;
    }
  };
}

/// Result of [getDataPO]. PHP may append `{"value":"1","message":"..."}` for
/// ADD / EDIT / DELETE; that envelope must not be parsed as a [PostList] row.
class PoFetchResult {
  final List<PostList> list;

  /// Server `message` for ADD/EDIT/DELETE (`value` from envelope).
  final String? serverMessage;

  /// Envelope `value` when `param` is ADD/EDIT/DELETE; `'1'` means success.
  final String? statusValue;

  const PoFetchResult({
    required this.list,
    this.serverMessage,
    this.statusValue,
  });
}

/// Same shape as [PoFetchResult]; used by [getDataSO] for ADD/EDIT/DELETE envelopes.
typedef SoFetchResult = PoFetchResult;
typedef ToolDetailFetchResult = PoFetchResult;

List<dynamic> _decodeJsonArray(dynamic data) {
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

bool _isPoApiStatusEnvelope(Map<String, dynamic> map) {
  if (!map.containsKey('value') || !map.containsKey('message')) return false;
  return !map.containsKey('id_po');
}

bool _isSoApiStatusEnvelope(Map<String, dynamic> map) {
  if (!map.containsKey('value') || !map.containsKey('message')) return false;
  return !map.containsKey('id_so');
}

bool _isToolDetailApiStatusEnvelope(Map<String, dynamic> map) {
  if (!map.containsKey('value') || !map.containsKey('message')) return false;
  return !map.containsKey('id_form_detail');
}

PoFetchResult _parsePoFetchResponse(dynamic data, String param) {
  final raw = _decodeJsonArray(data);
  String? statusValue;
  String? statusMessage;
  final dataRows = <Map<String, dynamic>>[];
  for (final item in raw) {
    if (item is! Map) continue;
    final m = Map<String, dynamic>.from(item);
    if (_isPoApiStatusEnvelope(m)) {
      statusValue = m['value']?.toString();
      statusMessage = m['message']?.toString();
    } else {
      dataRows.add(m);
    }
  }

  final isMutating =
      param == paramAddDataPO ||
      param == paramEditDataPO ||
      param == paramDeleteDataPO;
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

SoFetchResult _parseSoFetchResponse(dynamic data, String param) {
  final raw = _decodeJsonArray(data);
  String? statusValue;
  String? statusMessage;
  final dataRows = <Map<String, dynamic>>[];
  for (final item in raw) {
    if (item is! Map) continue;
    final m = Map<String, dynamic>.from(item);
    if (_isSoApiStatusEnvelope(m)) {
      statusValue = m['value']?.toString();
      statusMessage = m['message']?.toString();
    } else {
      dataRows.add(m);
    }
  }

  final isMutating =
      param == paramAddDataSO ||
      param == paramEditDataSO ||
      param == paramDeleteDataSO;
  if (isMutating) {
    if (statusValue == null) {
      throw Exception('Invalid server response (missing status)');
    }
    if (statusValue != '1') {
      final list = dataRows.map(PostList.fromJson).toList();
      return SoFetchResult(
        list: list,
        serverMessage: statusMessage?.trim(),
        statusValue: statusValue,
      );
    }
  }

  final list = dataRows.map(PostList.fromJson).toList();
  return SoFetchResult(
    list: list,
    serverMessage: isMutating ? statusMessage?.trim() : null,
    statusValue: isMutating ? statusValue : null,
  );
}

ToolDetailFetchResult _parseToolDetailFetchResponse(
  dynamic data,
  String param,
) {
  final raw = _decodeJsonArray(data);
  String? statusValue;
  String? statusMessage;
  final dataRows = <Map<String, dynamic>>[];
  for (final item in raw) {
    if (item is! Map) continue;
    final m = Map<String, dynamic>.from(item);
    if (_isToolDetailApiStatusEnvelope(m)) {
      statusValue = m['value']?.toString();
      statusMessage = m['message']?.toString();
    } else {
      dataRows.add(m);
    }
  }

  final isMutating =
      param == paramAddDataTool ||
      param == paramEditDataTool ||
      param == paramDeleteDataTool;
  if (isMutating) {
    if (statusValue == null) {
      throw Exception('Invalid server response (missing status)');
    }
    if (statusValue != '1') {
      final list = dataRows.map(PostList.fromJson).toList();
      return ToolDetailFetchResult(
        list: list,
        serverMessage: statusMessage?.trim(),
        statusValue: statusValue,
      );
    }
  }

  final list = dataRows.map(PostList.fromJson).toList();
  return ToolDetailFetchResult(
    list: list,
    serverMessage: isMutating ? statusMessage?.trim() : null,
    statusValue: isMutating ? statusValue : null,
  );
}

typedef RcvWhFetchResult = PoFetchResult;
typedef RcvToolFetchResult = PoFetchResult;

bool _isRcvWhApiStatusEnvelope(Map<String, dynamic> map) {
  if (!map.containsKey('value') || !map.containsKey('message')) return false;
  return !map.containsKey('id_rcv_wh');
}

bool _isRcvToolApiStatusEnvelope(Map<String, dynamic> map) {
  if (!map.containsKey('value') || !map.containsKey('message')) return false;
  return !map.containsKey('id_rcv_tool');
}

RcvWhFetchResult _parseRcvWhFetchResponse(dynamic data, String param) {
  final raw = _decodeJsonArray(data);
  String? statusValue;
  String? statusMessage;
  final dataRows = <Map<String, dynamic>>[];
  for (final item in raw) {
    if (item is! Map) continue;
    final m = Map<String, dynamic>.from(item);
    if (_isRcvWhApiStatusEnvelope(m)) {
      statusValue = m['value']?.toString();
      statusMessage = m['message']?.toString();
    } else {
      dataRows.add(m);
    }
  }

  final isMutating =
      param == paramAddDataRcvWh ||
      param == paramEditDataRcvWh ||
      param == paramDeleteDataRcvWh;
  if (isMutating) {
    if (statusValue == null) {
      throw Exception('Invalid server response (missing status)');
    }
    if (statusValue != '1') {
      final list = dataRows.map(PostList.fromJson).toList();
      return RcvWhFetchResult(
        list: list,
        serverMessage: statusMessage?.trim(),
        statusValue: statusValue,
      );
    }
  }

  final list = dataRows.map(PostList.fromJson).toList();
  return RcvWhFetchResult(
    list: list,
    serverMessage: isMutating ? statusMessage?.trim() : null,
    statusValue: isMutating ? statusValue : null,
  );
}

RcvToolFetchResult _parseRcvToolFetchResponse(dynamic data, String param) {
  final raw = _decodeJsonArray(data);
  String? statusValue;
  String? statusMessage;
  final dataRows = <Map<String, dynamic>>[];
  for (final item in raw) {
    if (item is! Map) continue;
    final m = Map<String, dynamic>.from(item);
    if (_isRcvToolApiStatusEnvelope(m)) {
      statusValue = m['value']?.toString();
      statusMessage = m['message']?.toString();
    } else {
      dataRows.add(m);
    }
  }

  final isMutating =
      param == paramAddDataRcvTool ||
      param == paramEditDataRcvTool ||
      param == paramDeleteDataRcvTool;
  if (isMutating) {
    if (statusValue == null) {
      throw Exception('Invalid server response (missing status)');
    }
    if (statusValue != '1') {
      final list = dataRows.map(PostList.fromJson).toList();
      return RcvToolFetchResult(
        list: list,
        serverMessage: statusMessage?.trim(),
        statusValue: statusValue,
      );
    }
  }

  final list = dataRows.map(PostList.fromJson).toList();
  return RcvToolFetchResult(
    list: list,
    serverMessage: isMutating ? statusMessage?.trim() : null,
    statusValue: isMutating ? statusValue : null,
  );
}

// DATA PO
ThunkAction<AppState> getDataPO({
  required String param,
  required String idPO,
  required String idFormDetail,
  required String poNO,
  required String dateUpdatePO,
  required String userUpdatePO,
}) {
  return (Store<AppState> store) async {
    final isView = param == paramViewDataPO;
    if (isView && store.state.posDetailState.posDetail.isNotEmpty) {
      store.dispatch(FetchDataPORefresh());
    } else if (isView) {
      store.dispatch(FetchDataPO());
    }
    final body = <String, dynamic>{
      'param': param,
      'id_po': idPO,
      'id_form_detail': idFormDetail,
      'po_no': poNO,
      'date_update_po': dateUpdatePO,
      'user_update_po': userUpdatePO,
    };

    try {
      final response = await apiPost(ApiUrl.contPO, body);
      final PoFetchResult result = _parsePoFetchResponse(response.data, param);
      store.dispatch(DataPOLoadedAction(result.list));
      return result;
    } on DioException catch (e) {
      final msg = applyDioError(e);
      store.dispatch(DataPOErrorAction(errors));
      throw Exception(msg);
    } catch (e) {
      final msg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      store.dispatch(DataPOErrorAction(msg));
      rethrow;
    }
  };
}

// DATA SO
ThunkAction<AppState> getDataSO({
  required String param,
  required String idSo,
  required String idFormDetail,
  required String so,
  required String eta,
  required String noteSo,
  required String dateUpdateSo,
  required String idUpdateSo,
}) {
  return (Store<AppState> store) async {
    final isView = param == paramViewDataSO;
    if (isView && store.state.sosDetailState.sosDetail.isNotEmpty) {
      store.dispatch(FetchDataSORefresh());
    } else if (isView) {
      store.dispatch(FetchDataSO());
    }
    final body = <String, dynamic>{
      'param': param,
      'id_so': idSo,
      'id_form_detail': idFormDetail,
      'so': so,
      'eta': eta,
      'note_so': noteSo,
      'date_update_so': dateUpdateSo,
      'id_update_so': idUpdateSo,
    };

    try {
      final response = await apiPost(ApiUrl.contSO, body);
      final SoFetchResult result = _parseSoFetchResponse(response.data, param);
      // print('response.data: ${response.data}');
      store.dispatch(DataSOLoadedAction(result.list));
      return result;
    } on DioException catch (e) {
      final msg = applyDioError(e);
      store.dispatch(DataSOErrorAction(errors));
      throw Exception(msg);
    } catch (e) {
      final msg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      store.dispatch(DataSOErrorAction(msg));
      rethrow;
    }
  };
}

// DATA SUPERRIOR
ThunkAction<AppState> getDataSuperrior({
  required String param,
  required String superiorId,
  required String namaSuperior,
  required String statusSuperior,
  required String userIdInputSuperior,
  required String dateInputSuperior,
}) {
  return (Store<AppState> store) async {
    final isView = param == paramViewDataSuperrior;
    if (isView && store.state.superriorState.superriorS.isNotEmpty) {
      store.dispatch(FetchDataSuperriorRefresh());
    } else if (isView) {
      store.dispatch(FetchDataSuperrior());
    }
    final body = <String, dynamic>{
      'param': param,
      'superior_id': superiorId,
      'nama_superior': namaSuperior,
      'status_superior': statusSuperior,
      'user_id_input_superior': userIdInputSuperior,
      'date_input_superior': dateInputSuperior,
    };

    try {
      final response = await apiPost(ApiUrl.contSuperrior, body);
      List<PostList> listSuperrior = parseResponse(response.data);
      // print(response.data);
      // Dispatch ke store (Redux)
      store.dispatch(DataSuperriorLoadedAction(listSuperrior));
      return listSuperrior;
    } on DioException catch (e) {
      applyDioError(e);
      store.dispatch(DataSuperriorErrorAction(errors));
      return [];
    } catch (e) {
      return [];
    }
  };
}

// DATA RCV WH
ThunkAction<AppState> getDataRcvWh({
  required String param,
  required String idRcvWh,
  required String idFormDetail,
  required String rcvWhDate,
  required String rcvWhIdInput,
  required String rcvWhDateInput,
}) {
  return (Store<AppState> store) async {
    final isView = param == paramViewDataRcvWh;
    if (isView && store.state.rcvWhState.rcvWhs.isNotEmpty) {
      store.dispatch(FetchDataRcvWhRefresh());
    } else if (isView) {
      store.dispatch(FetchDataRcvWh());
    }
    final body = <String, dynamic>{
      'param': param,
      'id_rcv_wh': idRcvWh,
      'id_form_detail': idFormDetail,
      'rcv_wh_date': rcvWhDate,
      'rcv_wh_id_input': rcvWhIdInput,
      'rcv_wh_date_input': rcvWhDateInput,
    };

    try {
      final response = await apiPost(ApiUrl.contRcvWh, body);
      final RcvWhFetchResult result = _parseRcvWhFetchResponse(
        response.data,
        param,
      );
      store.dispatch(DataRcvWhLoadedAction(result.list));
      return result;
    } on DioException catch (e) {
      final msg = applyDioError(e);
      store.dispatch(DataRcvWhErrorAction(errors));
      throw Exception(msg);
    } catch (e) {
      final msg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      store.dispatch(DataRcvWhErrorAction(msg));
      rethrow;
    }
  };
}

// DATA RCV TOOL
ThunkAction<AppState> getDataRcvTool({
  required String param,
  required String idRcvTool,
  required String idFormDetail,
  required String rcvToolDate,
  required String rcvToolIdInput,
  required String rcvToolDateInput,
}) {
  return (Store<AppState> store) async {
    final isView = param == paramViewDataRcvTool;
    if (isView && store.state.rcvToolState.rcvTools.isNotEmpty) {
      store.dispatch(FetchDataRcvToolRefresh());
    } else if (isView) {
      store.dispatch(FetchDataRcvTool());
    }
    final body = <String, dynamic>{
      'param': param,
      'id_rcv_tool': idRcvTool,
      'id_form_detail': idFormDetail,
      'rcv_tool_date': rcvToolDate,
      'rcv_tool_id_input': rcvToolIdInput,
      'rcv_tool_date_input': rcvToolDateInput,
    };

    try {
      final response = await apiPost(ApiUrl.contRcvTool, body);
      final RcvToolFetchResult result = _parseRcvToolFetchResponse(
        response.data,
        param,
      );
      store.dispatch(DataRcvToolLoadedAction(result.list));
      return result;
    } on DioException catch (e) {
      final msg = applyDioError(e);
      store.dispatch(DataRcvToolErrorAction(errors));
      throw Exception(msg);
    } catch (e) {
      final msg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      store.dispatch(DataRcvToolErrorAction(msg));
      rethrow;
    }
  };
}
