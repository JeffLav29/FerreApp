import 'package:ferre_app/models/product.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CartManager {
  static final List<Product> _cartItems = [];
  
  // Notifier para actualizar la UI cuando cambie el carrito
  static final ValueNotifier<List<Product>> cartNotifier = ValueNotifier([]);
  
  static void addToCart(Product product) {
    _cartItems.add(product);
    cartNotifier.value = List.from(_cartItems); // Notificar cambios
  }
  
  static List<Product> get cartItems => _cartItems;
  
  static int get itemCount => _cartItems.length;
  
  static void removeFromCart(BuildContext context, Product product) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de eliminar "${product.nombre}" del carrito?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: Text('Sí'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      _cartItems.removeWhere((item) => item == product);
      cartNotifier.value = [..._cartItems]; // Usar spread operator
    }
  }
  
  static void clearCart() {
    _cartItems.clear();
    cartNotifier.value = List.from(_cartItems);
  }

  // Nuevo método: Obtener cantidad de un producto específico en el carrito
  static int getQuantityInCart(String productId) {
    return _cartItems.where((product) => product.id == productId).length;
  }

  // Nuevo método: Verificar si hay stock disponible
  static bool hasStockAvailable(Product product) {
    int quantityInCart = getQuantityInCart(product.id as String);
    return quantityInCart < product.stock;
  }

  // Nuevo método: Obtener stock disponible restante
  static int getAvailableStock(Product product) {
    int quantityInCart = getQuantityInCart(product.id as String);
    return product.stock - quantityInCart;
  }

  // Método corregido para lista simple de Product
  static void printCartContents() {
    print('=== CONTENIDO DEL CARRITO ===');
    print('Total items: $itemCount'); // Cambié totalItems por itemCount
    print('Precio total: \$${totalPrice.toStringAsFixed(2)}');
    print('Productos:');
    for (var product in _cartItems) {
      print('- ${product.nombre} = \$${product.precio.toStringAsFixed(2)}'); // Cambié item.product por product
    }
    print('=============================');
  }

  // Agregar método para calcular precio total
  static double get totalPrice {
    return _cartItems.fold(0.0, (sum, product) => sum + product.precio);
  }
}