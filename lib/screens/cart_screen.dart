import 'package:ferre_app/models/product.dart';
import 'package:ferre_app/screens/login_screen.dart';
import 'package:ferre_app/services/cart_services.dart';
import 'package:ferre_app/services/whatsapp_service.dart';
import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  final String? userId; // Cambiado a nullable para soportar usuarios no logueados
  
  const CartScreen({
    super.key,
    this.userId, // Ahora es opcional
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartServices _cartService = CartServices();
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

  // Getter para verificar si el usuario está logueado
  bool get _isUserLoggedIn => widget.userId != null && widget.userId!.isNotEmpty;

  double _calculateTotalPrice(List<Product> products) {
    return products.fold(0.0, (sum, product) => sum + product.precio);
  }

  Future<void> _showCheckoutDialog(List<Product> cartItems) async {
    final totalPrice = _calculateTotalPrice(cartItems);
    
    // Si no está logueado, mostrar diálogo de inicio de sesión primero
    if (!_isUserLoggedIn) {
      _showLoginRequiredDialog();
      return;
    }
    
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Finalizar Compra'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total: S/. ${totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Tu nombre (opcional)',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Número de WhatsApp',
                    prefixIcon: const Icon(Icons.phone),
                    hintText: '987654321',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Notas adicionales (opcional)',
                    prefixIcon: const Icon(Icons.notes),
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
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FilledButton(
              onPressed: _isLoading ? null : () => _sendWhatsAppMessage(cartItems, totalPrice),
              child: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Enviar por WhatsApp'),
            ),
          ],
        );
      },
    );
  }

  // Diálogo para requerir inicio de sesión
  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.login, color: Colors.blue),
              SizedBox(width: 10),
              Text('Inicio Requerido'),
            ],
          ),
          content: const Text(
            'Para finalizar tu compra necesitas iniciar sesión.\n\n'
            'Tus productos se mantendrán en el carrito después de iniciar sesión.',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Más tarde'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen(),)
                );
              },
              child: const Text('Iniciar Sesión'),
            ),
          ],
        );
      },
    );
  }


  Future<void> _sendWhatsAppMessage(List<Product> cartItems, double totalPrice) async {
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
      for (var product in cartItems) {
        quantities[product.id] = 1; // O la cantidad que manejes
      }

      final success = await _whatsappService.sendCartFromProducts(
        phoneNumber: _phoneController.text.trim(),
        products: cartItems,
        quantities: quantities,
        totalAmount: totalPrice,
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
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 10),
              Text('¡Pedido Enviado!'),
            ],
          ),
          content: const Text(
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
              child: const Text('Entendido'),
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
          title: const Text('Limpiar Carrito'),
          content: const Text('¿Deseas limpiar el carrito ahora?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No'),
            ),
            FilledButton(
              onPressed: () async {
                final success = await _cartService.limpiarCarrito(widget.userId);
                Navigator.of(context).pop();
                
                if (success) {
                  _showSuccessSnackBar('Carrito limpiado');
                } else {
                  _showErrorSnackBar('Error al limpiar el carrito');
                }
              },
              child: const Text('Sí, limpiar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _removeFromCart(Product product) async {
    final success = await _cartService.quitarDeCarrito(product.id, widget.userId);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.nombre} removido del carrito'),
          backgroundColor: Colors.orange[600],
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      _showErrorSnackBar('Error al remover del carrito');
    }
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Limpiar carrito'),
          content: const Text('¿Estás seguro de que quieres eliminar todos los productos del carrito?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final success = await _cartService.limpiarCarrito(widget.userId);
                Navigator.of(context).pop();
                
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Todos los productos han sido eliminados del carrito'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else {
                  _showErrorSnackBar('Error al eliminar productos del carrito');
                }
              },
              child: const Text('Eliminar todo', style: TextStyle(color: Colors.red)),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Tu carrito está vacío',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isUserLoggedIn 
              ? 'Agrega productos al carrito para verlos aquí'
              : 'Agrega productos al carrito para verlos aquí\n(No necesitas iniciar sesión para agregar productos)',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList(List<Product> cartItems) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cartItems.length,
      itemBuilder: (context, index) {
        final product = cartItems[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (product.enOferta && product.precioOriginal != null) ...[
                  Text(
                    'S/. ${product.precioOriginal!.toStringAsFixed(2)}',
                    style: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'S/. ${product.precio.toStringAsFixed(2)} (${product.porcentajeDescuento.toStringAsFixed(0)}% OFF)',
                    style: const TextStyle(
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
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _removeFromCart(product),
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isUserLoggedIn ? 'Mi Carrito' : 'Carrito Temporal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () => _showClearAllDialog(),
            tooltip: 'Limpiar todo',
          ),
        ],
      ),
      body: StreamBuilder<List<Product>>(
        stream: _cartService.carritoStream(widget.userId),
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
                    'Error al cargar el carrito',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.red[600],
                    ),
                  ),
                ],
              ),
            );
          }

          final cartItems = snapshot.data ?? [];

          if (cartItems.isEmpty) {
            return Column(
              children: [
                Expanded(child: _buildEmptyState()),
              ],
            );
          }

          final totalPrice = _calculateTotalPrice(cartItems);

          return Column(
            children: [
              Expanded(
                child: _buildCartList(cartItems),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total: S/. ${totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                        Text(
                          '${cartItems.length} productos',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => _showCheckoutDialog(cartItems),
                        icon: Icon(
                          _isUserLoggedIn ? Icons.whatshot_sharp : Icons.login,
                          color: Colors.white,
                        ),
                        label: Text(_isUserLoggedIn ? 'Finalizar compra' : 'Iniciar sesión para comprar'),
                        style: FilledButton.styleFrom(
                          backgroundColor: _isUserLoggedIn ? Colors.green : Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}