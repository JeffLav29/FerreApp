import 'package:ferre_app/models/product.dart';
import 'package:ferre_app/services/cart_manager.dart';
import 'package:ferre_app/services/whatsapp_service.dart';
import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final WhatsAppService _whatsappService = WhatsAppService();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _showCheckoutDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Finalizar Compra'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total: S/. ${CartManager.totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Tu nombre (opcional)',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Número de WhatsApp',
                    prefixIcon: Icon(Icons.phone),
                    hintText: '987654321',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Notas adicionales (opcional)',
                    prefixIcon: Icon(Icons.notes),
                    hintText: 'Dirección, método de pago, etc.',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FilledButton(
              onPressed: _isLoading ? null : _sendWhatsAppMessage,
              child: _isLoading 
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text('Enviar por WhatsApp'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendWhatsAppMessage() async {
    if (_phoneController.text.trim().isEmpty) {
      _showErrorSnackBar('Por favor, ingresa tu número de WhatsApp');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Crear map de cantidades - asumiendo que cada producto aparece una vez
      Map<int, int> quantities = {};
      for (var product in CartManager.cartItems) {
        quantities[product.id] = 1; // O la cantidad que manejes
      }

      final success = await _whatsappService.sendCartFromProducts(
        phoneNumber: _phoneController.text.trim(),
        products: CartManager.cartItems,
        quantities: quantities,
        totalAmount: CartManager.totalPrice,
        customerName: _nameController.text.trim().isNotEmpty 
            ? _nameController.text.trim() 
            : null,
        additionalNotes: _notesController.text.trim().isNotEmpty 
            ? _notesController.text.trim() 
            : null,
      );

      if (success) {
        Navigator.of(context).pop(); // Cerrar diálogo
        _showSuccessDialog();
        _clearForm();
      } else {
        _showErrorSnackBar('Error al enviar el mensaje. Verifica tu conexión.');
      }
    } catch (e) {
      _showErrorSnackBar('Error inesperado: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 10),
              Text('¡Pedido Enviado!'),
            ],
          ),
          content: Text(
            'Tu pedido ha sido enviado por WhatsApp exitosamente. '
            'Nos pondremos en contacto contigo pronto.',
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Opcional: limpiar carrito después del pedido
                _showClearCartDialog();
              },
              child: Text('Entendido'),
            ),
          ],
        );
      },
    );
  }

  void _showClearCartDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Limpiar Carrito'),
          content: Text('¿Deseas limpiar el carrito ahora?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('No'),
            ),
            FilledButton(
              onPressed: () {
                CartManager.clearCart();
                Navigator.of(context).pop();
                _showSuccessSnackBar('Carrito limpiado');
              },
              child: Text('Sí, limpiar'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _clearForm() {
    _phoneController.clear();
    _nameController.clear();
    _notesController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Productos en tu carrito',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ValueListenableBuilder<List<Product>>(
                valueListenable: CartManager.cartNotifier,
                builder: (context, cartItems, child) {
                  return cartItems.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shopping_cart_outlined,
                                size: 80,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 20),
                              Text(
                                'Tu carrito está vacío',
                                style: TextStyle(
                                  fontSize: 18, 
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: cartItems.length,
                          itemBuilder: (context, index) {
                            final product = cartItems[index];
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 5),
                              elevation: 2,
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
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
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.image_not_supported,
                                          color: Colors.grey[600],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                title: Text(
                                  product.nombre,
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (product.enOferta && product.precioOriginal != null) ...[
                                      Text(
                                        'S/. ${product.precioOriginal!.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          decoration: TextDecoration.lineThrough,
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        'S/. ${product.precio.toStringAsFixed(2)} (${product.porcentajeDescuento.toStringAsFixed(0)}% OFF)',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ] else
                                      Text(
                                        'S/. ${product.precio.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[700],
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    CartManager.removeFromCart(context, product);
                                  },
                                ),
                              ),
                            );
                          },
                        );
                },
              ),
            ),
            if (CartManager.cartItems.isNotEmpty) ...[
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: S/. ${CartManager.totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                    Text(
                      '${CartManager.itemCount} productos',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _showCheckoutDialog,
                      icon: Icon(Icons.whatshot_sharp, color: Colors.white),
                      label: Text('Finalizar compra'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}