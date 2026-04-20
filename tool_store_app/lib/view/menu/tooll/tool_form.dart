import 'package:flutter/material.dart';
import 'package:tool_store_app/view/menu/drawer/drawer.dart';
import 'package:tool_store_app/view/menu/tooll/tool_form_input.dart';
import 'package:tool_store_app/view/var/var.dart';

class ToolForm extends StatefulWidget {
  const ToolForm({
    super.key,
    required this.title,
    required this.onPressTailing,
  });

  final String title;
  final void Function()? onPressTailing;

  @override
  State<ToolForm> createState() => _ToolFormState();
}

class _ToolFormState extends State<ToolForm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerMenu(title: name),
      body: SafeArea(child: ToolFormInput(subtitle: '')),
    );
  }
}
