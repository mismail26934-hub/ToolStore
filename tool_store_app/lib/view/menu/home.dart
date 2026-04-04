import 'package:flutter/material.dart';
import 'package:tool_store_app/view/responsive/dekstop_layout.dart';
import 'package:tool_store_app/view/responsive/mobil_layout.dart';
import 'package:tool_store_app/view/responsive/resposive_layout.dart';

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
        dekstopLayout: DekstopLayout(),
      ),
    );
  }
}
