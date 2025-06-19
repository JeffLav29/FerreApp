import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ferre_app/models/product.dart';
import 'package:ferre_app/screens/product_detail_screen.dart';
import 'package:ferre_app/services/cart_manager.dart';
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
  bool _isLoading = true;
  String? _errorMessage;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'productos';

  @override
  void initState() {
    super.initState();
    _loadProductsFromFirestore();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Cargar productos desde Firestore
  Future<void> _loadProductsFromFirestore() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      QuerySnapshot querySnapshot = await _firestore
          .collection(_collectionName)
          .orderBy('nombre')
          .get();

      List<Product> products = [];
      
      for (var doc in querySnapshot.docs) {
        try {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          
          // Agregamos el ID del documento de Firestore como 'id' si no existe
          if (!data.containsKey('id')) {
            data['id'] = doc.id.hashCode; // Convertimos el docId a int
          }
          
          Product product = Product.fromJson(data);
          products.add(product);
        } catch (e) {
          print('Error al procesar producto ${doc.id}: $e');
        }
      }

      setState(() {
        _allProducts = products;
        _filteredProducts = products;
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar productos: $e';
        _isLoading = false;
      });
      print('Error loading products: $e');
    }
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
    if (_isLoading) {
      return const Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Cargando productos...'),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadProductsFromFirestore,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailScreen(
                            product: _filteredProducts[index],
                          ),
                        ),
                      );
                    },
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


  void _addToCart(Product product) {
    if (!mounted) return;
    
    try {
      CartManager.addToCart(product);
      CartManager.printCartContents();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.nombre} agregado al carrito'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al agregar producto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
