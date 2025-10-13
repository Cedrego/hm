import 'package:flutter/material.dart';
import '../core/app_export.dart'; // Ajusta esta ruta si es necesario

class AppDrawer extends StatelessWidget {
  final Map<String, dynamic>? userData;
  final bool isAdmin;
  final Function(BuildContext) onLogoutPressed;

  const AppDrawer({
    super.key,
    required this.userData,
    required this.isAdmin,
    required this.onLogoutPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Rutas (usando las constantes de AppRoutes y las rutas fijas)
    final String roomListRoute = AppRoutes.roomListScreen;
    final String roomCreationRoute = AppRoutes.roomCreationScreen;
    final String reservationsRoute = '/reservas';
    final String profileRoute = AppRoutes.profileScreen;
    final String informationRoute = '/informacion';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.blue),
                ),
                const SizedBox(height: 10),
                Text(
                  userData?['nombre'] ?? 'Usuario',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  userData?['email'] ?? '',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Inicio'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/main_page');
              },
            ),
          ListTile(
            leading: const Icon(Icons.bed),
            title: const Text('Habitaciones'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, roomListRoute);
            },
          ),
          if (isAdmin)
            ListTile(
              leading: const Icon(Icons.add_box, color: Colors.indigo),
              title: const Text('Crear Habitación'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, roomCreationRoute);
              },
            ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Reservas'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, reservationsRoute);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Mi Perfil'),
            onTap: () {
              Navigator.pop(context);
              // Pasa el userData
              Navigator.pushNamed(context, profileRoute, arguments: userData); 
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Información'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, informationRoute);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              onLogoutPressed(context); // Llama al método de cierre de sesión
            },
          ),
        
        ],
      ),
    );
  }
}