import 'package:ferre_app/models/product.dart';

class CartItem {
  final int productId;
  final String nombre;
  final String descripcion;
  final double precio;
  final String imagenUrl;
  final String categoria;
  final String marca;
  final bool enOferta;
  final double? precioOriginal;
  int cantidad;
  final DateTime fechaAgregado;

  CartItem({
    required this.productId,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.imagenUrl,
    required this.categoria,
    required this.marca,
    this.enOferta = false,
    this.precioOriginal,
    this.cantidad = 1,
    DateTime? fechaAgregado,
  }) : fechaAgregado = fechaAgregado ?? DateTime.now();

  // Constructor desde Product
  factory CartItem.fromProduct(Product product, {int cantidad = 1}) {
    return CartItem(
      productId: product.id,
      nombre: product.nombre,
      descripcion: product.descripcion,
      precio: product.precio,
      imagenUrl: product.imagenUrl,
      categoria: product.categoria,
      marca: product.marca,
      enOferta: product.enOferta,
      precioOriginal: product.precioOriginal,
      cantidad: cantidad,
    );
  }

  // Factory constructor desde JSON
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: _parseInt(json['productId']),
      nombre: json['nombre']?.toString() ?? 'Sin nombre',
      descripcion: json['descripcion']?.toString() ?? 'Sin descripción',
      precio: _parseDouble(json['precio']),
      imagenUrl: json['imagenUrl']?.toString() ?? '',
      categoria: json['categoria']?.toString() ?? 'Sin categoría',
      marca: json['marca']?.toString() ?? 'Sin marca',
      enOferta: json['enOferta'] == true,
      precioOriginal: json['precioOriginal'] != null 
          ? _parseDouble(json['precioOriginal']) 
          : null,
      cantidad: _parseInt(json['cantidad']) > 0 ? _parseInt(json['cantidad']) : 1,
      fechaAgregado: json['fechaAgregado'] != null 
          ? DateTime.parse(json['fechaAgregado']) 
          : DateTime.now(),
    );
  }

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'imagenUrl': imagenUrl,
      'categoria': categoria,
      'marca': marca,
      'enOferta': enOferta,
      'precioOriginal': precioOriginal,
      'cantidad': cantidad,
      'fechaAgregado': fechaAgregado.toIso8601String(),
    };
  }

  // Convertir a Product (para compatibilidad con código existente)
  Product toProduct() {
    return Product(
      id: productId,
      nombre: nombre,
      descripcion: descripcion,
      precio: precio,
      imagenUrl: imagenUrl,
      categoria: categoria,
      marca: marca,
      stock: 0, // No manejamos stock en el carrito
      rating: 0.0,
      enOferta: enOferta,
      precioOriginal: precioOriginal,
    );
  }

  // Métodos auxiliares para parsing seguro
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // Getters útiles
  double get subtotal => precio * cantidad;
  
  double get porcentajeDescuento {
    if (enOferta && precioOriginal != null && precioOriginal! > precio) {
      return ((precioOriginal! - precio) / precioOriginal!) * 100;
    }
    return 0.0;
  }

  // Métodos para manejar cantidad
  void incrementarCantidad() {
    cantidad++;
  }

  void decrementarCantidad() {
    if (cantidad > 1) {
      cantidad--;
    }
  }

  void setCantidad(int nuevaCantidad) {
    if (nuevaCantidad > 0) {
      cantidad = nuevaCantidad;
    }
  }

  // Método para crear una copia con cambios
  CartItem copyWith({
    int? productId,
    String? nombre,
    String? descripcion,
    double? precio,
    String? imagenUrl,
    String? categoria,
    String? marca,
    bool? enOferta,
    double? precioOriginal,
    int? cantidad,
    DateTime? fechaAgregado,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      precio: precio ?? this.precio,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      categoria: categoria ?? this.categoria,
      marca: marca ?? this.marca,
      enOferta: enOferta ?? this.enOferta,
      precioOriginal: precioOriginal ?? this.precioOriginal,
      cantidad: cantidad ?? this.cantidad,
      fechaAgregado: fechaAgregado ?? this.fechaAgregado,
    );
  }

  @override
  String toString() {
    return 'CartItem{productId: $productId, nombre: $nombre, cantidad: $cantidad, subtotal: $subtotal}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem && other.productId == productId;
  }

  @override
  int get hashCode => productId.hashCode;
}