import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists and broadcasts Indonesian / English locale changes app-wide.
class LocaleController extends ChangeNotifier {
  LocaleController._();

  static final LocaleController instance = LocaleController._();

  static const prefKey = 'app_locale_code';
  static const defaultCode = 'id';

  static const Locale localeId = Locale('id');
  static const Locale localeEn = Locale('en');

  Locale _locale = localeId;

  Locale get locale => _locale;

  String get languageCode => _locale.languageCode;

  bool get isEnglish => _locale.languageCode == 'en';

  bool get isIndonesian => !isEnglish;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _locale = _localeFromCode(prefs.getString(prefKey));
    notifyListeners();
  }

  Future<void> setEnglish(bool enabled) async {
    final next = enabled ? localeEn : localeId;
    if (_locale == next) return;
    _locale = next;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefKey, next.languageCode);
  }

  Future<void> toggle() => setEnglish(!isEnglish);

  static Locale _localeFromCode(String? code) {
    if (code == 'en') return localeEn;
    return localeId;
  }

  /// Keeps locale preference when login data is cleared on logout.
  static Future<void> preserveOnPrefsClear(SharedPreferences prefs) async {
    final code = prefs.getString(prefKey) ?? defaultCode;
    await prefs.setString(prefKey, code);
    await instance.load();
  }
}
