import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tool_store_app/controller/api_url/api.dart';
import 'package:tool_store_app/controller/api_url/post_list.dart';
import 'package:tool_store_app/controller/cont_crud/redux/action.dart';
import 'package:tool_store_app/controller/cont_crud/redux/state.dart';
import 'package:tool_store_app/view/var/var.dart';

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
}) {
  return (Store<AppState> store) async {
    store.dispatch(FetchUsersAction());
    var map = FormData.fromMap({
      'param': param,
      'id_users': idUsers,
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
    });

    var dio = Dio();
    try {
      dio.options.connectTimeout = const Duration(seconds: 20);
      dio.options.receiveTimeout = const Duration(seconds: 20);
      final response = await dio.post(ApiUrl.contDataUser, data: map);
      List<PostList> listUser = parseResponse(response.data);
      // Dispatch ke store (Redux)
      store.dispatch(UsersLoadedAction(listUser));
      return listUser;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.error is SocketException ||
          e.type == DioExceptionType.connectionTimeout) {
        // Anda bisa melempar error agar ditangkap oleh UI (FutureBuilder/Provider)
        errors = cekInternet;
        messages = "(${e.message})";
        store.dispatch(UsersErrorAction(errors));
        throw Exception(cekInternet);
      } else {
        errors = serverDown;
        messages = "(${e.message})";
        store.dispatch(UsersErrorAction(errors));
        throw Exception("Server Down ($messages)");
      }
    } catch (e) {
      // Pastikan kirim action error agar state.isLoading jadi false
      store.dispatch(UsersErrorAction(e.toString()));
      // Lempar error agar RefreshIndicator tahu ini sudah selesai
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
}) {
  return (Store<AppState> store) async {
    store.dispatch(FetchDatasAction());
    var map = FormData.fromMap({
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
    });

    var dio = Dio();
    try {
      dio.options.connectTimeout = const Duration(seconds: 20);
      dio.options.receiveTimeout = const Duration(seconds: 20);
      final response = await dio.post(ApiUrl.contDataTool, data: map);
      List<PostList> listTool = parseResponse(response.data);
      // Dispatch ke store (Redux)
      store.dispatch(DatasLoadedAction(listTool));
      return listTool;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.error is SocketException ||
          e.type == DioExceptionType.connectionTimeout) {
        // Anda bisa melempar error agar ditangkap oleh UI (FutureBuilder/Provider)
        errors = cekInternet;
        messages = "(${e.message})";
        store.dispatch(DatasErrorAction(errors));
        throw Exception(cekInternet);
      } else {
        errors = serverDown;
        messages = "(${e.message})";
        store.dispatch(DatasErrorAction(errors));
        throw Exception("Server Down ($messages)");
      }
    } catch (e) {
      // Pastikan kirim action error agar state.isLoading jadi false
      store.dispatch(DatasErrorAction(e.toString()));
      // Lempar error agar RefreshIndicator tahu ini sudah selesai
      throw Exception(e);
    }
  };
}

//responseBody All Class Get
List<PostList> parseResponse(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<PostList>((e) => PostList.fromJson(e)).toList();
}

// LOGIN
Future login(String usernameApp, String passwordApp) async {
  try {
    var map = FormData.fromMap({
      'param': 'LOGIN',
      'username': usernameApp.toString(),
      'password': passwordApp.toString(),
    });
    var dio = Dio();
    final response = await dio.post(ApiUrl.contLogin, data: map);
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
    store.dispatch(FetchDataToolsAction());
    var map = FormData.fromMap({
      'param': param,
      'id_form_detail': idFormDetail,
      'id_form': idFrom,
      'form_comment': formComment,
      'pn_group': pnGroup,
      'pn_desc': pnDesc,
      'qty': qty,
      'explan': explan,
      'action_note': actionNote,
      'val_type': valType,
      'part_value': partValue,
      'form_detail_date': formDetailDate,
      'form_detail_user': formDetailUser,
    });

    var dio = Dio();
    try {
      dio.options.connectTimeout = const Duration(seconds: 20);
      dio.options.receiveTimeout = const Duration(seconds: 20);
      final response = await dio.post(ApiUrl.contDataToolDetail, data: map);
      final ToolDetailFetchResult result = _parseToolDetailFetchResponse(
        response.data,
        param,
      );
      store.dispatch(DataToolsLoadedAction(result.list));
      return result;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.error is SocketException ||
          e.type == DioExceptionType.connectionTimeout) {
        // Anda bisa melempar error agar ditangkap oleh UI (FutureBuilder/Provider)
        errors = cekInternet;
        messages = "(${e.message})";
        store.dispatch(DataToolsErrorAction(errors));
        throw Exception(cekInternet);
      } else {
        errors = serverDown;
        messages = "(${e.message})";
        store.dispatch(DataToolsErrorAction(errors));
        throw Exception("Server Down ($messages)");
      }
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
    store.dispatch(FetchDataPO());
    var map = FormData.fromMap({
      'param': param,
      'id_po': idPO,
      'id_form_detail': idFormDetail,
      'po_no': poNO,
      'date_update_po': dateUpdatePO,
      'user_update_po': userUpdatePO,
    });

    var dio = Dio();
    try {
      dio.options.connectTimeout = const Duration(seconds: 20);
      dio.options.receiveTimeout = const Duration(seconds: 20);
      final response = await dio.post(ApiUrl.contPO, data: map);
      final PoFetchResult result = _parsePoFetchResponse(response.data, param);
      store.dispatch(DataPOLoadedAction(result.list));
      return result;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.error is SocketException ||
          e.type == DioExceptionType.connectionTimeout) {
        // Anda bisa melempar error agar ditangkap oleh UI (FutureBuilder/Provider)
        errors = cekInternet;
        messages = "(${e.message})";
        store.dispatch(DataPOErrorAction(errors));
        throw Exception(cekInternet);
      } else {
        errors = serverDown;
        messages = "(${e.message})";
        store.dispatch(DataPOErrorAction(errors));
        throw Exception("Server Down ($messages)");
      }
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
    store.dispatch(FetchDataSO());
    var map = FormData.fromMap({
      'param': param,
      'id_so': idSo,
      'id_form_detail': idFormDetail,
      'so': so,
      'eta': eta,
      'note_so': noteSo,
      'date_update_so': dateUpdateSo,
      'id_update_so': idUpdateSo,
    });

    var dio = Dio();
    try {
      dio.options.connectTimeout = const Duration(seconds: 20);
      dio.options.receiveTimeout = const Duration(seconds: 20);
      final response = await dio.post(ApiUrl.contSO, data: map);
      final SoFetchResult result = _parseSoFetchResponse(response.data, param);
      store.dispatch(DataSOLoadedAction(result.list));
      return result;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.error is SocketException ||
          e.type == DioExceptionType.connectionTimeout) {
        // Anda bisa melempar error agar ditangkap oleh UI (FutureBuilder/Provider)
        errors = cekInternet;
        messages = "(${e.message})";
        store.dispatch(DataSOErrorAction(errors));
        throw Exception(cekInternet);
      } else {
        errors = serverDown;
        messages = "(${e.message})";
        store.dispatch(DataSOErrorAction(errors));
        throw Exception("Server Down ($messages)");
      }
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
    store.dispatch(FetchDataSuperrior());
    var map = FormData.fromMap({
      'param': param,
      'superior_id': superiorId,
      'nama_superior': namaSuperior,
      'status_superior': statusSuperior,
      'user_id_input_superior': userIdInputSuperior,
      'date_input_superior': dateInputSuperior,
    });

    var dio = Dio();
    try {
      dio.options.connectTimeout = const Duration(seconds: 20);
      dio.options.receiveTimeout = const Duration(seconds: 20);
      final response = await dio.post(ApiUrl.contSuperrior, data: map);
      List<PostList> listSuperrior = parseResponse(response.data);
      // print(response.data);
      // Dispatch ke store (Redux)
      store.dispatch(DataSuperriorLoadedAction(listSuperrior));
      return listSuperrior;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.error is SocketException ||
          e.type == DioExceptionType.connectionTimeout) {
        // Anda bisa melempar error agar ditangkap oleh UI (FutureBuilder/Provider)
        errors = cekInternet;
        messages = "(${e.message})";
        store.dispatch(DataSuperriorErrorAction(errors));
        throw Exception(cekInternet);
      } else {
        errors = serverDown;
        messages = "(${e.message})";
        store.dispatch(DataSuperriorErrorAction(errors));
        throw Exception("Server Down ($messages)");
      }
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
    store.dispatch(FetchDataRcvWh());
    var map = FormData.fromMap({
      'param': param,
      'id_rcv_wh': idRcvWh,
      'id_form_detail': idFormDetail,
      'rcv_wh_date': rcvWhDate,
      'rcv_wh_id_input': rcvWhIdInput,
      'rcv_wh_date_input': rcvWhDateInput,
    });

    var dio = Dio();
    try {
      dio.options.connectTimeout = const Duration(seconds: 20);
      dio.options.receiveTimeout = const Duration(seconds: 20);
      final response = await dio.post(ApiUrl.contRcvWh, data: map);
      final RcvWhFetchResult result = _parseRcvWhFetchResponse(
        response.data,
        param,
      );
      store.dispatch(DataRcvWhLoadedAction(result.list));
      return result;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.error is SocketException ||
          e.type == DioExceptionType.connectionTimeout) {
        // Anda bisa melempar error agar ditangkap oleh UI (FutureBuilder/Provider)
        errors = cekInternet;
        messages = "(${e.message})";
        store.dispatch(DataRcvWhErrorAction(errors));
        throw Exception(cekInternet);
      } else {
        errors = serverDown;
        messages = "(${e.message})";
        store.dispatch(DataRcvWhErrorAction(errors));
        throw Exception("Server Down ($messages)");
      }
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
    store.dispatch(FetchDataRcvTool());
    var map = FormData.fromMap({
      'param': param,
      'id_rcv_tool': idRcvTool,
      'id_form_detail': idFormDetail,
      'rcv_tool_date': rcvToolDate,
      'rcv_tool_id_input': rcvToolIdInput,
      'rcv_tool_date_input': rcvToolDateInput,
    });

    var dio = Dio();
    try {
      dio.options.connectTimeout = const Duration(seconds: 20);
      dio.options.receiveTimeout = const Duration(seconds: 20);
      final response = await dio.post(ApiUrl.contRcvTool, data: map);
      final RcvToolFetchResult result = _parseRcvToolFetchResponse(
        response.data,
        param,
      );
      store.dispatch(DataRcvToolLoadedAction(result.list));
      return result;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.error is SocketException ||
          e.type == DioExceptionType.connectionTimeout) {
        // Anda bisa melempar error agar ditangkap oleh UI (FutureBuilder/Provider)
        errors = cekInternet;
        messages = "(${e.message})";
        store.dispatch(DataRcvToolErrorAction(errors));
        throw Exception(cekInternet);
      } else {
        errors = serverDown;
        messages = "(${e.message})";
        store.dispatch(DataRcvToolErrorAction(errors));
        throw Exception("Server Down ($messages)");
      }
    } catch (e) {
      final msg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      store.dispatch(DataRcvToolErrorAction(msg));
      rethrow;
    }
  };
}
