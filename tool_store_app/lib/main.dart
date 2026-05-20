import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter/services.dart';
import 'package:tool_store_app/controller/cont_crud/redux/state.dart';
import 'package:tool_store_app/controller/cont_crud/redux/store.dart';
import 'package:tool_store_app/model/post_get_data.dart';
import 'package:tool_store_app/theme/app_theme.dart';
import 'package:tool_store_app/theme/theme_controller.dart';
import 'package:tool_store_app/view/custom/mixin/mixin_pref.dart';
import 'package:tool_store_app/view/custom/web_custom/web_custom_berhaviour.dart';
import 'package:tool_store_app/view/menu/splash_login/splash.dart';
import 'package:tool_store_app/view/var/var.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await themeController.load();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const MyApp());
  });

  store.dispatch(
    getDataUser(
      param: paramViewDataUser,
      idUsers: '',
      username: '',
      password: '',
      namaUser: '',
      foto: '',
      idTU: '',
      noTelp: '',
      token: '',
      level: '',
      status: '',
      superiorId: '',
    ),
  );

  store.dispatch(
    getDataTool(
      param: paramViewDataForm,
      idForm: '',
      formNo: '',
      formServName: '',
      formCheckBy: '',
      formDateCheckBy: '',
      formDateServName: '',
      formServComment: '',
      formSuperiorAprd: '',
      formSuperiorComment: '',
      formSadminComment: '',
      formMilestone: '',
      formStatusOrder: '',
      formSheadAprd: '',
      formSheadComment: '',
      fromDateUpdate: '',
      formUserUpdate: '',
    ),
  );

  store.dispatch(
    getDataToolDetail(
      param: paramViewDataTool,
      idFormDetail: '',
      idFrom: '',
      formComment: '',
      pnGroup: '',
      pnDesc: '',
      qty: '',
      explan: '',
      actionNote: '',
      valType: '',
      partValue: '',
      formDetailDate: '',
      formDetailUser: '',
    ),
  );

  store.dispatch(
    getDataPO(
      param: paramViewDataPO,
      idPO: '',
      idFormDetail: '',
      poNO: '',
      dateUpdatePO: '',
      userUpdatePO: '',
    ),
  );

  store.dispatch(
    getDataSO(
      param: paramViewDataSO,
      idSo: '',
      idFormDetail: '',
      so: '',
      eta: '',
      noteSo: '',
      dateUpdateSo: '',
      idUpdateSo: '',
    ),
  );

  store.dispatch(
    getDataSuperrior(
      param: paramViewDataSuperrior,
      superiorId: '',
      namaSuperior: '',
      statusSuperior: '',
      userIdInputSuperior: '',
      dateInputSuperior: '',
    ),
  );

  store.dispatch(
    getDataRcvWh(
      param: paramViewDataRcvWh,
      idRcvWh: '',
      idFormDetail: '',
      rcvWhDate: '',
      rcvWhIdInput: '',
      rcvWhDateInput: '',
    ),
  );

  store.dispatch(
    getDataRcvTool(
      param: paramViewDataRcvTool,
      idRcvTool: '',
      idFormDetail: '',
      rcvToolDate: '',
      rcvToolIdInput: '',
      rcvToolDateInput: '',
    ),
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
    themeController.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    themeController.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        color: themeController.isDarkMode ? const Color(0xFF0F1117) : clrWhite,
        scrollBehavior: WebCustomScrollBehavior(),
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeController.themeMode,
        home: SplashScreen(),
      ),
    );
  }
}

final themeController = ThemeController.instance;
