import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tool_store_app/view/menu/home/home.dart';
import 'package:tool_store_app/view/menu/splash_login/login.dart';
import 'package:tool_store_app/view/menu/tooll/tool_form_multiple_input.dart';
import 'package:tool_store_app/view/menu/user/user_data.dart';
import 'package:tool_store_app/view/menu/user/user_form.dart';

class PageRoutes {
  // Gunakan void karena kita tidak perlu menunggu hasil dari Timer/Route
  static Future<void> routeLogin(BuildContext context) async {
    // Cek apakah context masih aktif/valid di layar
    if (!context.mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const Login(),
        transitionDuration: const Duration(
          milliseconds: 2000,
        ), // Durasi lebih lama agar smooth
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Efek memudar (Fade)
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  static Future<void> routeHome(BuildContext context) async {
    await Future.delayed(const Duration(milliseconds: 1));

    // Cek apakah context masih aktif/valid di layar
    if (!context.mounted) return;

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const Home()));
  }

  static Future<void> routeUser(BuildContext context) async {
    await Future.delayed(const Duration(milliseconds: 1));

    // Cek apakah context masih aktif/valid di layar
    if (!context.mounted) return;

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const UserData()));
  }

  static Future<void> routeLoginFast(BuildContext context) async {
    await Future.delayed(const Duration(milliseconds: 1));

    // Cek apakah context masih aktif/valid di layar
    if (!context.mounted) return;

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const Login()));
  }

  static Future<void> routeUserForm(
    BuildContext context,
    titles,
    onPressTailing,
  ) async {
    await Future.delayed(const Duration(milliseconds: 1));

    // Cek apakah context masih aktif/valid di layar
    if (!context.mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UserForm(title: titles, onPressTailing: onPressTailing),
      ),
    );
  }

  static Future<void> routeUserFormDetail(
    BuildContext context,
    subtitle,
  ) async {
    await Future.delayed(const Duration(milliseconds: 1));

    // Cek apakah context masih aktif/valid di layar
    if (!context.mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ToolFormMultipleInput(subtitle: subtitle),
      ),
    );
  }
}
