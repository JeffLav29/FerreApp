class Product {
  final int id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String imagenUrl;
  final String categoria;
  final String marca;
  final int stock;
  final double rating;
  final bool enOferta;
  final double? precioOriginal; // Para mostrar descuentos

  Product({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.imagenUrl,
    required this.categoria,
    required this.marca,
    required this.stock,
    this.rating = 0.0,
    this.enOferta = false,
    this.precioOriginal,
  });

  // Factory constructor mejorado para crear desde JSON/Firestore
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: _parseId(json['id']),
      nombre: json['nombre']?.toString() ?? 'Sin nombre',
      descripcion: json['descripcion']?.toString() ?? 'Sin descripción',
      precio: _parseDouble(json['precio']),
      imagenUrl: json['imagenUrl']?.toString() ?? '',
      categoria: json['categoria']?.toString() ?? 'Sin categoría',
      marca: json['marca']?.toString() ?? 'Sin marca',
      stock: _parseInt(json['stock']),
      rating: _parseDouble(json['rating']),
      enOferta: json['enOferta'] == true,
      precioOriginal: json['precioOriginal'] != null 
          ? _parseDouble(json['precioOriginal']) 
          : null,
    );
  }

  // Factory constructor específico para Firestore DocumentSnapshot
  factory Product.fromFirestore(Map<String, dynamic> data, String documentId) {
    // Si no tiene ID, usamos el hash del documentId
    if (!data.containsKey('id')) {
      data['id'] = documentId.hashCode;
    }
    return Product.fromJson(data);
  }

  // Método para convertir a JSON/Map para Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'imagenUrl': imagenUrl,
      'categoria': categoria,
      'marca': marca,
      'stock': stock,
      'rating': rating,
      'enOferta': enOferta,
      'precioOriginal': precioOriginal,
    };
  }

  

  // Método para convertir a Map sin el ID (útil para Firestore)
  Map<String, dynamic> toFirestore() {
    final data = toJson();
    data.remove('id'); // Firestore maneja sus propios IDs
    return data;
  }

  // Métodos auxiliares para parsing seguro
  static int _parseId(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? value.hashCode;
    return value.hashCode;
  }

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

  // Getter para saber si está disponible
  bool get estaDisponible => stock > 0;

  // Getter para calcular el descuento
  double get porcentajeDescuento {
    if (enOferta && precioOriginal != null && precioOriginal! > precio) {
      return ((precioOriginal! - precio) / precioOriginal!) * 100;
    }
    return 0.0;
  }

  // Método para crear una copia con cambios
  Product copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    double? precio,
    String? imagenUrl,
    String? categoria,
    String? marca,
    int? stock,
    double? rating,
    bool? enOferta,
    double? precioOriginal,
  }) {
    return Product(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      precio: precio ?? this.precio,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      categoria: categoria ?? this.categoria,
      marca: marca ?? this.marca,
      stock: stock ?? this.stock,
      rating: rating ?? this.rating,
      enOferta: enOferta ?? this.enOferta,
      precioOriginal: precioOriginal ?? this.precioOriginal,
    );
  }

  @override
  String toString() {
    return 'Product{id: $id, nombre: $nombre, precio: $precio, stock: $stock}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}