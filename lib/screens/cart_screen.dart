import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: [
            Text('Productos en tu carrito',style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),),

            SizedBox(height: 10,)

            
          ],
        ),
      ),
    );
  }
}