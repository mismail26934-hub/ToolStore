import 'package:flutter/material.dart';
import 'package:tool_store_app/view/menu/tooll/tool_data.dart';

class DekstopLayout extends StatefulWidget {
  const DekstopLayout({super.key});

  @override
  State<DekstopLayout> createState() => _DekstopLayoutState();
}

class _DekstopLayoutState extends State<DekstopLayout> {
  @override
  Widget build(BuildContext context) {
    return ToolData();
  }
}
