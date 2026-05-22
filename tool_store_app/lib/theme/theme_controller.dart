import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tool_store_app/l10n/locale_controller.dart';

/// Persists and broadcasts light / dark theme changes app-wide.
class ThemeController extends ChangeNotifier {
  ThemeController._();

  static final ThemeController instance = ThemeController._();

  static const prefKey = 'is_dark_mode';

  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(prefKey) ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> setDarkMode(bool enabled) async {
    final next = enabled ? ThemeMode.dark : ThemeMode.light;
    if (_themeMode == next) return;
    _themeMode = next;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefKey, enabled);
  }

  Future<void> toggle() => setDarkMode(!isDarkMode);

  /// Keeps theme and locale preferences when login data is cleared on logout.
  static Future<void> preserveOnPrefsClear(SharedPreferences prefs) async {
    final isDark = prefs.getBool(prefKey) ?? false;
    final localeCode =
        prefs.getString(LocaleController.prefKey) ?? LocaleController.defaultCode;
    await prefs.clear();
    await prefs.setBool(prefKey, isDark);
    await prefs.setString(LocaleController.prefKey, localeCode);
    await instance.load();
    await LocaleController.instance.load();
  }
}
