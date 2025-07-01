import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ferre_app/models/product.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

class CartServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _localCartKey = 'local_cart';
  
  // StreamController para notificar cambios en el carrito local
  final StreamController<List<Product>> _localCartController = StreamController<List<Product>>.broadcast();

    // Agregar este método público para verificar y sincronizar automáticamente
  Future<bool> verificarYSincronizarCarrito(String userId) async {
    try {
      // Verificar si hay productos locales
      final tieneProductosLocales = await this.tieneProductosLocales();
      
      if (tieneProductosLocales) {
        print('Sincronizando carrito local con usuario: $userId');
        return await sincronizarCarritoAlLoguear(userId);
      }
      
      return true; // No hay nada que sincronizar
    } catch (e) {
      print('Error al verificar y sincronizar carrito: $e');
      return false;
    }
  }

  // Agregar producto al carrito (local o Firestore según el estado de autenticación)
  Future<bool> agregarACarrito(Product product, String? userId) async {
    try {
      if (userId != null && userId.isNotEmpty) {
        // Usuario logueado - guardar en Firestore
        return await _agregarAFirestore(product, userId);
      } else {
        // Usuario no logueado - guardar localmente
        return await _agregarLocalmente(product);
      }
    } catch (e) {
      print('Error al agregar al carrito: $e');
      return false;
    }
  }

  // Agregar producto a Firestore
  Future<bool> _agregarAFirestore(Product product, String userId) async {
    try {
      final carritoData = product.toJson();
      carritoData['fechaAgregado'] = Timestamp.now();
      carritoData['userId'] = userId;

      await _firestore
          .collection('carrito')
          .doc(userId)
          .collection('productos')
          .doc(product.id.toString())
          .set(carritoData);

      return true;
    } catch (e) {
      return false;
    }
  }

  // Agregar producto localmente
  Future<bool> _agregarLocalmente(Product product) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<Product> cartItems = await _obtenerCarritoLocal();
      
      // Verificar si el producto ya existe
      if (!cartItems.any((item) => item.id == product.id)) {
        cartItems.add(product);
        await _guardarCarritoLocal(cartItems);
        _localCartController.add(cartItems);
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Quitar producto del carrito
  Future<bool> quitarDeCarrito(int productId, String? userId) async {
    try {
      if (userId != null && userId.isNotEmpty) {
        // Usuario logueado - quitar de Firestore
        await _firestore
            .collection('carrito')
            .doc(userId)
            .collection('productos')
            .doc(productId.toString())
            .delete();
      } else {
        // Usuario no logueado - quitar localmente
        List<Product> cartItems = await _obtenerCarritoLocal();
        cartItems.removeWhere((item) => item.id == productId);
        await _guardarCarritoLocal(cartItems);
        _localCartController.add(cartItems);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  // Verificar si un producto está en el carrito
  Future<bool> estanEnCarrito(int productId, String? userId) async {
    try {
      if (userId != null && userId.isNotEmpty) {
        // Usuario logueado - verificar en Firestore
        final doc = await _firestore
            .collection('carrito')
            .doc(userId)
            .collection('productos')
            .doc(productId.toString())
            .get();
        return doc.exists;
      } else {
        // Usuario no logueado - verificar localmente
        List<Product> cartItems = await _obtenerCarritoLocal();
        return cartItems.any((item) => item.id == productId);
      }
    } catch (e) {
      return false;
    }
  }

  // Obtener carrito (local o Firestore)
  Future<List<Product>> obtenerCarrito(String? userId) async {
    try {
      if (userId != null && userId.isNotEmpty) {
        // Usuario logueado - obtener de Firestore
        final querySnapshot = await _firestore
            .collection('carrito')
            .doc(userId)
            .collection('productos')
            .orderBy('fechaAgregado', descending: true)
            .get();

        return querySnapshot.docs.map((doc) {
          final data = doc.data();
          data.remove('fechaAgregado');
          data.remove('userId');
          return Product.fromJson(data);
        }).toList();
      } else {
        // Usuario no logueado - obtener localmente
        return await _obtenerCarritoLocal();
      }
    } catch (e) {
      return [];
    }
  }

  // Stream del carrito (local o Firestore)
  Stream<List<Product>> carritoStream(String? userId) {
    if (userId != null && userId.isNotEmpty) {
      // Usuario logueado - stream de Firestore
      return _firestore
          .collection('carrito')
          .doc(userId)
          .collection('productos')
          .orderBy('fechaAgregado', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            data.remove('fechaAgregado');
            data.remove('userId');
            return Product.fromJson(data);
          }).toList());
    } else {
      // Usuario no logueado - stream local
      return _localCartController.stream.startsWith(_obtenerCarritoLocal());
    }
  }

  // Contar productos en el carrito
  Future<int> contarCarrito(String? userId) async {
    try {
      if (userId != null && userId.isNotEmpty) {
        // Usuario logueado
        final querySnapshot = await _firestore
            .collection('carrito')
            .doc(userId)
            .collection('productos')
            .get();
        return querySnapshot.docs.length;
      } else {
        // Usuario no logueado
        List<Product> cartItems = await _obtenerCarritoLocal();
        return cartItems.length;
      }
    } catch (e) {
      return 0;
    }
  }

  // Limpiar carrito
  Future<bool> limpiarCarrito(String? userId) async {
    try {
      if (userId != null && userId.isNotEmpty) {
        // Usuario logueado - limpiar Firestore
        final batch = _firestore.batch();
        final querySnapshot = await _firestore
            .collection('carrito')
            .doc(userId)
            .collection('productos')
            .get();

        for (var doc in querySnapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      } else {
        // Usuario no logueado - limpiar local
        await _guardarCarritoLocal([]);
        _localCartController.add([]);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  // Toggle carrito
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

  // MÉTODOS PARA MANEJO LOCAL
  Future<List<Product>> _obtenerCarritoLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(_localCartKey);
      
      if (cartJson != null) {
        final List<dynamic> cartList = json.decode(cartJson);
        return cartList.map((item) => Product.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<void> _guardarCarritoLocal(List<Product> products) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = json.encode(products.map((p) => p.toJson()).toList());
      await prefs.setString(_localCartKey, cartJson);
    } catch (e) {
      print('Error al guardar carrito local: $e');
    }
  }

  // SINCRONIZACIÓN AL LOGUEAR
  Future<bool> sincronizarCarritoAlLoguear(String userId) async {
    try {
      // Obtener carrito local
      List<Product> carritoLocal = await _obtenerCarritoLocal();
      
      if (carritoLocal.isEmpty) {
        return true; // No hay nada que sincronizar
      }

      // Obtener carrito existente en Firestore
      List<Product> carritoFirestore = await obtenerCarrito(userId);
      
      // Combinar carritos (evitar duplicados)
      Set<int> idsExistentes = carritoFirestore.map((p) => p.id).toSet();
      List<Product> nuevosProductos = carritoLocal.where((p) => !idsExistentes.contains(p.id)).toList();
      
      // Agregar productos nuevos a Firestore
      for (Product producto in nuevosProductos) {
        await _agregarAFirestore(producto, userId);
      }

      // Limpiar carrito local después de sincronizar
      await _guardarCarritoLocal([]);
      _localCartController.add([]);
      
      return true;
    } catch (e) {
      print('Error al sincronizar carrito: $e');
      return false;
    }
  }

  // Limpiar carrito local al cerrar sesión
  Future<void> limpiarCarritoLocal() async {
    try {
      await _guardarCarritoLocal([]);
      _localCartController.add([]);
    } catch (e) {
      print('Error al limpiar carrito local: $e');
    }
  }

  // Verificar si hay productos en el carrito local
  Future<bool> tieneProductosLocales() async {
    List<Product> carritoLocal = await _obtenerCarritoLocal();
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



