import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:tool_store_app/controller/api_url/post_list.dart';
import 'package:tool_store_app/controller/cont_crud/cont_function_crud.dart';
import 'package:tool_store_app/controller/cont_crud/redux/state.dart';
import 'package:tool_store_app/model/post_get_data.dart';
import 'package:tool_store_app/view/custom/navbar/sliver_appbars.dart';
import 'package:tool_store_app/view/custom/navbar/sliver_lists.dart';

class ToolDataCopy extends StatefulWidget {
  const ToolDataCopy({super.key});
  @override
  State<ToolDataCopy> createState() => _ToolDataCopyState();
}

class _ToolDataCopyState extends State<ToolDataCopy> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[300],
      body: StoreConnector<UserState, List<PostList>>(
        converter: (store) => store.state.users,
        builder: (context, users) {
          if (users.isEmpty) return Center(child: Text("Tidak ada data"));
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) =>
                ListTile(title: Text(users[index].username)),
          );
        },
      ),
    );
  }
}
