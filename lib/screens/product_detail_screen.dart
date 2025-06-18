import 'package:ferre_app/models/product.dart';
import 'package:flutter/material.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;


  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle del producto'),
        backgroundColor: Colors.blue,
        centerTitle: false,
      ),

      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              widget.product.imagenUrl.isNotEmpty
                ? widget.product.imagenUrl
                : 'https://via.placeholder.com/300x200?text=Sin+Imagen',
            ),
        
            SizedBox(height: 10),
        
            Text('Descripcion Técnica',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
            SizedBox(height: 10),
        
            Text('Precio', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
            Text('${widget.product.precio} Soles', style: TextStyle(color: Colors.blueGrey),),

            SizedBox(height: 10),

            Container(
              padding: EdgeInsets.all(6.0),
              width: 400,
              decoration: BoxDecoration(
                border: Border.all(
                  color: widget.product.stock>0 ? Colors.green : Colors.red,
                ),
                borderRadius: BorderRadius.circular(4.0),
                color: widget.product.stock>0?Colors.green.shade50 : Colors.red.shade50,
                
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Disponibilidad',style: TextStyle(color: Colors.grey),),
                
                    Text(widget.product.stock>0?'En stock: ${widget.product.stock}': 'Agotado', style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500
                    ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 10),

            FilledButton(
              onPressed: () {
                
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: Size(400, 50)
              ),
              child: Text('Agregar a favoritos'),
            ),

            SizedBox(height: 10),

            FilledButton(
              onPressed: () {
                
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 124, 1, 206),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: Size(400, 50),
              ),
              child: Text('Agregar al carrito'),
            )
          ],
        ),
      ),
    );
  }
}