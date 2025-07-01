import 'package:ferre_app/screens/login_screen.dart';
import 'package:ferre_app/screens/main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _apellidoController = TextEditingController(); // Nuevo campo
  final _nombreUsuarioController = TextEditingController(); // Nuevo campo
  final _phoneController = TextEditingController();
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _apellidoController.dispose(); // Dispose del nuevo campo
    _nombreUsuarioController.dispose(); // Dispose del nuevo campo
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Verificar si el nombre de usuario ya existe
      final usernameExists = await _checkUsernameExists(_nombreUsuarioController.text.trim());
      if (usernameExists) {
        _showErrorDialog('El nombre de usuario ya está en uso. Por favor elige otro.');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // 1. Crear usuario en Firebase Auth
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. Obtener el UID del usuario creado
      final String uid = userCredential.user!.uid;

      // 3. Crear documento en Firestore con el mismo UID
      await _createUserDocument(uid);

      // 4. Actualizar el displayName en Firebase Auth (nombre completo)
      final nombreCompleto = '${_nameController.text.trim()} ${_apellidoController.text.trim()}';
      await userCredential.user!.updateDisplayName(nombreCompleto);

      // 5. Verificar que el widget aún esté montado antes de usar context
      if (!mounted) return;

      // 6. Mostrar mensaje de éxito y navegar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario registrado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );

      // Navegar a la pantalla principal
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => MainScreen())
      );

    } on FirebaseAuthException catch (e) {
      _showErrorDialog(_getAuthErrorMessage(e.code));
    } catch (e) {
      _showErrorDialog('Error inesperado: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _checkUsernameExists(String username) async {
    try {
      final QuerySnapshot result = await _firestore
          .collection('users')
          .where('nombreUsuario', isEqualTo: username)
          .limit(1)
          .get();
      
      return result.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> _createUserDocument(String uid) async {
    try {
      final userData = {
        'uid': uid,
        'nombre': _nameController.text.trim(),
        'apellido': _apellidoController.text.trim(), // Nuevo campo
        'nombreUsuario': _nombreUsuarioController.text.trim(), // Nuevo campo
        'email': _emailController.text.trim(),
        'telefono': _phoneController.text.trim(),
        'tipoCliente': 'Cliente Regular',
        'fechaRegistro': FieldValue.serverTimestamp(),
        'comprasRealizadas': 0,
        'montoTotal': 0.0,
        'direccion': {
          'calle': '',
          'ciudad': '',
          'codigoPostal': '',
          'pais': 'Perú'
        },
        'configuraciones': {
          'notificaciones': false,
        },
        'fechaActualizacion': FieldValue.serverTimestamp(),
        'activo': true,
      };

      await _firestore.collection('users').doc(uid).set(userData);
      
    } catch (e) {
      rethrow;
    }
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'La contraseña es muy débil.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con este correo electrónico.';
      case 'invalid-email':
        return 'El correo electrónico no es válido.';
      default:
        return 'Error al crear la cuenta. Inténtalo de nuevo.';
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrarse'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              
              // Logo o título
              const Icon(
                Icons.person_add,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 32),
              
              // Campo Nombre
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Campo Apellido (NUEVO)
              TextFormField(
                controller: _apellidoController,
                decoration: const InputDecoration(
                  labelText: 'Apellido',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu apellido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Campo Nombre de Usuario (NUEVO)
              TextFormField(
                controller: _nombreUsuarioController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de usuario',
                  prefixIcon: Icon(Icons.alternate_email),
                  border: OutlineInputBorder(),
                  helperText: 'Debe ser único, sin espacios',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un nombre de usuario';
                  }
                  if (value.contains(' ')) {
                    return 'El nombre de usuario no puede contener espacios';
                  }
                  if (value.length < 3) {
                    return 'El nombre de usuario debe tener al menos 3 caracteres';
                  }
                  // Validar que solo contenga letras, números y guiones bajos
                  if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                    return 'Solo se permiten letras, números y guiones bajos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Campo Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu correo';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Ingresa un correo válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Campo Teléfono
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Teléfono (opcional)',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              
              // Campo Contraseña
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una contraseña';
                  }
                  if (value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              
              // Botón de registro
              ElevatedButton(
                onPressed: _isLoading ? null : _registerUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Registrarse',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              
              // Link para ir al login
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen())
                  );
                },
                child: const Text('¿Ya tienes cuenta? Iniciar sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}