import 'package:flutter/material.dart';
import 'package:tool_store_app/view/menu/tool/tool_data.dart';

class DesktopLayout extends StatefulWidget {
  const DesktopLayout({super.key});

  @override
  State<DesktopLayout> createState() => _DesktopLayoutState();
}

class _DesktopLayoutState extends State<DesktopLayout> {
  @override
  Widget build(BuildContext context) {
    return ToolData();
  }
}
