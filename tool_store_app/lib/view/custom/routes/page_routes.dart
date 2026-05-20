import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tool_store_app/view/menu/dashboard/dashboard.dart';
import 'package:tool_store_app/view/menu/home/home.dart';
import 'package:tool_store_app/view/menu/splash_login/login.dart';
import 'package:tool_store_app/view/menu/tooll/tool_data.dart';
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

    final prefs = await SharedPreferences.getInstance();
    if (!context.mounted) return;

    final lvl = (prefs.getString('level') ?? '').trim().toUpperCase();
    if (lvl != 'SUPERADMIN') {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Akses ditolak. Menu User hanya untuk pengguna level SUPERADMIN.',
          ),
        ),
      );
      return;
    }

    if (!context.mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const UserData()));
  }

  static Future<void> routeTool(
    BuildContext context, {
    String? title,
    String? formMilestoneFilter,
    List<String> formMilestoneFilters = const <String>[],
    bool excludeFormMilestoneFilter = false,
    List<String> excludeFormMilestoneFilters = const <String>[],
    bool filterBlankFormMilestone = false,
    String? initialSearchQuery,
    String initialSearchField = 'all',
  }) async {
    await Future.delayed(const Duration(milliseconds: 1));
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            ToolData(
              title: title,
              formMilestoneFilter: formMilestoneFilter,
              formMilestoneFilters: formMilestoneFilters,
              excludeFormMilestoneFilter: excludeFormMilestoneFilter,
              excludeFormMilestoneFilters: excludeFormMilestoneFilters,
              filterBlankFormMilestone: filterBlankFormMilestone,
              initialSearchQuery: initialSearchQuery,
              initialSearchField: initialSearchField,
            ),
      ),
    );
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
    onPressTailing, {
    bool levelReadOnly = false,
    bool popOnSuccess = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1));

    // Cek apakah context masih aktif/valid di layar
    if (!context.mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UserForm(
          title: titles,
          onPressTailing: onPressTailing,
          levelReadOnly: levelReadOnly,
          popOnSuccess: popOnSuccess,
        ),
      ),
    );
  }

  static Future<void> routeUserFormDetail(
    BuildContext context,
    String subtitle, {
    String parentIdForm = '',
  }) async {
    await Future.delayed(const Duration(milliseconds: 1));
    // Cek apakah context masih aktif/valid di layar
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ToolFormMultipleInput(
          subtitle: subtitle,
          parentIdForm: parentIdForm,
        ),
      ),
    );
  }

  static Future<void> routeDashboard(BuildContext context, subtitle) async {
    await Future.delayed(const Duration(milliseconds: 1));
    // Cek apakah context masih aktif/valid di layar
    if (!context.mounted) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => Dashboard()));
  }

  static Future<void> routeDashboards(BuildContext context) async {
    // Cek apakah context masih aktif/valid di layar
    if (!context.mounted) return;

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const Dashboard(),
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
}
