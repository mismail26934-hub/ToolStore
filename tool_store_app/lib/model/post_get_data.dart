import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:tool_store_app/controller/api_url/api.dart';
import 'package:tool_store_app/controller/api_url/post_list.dart';
import 'package:tool_store_app/controller/cont_crud/cont_function_crud.dart';
import 'package:tool_store_app/controller/cont_crud/redux/store.dart';
import 'package:tool_store_app/view/var/var.dart';

class PostData {
  static Future<List<PostList>> getDataUser(
    String param,
    idUsers,
    username,
    password,
    namaUser,
    foto,
    idTU,
    noTelp,
    token,
    level,
    status,
  ) async {
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
  }

  static List<PostList> parseResponse(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<PostList>((e) => PostList.fromJson(e)).toList();
  }
}
