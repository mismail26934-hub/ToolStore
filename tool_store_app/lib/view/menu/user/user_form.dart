import 'package:flutter/material.dart';
import 'package:tool_store_app/view/menu/drawer/drawer.dart';
import 'package:tool_store_app/view/menu/user/user_form_input.dart';
import 'package:tool_store_app/view/var/var.dart';

class UserForm extends StatefulWidget {
  const UserForm({
    super.key,
    required this.title,
    required this.onPressTailing,
    this.levelReadOnly = false,
    this.popOnSuccess = false,
  });

  final String title;
  final void Function()? onPressTailing;
  final bool levelReadOnly;
  final bool popOnSuccess;

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerMenu(title: name),
      body: UserFormInput(
        title: 'FORM USER',
        onPressTailing: () {},
        levelReadOnly: widget.levelReadOnly,
        popOnSuccess: widget.popOnSuccess,
      ),
    );
  }
}
