import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tool_store_app/controller/api_url/api.dart';
import 'package:tool_store_app/controller/api_url/post_list.dart';
import 'package:tool_store_app/controller/cont_crud/cont_function_crud.dart';
import 'package:tool_store_app/controller/cont_crud/redux/state.dart';
import 'package:tool_store_app/view/menu/login.dart';
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
      return [];
    }
  };
}

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
      print(listUser);
      print(usernameApp);
      print(passwordApp);
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
