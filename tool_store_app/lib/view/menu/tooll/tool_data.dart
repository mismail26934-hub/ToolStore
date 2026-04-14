import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:tool_store_app/controller/cont_crud/redux/state.dart';
import 'package:tool_store_app/controller/cont_crud/redux/store.dart';
import 'package:tool_store_app/model/post_get_data.dart';
import 'package:tool_store_app/view/custom/mixin/mixin_pref.dart';
import 'package:tool_store_app/view/custom/navbar/sliver_appbars.dart';
import 'package:tool_store_app/view/custom/navbar/sliver_fill_remaining.dart';
import 'package:tool_store_app/view/menu/drawer/drawer.dart';
import 'package:tool_store_app/view/menu/tooll/tool_form.dart';
import 'package:tool_store_app/view/var/var.dart';

class ToolData extends StatefulWidget {
  const ToolData({super.key});
  @override
  State<ToolData> createState() => _ToolDataState();
}

class _ToolDataState extends State<ToolData> with MixinPref {
  // 1. Buat variabel key di sini
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    refreshPref();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: clrWhite,
      drawer: DrawerMenu(title: name),
      body: RefreshIndicator(
        onRefresh: () async {
          await store.dispatch(
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
        },
        child: CustomScrollView(
          slivers: [
            SliverAppbars(
              title: 'Large App Bar',
              onPressTailing: () {
                Navigator.push(
                  context,
                  Platform.isIOS
                      ? CupertinoPageRoute(
                          builder: (context) => ToolForm(
                            title: 'ADD DATA',
                            onPressTailing: () {},
                          ),
                        )
                      : MaterialPageRoute(
                          builder: (context) => ToolForm(
                            title: 'ADD DATA',
                            onPressTailing: () {},
                          ),
                        ),
                );
              },
              onPressLeading: () {},
              textColor: Colors.black,
              iconTailing: Icon(Icons.add),
              iconLeading: Icon(Icons.menu),
            ),
            StoreConnector<AppState, UserState>(
              converter: (store) => store.state.userState,
              builder: (context, state) {
                // 1. Tampilan saat Loading
                if (state.isLoading) {
                  return SliverFillRemaiings(
                    errors: state.error ?? "Loading",
                    hasScrollBodys: false,
                  );
                }
                // 2. Tampilan saat Error
                if (state.error != null) {
                  return SliverFillRemaiings(
                    errors: state.error ?? "Loading",
                    hasScrollBodys: false,
                  );
                }
                // 3. Tampilan saat Data Kosong
                if (state.users.isEmpty) {
                  return SliverFillRemaiings(
                    errors: state.error ?? "Loading",
                    hasScrollBodys: false,
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final users = state.users[index];
                    return Card(
                      child: ListTile(
                        title: SelectableText(
                          users.username,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SelectableText('Name : ${users.namaUser}'),
                            SelectableText('No.Telp : ${users.noTelp}'),
                            SelectableText('Level : ${users.level}'),
                            SelectableText('Status : ${users.status}'),
                          ],
                        ),
                        leading: Icon(Icons.remove_red_eye),
                        trailing: Icon(Icons.edit_document),
                      ),
                    );
                  }, childCount: state.users.length),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
