import 'package:flutter/material.dart';
import 'package:tool_store_app/view/responsive/desktop_layout.dart';
import 'package:tool_store_app/view/responsive/mobile_layout.dart';
import 'package:tool_store_app/view/responsive/responsive_layout.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
        mobileLayout: MobilLayout(),
        desktopLayout: DesktopLayout(),
      ),
    );
  }
}
