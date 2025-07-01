import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ferre_app/models/product.dart';

class FavoritosService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Agregar producto a favoritos (usando Product directamente)
  Future<bool> agregarAFavoritos(Product product, String userId) async {
    try {
      // Convertir Product a Map y agregar metadata de favorito
      final favoritoData = product.toJson();
      favoritoData['fechaAgregado'] = Timestamp.now();
      favoritoData['userId'] = userId;
      
      await _firestore
          .collection('favoritos')
          .doc(userId)
          .collection('productos')
          .doc(product.id.toString())
          .set(favoritoData);
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Quitar producto de favoritos
  Future<bool> quitarDeFavoritos(int productId, String userId) async {
    try {
      await _firestore
          .collection('favoritos')
          .doc(userId)
          .collection('productos')
          .doc(productId.toString())
          .delete();
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Verificar si un producto está en favoritos
  Future<bool> estaEnFavoritos(int productId, String userId) async {
    try {
      final doc = await _firestore
          .collection('favoritos')
          .doc(userId)
          .collection('productos')
          .doc(productId.toString())
          .get();
      
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // Obtener todos los favoritos como List<Product>
  Future<List<Product>> obtenerFavoritos(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('favoritos')
          .doc(userId)
          .collection('productos')
          .orderBy('fechaAgregado', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        // Remover metadata antes de crear Product
        data.remove('fechaAgregado');
        data.remove('userId');
        return Product.fromJson(data);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Stream para favoritos en tiempo real como List<Product>
  Stream<List<Product>> favoritosStream(String userId) {
    return _firestore
        .collection('favoritos')
        .doc(userId)
        .collection('productos')
        .orderBy('fechaAgregado', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
          final data = doc.data();
          // Remover metadata antes de crear Product
          data.remove('fechaAgregado');
          data.remove('userId');
          return Product.fromJson(data);
        }).toList());
  }

  // Obtener favoritos con fecha de agregado (si necesitas esa info)
  Future<List<Map<String, dynamic>>> obtenerFavoritosConFecha(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('favoritos')
          .doc(userId)
          .collection('productos')
          .orderBy('fechaAgregado', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'product': Product.fromJson({
            ...data
            ..remove('fechaAgregado')
            ..remove('userId')
          }),
          'fechaAgregado': (data['fechaAgregado'] as Timestamp).toDate(),
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Obtener cantidad de favoritos
  Future<int> contarFavoritos(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('favoritos')
          .doc(userId)
          .collection('productos')
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  // Limpiar todos los favoritos
  Future<bool> limpiarFavoritos(String userId) async {
    try {
      final batch = _firestore.batch();
      final querySnapshot = await _firestore
          .collection('favoritos')
          .doc(userId)
          .collection('productos')
          .get();

      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Toggle favorito (agregar/quitar en una sola función)
  Future<bool> toggleFavorito(Product product, String userId) async {
    try {
      final esFavorito = await estaEnFavoritos(product.id, userId);
      
      if (esFavorito) {
        return await quitarDeFavoritos(product.id, userId);
      } else {
        return await agregarAFavoritos(product, userId);
      }
    } catch (e) {
      return false;
    }
  }
}