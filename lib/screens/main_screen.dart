import 'package:ferre_app/screens/cart_screen.dart';
import 'package:ferre_app/screens/favorites_screen.dart';
import 'package:ferre_app/screens/home_screen.dart';
import 'package:ferre_app/screens/login_screen.dart';
import 'package:ferre_app/screens/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Lista de pantallas
  final List<Widget> _screens = [
    HomeScreen(),      // 0 - Inicio
    CartScreen(),      // 1 - Carrito
    FavoritesScreen(), // 2 - Favoritos
    ProfileScreen(),   // 3 - Perfil
  ];

  // Títulos de AppBar para cada pantalla
  static const List<String> _appBarTitles = [
    'FerreApp',
    'Carrito',
    'Favoritos',
    'Mi Perfil',
  ];

  // Índices de pantallas que requieren autenticación
  final Set<int> _protectedScreens = {2, 3}; // Favoritos y Perfil

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    
    // Verificar si la pantalla requiere autenticación
    if (_protectedScreens.contains(index)) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // Usuario no autenticado, mostrar diálogo o navegar a login
        _showLoginDialog();
        return;
      }
    }
    
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Iniciar Sesión'),
          content: const Text(
            'Debes iniciar sesión para acceder a esta función.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Aquí navegas a tu pantalla de login
                _navigateToLogin();
              },
              child: const Text('Iniciar Sesión'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToLogin(){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen(),)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _appBarTitles[_selectedIndex],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
        actions: _selectedIndex == 0 ? [
          // Solo mostrar ícono de carrito en la pantalla Home
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              setState(() {
                _selectedIndex = 1; // Ir al carrito
              });
            },
          ),
        ] : null,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Carrito',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}