import 'package:ferre_app/models/product.dart';
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
  
  static void removeFromCart(BuildContext context, Product product, {VoidCallback? onRemoved}) async {
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

    // Solo eliminar si el usuario confirmó
    if (confirmDelete == true) {
      _cartItems.remove(product);
      cartNotifier.value = List.from(_cartItems);
      // Llamar al callback si se proporciona
      onRemoved?.call();
    }
  }
  
  static void clearCart() {
    _cartItems.clear();
    cartNotifier.value = List.from(_cartItems);
  }

  // Agregar método para calcular precio total
  static double get totalPrice {
    return _cartItems.fold(0.0, (sum, product) => sum + product.precio);
  }
}