import 'package:ferre_app/services/cart_manager.dart';
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Productos en tu carrito',style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),),

            SizedBox(height: 10,),

            Expanded(
              child: CartManager.cartItems.isEmpty
                  ? Center(
                      child: Text(
                        'Tu carrito está vacío',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: CartManager.cartItems.length,
                      itemBuilder: (context, index) {
                        final product = CartManager.cartItems[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            leading: Image.network(
                              product.imagenUrl.isNotEmpty 
                                  ? product.imagenUrl 
                                  : 'https://via.placeholder.com/50x50?text=Sin+Imagen',
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey[300],
                                  child: Icon(Icons.image_not_supported),
                                );
                              },
                            ),
                            title: Text(product.nombre),
                            subtitle: Text('S/. ${product.precio}'),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  CartManager.removeFromCart(product);
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),


            if (CartManager.cartItems.isNotEmpty)
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: S/. ${CartManager.totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${CartManager.itemCount} productos',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10,),


              Row(
                children: [
                  FilledButton(
                    onPressed: () {
                      
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(10.0)
                      ),
                      minimumSize: Size(390, 50)
                    ),
                    child: Text('Finalizar compra'),
                  ),
                ],
              ),
              

          ],
        ),
      ),
    );
  }
}