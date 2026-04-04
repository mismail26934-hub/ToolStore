import 'package:flutter/material.dart';

class MobilLayout extends StatefulWidget {
  const MobilLayout({super.key});

  @override
  State<MobilLayout> createState() => _MobilLayoutState();
}

class _MobilLayoutState extends State<MobilLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[300],
      appBar: AppBar(title: Text("M O B I L E")),
    );
  }
}
