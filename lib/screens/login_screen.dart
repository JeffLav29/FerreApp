import 'package:ferre_app/screens/main_screen.dart';
import 'package:ferre_app/screens/register_screen.dart'; // Importa tu pantalla de registro
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ferre App", style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    margin: EdgeInsets.only(bottom: 32),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      size: 70,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                
                SizedBox(
                  height: 64,
                  child: TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: "Correo electrónico",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)
                      )
                    ),
                  ),
                ),
                SizedBox(height: 5), // Espaciado entre campos
                SizedBox(
                  height: 64,
                  child: TextField(
                    controller: passwordController,
                    obscureText: true, // Ocultar contraseña
                    decoration: InputDecoration(
                      labelText: "Contraseña",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)
                      )
                    ),
                  ),
                ),
                SizedBox(height: 24),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.blue[500],
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)
                    )
                  ),
                  onPressed: () {
                    signInWithEmailAndPassword(emailController.text, passwordController.text, context,);
                  }, 
                  child: Text("Ingresar")),
                
                SizedBox(height: 16), // Espaciado entre botones
                
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)
                    ),
                    side: BorderSide(color: Colors.blue[500]!)
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterScreen())
                    );
                  }, 
                  child: Text(
                    "Crear cuenta",
                    style: TextStyle(color: Colors.blue[500]),
                  )),
                
                SizedBox(height: 16),
                
                Center(
                  child: Text(
                    "¿No tienes cuenta? Créala usando el botón de arriba",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                SizedBox(height: 32),
                
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const MainScreen())
                      );
                    },
                    child: Text(
                      "Continuar sin iniciar sesión",
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ]
            ),
          ),
        ),
      );
  }
}

// Métodos
signInWithEmailAndPassword (String emailAddress, String password, BuildContext context) async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailAddress, password: password
    );

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen())
      );
    }
  } on FirebaseException catch (e) {
    String errorMessage;

    switch (e.code) {
      case 'user-not-found':
        errorMessage = 'No se encontró una cuenta con este correo electrónico.';
        break;
      case 'wrong-password':
        errorMessage = 'Contraseña incorrecta.';
        break;
      case 'invalid-email':
        errorMessage = 'El formato del correo electrónico no es válido.';
        break;
      case 'user-disabled':
        errorMessage = 'Esta cuenta ha sido deshabilitada.';
        break;
      case 'too-many-requests':
        errorMessage = 'Demasiados intentos fallidos. Intenta más tarde.';
        break;
      default:
        errorMessage = 'Error al iniciar sesión: ${e.message}';
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        )
      );
    } 
  }catch (e){
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error inesperado. Intenta nuevamente.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        )
      );
    }
  }
}