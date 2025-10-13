import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../custom_app_bar.dart';
import '../../core/auth_service.dart'; // 🟢 Importa AuthService
import '../app_drawer.dart'; // 🟢 Importa AppDrawer
import '../../core/app_export.dart'; // Asumiendo que AppRoutes está aquí

class ProfileScreen extends StatelessWidget {
   final Map<String, dynamic> userData ;
   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

   ProfileScreen({super.key, required this.userData});


  // Método para construir el avatar con la imagen
  Widget _buildAvatar() {
    final String? imagenBase64 = userData?['imagen'];
    
    // Si no hay imagen o es "vacio"
    if (imagenBase64 == null || 
        imagenBase64.isEmpty || 
        imagenBase64 == 'vacio') {
      return const CircleAvatar(
        radius: 70,
        backgroundColor: Colors.white,
        child: Icon(Icons.person, size: 40, color: Colors.blue),
      );
    }

    // Si hay imagen, decodificar y mostrar
    try {
      Uint8List bytes = base64Decode(imagenBase64);
      return CircleAvatar(
        radius: 70,
        backgroundColor: Colors.white,
        backgroundImage: MemoryImage(bytes),
      );
    } catch (e) {
      print('❌ Error al decodificar imagen del usuario: $e');
      // Si hay error, mostrar avatar por defecto
      return const CircleAvatar(
        radius: 30,
        backgroundColor: Colors.white,
        child: Icon(Icons.person, size: 40, color: Colors.blue),
      );
    }
  }

  // 🟢 Función para manejar el cierre de sesión 🟢
  Future<void> _onLogoutPressed(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmación'),
        content: const Text('¿Está seguro de cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AuthService.logout(); 
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.loginScreen, // Usa la ruta de AppRoutes
        (route) => false,
      );
    }
  }
  
   @override
   Widget build(BuildContext context) {
      final bool isAdmin = userData['rol'] == 'admin';

      return Scaffold(
         key: _scaffoldKey,
         appBar: CustomAppBar(
            // 🟢 Esto conecta el AppBar a la llave de este Scaffold 🟢
            scaffoldKey: _scaffoldKey,
            onLogoutPressed: () => _onLogoutPressed(context),
            userData: userData,
            isAdmin: isAdmin,
         ),
      // 🟢 Añade el Drawer y pasa la data 🟢
      drawer: AppDrawer(
          userData: userData,
          isAdmin: isAdmin,
          onLogoutPressed: _onLogoutPressed,
      ),
         body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
               crossAxisAlignment: CrossAxisAlignment.center,
               children: [
                   _buildAvatar(),
                  const SizedBox(height: 20),
                  _buildProfileItem('Nombre', userData['nombre'] ?? 'N/A'),
                  _buildProfileItem('Email', userData['email'] ?? 'N/A'),
                  _buildProfileItem('Documento', userData['documento'] ?? 'N/A'),
                  _buildProfileItem('Contacto', userData['contacto'] ?? 'N/A'),
               ],
            ),
         ),
      );
   }

   Widget _buildProfileItem(String label, String value) {
      return Padding(
         padding: const EdgeInsets.symmetric(vertical: 8.0),
         child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(
                  label,
                  style: const TextStyle(
                     fontSize: 14,
                     color: Colors.grey,
                     fontWeight: FontWeight.bold,
                  ),
               ),
               const SizedBox(height: 4),
               Text(
                  value,
                  style: const TextStyle(
                     fontSize: 16,
                     color: Colors.black,
                  ),
               ),
               const Divider(),
            ],
         ),
      );
   }
}