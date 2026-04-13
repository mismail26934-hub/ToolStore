import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:tool_store_app/controller/cont_crud/redux/state.dart';
import 'package:tool_store_app/view/menu/drawer.dart';
import 'package:tool_store_app/view/var/var.dart';

class ToolDataCopy extends StatefulWidget {
  const ToolDataCopy({super.key});
  @override
  State<ToolDataCopy> createState() => _ToolDataCopyState();
}

class _ToolDataCopyState extends State<ToolDataCopy> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerMenu(title: name),
      appBar: AppBar(
        title: const Text('Aplikasi Saya'),
        backgroundColor: Colors.blueAccent,
      ),
      backgroundColor: Colors.deepPurple[300],
      body: StoreConnector<AppState, UserState>(
        converter: (store) => store.state.userState,
        builder: (context, state) {
          if (state.users.isEmpty) return Center(child: Text("Tidak ada data"));
          return ListView.builder(
            itemCount: state.users.length,
            itemBuilder: (context, index) =>
                ListTile(title: Text(state.users[index].username)),
          );
        },
      ),
    );
  }
}
