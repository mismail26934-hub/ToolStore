import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:tool_store_app/controller/api_url/api.dart';
import 'package:tool_store_app/controller/api_url/post_list.dart';

class PostData {
  static Future<List<PostList>> getDataUser(
    param,
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
    final response = await dio.post(ApiUrl.contDataUser, data: map);
    List<PostList> listUser = parseResponse(response.data);
    print(response.data);
    return listUser;
  }

  static List<PostList> parseResponse(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<PostList>((e) => PostList.fromJson(e)).toList();
  }
}
