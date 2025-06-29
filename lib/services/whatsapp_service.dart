import 'dart:convert';
import 'package:ferre_app/models/product.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class WhatsAppService {
  static const String _baseUrl = 'https://serviciowhatsapp-production.up.railway.app'; // ✅ ACTUALIZADO: URL de Railway
  static const String _apiEndpoint = '/api/whatsapp';
  static const String _apiKey = ''; // ✅ AGREGADO: API Key
  
  // Singleton pattern
  static final WhatsAppService _instance = WhatsAppService._internal();
  factory WhatsAppService() => _instance;
  WhatsAppService._internal();

  /// Envía un mensaje de texto simple - VERSION CON DEBUG
  Future<bool> sendTextMessage({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      final formattedPhone = _formatPhoneNumber(phoneNumber);
      final url = '$_baseUrl$_apiEndpoint/send-text';
      
      if (kDebugMode) {
        print('🔍 DEBUG WhatsApp Service:');
        print('📱 Número original: $phoneNumber');
        print('📱 Número formateado: $formattedPhone');
        print('🌐 URL: $url');
        print('📝 Mensaje: ${message.substring(0, message.length > 50 ? 50 : message.length)}...');
      }

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': _apiKey, // ✅ AGREGADO: API Key en headers
        },
        body: jsonEncode({
          'phoneNumber': formattedPhone,
          'message': message,
        }),
      );

      if (kDebugMode) {
        print('📊 Status Code: ${response.statusCode}');
        print('📄 Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          if (kDebugMode) {
            print('✅ Mensaje enviado exitosamente');
          }
          return true;
        } else {
          if (kDebugMode) {
            print('❌ Error del servidor: ${responseData['error']}');
          }
          return false;
        }
      } else {
        if (kDebugMode) {
          print('❌ Error HTTP: ${response.statusCode}');
          print('📄 Response body: ${response.body}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error de conexión: $e');
      }
      return false;
    }
  }

  /// Envía los productos del carrito como mensaje formateado
  Future<bool> sendCartProducts({
    required String phoneNumber,
    required List<CartItem> cartItems,
    required double totalAmount,
    String? customerName,
    String? additionalNotes,
  }) async {
    try {
      final String formattedMessage = _formatCartMessage(
        cartItems: cartItems,
        totalAmount: totalAmount,
        customerName: customerName,
        additionalNotes: additionalNotes,
      );

      return await sendTextMessage(
        phoneNumber: phoneNumber,
        message: formattedMessage,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error al enviar productos del carrito: $e');
      }
      return false;
    }
  }

  /// Versión que trabaja directamente con List<Product> y cantidades
  Future<bool> sendCartFromProducts({
    required String phoneNumber,
    required List<Product> products,
    required Map<int, int> quantities, // productId -> quantity
    required double totalAmount,
    String? customerName,
    String? additionalNotes,
  }) async {
    try {
      // Convertir productos a CartItems
      final List<CartItem> cartItems = products.map((product) {
        final quantity = quantities[product.id] ?? 1;
        return CartItem.fromProduct(product, quantity);
      }).toList();

      return await sendCartProducts(
        phoneNumber: phoneNumber,
        cartItems: cartItems,
        totalAmount: totalAmount,
        customerName: customerName,
        additionalNotes: additionalNotes,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error al enviar carrito desde productos: $e');
      }
      return false;
    }
  }

  /// Envía una imagen con caption
  Future<bool> sendImageMessage({
    required String phoneNumber,
    required String imagePath,
    String? caption,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$_apiEndpoint/send-image'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': _apiKey, // ✅ AGREGADO: API Key en headers
        },
        body: jsonEncode({
          'phoneNumber': _formatPhoneNumber(phoneNumber),
          'imagePath': imagePath,
          'caption': caption ?? '',
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error al enviar imagen: $e');
      }
      return false;
    }
  }

  /// Verifica el estado de la conexión con WhatsApp Web
  Future<bool> checkConnectionStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$_apiEndpoint/status'),
        headers: {
          'X-API-Key': _apiKey, // ✅ AGREGADO: API Key en headers
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['connected'] ?? false;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error al verificar estado de conexión: $e');
      }
      return false;
    }
  }

  /// Formatea el número de teléfono al formato internacional
  String _formatPhoneNumber(String phoneNumber) {
    // Remover espacios, guiones y paréntesis
    String cleaned = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Si no empieza con +, agregar código de país (ejemplo: +51 para Perú)
    if (!cleaned.startsWith('+')) {
      // Ajusta el código de país según tu ubicación
      cleaned = '+51$cleaned'; // Perú como ejemplo
    }
    
    // ✅ SOLUCIÓN: No agregar @c.us aquí, el servidor lo maneja
    return cleaned.replaceFirst('+', '');
  }

  /// Formatea el mensaje del carrito de compras
  String _formatCartMessage({
    required List<CartItem> cartItems,
    required double totalAmount,
    String? customerName,
    String? additionalNotes,
  }) {
    final StringBuffer message = StringBuffer();
    
    // Encabezado
    message.writeln('🛒 *RESUMEN DE COMPRA*');
    message.writeln('━━━━━━━━━━━━━━━━━━━━━━');
    
    if (customerName != null && customerName.isNotEmpty) {
      message.writeln('👤 *Cliente:* $customerName');
      message.writeln('');
    }
    
    // Lista de productos
    message.writeln('📋 *Productos:*');
    for (int i = 0; i < cartItems.length; i++) {
      final item = cartItems[i];
      message.writeln('${i + 1}. *${item.nombre}*');
      
      // Mostrar marca si existe
      if (item.marca != null && item.marca!.isNotEmpty) {
        message.writeln('   🏷️ Marca: ${item.marca}');
      }
      
      // Mostrar precio con descuento si aplica
      if (item.enOferta == true && item.precioOriginal != null) {
        message.writeln('   💰 Precio: ~S/. ${item.precioOriginal!.toStringAsFixed(2)}~ S/. ${item.precio.toStringAsFixed(2)} (${item.porcentajeDescuento.toStringAsFixed(0)}% OFF)');
      } else {
        message.writeln('   💰 Precio: S/. ${item.precio.toStringAsFixed(2)}');
      }
      
      message.writeln('   📦 Cantidad: ${item.quantity}');
      message.writeln('   💵 Subtotal: S/. ${item.subtotal.toStringAsFixed(2)}');
      
      if (i < cartItems.length - 1) message.writeln('');
    }
    
    message.writeln('━━━━━━━━━━━━━━━━━━━━━━');
    message.writeln('💰 *TOTAL: S/. ${totalAmount.toStringAsFixed(2)}*');
    
    if (additionalNotes != null && additionalNotes.isNotEmpty) {
      message.writeln('');
      message.writeln('📝 *Notas adicionales:*');
      message.writeln(additionalNotes);
    }
    
    message.writeln('');
    message.writeln('¡Gracias por tu compra! 🙏');
    message.writeln('En breve nos pondremos en contacto contigo.');
    
    return message.toString();
  }
}

/// Modelo para los items del carrito
class CartItem {
  final int id;
  final String nombre;
  final double precio;
  final int quantity;
  final String? descripcion;
  final String? imagenUrl;
  final String? marca;
  final bool? enOferta;
  final double? precioOriginal;

  CartItem({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.quantity,
    this.descripcion,
    this.imagenUrl,
    this.marca,
    this.enOferta,
    this.precioOriginal,
  });

  // Constructor desde Product
  factory CartItem.fromProduct(Product product, int quantity) {
    return CartItem(
      id: product.id,
      nombre: product.nombre,
      precio: product.precio,
      quantity: quantity,
      descripcion: product.descripcion,
      imagenUrl: product.imagenUrl,
      marca: product.marca,
      enOferta: product.enOferta,
      precioOriginal: product.precioOriginal,
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      precio: (json['precio'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      descripcion: json['descripcion'],
      imagenUrl: json['imagenUrl'],
      marca: json['marca'],
      enOferta: json['enOferta'],
      precioOriginal: json['precioOriginal'] != null 
          ? (json['precioOriginal']).toDouble() 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'precio': precio,
      'quantity': quantity,
      'descripcion': descripcion,
      'imagenUrl': imagenUrl,
      'marca': marca,
      'enOferta': enOferta,
      'precioOriginal': precioOriginal,
    };
  }

  // Getter para calcular subtotal
  double get subtotal => precio * quantity;

  // Getter para mostrar si tiene descuento
  double get porcentajeDescuento {
    if (enOferta == true && precioOriginal != null && precioOriginal! > precio) {
      return ((precioOriginal! - precio) / precioOriginal!) * 100;
    }
    return 0.0;
  }
}