import 'package:ferre_app/screens/main_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const FerreApp());
}

class FerreApp extends StatelessWidget {
  const FerreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FerreApp',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: const MainScreen(),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }
}