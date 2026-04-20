import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tool_store_app/controller/cont_crud/redux/state.dart';
import 'package:tool_store_app/controller/cont_crud/redux/store.dart';
import 'package:tool_store_app/model/post_get_data.dart';
import 'package:tool_store_app/view/custom/mixin/mixin_pref.dart';
import 'package:tool_store_app/view/custom/web_custom/web_custom_berhaviour.dart';
import 'package:tool_store_app/view/menu/splash_login/splash.dart';
import 'package:tool_store_app/view/var/var.dart';

void main() {
  runApp(const MyApp());
  WidgetsFlutterBinding.ensureInitialized();
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
    ),
  );
  store.dispatch(
    getDataTool(
      param: paramViewDataForm,
      idFrom: '',
      formNo: '',
      formServName: '',
      formCheckBy: '',
      formDateCheckBy: '',
      formDateServName: '',
      formServComment: '',
      formSuperiorAprd: '',
      formSuperiorComment: '',
      formSadminComment: '',
      formSheadAprd: '',
      formSheadComment: '',
      fromDateUpdate: '',
      formUserUpdate: '',
    ),
  );
  store.dispatch(
    getDataToolDetail(
      param: 'VIEW DATA TOOL',
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
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with MixinPref {
  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        color: clrOrange,
        scrollBehavior: WebCustomScrollBehavior(),
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: clrOrange,
            primary: clrOrange,
          ),
          textTheme: TextTheme(
            // Kita daftarkan style khusus untuk title app bar
            titleLarge: GoogleFonts.robotoFlex(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: clrBlack, // Sesuaikan warna default
            ),
            titleMedium: GoogleFonts.robotoFlex(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: clrBlack, // Sesuaikan warna default
            ),
            titleSmall: GoogleFonts.robotoFlex(
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
              color: clrBlack, // Sesuaikan warna default
            ),
          ),
        ),
      ),
    );
  }
}
