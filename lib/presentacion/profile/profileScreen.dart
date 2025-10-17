import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../custom_app_bar.dart';
import '../../core/auth_service.dart';
import '../app_drawer.dart';
import '../../core/app_export.dart';

class ProfileScreen extends StatelessWidget {
  final Map<String, dynamic> userData;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  ProfileScreen({super.key, required this.userData});

  Widget _buildAvatar() {
    final String? imagenUrl = userData['imagenUrl'];
    
    // Si no hay imagen o es "vacio"
    if (imagenUrl == null || imagenUrl.isEmpty || imagenUrl == 'vacio') {
      return CircleAvatar(
        radius: 70,
        backgroundColor: Colors.grey[200],
        child: Icon(Icons.person, size: 50, color: Colors.grey[600]),
      );
    }

    // ✅ SI HAY IMAGEN URL - Usar CachedNetworkImage
    return CircleAvatar(
      radius: 70,
      backgroundColor: Colors.grey[200],
      backgroundImage: CachedNetworkImageProvider(imagenUrl),
    );
  }
  
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
        AppRoutes.loginScreen,
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
        scaffoldKey: _scaffoldKey,
        onLogoutPressed: () => _onLogoutPressed(context),
        userData: userData,
        isAdmin: isAdmin,
      ),
      drawer: AppDrawer(
        userData: userData,
        isAdmin: isAdmin,
        onLogoutPressed: () => _onLogoutPressed(context),
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
            _buildProfileItem('Rol', userData['rol'] ?? 'usuario'), // ← AGREGADO
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