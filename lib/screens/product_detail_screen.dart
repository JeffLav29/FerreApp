import 'package:ferre_app/models/product.dart';
import 'package:ferre_app/services/cart_services.dart'; // Cambio aquí
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
  final CartServices _cartService = CartServices(); // Nueva instancia del servicio
  bool isInFavorites = false;
  bool isLoading = false;
  bool isAddingToCart = false; // Nueva variable para controlar el estado del carrito
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

  // Nueva función para agregar al carrito usando el nuevo servicio
  Future<void> _addToCart() async {
    if (!mounted) return;
    
    setState(() {
      isAddingToCart = true;
    });
    
    try {
      // Mostrar indicador de carga
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 16),
              Text('Agregando al carrito...'),
            ],
          ),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Usar el nuevo servicio para agregar al carrito
      final success = await _cartService.agregarACarrito(
        widget.product, 
        currentUserId, // Puede ser null para carrito local
      );
      
      // Ocultar el snackbar de carga
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
      
      if (success) {
        // Obtener la cantidad actual del producto en el carrito
        final cantidadActual = await _cartService.obtenerCantidadProducto(
          widget.product.id, 
          currentUserId
        );
        
        final mensaje = currentUserId != null && currentUserId!.isNotEmpty
            ? '${widget.product.nombre} agregado al carrito ($cantidadActual unidad${cantidadActual > 1 ? 'es' : ''})'
            : '${widget.product.nombre} agregado al carrito temporal ($cantidadActual unidad${cantidadActual > 1 ? 'es' : ''})';
            
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(mensaje),
              backgroundColor: Colors.green[600],
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              action: SnackBarAction(
                label: 'Ver carrito',
                textColor: Colors.white,
                onPressed: () {
                  Navigator.pushNamed(context, '/cart');
                },
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al agregar producto al carrito'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      // Ocultar cualquier snackbar anterior
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isAddingToCart = false;
        });
      }
    }
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen con tamaño fijo y contenedor
            Container(
              width: double.infinity,
              height: 300, // Altura fija para evitar overflow
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[100],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FadeInImage.assetNetwork(
                  placeholder: 'assets/cat.gif',
                  image: widget.product.imagenUrl.isNotEmpty
                    ? widget.product.imagenUrl
                    : 'https://via.placeholder.com/300x200?text=Sin+Imagen',
                  fit: BoxFit.cover, // Ajustar imagen al contenedor
                  imageErrorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 250,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'No se pudo cargar la imagen',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Título del producto
            Text(
              widget.product.nombre,
              style: const TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 16),
        
            const Text(
              'Descripción',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 8),

            Text(
              widget.product.descripcion, 
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 16),
        
            const Text(
              'Precio', 
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)
            ),
            const SizedBox(height: 4),
            Text(
              'S/ ${widget.product.precio}', 
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Container de disponibilidad
            Container(
              padding: const EdgeInsets.all(16.0),
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(
                  color: widget.product.stock > 0 ? Colors.green : Colors.red,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(12.0),
                color: widget.product.stock > 0 
                  ? Colors.green.shade50 
                  : Colors.red.shade50,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Disponibilidad',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        widget.product.stock > 0 
                          ? Icons.check_circle 
                          : Icons.cancel,
                        color: widget.product.stock > 0 
                          ? Colors.green 
                          : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.product.stock > 0
                          ? 'En stock: ${widget.product.stock} unidades'
                          : 'Agotado',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: widget.product.stock > 0 
                            ? Colors.green.shade700 
                            : Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Botones de acción
            Column(
              children: [
                // Botón agregar al carrito
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: (isAddingToCart || widget.product.stock <= 0) 
                        ? null 
                        : _addToCart,
                    style: FilledButton.styleFrom(
                      backgroundColor: widget.product.stock > 0 
                          ? Colors.blue 
                          : Colors.grey,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isAddingToCart
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
                            const Icon(Icons.shopping_cart, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              widget.product.stock > 0 
                                  ? 'Agregar al carrito' 
                                  : 'Sin stock',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                  ),
                ),
                const SizedBox(height: 12),

                // Botón favoritos
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: isLoading ? null : _toggleFavorite,
                    style: FilledButton.styleFrom(
                      backgroundColor: isInFavorites ? Colors.red : Colors.pink,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                            Text(
                              isInFavorites 
                                ? 'Quitar de favoritos' 
                                : 'Agregar a favoritos',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                  ),
                ),
              ],
            ),
            
            // Padding adicional para evitar que los botones queden muy pegados al borde
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Limpiar recursos si es necesario
    super.dispose();
  }
}