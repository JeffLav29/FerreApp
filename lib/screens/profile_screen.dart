import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget{
  const ProfileScreen({super.key});
  
  @override
  State<ProfileScreen> createState() => _PerfilScreen();
}

class _PerfilScreen extends State<ProfileScreen>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hola mundo xd'),
      ),
    );
  }
}