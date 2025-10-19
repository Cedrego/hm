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

    if (imagenUrl == null || imagenUrl.isEmpty || imagenUrl == 'vacio') {
      return Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[100],
          border: Border.all(color: Color(0xFF00897B), width: 3),
        ),
        child: Icon(Icons.person, size: 60, color: Color(0xFF00897B)),
      );
    }

    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Color(0xFF00897B), width: 3),
      ),
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        backgroundImage: CachedNetworkImageProvider(imagenUrl),
      ),
    );
  }

  Future<void> _onLogoutPressed(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Confirmar cierre de sesión',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('¿Está seguro de que desea cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Cerrar sesión',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AuthService.logout();

      // Para StatelessWidget, usamos esto:
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.loginScreen,
          (route) => false,
        );
      });
    }
  }

  String _formatearRol(String rol) {
    if (rol.isEmpty) return 'Huesped';
    return rol[0].toUpperCase() + rol.substring(1);
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            _buildAvatar(),
            const SizedBox(height: 32),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildProfileItem(
                      Icons.person,
                      'Nombre',
                      userData['nombre'] ?? 'No especificado',
                    ),
                    const SizedBox(height: 20),
                    _buildProfileItem(
                      Icons.email,
                      'Email',
                      userData['email'] ?? 'No especificado',
                    ),
                    const SizedBox(height: 20),
                    _buildProfileItem(
                      Icons.badge,
                      'Documento',
                      userData['documento'] ?? 'No especificado',
                    ),
                    const SizedBox(height: 20),
                    _buildProfileItem(
                      Icons.phone,
                      'Contacto',
                      userData['contacto'] ?? 'No especificado',
                    ),
                    const SizedBox(height: 20),
                    _buildProfileItem(
                      Icons.security,
                      'Rol',
                      _formatearRol(userData['rol'] ?? 'huesped'),
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

  Widget _buildProfileItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFF00897B).withAlpha(26),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: Color(0xFF00897B)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 0,
                ),
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
