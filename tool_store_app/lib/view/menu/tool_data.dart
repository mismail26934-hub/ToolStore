import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:tool_store_app/controller/cont_crud/redux/state.dart';
import 'package:tool_store_app/model/post_get_data.dart';
import 'package:tool_store_app/view/custom/navbar/sliver_appbars.dart';
import 'package:tool_store_app/view/custom/navbar/sliver_fill_remaining.dart';
import 'package:tool_store_app/view/menu/tool_data_copy.dart';

class ToolData extends StatefulWidget {
  const ToolData({super.key});
  @override
  State<ToolData> createState() => _ToolDataState();
}

class _ToolDataState extends State<ToolData> {
  @override
  void initState() {
    PostData.getDataUser(
      "VIEW DATA USER",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[300],
      body: CustomScrollView(
        slivers: [
          SliverAppbars(
            title: 'Large App Bar',
            onPressTailing: () {},
            onPressLeading: () {},
            textColor: Colors.black,
          ),
          StoreConnector<UserState, UserState>(
            converter: (store) => store.state,
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
                  final user = state.users[index];
                  return Card(
                    child: ListTile(
                      title: Text(user.username),
                      leading: IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            Platform.isIOS
                                ? CupertinoPageRoute(
                                    builder: (_) => ToolDataCopy(),
                                  )
                                : MaterialPageRoute(
                                    builder: (_) => ToolDataCopy(),
                                  ),
                          );
                        },
                        icon: Icon(Icons.point_of_sale),
                      ),
                    ),
                  );
                }, childCount: state.users.length),
              );
            },
          ),
        ],
      ),
    );
  }
}
