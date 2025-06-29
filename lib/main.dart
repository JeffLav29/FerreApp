import 'package:ferre_app/screens/login_screen.dart';
import 'package:ferre_app/screens/main_screen.dart';
import 'package:flutter/material.dart';
// Paquetes de Firebase
import 'package:ferre_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
  );
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
      home: const LoginScreen(),
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