import 'package:flutter/material.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'Español';

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cerrar Sesión'),
          content: Text('¿Estás seguro de que deseas cerrar sesión?'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Cerrar Sesión'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _editProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Función de editar perfil próximamente'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Seleccionar Idioma'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: Text('Español'),
                value: 'Español',
                groupValue: _selectedLanguage,
                onChanged: (String? value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<String>(
                title: Text('English'),
                value: 'English',
                groupValue: _selectedLanguage,
                onChanged: (String? value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Perfil'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Información del usuario
            Container(
              padding: EdgeInsets.all(24),
              color: Colors.blue.shade50,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue.shade200,
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.blue.shade600,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Admin Usuario',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'admin@ejemplo.com',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _editProfile,
                    icon: Icon(Icons.edit),
                    label: Text('Editar Perfil'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Estadísticas
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Card(
                      elevation: 2,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(Icons.shopping_bag, color: Colors.blue.shade600, size: 32),
                            SizedBox(height: 8),
                            Text('12', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            Text('Pedidos', style: TextStyle(color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Card(
                      elevation: 2,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(Icons.favorite, color: Colors.red.shade400, size: 32),
                            SizedBox(height: 8),
                            Text('8', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            Text('Favoritos', style: TextStyle(color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Card(
                      elevation: 2,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(Icons.star, color: Colors.orange.shade400, size: 32),
                            SizedBox(height: 8),
                            Text('4.8', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            Text('Rating', style: TextStyle(color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Opciones del menú
            Container(
              margin: EdgeInsets.all(16),
              child: Column(
                children: [
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.history, color: Colors.blue.shade600),
                          title: Text('Historial de Pedidos'),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Historial de pedidos próximamente')),
                            );
                          },
                        ),
                        Divider(height: 1),
                        ListTile(
                          leading: Icon(Icons.favorite_outline, color: Colors.red.shade400),
                          title: Text('Lista de Deseos'),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Lista de deseos próximamente')),
                            );
                          },
                        ),
                        Divider(height: 1),
                        ListTile(
                          leading: Icon(Icons.location_on_outlined, color: Colors.green.shade600),
                          title: Text('Direcciones'),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Gestión de direcciones próximamente')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        SwitchListTile(
                          secondary: Icon(Icons.notifications_outlined, color: Colors.orange.shade600),
                          title: Text('Notificaciones'),
                          subtitle: Text('Recibir notificaciones push'),
                          value: _notificationsEnabled,
                          onChanged: (bool value) {
                            setState(() {
                              _notificationsEnabled = value;
                            });
                          },
                        ),
                        Divider(height: 1),
                        SwitchListTile(
                          secondary: Icon(Icons.dark_mode_outlined, color: Colors.grey.shade700),
                          title: Text('Modo Oscuro'),
                          subtitle: Text('Activar tema oscuro'),
                          value: _darkModeEnabled,
                          onChanged: (bool value) {
                            setState(() {
                              _darkModeEnabled = value;
                            });
                          },
                        ),
                        Divider(height: 1),
                        ListTile(
                          leading: Icon(Icons.language, color: Colors.blue.shade600),
                          title: Text('Idioma'),
                          subtitle: Text(_selectedLanguage),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: _showLanguageDialog,
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.help_outline, color: Colors.blue.shade600),
                          title: Text('Ayuda y Soporte'),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Centro de ayuda próximamente')),
                            );
                          },
                        ),
                        Divider(height: 1),
                        ListTile(
                          leading: Icon(Icons.info_outline, color: Colors.grey.shade600),
                          title: Text('Acerca de'),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            showAboutDialog(
                              context: context,
                              applicationName: 'Mi App',
                              applicationVersion: '1.0.0',
                              applicationLegalese: '© 2024 Mi Empresa',
                            );
                          },
                        ),
                        Divider(height: 1),
                        ListTile(
                          leading: Icon(Icons.logout, color: Colors.red),
                          title: Text('Cerrar Sesión'),
                          onTap: _logout,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}