import 'package:ferre_app/models/product.dart';
import 'package:ferre_app/services/cart_manager.dart';
import 'package:ferre_app/services/favorites_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final FavoritosService _favoritosService = FavoritosService();
  bool isInFavorites = false;
  bool isLoading = false;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  // Inicializar usuario y verificar favoritos
  _initializeUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.uid;
      });
      await _checkIfInFavorites();
    }
    
    // Escuchar cambios en autenticación
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() {
          currentUserId = user?.uid;
        });
        if (user != null) {
          _checkIfInFavorites();
        } else {
          setState(() {
            isInFavorites = false;
          });
        }
      }
    });
  }

  // Verificar si el producto ya está en favoritos
  _checkIfInFavorites() async {
    if (currentUserId == null) {
      setState(() {
        isInFavorites = false;
      });
      return;
    }
    
    bool inFavorites = await _favoritosService.estaEnFavoritos(
      widget.product.id, 
      currentUserId!
    );
    
    if (mounted) {
      setState(() {
        isInFavorites = inFavorites;
      });
    }
  }

  // Función para manejar favoritos
  _toggleFavorite() async {
    // Verificar si el usuario está logueado
    if (currentUserId == null) {
      _showLoginRequiredDialog();
      return;
    }

    setState(() {
      isLoading = true;
    });

    bool success = await _favoritosService.toggleFavorito(
      widget.product, 
      currentUserId!
    );
    
    if (success) {
      setState(() {
        isInFavorites = !isInFavorites;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isInFavorites 
              ? '${widget.product.nombre} agregado a favoritos'
              : '${widget.product.nombre} removido de favoritos'),
            duration: const Duration(seconds: 2),
            backgroundColor: isInFavorites ? Colors.green : Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al actualizar favoritos'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  // Mostrar diálogo cuando se requiere login
  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Iniciar Sesión'),
          content: const Text(
            'Debes iniciar sesión para agregar productos a favoritos.',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Aquí puedes navegar a la pantalla de login
                // Navigator.pushNamed(context, '/login');
              },
              child: const Text('Iniciar Sesión'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del producto'),
        backgroundColor: Colors.blue,
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInImage.assetNetwork(
              placeholder: 'assets/cat.gif',
              image: widget.product.imagenUrl.isNotEmpty
                ? widget.product.imagenUrl
                : 'https://via.placeholder.com/300x200?text=Sin+Imagen',
              imageErrorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Text('No se pudo cargar la imagen'),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
        
            const Text(
              'Descripción',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
            ),
            const SizedBox(height: 10),

            Text(
              widget.product.descripcion, 
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 10),
        
            const Text(
              'Precio', 
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)
            ),
            Text(
              '${widget.product.precio} Soles', 
              style: const TextStyle(color: Colors.blueGrey),
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(6.0),
              width: 400,
              decoration: BoxDecoration(
                border: Border.all(
                  color: widget.product.stock > 0 ? Colors.green : Colors.red,
                ),
                borderRadius: BorderRadius.circular(4.0),
                color: widget.product.stock > 0 
                  ? Colors.green.shade50 
                  : Colors.red.shade50,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Disponibilidad',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      widget.product.stock > 0
                        ? 'En stock: ${widget.product.stock}'
                        : 'Agotado',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            FilledButton(
              onPressed: () {
                CartManager.addToCart(widget.product);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${widget.product.nombre} agregado al carrito'),
                    duration: const Duration(seconds: 2),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: const Size(400, 50)
              ),
              child: const Text('Agregar al carrito'),
            ),
            const SizedBox(height: 10),

            FilledButton(
              onPressed: isLoading ? null : _toggleFavorite,
              style: FilledButton.styleFrom(
                backgroundColor: isInFavorites ? Colors.red : Colors.pink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: const Size(400, 50),
              ),
              child: isLoading 
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isInFavorites ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(isInFavorites 
                        ? 'Quitar de favoritos' 
                        : 'Agregar a favoritos'
                      ),
                    ],
                  ),
            )
          ],
        ),
      ),
    );
  }
}