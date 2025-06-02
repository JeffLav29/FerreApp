import 'package:ferre_app/screens/login_screen.dart';
import 'package:ferre_app/screens/perfil_screen.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';

// Clase global para manejar el carrito
class CartManager {
  static final CartManager _instance = CartManager._internal();
  factory CartManager() => _instance;
  CartManager._internal();

  List<CartItem> _cartItems = [];
  
  List<CartItem> get cartItems => _cartItems;
  
  int get itemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  
  void addProduct(Product product) {
    final existingIndex = _cartItems.indexWhere((item) => item.product.id == product.id);
    
    if (existingIndex >= 0) {
      _cartItems[existingIndex].quantity++;
    } else {
      _cartItems.add(CartItem(product: product, quantity: 1));
    }
  }
  
  void removeProduct(Product product) {
    _cartItems.removeWhere((item) => item.product.id == product.id);
  }
  
  void clear() {
    _cartItems.clear();
  }
}

class CatalogScreen extends StatefulWidget {
  @override
  _CatalogScreenState createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  String _searchQuery = '';
  String _selectedCategory = 'Todos';
  int _selectedIndex = 0;
  final CartManager _cartManager = CartManager();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    // Productos de ejemplo
    _products = [
      Product(
        id: 7,
        name: 'Taladro Inalámbrico',
        description: 'Taladro de 18V con batería recargable',
        price: 149.99,
        imageUrl: 'https://dojiw2m9tvv09.cloudfront.net/85563/product/F_taladro-atornillador-truper-11020-20-v2719.jpg?89&time=1748446508',
        category: 'Ferretería',
      ),
      Product(
        id: 8,
        name: 'Martillo de Carpintero',
        description: 'Martillo de 16 oz con mango ergonómico',
        price: 24.99,
        imageUrl: 'https://carpintec.com.pe/cdn/shop/files/Martillo_de_carpintero_20_oz_Bahco_700x700.jpg?v=1706652605',
        category: 'Ferretería',
      ),
      Product(
        id: 9,
        name: 'Destornilladores Set',
        description: 'Juego de 12 destornilladores variados',
        price: 19.99,
        imageUrl: 'https://promart.vteximg.com.br/arquivos/ids/8115545-1000-1000/image-203167fcc95a4a8badfb86f1e4edabe9.jpg?v=638609813965970000',
        category: 'Ferretería',
      ),
      Product(
        id: 10,
        name: 'Cinta Métrica 5m',
        description: 'Cinta métrica resistente de 5 metros',
        price: 12.99,
        imageUrl: 'https://tiendaonline.soltrak.com.pe/media/catalog/product/c/i/cinta_30-615_1.png',
        category: 'Ferretería',
      ),
      Product(
        id: 11,
        name: 'Llave Inglesa Ajustable',
        description: 'Llave ajustable de 10 pulgadas',
        price: 18.99,
        imageUrl: 'https://promart.vteximg.com.br/arquivos/ids/4221490-1000-1000/image-657e9d9dd0ca476c829afeae0b46541f.jpg?v=637796006221200000',
        category: 'Ferretería',
      ),
      Product(
        id: 12,
        name: 'Sierra de Mano',
        description: 'Sierra de 20 pulgadas para madera',
        price: 34.99,
        imageUrl: 'https://www.alitecnoperu.com/product/image/medium/CCUCH-0143_3.jpg',
        category: 'Ferretería',
      ),
      Product(
        id: 13,
        name: 'Nivel de Burbuja',
        description: 'Nivel de aluminio de 60cm',
        price: 22.99,
        imageUrl: 'https://promart.vteximg.com.br/arquivos/ids/5188085-1000-1000/139882.jpg?v=637844248662430000',
        category: 'Ferretería',
      ),
      Product(
        id: 14,
        name: 'Alicates Universales',
        description: 'Alicates multiuso con aislamiento',
        price: 16.99,
        imageUrl: 'https://gpc.pe/cdn/shop/products/6164-0.png?v=1666816838',
        category: 'Ferretería',
      ),
    ];
    _filteredProducts = _products;
  }

  void _filterProducts() {
    setState(() {
      _filteredProducts = _products.where((product) {
        final matchesSearch = product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            product.description.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesCategory = _selectedCategory == 'Todos' || product.category == _selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    switch (index) {
      case 0:
        // Home - ya estamos aquí
        break;
      case 1:
        // Carrito
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CartScreen()),
        ).then((_) {
          // Actualizar la UI cuando regrese del carrito
          setState(() {});
        });
        break;
      case 2:
        // Perfil
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen()),
        );
        break;
    }
  }

  void _addToCart(Product product) {
    _cartManager.addProduct(product);
    setState(() {}); // Actualizar el badge del carrito
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} agregado al carrito'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'Ver Carrito',
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CartScreen()),
            ).then((_) {
              setState(() {});
            });
          },
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              height: 120,
              width: double.infinity,
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey.shade200,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / 
                              loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image,
                          size: 32,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Error al cargar',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Nombre del producto
                  Text(
                    product.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  // Descripción del producto
                  Expanded(
                    child: Text(
                      product.description,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: 4),
                  // Precio y botón de agregar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          'S/${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: IconButton(
                          onPressed: () => _addToCart(product),
                          icon: Icon(
                            Icons.add_shopping_cart,
                            color: Colors.blue.shade600,
                            size: 18,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          tooltip: 'Agregar al carrito',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catálogo de Productos'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CartScreen()),
                  ).then((_) {
                    setState(() {});
                  });
                },
              ),
              if (_cartManager.itemCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${_cartManager.itemCount}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda y filtros
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar productos...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (value) {
                    _searchQuery = value;
                    _filterProducts();
                  },
                ),
                SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['Todos', 'Electrónicos', 'Ropa', 'Libros'].map((category) {
                      return Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: _selectedCategory == category,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category;
                              _filterProducts();
                            });
                          },
                          backgroundColor: Colors.grey.shade200,
                          selectedColor: Colors.blue.shade100,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          // Lista de productos
          Expanded(
            child: _filteredProducts.isEmpty
                ? Center(
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
                  )
                : GridView.builder(
                    padding: EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return _buildProductCard(product);
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                Icon(Icons.shopping_cart),
                if (_cartManager.itemCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        '${_cartManager.itemCount}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Carrito',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue.shade600,
        onTap: _onItemTapped,
      ),
    );
  }
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });
}