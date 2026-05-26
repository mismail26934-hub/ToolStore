import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tool_store_app/controller/api_url/api.dart';
import 'package:tool_store_app/model/api_client.dart';
import 'package:tool_store_app/view/var/var.dart';

Future<dynamic> login(String usernameApp, String passwordApp) async {
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
      throw Exception('Server Error: ${response.statusCode}');
    }
  } on DioException catch (e) {
    throw Exception(applyDioError(e));
  } on FormatException {
    throw Exception(serverDown);
  }
}

Future<SharedPreferences> writeSR(
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
  return SharedPreferences.getInstance();
}

Future<SharedPreferences> getPref() async {
  return SharedPreferences.getInstance();
}
