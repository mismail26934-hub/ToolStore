import 'package:flutter/material.dart';
import 'package:tool_store_app/view/menu/drawer.dart';
import 'package:tool_store_app/view/menu/fm_input_tool.dart';
import 'package:tool_store_app/view/var/var.dart';

class ToolDataCopy extends StatefulWidget {
  const ToolDataCopy({
    super.key,
    required this.title,
    required this.onPressTailing,
  });

  final String title;
  final void Function()? onPressTailing;

  @override
  State<ToolDataCopy> createState() => _ToolDataCopyState();
}

class _ToolDataCopyState extends State<ToolDataCopy> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerMenu(title: name),
      appBar: AppBar(
        title: Text(
          widget.title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: clrWhite,
      ),
      backgroundColor: clrWhite,
      body: FmInputDataTool(),
    );
  }
}
