import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart, size: 64, color: Colors.blue),
          SizedBox(height: 16),
          Text(
            'Carrito de Compras',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text('Aquí irán los productos del carrito'),
        ],
      ),
    );
  }
}