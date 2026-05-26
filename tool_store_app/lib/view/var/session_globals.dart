import 'package:flutter/material.dart';
import 'package:tool_store_app/l10n/app_strings.dart';

String errors = "";
String messages = "";
String get cekInternet => AppStrings.current.checkInternet;
String get serverDown => AppStrings.current.serverDown;
String get sessionExpired => AppStrings.current.sessionExpired;
String titleApp = "";
String usernameApp = "";
String passwordApp = "";
String messageLogin = "";
String valueLogin = "";

String value = "";
String idUsersApp = "";
String name = "";
String usernamePref = "";
String passwordPref = "";
String address = "";
String level = "";
String email = "";
String noTelp = "";
String token = "";
String idTu = "";
String status = "";
String foto = "";
String superiorId = "";
String namaSuperior = "";

final formKey = GlobalKey<FormState>();
bool isLoadingLogin = true;
bool loadingLogin = false;
bool expandeds = true;
bool isExpanded = true;

final username = TextEditingController();
final password = TextEditingController();
