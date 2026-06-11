import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter/services.dart';
import 'package:tool_store_app/controller/cont_crud/redux/state.dart';
import 'package:tool_store_app/controller/cont_crud/redux/store.dart';
import 'package:tool_store_app/l10n/locale_controller.dart';
import 'package:tool_store_app/theme/app_theme.dart';
import 'package:tool_store_app/theme/theme_controller.dart';
import 'package:tool_store_app/view/custom/mixin/mixin_pref.dart';
import 'package:tool_store_app/view/custom/web_custom/web_custom_berhaviour.dart';
import 'package:tool_store_app/services/form_deep_link.dart';
import 'package:tool_store_app/services/push_notification_service.dart';
import 'package:tool_store_app/view/menu/splash_login/splash.dart';
import 'package:tool_store_app/view/var/var.dart';
import 'package:tool_store_app/navigation/root_navigator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await themeController.load();
  await localeController.load();
  await FormDeepLinkService.instance.initialize();

  runApp(const MyApp());

  // Firebase + local notifications after first frame so Android can draw UI.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(PushNotificationService.instance.initialize());
  });

  unawaited(
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with MixinPref {
  @override
  void initState() {
    super.initState();
    themeController.load();
    localeController.load();
    themeController.addListener(_onAppearanceChanged);
    localeController.addListener(_onAppearanceChanged);
  }

  @override
  void dispose() {
    themeController.removeListener(_onAppearanceChanged);
    localeController.removeListener(_onAppearanceChanged);
    super.dispose();
  }

  void _onAppearanceChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        navigatorKey: rootNavigatorKey,
        color: themeController.isDarkMode ? const Color(0xFF0F1117) : clrWhite,
        scrollBehavior: WebCustomScrollBehavior(),
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeController.themeMode,
        locale: localeController.locale,
        supportedLocales: const [
          LocaleController.localeId,
          LocaleController.localeEn,
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: SplashScreen(),
      ),
    );
  }
}

final themeController = ThemeController.instance;
final localeController = LocaleController.instance;
