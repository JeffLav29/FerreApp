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

  // Factory constructor para crear desde JSON (útil para APIs)
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      precio: json['precio'].toDouble(),
      imagenUrl: json['imagenUrl'],
      categoria: json['categoria'],
      marca: json['marca'],
      stock: json['stock'],
      rating: json['rating']?.toDouble() ?? 0.0,
      enOferta: json['enOferta'] ?? false,
      precioOriginal: json['precioOriginal']?.toDouble(),
    );
  }

  // Método para convertir a JSON
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

  // Getter para saber si está disponible
  bool get estaDisponible => stock > 0;

  // Getter para calcular el descuento
  double get porcentajeDescuento {
    if (enOferta && precioOriginal != null && precioOriginal! > precio) {
      return ((precioOriginal! - precio) / precioOriginal!) * 100;
    }
    return 0.0;
  }
}