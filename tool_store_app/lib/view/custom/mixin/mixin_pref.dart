import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tool_store_app/view/custom/routes/page_routes.dart'
    show PageRoutes;
// Import file var.dart Anda agar variabel global terbaca
import 'package:tool_store_app/view/var/var.dart';

mixin MixinPref<T extends StatefulWidget> on State<T> {
  Future<void> refreshPref() async {
    final preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      value = preferences.getString('value') ?? "";
      idUsersApp = preferences.getString('idUsersApp') ?? "";
      name = preferences.getString('name') ?? "";
      usernamePref = preferences.getString('username') ?? "";
      passwordPref = preferences.getString('password') ?? "";
      address = preferences.getString('address') ?? "";
      level = preferences.getString('level') ?? "";
      email = preferences.getString('email') ?? "";
      noTelp = preferences.getString('noTelp') ?? "";
      token = preferences.getString('token') ?? "";
      idTu = preferences.getString('idTu') ?? "";
      foto = preferences.getString('foto') ?? "";
      status = preferences.getString('status') ?? "";
    });
  }
}
