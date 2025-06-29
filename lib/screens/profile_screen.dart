import 'package:ferre_app/main.dart';
import 'package:ferre_app/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final docSnapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (docSnapshot.exists) {
          setState(() {
            _userData = docSnapshot.data();
            _isLoading = false;
          });
        } else {
          // Si no existe el documento, crear uno con datos básicos
          await _createUserDocument(user);
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Error al cargar los datos: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _createUserDocument(User user) async {
    try {
      final userData = {
        'uid': user.uid,
        'nombre': user.displayName ?? 'Usuario',
        'email': user.email ?? '',
        'telefono': user.phoneNumber ?? '',
        'tipoCliente': 'Cliente Regular',
        'fechaRegistro': FieldValue.serverTimestamp(),
        'comprasRealizadas': 0,
        'montoTotal': 0.0,
        'direccion': {
          'calle': '',
          'ciudad': '',
          'codigoPostal': '',
          'pais': 'Perú'
        },
        'configuraciones': {
          'notificaciones': true,
          'emailMarketing': false,
          'smsNotifications': true
        },
        'fechaActualizacion': FieldValue.serverTimestamp(),
        'activo': true,
      };

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userData);

      setState(() {
        _userData = userData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al crear el perfil: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserData(Map<String, dynamic> updates) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Crear una copia para Firestore que incluya el timestamp
        Map<String, dynamic> firestoreUpdates = Map.from(updates);
        firestoreUpdates['fechaActualizacion'] = FieldValue.serverTimestamp();
        
        await _firestore
            .collection('users')
            .doc(user.uid)
            .update(firestoreUpdates);

        if (!mounted) return;

        // Actualizar datos locales
        Map<String, dynamic> localUpdates = Map.from(updates);
        localUpdates['fechaActualizacion'] = DateTime.now().toIso8601String();
        
        setState(() {
          _userData = {..._userData!, ...localUpdates};
        });
        

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Información actualizada correctamente'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              _error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUserData,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_userData == null) {
      return const Center(
        child: Text('No se encontraron datos del usuario'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 24),
          _buildStatsCards(),
          const SizedBox(height: 24),
          _buildMenuOptions(),
          const SizedBox(height: 24),
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 46,
                  backgroundColor: Colors.blue.shade100,
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.blue.shade600,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _userData!['nombreUsuario'] ?? 'Usuario',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _userData!['tipoCliente'] ?? 'Cliente Regular',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Compras',
            '${_userData!['comprasRealizadas'] ?? 0}',
            Icons.shopping_bag,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Total Gastado',
            'S/ ${(_userData!['montoTotal'] ?? 0.0).toStringAsFixed(2)}',
            Icons.attach_money,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOptions() {
    return Column(
      children: [
        _buildMenuSection('Información Personal', [
          _buildMenuItem(
            'Editar Informacion Personal',
            Icons.edit,
            () => _editPersonalProfile(),
          ),
          _buildMenuItem(
            'Editar Dirección',
            Icons.location_on,
            () => _editAddress(),
          ),
        ]),
        const SizedBox(height: 16),
        _buildMenuSection('Compras', [
          _buildMenuItem(
            'Historial de Compras',
            Icons.history,
            () => _showPurchaseHistory(),
          ),
          _buildMenuItem(
            'Lista de Deseos',
            Icons.favorite_border,
            () => _showWishlist(),
          ),
        ]),
        const SizedBox(height: 16),
        _buildMenuSection('Configuraciones', [
          _buildMenuItem(
            'Modo oscuro',
            Icons.dark_mode,
            () => _editTheme(context),
          ),
          _buildMenuItem(
            'Configurar Notificaciones',
            Icons.notifications_outlined,
            () => _editNotificationSettings(),
          ),
          _buildMenuItem(
            'Política de Privacidad',
            Icons.privacy_tip_outlined,
            () => _showPrivacyPolicy(),
          ),
          _buildMenuItem(
            'Ayuda y Soporte',
            Icons.help_outline,
            () => _showSupport(),
          ),
        ]),
      ],
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.blue.shade600,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade400,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _logout,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout),
            SizedBox(width: 8),
            Text(
              'Cerrar Sesión',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // NUEVOS MÉTODOS DE EDICIÓN

  void _editPersonalProfile() {
    final nameController = TextEditingController(text: _userData!['nombre'] ?? '');
    final lastNameController = TextEditingController(text: _userData!['apellido'] ?? '');
    final phoneController = TextEditingController(text: _userData!['telefono'] ?? '');
    String selectedTipoCliente = _userData!['tipoCliente'] ?? 'Cliente Regular';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar informacion Personal'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Apellido',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedTipoCliente,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Cliente',
                  prefixIcon: Icon(Icons.card_membership),
                  border: OutlineInputBorder(),
                ),
                items: ['Cliente Regular', 'Cliente Premium', 'Cliente VIP']
                    .map((tipo) => DropdownMenuItem(
                          value: tipo,
                          child: Text(tipo),
                        ))
                    .toList(),
                onChanged: (value) {
                  selectedTipoCliente = value!;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final updates = {
                'nombre': nameController.text.trim(),
                'telefono': phoneController.text.trim(),
                'tipoCliente': selectedTipoCliente,
              };
              
              Navigator.pop(context);
              _updateUserData(updates);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _editAddress() {
    final calleController = TextEditingController(
      text: _userData!['direccion']?['calle'] ?? ''
    );
    final ciudadController = TextEditingController(
      text: _userData!['direccion']?['ciudad'] ?? ''
    );
    final codigoPostalController = TextEditingController(
      text: _userData!['direccion']?['codigoPostal'] ?? ''
    );
    final paisController = TextEditingController(
      text: _userData!['direccion']?['pais'] ?? 'Perú'
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Dirección'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: calleController,
                decoration: const InputDecoration(
                  labelText: 'Calle y Número',
                  prefixIcon: Icon(Icons.home),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ciudadController,
                decoration: const InputDecoration(
                  labelText: 'Ciudad',
                  prefixIcon: Icon(Icons.location_city),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: codigoPostalController,
                decoration: const InputDecoration(
                  labelText: 'Código Postal',
                  prefixIcon: Icon(Icons.mail),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: paisController,
                decoration: const InputDecoration(
                  labelText: 'País',
                  prefixIcon: Icon(Icons.flag),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final updates = {
                'direccion': {
                  'calle': calleController.text.trim(),
                  'ciudad': ciudadController.text.trim(),
                  'codigoPostal': codigoPostalController.text.trim(),
                  'pais': paisController.text.trim(),
                }
              };
              
              Navigator.pop(context);
              _updateUserData(updates);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _editNotificationSettings() {
    bool notificaciones = _userData!['configuraciones']?['notificaciones'] ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Configurar Notificaciones'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Notificaciones'),
                subtitle: const Text('Recibir notificaciones en la app'),
                value: notificaciones,
                onChanged: (value) {
                  setState(() {
                    notificaciones = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final updates = {
                  'configuraciones': {
                    'notificaciones': notificaciones
                  }
                };
                
                Navigator.pop(context);
                _updateUserData(updates);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }


  void _showPurchaseHistory() {
    debugPrint('Mostrar historial de compras');
    _showComingSoon('Historial de Compras');
  }

  void _showWishlist() {
    debugPrint('Mostrar lista de deseos');
    _showComingSoon('Lista de Deseos');
  }

  void _showPrivacyPolicy() {
    debugPrint('Mostrar política de privacidad');
    _showComingSoon('Política de Privacidad');
  }

  void _showSupport() {
    debugPrint('Mostrar ayuda y soporte');
    _showComingSoon('Ayuda y Soporte');
  }

void _editTheme(BuildContext context) {
  bool isDarkMode = themeNotifier.value == ThemeMode.dark;
  
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Configuración de Tema'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(isDarkMode ? 'Tema Oscuro' : 'Tema Claro'),
                    Switch(
                      value: isDarkMode,
                      onChanged: (bool value) {
                        setState(() {
                          isDarkMode = value;
                        });
                        _changeTheme(value);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      color: isDarkMode ? Colors.amber : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isDarkMode ? 'Modo Oscuro Activado' : 'Modo Claro Activado',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cerrar'),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<void> _changeTheme(bool isDarkMode) async {
  // Cambiar el tema en la aplicación
  themeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;
  
  // Guardar la preferencia en SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isDarkMode', isDarkMode);
  
}

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Próximamente disponible'),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              await FirebaseAuth.instance.signOut();

              if (!context.mounted) return;
              
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sesión cerrada exitosamente'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}