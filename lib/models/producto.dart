class Producto {
  final int id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String categoria;
  final String imagen;
  final int stock;

  Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.categoria,
    required this.imagen,
    required this.stock,
  });
}