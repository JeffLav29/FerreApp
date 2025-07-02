import 'package:ferre_app/screens/main_screen.dart';
import 'package:ferre_app/services/cart_services.dart'; // Cambio: nuevo servicio
import 'package:ferre_app/services/favorites_service.dart';
import 'package:flutter/material.dart';
import 'package:ferre_app/models/product.dart';

class FavoritesScreen extends StatefulWidget {
  final String userId; // Pasar el userId como parámetro
  
  const FavoritesScreen({
    super.key,
    required this.userId,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritosService _favoritosService = FavoritosService();
  final CartServices _cartServices = CartServices(); // Nuevo servicio de carrito

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Product>>(
      stream: _favoritosService.favoritosStream(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar favoritos',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.red[600],
                  ),
                ),
              ],
            ),
          );
        }

        final favoriteProducts = snapshot.data ?? [];

        if (favoriteProducts.isEmpty) {
          return _buildEmptyState();
        }

        return _buildFavoritesList(favoriteProducts);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes favoritos aún',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega productos a favoritos para verlos aquí',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MainScreen())
              );
            },
            icon: const Icon(Icons.shopping_bag),
            label: const Text('Explorar productos'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[500],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(List<Product> favoriteProducts) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favoriteProducts.length,
      itemBuilder: (context, index) {
        final product = favoriteProducts[index];
        return _buildFavoriteCard(product, index);
      },
    );
  }

  Widget _buildFavoriteCard(Product product, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Imagen del producto
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: product.imagenUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product.imagenUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.hardware,
                            size: 40,
                            color: Colors.grey[600],
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.hardware,
                      size: 40,
                      color: Colors.grey[600],
                    ),
            ),
            const SizedBox(width: 12),
            
            // Información del producto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.nombre,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.categoria,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.descripcion,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Mostrar precio
                  Row(
                    children: [
                      Text(
                        'S/${product.precio.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Botones de acción
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  onPressed: () => _removeFromFavorites(product),
                  tooltip: 'Quitar de favoritos',
                ),
                const SizedBox(height: 8),
                IconButton(
                  icon: Icon(Icons.shopping_cart, color: Colors.blue[600]),
                  onPressed: () => _addToCart(product),
                  tooltip: 'Agregar al carrito',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _removeFromFavorites(Product product) async {
    final success = await _favoritosService.quitarDeFavoritos(product.id, widget.userId);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.nombre} removido de favoritos'),
          backgroundColor: Colors.orange[600],
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al remover de favoritos'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Método actualizado para usar el nuevo servicio
  Future<void> _addToCart(Product product) async {
    try {
      final userIdParam = widget.userId.isNotEmpty ? widget.userId : null;
      final success = await _cartServices.agregarACarrito(product, userIdParam);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.nombre} agregado al carrito'),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Ver carrito',
              textColor: Colors.white,
              onPressed: () {
                Navigator.pushNamed(context, '/cart');
              },
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al agregar al carrito'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al agregar al carrito'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _cartServices.dispose(); // Limpiar recursos del servicio
    super.dispose();
  }
}