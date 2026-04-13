import 'package:flutter/material.dart';
import 'package:tool_store_app/view/menu/user/user_data.dart';

class MobilLayout extends StatefulWidget {
  const MobilLayout({super.key});

  @override
  State<MobilLayout> createState() => _MobilLayoutState();
}

class _MobilLayoutState extends State<MobilLayout> {
  @override
  Widget build(BuildContext context) {
    return ToolData();
  }
}
