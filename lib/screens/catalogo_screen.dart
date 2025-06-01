import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../data/productos_data.dart';
import '../widgets/producto_card.dart';
import '../widgets/categoria_chip.dart';

class CatalogoScreen extends StatefulWidget {
  @override
  _CatalogoScreenState createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  String categoriaSeleccionada = 'Todas';
  String busqueda = '';
  List<Producto> productosFiltrados = [];

  @override
  void initState() {
    super.initState();
    productosFiltrados = productosEjemplo;
  }

  List<String> get categorias {
    Set<String> cats = {'Todas'};
    cats.addAll(productosEjemplo.map((p) => p.categoria));
    return cats.toList();
  }

  void _filtrarProductos() {
    setState(() {
      productosFiltrados = productosEjemplo.where((producto) {
        bool coincideCategoria = categoriaSeleccionada == 'Todas' || 
                                producto.categoria == categoriaSeleccionada;
        bool coincideBusqueda = busqueda.isEmpty || 
                               producto.nombre.toLowerCase().contains(busqueda.toLowerCase()) ||
                               producto.descripcion.toLowerCase().contains(busqueda.toLowerCase());
        return coincideCategoria && coincideBusqueda;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Ferretería El Martillo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Container(
            color: Colors.blue[700],
            padding: EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                busqueda = value;
                _filtrarProductos();
              },
              decoration: InputDecoration(
                hintText: 'Buscar productos...',
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          // Filtros de categoría
          Container(
            height: 60,
            padding: EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: categorias.length,
              itemBuilder: (context, index) {
                String categoria = categorias[index];
                return CategoriaChip(
                  categoria: categoria,
                  isSelected: categoriaSeleccionada == categoria,
                  onTap: () {
                    setState(() {
                      categoriaSeleccionada = categoria;
                    });
                    _filtrarProductos();
                  },
                );
              },
            ),
          ),
          // Información de resultados
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${productosFiltrados.length} productos encontrados',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                DropdownButton<String>(
                  value: 'Nombre',
                  items: ['Nombre', 'Precio menor', 'Precio mayor']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: TextStyle(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      _ordenarProductos(newValue);
                    }
                  },
                  underline: Container(),
                ),
              ],
            ),
          ),
          // Grid de productos
          Expanded(
            child: productosFiltrados.isEmpty
                ? _buildEmptyState()
                : GridView.builder(
                    padding: EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: productosFiltrados.length,
                    itemBuilder: (context, index) {
                      return ProductoCard(producto: productosFiltrados[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Carrito de compras (próximamente)'),
              backgroundColor: Colors.blue[700],
            ),
          );
        },
        backgroundColor: Colors.blue[700],
        child: Icon(Icons.shopping_cart, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No se encontraron productos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Intenta con otros términos de búsqueda',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _ordenarProductos(String criterio) {
    setState(() {
      switch (criterio) {
        case 'Precio menor':
          productosFiltrados.sort((a, b) => a.precio.compareTo(b.precio));
          break;
        case 'Precio mayor':
          productosFiltrados.sort((a, b) => b.precio.compareTo(a.precio));
          break;
        case 'Nombre':
        default:
          productosFiltrados.sort((a, b) => a.nombre.compareTo(b.nombre));
          break;
      }
    });
  }
}
