import 'package:ferre_app/models/product.dart';
import 'package:ferre_app/widgets/product_card.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget{
  const HomeScreen({super.key});
  
  @override
  State<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen>{

  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0; // Para controlar la pestaña seleccionada

  //variables para los filtros
  String _seleccionarCategoria = 'Todas';
  //Lista para los filtros
  final List<String> _categorias = ['Todas', 'Herramientas', 'Tornillos', 'Pinturas', 'Electricidad', 'Plomeria'];

  //-------Lista de productos de ejemplo---------
  List<Product> _todosLosProductos = [];
  List<Product> _productosFiltrados = [];

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  void _cargarProductos() {
    // Productos de ejemplo para tu ferretería
    _todosLosProductos = [
      Product(
        id: 1,
        nombre: 'Taladro Inalámbrico DeWalt',
        descripcion: 'Taladro inalámbrico 18V con batería incluida',
        precio: 299.99,
        imagenUrl: '',
        categoria: 'Herramientas',
        marca: 'DeWalt',
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
    
    _productosFiltrados = _todosLosProductos;
  }

  // Método para manejar el cambio de pestaña
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    // Aquí puedes agregar navegación a otras pantallas
    switch (index) {
      case 0:
        // Ya estamos en Home
        break;
      case 1:
        // Navegar a Carrito
        print('Navegar a Carrito');
        break;
      case 2:
        // Navegar a Favoritos
        print('Navegar a Favoritos');
        break;
      case 3:
        // Navegar a Perfil
        print('Navegar a Perfil');
        break;
    }
  }

  // Widget que devuelve el contenido según la pestaña seleccionada
  Widget _getSelectedWidget() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return _buildCartContent();
      case 2:
        return _buildFavoritesContent();
      case 3:
        return _buildProfileContent();
      default:
        return _buildHomeContent();
    }
  }

  // Contenido de la pantalla Home
  Widget _buildHomeContent() {
    return Column(
      children: [
        // Barra de búsqueda
        Container(
          padding: EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar producto',
              prefixIcon: Icon(Icons.search, color: Colors.grey,),
              suffixIcon: IconButton(
                icon: Icon(Icons.clear, color: Colors.grey,),
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                  _buscarProducto('');                    
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
                borderSide: BorderSide(color: Colors.blue, width: 2.0)
              )
            ),
            onSubmitted: (value) {
              print('Busqueda: $value');
              _buscarProducto(value);
            },
          ),
        ),

        // Filtros
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categorias.map((category) {
                    return Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category),
                        selected: _seleccionarCategoria == category,
                        onSelected: (selected) {
                          setState(() {
                            _seleccionarCategoria = category;
                          });
                          _filtrarPorCategoria(category);
                        },
                        backgroundColor: Colors.grey.shade200,
                        selectedColor: Colors.blue.shade100,
                        checkmarkColor: Colors.blue,
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),

        // Productos
        Expanded(
          child: _productosFiltrados.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No se encontraron productos',
                        style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: EdgeInsets.all(16),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _productosFiltrados.length,
                    itemBuilder: (context, index) {
                      return ProductCard(
                        product: _productosFiltrados[index],
                        onTap: () {
                          print('Ver detalles de: ${_productosFiltrados[index].nombre}');
                        },
                        onAddToCart: () {
                          _agregarAlCarrito(_productosFiltrados[index]);
                        },
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  // Contenido placeholder para otras pestañas
  Widget _buildCartContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart, size: 64, color: Colors.blue),
          SizedBox(height: 16),
          Text('Carrito de Compras', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text('Aquí irán los productos del carrito'),
        ],
      ),
    );
  }

  Widget _buildFavoritesContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text('Favoritos', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text('Aquí irán los productos favoritos'),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 64, color: Colors.green),
          SizedBox(height: 16),
          Text('Perfil', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text('Aquí irá la información del usuario'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FerreApp', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart, color: Colors.white),
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            onPressed: () {
              setState(() {
                _selectedIndex = 1; // Cambiar a la pestaña del carrito
              });
            },
          )
        ],
      ),
      body: _getSelectedWidget(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Para mostrar más de 3 items
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Carrito',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  void _filtrarPorCategoria(String category) {
    setState(() {
      if (category == 'Todas') {
        _productosFiltrados = _todosLosProductos;
      } else {
        _productosFiltrados = _todosLosProductos
            .where((producto) => producto.categoria == category)
            .toList();
      }
    });
    print('Filtrando por categoría: $category');
  }
  
  void _buscarProducto(String query) {
    setState(() {
      if (query.isEmpty) {
        _filtrarPorCategoria(_seleccionarCategoria);
      } else {
        _productosFiltrados = _todosLosProductos
            .where((producto) =>
                producto.nombre.toLowerCase().contains(query.toLowerCase()) ||
                producto.descripcion.toLowerCase().contains(query.toLowerCase()) ||
                producto.marca.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _agregarAlCarrito(Product producto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${producto.nombre} agregado al carrito'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
    print('Agregado al carrito: ${producto.nombre}');
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}