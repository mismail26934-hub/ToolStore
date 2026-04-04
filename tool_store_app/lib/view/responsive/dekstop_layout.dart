import 'package:flutter/material.dart';

class DekstopLayout extends StatefulWidget {
  const DekstopLayout({super.key});

  @override
  State<DekstopLayout> createState() => _DekstopLayoutState();
}

class _DekstopLayoutState extends State<DekstopLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[300],
      appBar: AppBar(title: Text("D E K S T O P")),
    );
  }
}
