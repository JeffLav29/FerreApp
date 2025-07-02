import 'package:ferre_app/models/cart_item.dart' as models;
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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;

  // ✅ NUEVO: Números fijos disponibles
  final List<Map<String, String>> _availableNumbers = [
    {
      'number': '900335726',
      'name': 'Ventas Principal',
      'description': 'Atención general y consultas'
    },
    {
      'number': '907906862',
      'name': 'Ventas Secundaria',
      'description': 'Productos técnicos y cotizaciones'
    },
  ];

  // ✅ NUEVO: Variable para almacenar el número seleccionado
  String? _selectedPhoneNumber;

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Getter para verificar si el usuario está logueado
  bool get _isUserLoggedIn => widget.userId != null && widget.userId!.isNotEmpty;

  // Actualizado para usar CartItem con el alias
  double _calculateTotalPrice(List<models.CartItem> cartItems) {
    return cartItems.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  // Actualizado para usar CartItem con el alias
  int _calculateTotalQuantity(List<models.CartItem> cartItems) {
    return cartItems.fold(0, (sum, item) => sum + item.cantidad);
  }

  // ✅ MODIFICADO: Diálogo actualizado con selección de números
  Future<void> _showCheckoutDialog(List<models.CartItem> cartItems) async {
    final totalPrice = _calculateTotalPrice(cartItems);
    final totalQuantity = _calculateTotalQuantity(cartItems);
    
    // Si no está logueado, mostrar diálogo de inicio de sesión primero
    if (!_isUserLoggedIn) {
      _showLoginRequiredDialog();
      return;
    }
    
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
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
                    Text(
                      'Productos: $totalQuantity unidades',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Campo de nombre
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
                    
                    // ✅ NUEVO: Selector de números de WhatsApp
                    const Text(
                      'Selecciona el número de WhatsApp:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    // Lista de números disponibles
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: _availableNumbers.map((numberInfo) {
                          return RadioListTile<String>(
                            title: Row(
                              children: [
                                const Icon(Icons.phone, size: 16, color: Colors.green),
                                const SizedBox(width: 8),
                                Text(
                                  numberInfo['number']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  numberInfo['name']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue,
                                  ),
                                ),
                                Text(
                                  numberInfo['description']!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            value: numberInfo['number'].toString(),
                            groupValue: _selectedPhoneNumber,
                            onChanged: (String? value) {
                              setDialogState(() {
                                _selectedPhoneNumber = value;
                              });
                            },
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    
                    const SizedBox(height: 15),
                    
                    // Campo de notas
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

  // ✅ MODIFICADO: Validación del número seleccionado
  Future<void> _sendWhatsAppMessage(List<models.CartItem> cartItems, double totalPrice) async {
    if (_selectedPhoneNumber == null || _selectedPhoneNumber!.isEmpty) {
      _showErrorSnackBar('Por favor, selecciona un número de WhatsApp');
      return;
    }

    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Convertir CartItems a Products y crear map de cantidades
      List<Product> products = cartItems.map((item) => item.toProduct()).toList();
      Map<int, int> quantities = {};
      
      for (var item in cartItems) {
        quantities[item.productId] = item.cantidad;
      }

      final success = await _whatsappService.sendCartFromProducts(
        phoneNumber: _selectedPhoneNumber!, // ✅ CAMBIADO: Usar número seleccionado
        products: products,
        quantities: quantities,
        totalAmount: totalPrice,
        customerName: _nameController.text.trim().isNotEmpty 
            ? _nameController.text.trim() 
            : null,
        additionalNotes: _notesController.text.trim().isNotEmpty 
            ? _notesController.text.trim() 
            : null,
      );

      if (!mounted) return;

      if (success) {
        Navigator.of(context).pop(); // Cerrar diálogo
        _showSuccessDialog();
        _clearForm();
      } else {
        _showErrorSnackBar('Error al enviar el mensaje. Verifica tu conexión.');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error inesperado: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
              // Capturar la referencia del Navigator antes de la operación async
              final navigator = Navigator.of(context);
              
              try {
                final success = await _cartService.limpiarCarrito(widget.userId);
                
                // Cerrar el diálogo usando la referencia capturada
                navigator.pop();
                
                if (success) {
                  _showSuccessSnackBar('Carrito limpiado');
                } else {
                  _showErrorSnackBar('Error al limpiar el carrito');
                }
              } catch (e) {
                // En caso de error inesperado
                navigator.pop();
                _showErrorSnackBar('Error inesperado al limpiar el carrito: $e');
              }
            },
            child: const Text('Sí, limpiar'),
          ),
        ],
      );
    },
  );
}

  // Actualizado para usar CartItem con el alias
  Future<void> _removeFromCart(models.CartItem cartItem) async {
    final success = await _cartService.quitarDeCarrito(cartItem.productId, widget.userId);
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${cartItem.nombre} removido del carrito'),
            backgroundColor: Colors.orange[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        _showErrorSnackBar('Error al remover del carrito');
      } 
    }
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

  // ✅ MODIFICADO: Limpiar también la selección de número
  void _clearForm() {
    _nameController.clear();
    _notesController.clear();
    _selectedPhoneNumber = null; // ✅ NUEVO: Limpiar selección
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

  // Actualizado para mostrar solo la cantidad sin controles de + y -
  Widget _buildCartList(List<models.CartItem> cartItems) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cartItems.length,
      itemBuilder: (context, index) {
        final cartItem = cartItems[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen del producto
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    cartItem.imagenUrl.isNotEmpty
                        ? cartItem.imagenUrl
                        : 'https://via.placeholder.com/60x60?text=Sin+Imagen',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 60,
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
                const SizedBox(width: 12),
                
                // Información del producto
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cartItem.nombre,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      
                      // Precio y descuento
                      if (cartItem.enOferta && cartItem.precioOriginal != null) ...[
                        Text(
                          'S/. ${cartItem.precioOriginal!.toStringAsFixed(2)}',
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'S/. ${cartItem.precio.toStringAsFixed(2)} (${cartItem.porcentajeDescuento.toStringAsFixed(0)}% OFF)',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ] else
                        Text(
                          'S/. ${cartItem.precio.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                            fontSize: 16,
                          ),
                        ),
                      
                      const SizedBox(height: 8),
                      
                      // Cantidad y subtotal
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Solo mostrar cantidad
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: Text(
                              'Cantidad: ${cartItem.cantidad}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          
                          // Subtotal
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Subtotal:',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                'S/. ${cartItem.subtotal.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Botón eliminar
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeFromCart(cartItem),
                      tooltip: 'Eliminar producto',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<models.CartItem>>(
        stream: _cartService.carritoItemsStream(widget.userId), // Cambiar a carritoItemsStream
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
          final totalQuantity = _calculateTotalQuantity(cartItems);

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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${cartItems.length} producto${cartItems.length > 1 ? 's' : ''}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            Text(
                              '$totalQuantity unidad${totalQuantity > 1 ? 'es' : ''}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
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