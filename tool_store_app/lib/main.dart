import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:tool_store_app/controller/cont_crud/redux/state.dart';
import 'package:tool_store_app/controller/cont_crud/redux/store.dart';
import 'package:tool_store_app/model/post_get_data.dart';
import 'package:tool_store_app/view/custom/mixin/mixin_pref.dart';
import 'package:tool_store_app/view/custom/routes/page_routes.dart';
import 'package:tool_store_app/view/custom/web_custom/web_custom_berhaviour.dart';
import 'package:tool_store_app/view/menu/login.dart';
import 'package:tool_store_app/view/menu/splash.dart';
import 'package:tool_store_app/view/var/var.dart';

void main() {
  runApp(const MyApp());
  WidgetsFlutterBinding.ensureInitialized();
  store.dispatch(
    getDataUser(
      param: 'VIEW DATA USER',
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
        ),
      ),
    );
  }
}
