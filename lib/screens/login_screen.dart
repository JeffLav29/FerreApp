import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ferre App", style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 64,
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Correo electrónico",
                  border: OutlineInputBorder()
                ),
              ),
            ),
            SizedBox(
              height: 64,
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Contraseña",
                  border: OutlineInputBorder()
                ),
              ),
            ),
            FilledButton(
              onPressed: () {

              }, 
              child: Text("Ingresar"))
          ]
        ),
      ),
    );
  }
}