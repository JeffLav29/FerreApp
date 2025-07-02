import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ferre_app/models/product.dart';
import 'package:ferre_app/models/cart_item.dart'; // Importar el nuevo modelo
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

class CartServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _localCartKey = 'local_cart';
  
  // StreamController para notificar cambios en el carrito local
  final StreamController<List<CartItem>> _localCartController = StreamController<List<CartItem>>.broadcast();

  // Verificar y sincronizar automáticamente
  Future<bool> verificarYSincronizarCarrito(String userId) async {
    try {
      final tieneProductosLocales = await this.tieneProductosLocales();
      
      if (tieneProductosLocales) {
        debugPrint('Sincronizando carrito local con usuario: $userId');
        return await sincronizarCarritoAlLoguear(userId);
      }
      
      return true;
    } catch (e) {
      debugPrint('Error al verificar y sincronizar carrito: $e');
      return false;
    }
  }

  // Agregar producto al carrito (NUEVA LÓGICA CON CANTIDADES)
  Future<bool> agregarACarrito(Product product, String? userId, {int cantidad = 1}) async {
    try {
      if (userId != null && userId.isNotEmpty) {
        return await _agregarAFirestore(product, userId, cantidad);
      } else {
        return await _agregarLocalmente(product, cantidad);
      }
    } catch (e) {
      debugPrint('Error al agregar al carrito: $e');
      return false;
    }
  }

  // Agregar producto a Firestore con manejo de cantidades
  Future<bool> _agregarAFirestore(Product product, String userId, int cantidad) async {
    try {
      final docRef = _firestore
          .collection('carrito')
          .doc(userId)
          .collection('items')
          .doc(product.id.toString());

      // Verificar si el producto ya existe
      final docSnapshot = await docRef.get();
      
      if (docSnapshot.exists) {
        // Si existe, incrementar la cantidad
        final existingData = docSnapshot.data()!;
        final cantidadActual = existingData['cantidad'] ?? 1;
        final nuevaCantidad = cantidadActual + cantidad;
        
        await docRef.update({
          'cantidad': nuevaCantidad,
          'fechaActualizado': Timestamp.now(),
        });
      } else {
        // Si no existe, crear nuevo item
        final cartItem = CartItem.fromProduct(product, cantidad: cantidad);
        final carritoData = cartItem.toJson();
        carritoData['fechaAgregado'] = Timestamp.now();
        carritoData['fechaActualizado'] = Timestamp.now();
        carritoData['userId'] = userId;

        await docRef.set(carritoData);
      }

      return true;
    } catch (e) {
      debugPrint('Error al agregar a Firestore: $e');
      return false;
    }
  }

  // Agregar producto localmente con manejo de cantidades
  Future<bool> _agregarLocalmente(Product product, int cantidad) async {
    try {
      List<CartItem> cartItems = await _obtenerCarritoLocalItems();
      
      // Buscar si el producto ya existe
      final existingIndex = cartItems.indexWhere((item) => item.productId == product.id);
      
      if (existingIndex != -1) {
        // Si existe, incrementar la cantidad
        cartItems[existingIndex].cantidad += cantidad;
      } else {
        // Si no existe, agregar nuevo item
        cartItems.add(CartItem.fromProduct(product, cantidad: cantidad));
      }
      
      await _guardarCarritoLocalItems(cartItems);
      _localCartController.add(cartItems);
      
      return true;
    } catch (e) {
      debugPrint('Error al agregar localmente: $e');
      return false;
    }
  }

  // Actualizar cantidad de un producto específico
  Future<bool> actualizarCantidad(int productId, int nuevaCantidad, String? userId) async {
    try {
      if (nuevaCantidad <= 0) {
        return await quitarDeCarrito(productId, userId);
      }

      if (userId != null && userId.isNotEmpty) {
        // Actualizar en Firestore
        await _firestore
            .collection('carrito')
            .doc(userId)
            .collection('items')
            .doc(productId.toString())
            .update({
          'cantidad': nuevaCantidad,
          'fechaActualizado': Timestamp.now(),
        });
      } else {
        // Actualizar localmente
        List<CartItem> cartItems = await _obtenerCarritoLocalItems();
        final index = cartItems.indexWhere((item) => item.productId == productId);
        
        if (index != -1) {
          cartItems[index].cantidad = nuevaCantidad;
          await _guardarCarritoLocalItems(cartItems);
          _localCartController.add(cartItems);
        }
      }
      
      return true;
    } catch (e) {
      debugPrint('Error al actualizar cantidad: $e');
      return false;
    }
  }

  // Quitar producto del carrito
  Future<bool> quitarDeCarrito(int productId, String? userId) async {
    try {
      if (userId != null && userId.isNotEmpty) {
        await _firestore
            .collection('carrito')
            .doc(userId)
            .collection('items')
            .doc(productId.toString())
            .delete();
      } else {
        List<CartItem> cartItems = await _obtenerCarritoLocalItems();
        cartItems.removeWhere((item) => item.productId == productId);
        await _guardarCarritoLocalItems(cartItems);
        _localCartController.add(cartItems);
      }
      return true;
    } catch (e) {
      debugPrint('Error al quitar del carrito: $e');
      return false;
    }
  }

  // Verificar si un producto está en el carrito
  Future<bool> estanEnCarrito(int productId, String? userId) async {
    try {
      if (userId != null && userId.isNotEmpty) {
        final doc = await _firestore
            .collection('carrito')
            .doc(userId)
            .collection('items')
            .doc(productId.toString())
            .get();
        return doc.exists;
      } else {
        List<CartItem> cartItems = await _obtenerCarritoLocalItems();
        return cartItems.any((item) => item.productId == productId);
      }
    } catch (e) {
      return false;
    }
  }

  // Obtener cantidad específica de un producto
  Future<int> obtenerCantidadProducto(int productId, String? userId) async {
    try {
      if (userId != null && userId.isNotEmpty) {
        final doc = await _firestore
            .collection('carrito')
            .doc(userId)
            .collection('items')
            .doc(productId.toString())
            .get();
        
        if (doc.exists) {
          return doc.data()?['cantidad'] ?? 0;
        }
      } else {
        List<CartItem> cartItems = await _obtenerCarritoLocalItems();
        final item = cartItems.firstWhere(
          (item) => item.productId == productId,
          orElse: () => CartItem.fromProduct(
            Product(id: 0, nombre: '', descripcion: '', precio: 0, 
                   imagenUrl: '', categoria: '', marca: '', stock: 0),
            cantidad: 0,
          ),
        );
        return item.cantidad;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  // Obtener carrito como CartItems
  Future<List<CartItem>> obtenerCarritoItems(String? userId) async {
    try {
      if (userId != null && userId.isNotEmpty) {
        final querySnapshot = await _firestore
            .collection('carrito')
            .doc(userId)
            .collection('items')
            .orderBy('fechaAgregado', descending: true)
            .get();

        return querySnapshot.docs.map((doc) {
          final data = doc.data();
          data.remove('fechaAgregado');
          data.remove('fechaActualizado');
          data.remove('userId');
          return CartItem.fromJson(data);
        }).toList();
      } else {
        return await _obtenerCarritoLocalItems();
      }
    } catch (e) {
      debugPrint('Error al obtener carrito: $e');
      return [];
    }
  }

  // Obtener carrito como Products (para compatibilidad)
  Future<List<Product>> obtenerCarrito(String? userId) async {
    final cartItems = await obtenerCarritoItems(userId);
    return cartItems.map((item) => item.toProduct()).toList();
  }

  // Stream del carrito como CartItems
  Stream<List<CartItem>> carritoItemsStream(String? userId) {
    if (userId != null && userId.isNotEmpty) {
      return _firestore
          .collection('carrito')
          .doc(userId)
          .collection('items')
          .orderBy('fechaAgregado', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            data.remove('fechaAgregado');
            data.remove('fechaActualizado');
            data.remove('userId');
            return CartItem.fromJson(data);
          }).toList());
    } else {
      return _localCartController.stream.startsWith(_obtenerCarritoLocalItems());
    }
  }

  // Stream del carrito como Products (para compatibilidad)
  Stream<List<Product>> carritoStream(String? userId) {
    return carritoItemsStream(userId).map((cartItems) =>
        cartItems.map((item) => item.toProduct()).toList());
  }

  // Contar productos en el carrito (suma de cantidades)
  Future<int> contarCarrito(String? userId) async {
    try {
      final cartItems = await obtenerCarritoItems(userId);
      return cartItems.fold<int>(
        0,
        (int sum, CartItem item) => sum + item.cantidad,
      );
    } catch (e) {
      return 0;
    }
  }

  // Contar ítems únicos en el carrito
  Future<int> contarItemsUnicos(String? userId) async {
    try {
      final cartItems = await obtenerCarritoItems(userId);
      return cartItems.length;
    } catch (e) {
      return 0;
    }
  }

  // Calcular precio total del carrito
  Future<double> calcularTotalCarrito(String? userId) async {
    try {
      final cartItems = await obtenerCarritoItems(userId);
      return cartItems.fold<double>(
        0.0,
        (double sum, CartItem item) => sum + item.subtotal,
      );
    } catch (e) {
      return 0.0;
    }
  }


  // Limpiar carrito
  Future<bool> limpiarCarrito(String? userId) async {
    try {
      if (userId != null && userId.isNotEmpty) {
        final batch = _firestore.batch();
        final querySnapshot = await _firestore
            .collection('carrito')
            .doc(userId)
            .collection('items')
            .get();

        for (var doc in querySnapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      } else {
        await _guardarCarritoLocalItems([]);
        _localCartController.add([]);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  // Toggle carrito (mantener compatibilidad)
  Future<bool> toogleCarrito(Product product, String? userId) async {
    try {
      final estaEnCarrito = await estanEnCarrito(product.id, userId);
      
      if (estaEnCarrito) {
        return await quitarDeCarrito(product.id, userId);
      } else {
        return await agregarACarrito(product, userId);
      }
    } catch (e) {
      return false;
    }
  }

  // MÉTODOS PARA MANEJO LOCAL CON CARTITEM
  Future<List<CartItem>> _obtenerCarritoLocalItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(_localCartKey);
      
      if (cartJson != null) {
        final List<dynamic> cartList = json.decode(cartJson);
        return cartList.map((item) => CartItem.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error al obtener carrito local: $e');
      return [];
    }
  }

  Future<void> _guardarCarritoLocalItems(List<CartItem> cartItems) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = json.encode(cartItems.map((item) => item.toJson()).toList());
      await prefs.setString(_localCartKey, cartJson);
    } catch (e) {
      debugPrint('Error al guardar carrito local: $e');
    }
  }


  // SINCRONIZACIÓN AL LOGUEAR (actualizada)
  Future<bool> sincronizarCarritoAlLoguear(String userId) async {
    try {
      List<CartItem> carritoLocal = await _obtenerCarritoLocalItems();
      
      if (carritoLocal.isEmpty) {
        return true;
      }

      List<CartItem> carritoFirestore = await obtenerCarritoItems(userId);
      
      // Combinar carritos inteligentemente
      Map<int, CartItem> carritoFinal = {};
      
      // Agregar items de Firestore
      for (CartItem item in carritoFirestore) {
        carritoFinal[item.productId] = item;
      }
      
      // Combinar con items locales
      for (CartItem itemLocal in carritoLocal) {
        if (carritoFinal.containsKey(itemLocal.productId)) {
          // Si ya existe, sumar cantidades
          carritoFinal[itemLocal.productId]!.cantidad += itemLocal.cantidad;
        } else {
          // Si no existe, agregar
          carritoFinal[itemLocal.productId] = itemLocal;
        }
      }
      
      // Guardar items combinados en Firestore
      final batch = _firestore.batch();
      for (CartItem item in carritoFinal.values) {
        final docRef = _firestore
            .collection('carrito')
            .doc(userId)
            .collection('items')
            .doc(item.productId.toString());
        
        final data = item.toJson();
        data['fechaAgregado'] = Timestamp.now();
        data['fechaActualizado'] = Timestamp.now();
        data['userId'] = userId;
        
        batch.set(docRef, data, SetOptions(merge: true));
      }
      
      await batch.commit();

      // Limpiar carrito local
      await _guardarCarritoLocalItems([]);
      _localCartController.add([]);
      
      return true;
    } catch (e) {
      debugPrint('Error al sincronizar carrito: $e');
      return false;
    }
  }

  // Limpiar carrito local al cerrar sesión
  Future<void> limpiarCarritoLocal() async {
    try {
      await _guardarCarritoLocalItems([]);
      _localCartController.add([]);
    } catch (e) {
      debugPrint('Error al limpiar carrito local: $e');
    }
  }

  // Verificar si hay productos en el carrito local
  Future<bool> tieneProductosLocales() async {
    final carritoLocal = await _obtenerCarritoLocalItems();
    return carritoLocal.isNotEmpty;
  }

  // Dispose del StreamController
  void dispose() {
    _localCartController.close();
  }
}

// Extension para startsWith en Stream
extension StreamExtension<T> on Stream<T> {
  Stream<T> startsWith(Future<T> futureValue) async* {
    yield await futureValue;
    yield* this;
  }
}