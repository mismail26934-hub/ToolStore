import 'package:flutter/material.dart';
import 'package:tool_store_app/view/home.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Data Tool',
      theme: ThemeData(
        colorSchemeSeed: Colors.deepOrange,
        primaryColor: Colors.deepOrange,
        hoverColor: Colors.deepOrange,
        hintColor: Colors.deepOrange,
        focusColor: Colors.deepOrange,
        colorScheme: .fromSeed(seedColor: Colors.orange),
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: Colors.deepOrange, // Warna default untuk semua progress bar
        ),
      ),
      home: const Home(),
      debugShowCheckedModeBanner: false,
    ),
  );
}
