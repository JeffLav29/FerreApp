import 'package:flutter/material.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // Lista de productos favoritos de ejemplo
  List<Map<String, dynamic>> favoriteProducts = [
    {
      'id': '1',
      'name': 'Martillo de Acero',
      'price': 25.99,
      'image': 'assets/images/hammer.png', // Ruta de ejemplo
      'category': 'Herramientas',
      'description': 'Martillo resistente para uso profesional'
    },
    {
      'id': '2',
      'name': 'Taladro Eléctrico',
      'price': 89.99,
      'image': 'assets/images/drill.png',
      'category': 'Herramientas Eléctricas',
      'description': 'Taladro con batería recargable'
    },
    {
      'id': '3',
      'name': 'Clavos 2 pulgadas',
      'price': 12.50,
      'image': 'assets/images/nails.png',
      'category': 'Ferretería',
      'description': 'Caja con 100 clavos galvanizados'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favoritos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[50],
        actions: [
          if (favoriteProducts.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: () => _showClearAllDialog(),
              tooltip: 'Limpiar todo',
            ),
        ],
      ),
      body: favoriteProducts.isEmpty ? _buildEmptyState() : _buildFavoritesList(),
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
              // Navegar a la pantalla principal o catálogo
              Navigator.pop(context);
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

  Widget _buildFavoritesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favoriteProducts.length,
      itemBuilder: (context, index) {
        final product = favoriteProducts[index];
        return _buildFavoriteCard(product, index);
      },
    );
  }

  Widget _buildFavoriteCard(Map<String, dynamic> product, int index) {
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
              child: Icon(
                Icons.hardware, // Icono por defecto
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
                    product['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product['category'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product['description'],
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${product['price'].toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[600],
                    ),
                  ),
                ],
              ),
            ),
            
            // Botones de acción
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  onPressed: () => _removeFromFavorites(index),
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

  void _removeFromFavorites(int index) {
    setState(() {
      favoriteProducts.removeAt(index);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Producto removido de favoritos'),
        backgroundColor: Colors.orange[600],
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'DESHACER',
          textColor: Colors.white,
          onPressed: () {
            // Aquí podrías implementar la funcionalidad de deshacer
          },
        ),
      ),
    );
  }

  void _addToCart(Map<String, dynamic> product) {
    // Aquí implementarías la lógica para agregar al carrito
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product['name']} agregado al carrito'),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Limpiar favoritos'),
          content: const Text('¿Estás seguro de que quieres eliminar todos los productos de favoritos?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  favoriteProducts.clear();
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Todos los favoritos han sido eliminados'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Eliminar todo', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}