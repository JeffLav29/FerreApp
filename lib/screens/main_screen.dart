import 'package:ferre_app/screens/cart_screen.dart';
import 'package:ferre_app/screens/favorites_screen.dart';
import 'package:ferre_app/screens/home_screen.dart';
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
  final user = FirebaseAuth.instance.currentUser;
  // Lista de pantallas
  final List<Widget> _screens = [
    HomeScreen(),  // 0 - Inicio
    CartScreen(),  // 1 - Carrito
    FavoritesScreen(),  // 2 - Favoritos
    ProfileScreen(),  // 3 - Perfil
  ];
  
  // Lista de pantallas públicas
  final List<Widget> _publicScreens = [
    HomeScreen(),  // 0 - Inicio
    CartScreen(),  // 1 - Carrito
    FavoritesScreen(),  // 2 - Favoritos
  ];
  //Lista de pantallas privadas
  final List<Widget> _privateScreens = [
    ProfileScreen(),  // 3 - Perfil
  ];

  // Títulos de AppBar para cada pantalla
  static const List<String> _appBarTitles = [
    'FerreApp',
    'Carrito',
    'Favoritos',
    'Mi Perfil',
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    
    setState(() {
      _selectedIndex = index;
    });
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