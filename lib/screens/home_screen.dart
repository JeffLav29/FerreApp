import 'package:ferre_app/models/product.dart';
import 'package:ferre_app/widgets/product_card.dart';
import 'package:flutter/material.dart';

class AppConstants {
  static const List<String> categories = [
    'Todas',
    'Herramientas',
    'Tornillos',
    'Pinturas',
    'Electricidad',
    'Plomeria'
  ];
  
  static const double defaultPadding = 16.0;
  static const double borderRadius = 15.0;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Todas';
  
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadProducts() {
    _allProducts = [
      Product(
        id: 1,
        nombre: 'Taladro Inalámbrico 18V',
        descripcion: 'Taladro inalámbrico con batería de litio 18V',
        precio: 299.99,
        imagenUrl: '',
        categoria: 'Herramientas',
        marca: 'Black & Decker',
        stock: 15,
        rating: 4.8,
      ),
      Product(
        id: 2,
        nombre: 'Tornillos Autorroscantes x100',
        descripcion: 'Pack de 100 tornillos autorroscantes 3.5x25mm',
        precio: 12.50,
        imagenUrl: '',
        categoria: 'Tornillos',
        marca: 'Stanley',
        stock: 50,
        rating: 4.2,
      ),
      Product(
        id: 3,
        nombre: 'Pintura Látex Blanco 4L',
        descripcion: 'Pintura látex lavable para interiores',
        precio: 45.90,
        imagenUrl: '',
        categoria: 'Pinturas',
        marca: 'Sherwin Williams',
        stock: 8,
        rating: 4.5,
      ),
      Product(
        id: 4,
        nombre: 'Cable Eléctrico 2.5mm x10m',
        descripcion: 'Cable eléctrico THW 2.5mm, rollo de 10 metros',
        precio: 28.75,
        imagenUrl: '',
        categoria: 'Electricidad',
        marca: 'Indeco',
        stock: 3,
        rating: 4.0,
      ),
      Product(
        id: 5,
        nombre: 'Llave Inglesa Ajustable 10"',
        descripcion: 'Llave inglesa ajustable de 10 pulgadas',
        precio: 35.00,
        imagenUrl: '',
        categoria: 'Herramientas',
        marca: 'Stanley',
        stock: 12,
        rating: 4.6,
      ),
      Product(
        id: 6,
        nombre: 'Tubería PVC 1/2" x6m',
        descripcion: 'Tubería PVC sanitaria 1/2 pulgada',
        precio: 18.50,
        imagenUrl: '',
        categoria: 'Plomeria',
        marca: 'Pavco',
        stock: 25,
        rating: 4.3,
      ),
    ];
    
    _filteredProducts = _allProducts;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        _buildCategoryFilters(),
        _buildProductGrid(),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Material(
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Buscar producto',
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey),
              onPressed: () {
                _searchController.clear();
                _searchProduct('');
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              borderSide: const BorderSide(color: Colors.blue, width: 2.0),
            ),
          ),
          onChanged: _searchProduct,
          textInputAction: TextInputAction.search,
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: AppConstants.categories.map((category) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    onSelected: (selected) => _filterByCategory(category),
                    backgroundColor: Colors.grey.shade200,
                    selectedColor: Colors.blue.shade100,
                    checkmarkColor: Colors.blue,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    return Expanded(
      child: _filteredProducts.isEmpty
          ? _buildEmptyState()
          : Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _filteredProducts.length,
                itemBuilder: (context, index) {
                  return ProductCard(
                    product: _filteredProducts[index],
                    onTap: () => _viewProductDetails(_filteredProducts[index]),
                    onAddToCart: () => _addToCart(_filteredProducts[index]),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No se encontraron productos',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == 'Todas') {
        _filteredProducts = _allProducts;
      } else {
        _filteredProducts = _allProducts
            .where((product) => product.categoria == category)
            .toList();
      }
    });
  }
  
  void _searchProduct(String query) {
    setState(() {
      if (query.isEmpty) {
        _filterByCategory(_selectedCategory);
      } else {
        _filteredProducts = _allProducts
            .where((product) =>
                product.nombre.toLowerCase().contains(query.toLowerCase()) ||
                product.descripcion.toLowerCase().contains(query.toLowerCase()) ||
                product.marca.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _viewProductDetails(Product product) {
    debugPrint('Ver detalles de: ${product.nombre}');
  }

  void _addToCart(Product product) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.nombre} agregado al carrito'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
