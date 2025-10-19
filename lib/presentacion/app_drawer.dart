import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/app_export.dart';

class AppDrawer extends StatelessWidget {
  final Map<String, dynamic>? userData;
  final bool isAdmin;
  final VoidCallback onLogoutPressed;

  const AppDrawer({
    super.key,
    required this.userData,
    required this.isAdmin,
    required this.onLogoutPressed,
  });

  Widget _buildAvatar() {
    final String? imagenUrl = userData?['imagenUrl'];

    if (imagenUrl == null || imagenUrl.isEmpty || imagenUrl == 'vacio') {
      return CircleAvatar(
        radius: 30,
        backgroundColor: Colors.white,
        child: Icon(Icons.person, size: 30, color: Colors.blue[700]),
      );
    }

    return CircleAvatar(
      radius: 30,
      backgroundColor: Colors.white,
      backgroundImage: CachedNetworkImageProvider(imagenUrl),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue[700]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    _buildAvatar(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userData?['nombre'] ?? 'Usuario',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userData?['email'] ?? '',
                            style: TextStyle(
                              color: Colors.white.withAlpha(204),
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(51),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              (userData?['rol'] ?? 'usuario').toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Inicio'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.mainPage);
            },
          ),
          ListTile(
            leading: const Icon(Icons.bed),
            title: const Text('Habitaciones'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.roomListScreen);
            },
          ),
          if (isAdmin)
            ListTile(
              leading: const Icon(Icons.add_box, color: Colors.indigo),
              title: const Text('Crear Habitación'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.roomCreationScreen);
              },
            ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Mis Reservas'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.misReservas);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Mi Perfil'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
                AppRoutes.profileScreen,
                arguments: userData,
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.pop(context);
              onLogoutPressed();
            },
          ),
        ],
      ),
    );
  }
}
