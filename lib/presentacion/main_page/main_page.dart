import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import '../../core/auth_service.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await AuthService.getUserData();
    setState(() {
      _userData = userData;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Definimos las rutas estáticas de AppRoutes
    final String roomListRoute = AppRoutes.roomListScreen;
    final String roomCreationRoute = AppRoutes.roomCreationScreen; // 🎯 Nueva ruta

    return Scaffold(
      backgroundColor: const Color(0XFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        title: const Text(
          'Hostel Mochileros',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () => _onLogoutPressed(context),
          ),
        ],
      ),
      drawer: _buildDrawer(context, roomListRoute, roomCreationRoute), // Pasamos la nueva ruta
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bienvenida con nombre del usuario
                    Text(
                      '¡Bienvenido${_userData?['nombre'] != null ? ', ${_userData!['nombre'].split(' ')[0]}' : ''}!',
                      style: TextStyleHelper.instance.headline24SemiBoldInter
                          .copyWith(color: Colors.black),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      _userData?['email'] ?? 'Has iniciado sesión exitosamente',
                      style: TextStyleHelper.instance.title16RegularInter.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 30.h),

                    // Tarjetas de funcionalidades en Grid 3x2 (Ajustado a 2x3 para la nueva tarjeta)
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.h,
                        mainAxisSpacing: 16.h,
                        childAspectRatio: 1.0,
                        children: [
                          // 1. Habitaciones (Reservar)
                          _buildFeatureCard(
                            icon: Icons.bed,
                            title: 'Habitaciones',
                            color: Colors.blue,
                            onTap: () {
                              Navigator.pushNamed(context, roomListRoute);
                            },
                          ),
                          // 2. Crear Habitación (Nueva Tarjeta)
                          _buildFeatureCard(
                            icon: Icons.add_box,
                            title: 'Crear Habitación',
                            color: Colors.indigo,
                            onTap: () {
                              Navigator.pushNamed(context, roomCreationRoute);
                            },
                          ),
                          // 3. Reservas
                          _buildFeatureCard(
                            icon: Icons.calendar_today,
                            title: 'Reservas',
                            color: Colors.green,
                            onTap: () {
                              Navigator.pushNamed(context, '/reservas');
                            },
                          ),
                          // 4. Perfil
                          _buildFeatureCard(
                            icon: Icons.person,
                            title: 'Perfil',
                            color: Colors.orange,
                            onTap: () {
                              _showUserProfile(context);
                            },
                          ),
                          // 5. Información
                          _buildFeatureCard(
                            icon: Icons.info,
                            title: 'Información',
                            color: Colors.purple,
                            onTap: () {
                              Navigator.pushNamed(context, '/informacion');
                            },
                          ),
                          // Puedes añadir una sexta tarjeta si tu GridView tiene espacio
                        ],
                      ),
                    ),

                    // Información adicional
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.h),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12.h),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Información del Hostel',
                            style: TextStyleHelper.instance.title16RegularInter
                                .copyWith(color: Colors.black),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Horario de atención: 24/7\nTeléfono: +1 234 567 890\nEmail: info@hostelmochileros.com',
                            style: TextStyleHelper.instance.title16RegularInter
                                .copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // --- Widget para construir el Drawer ---
  Widget _buildDrawer(
      BuildContext context, String roomListRoute, String roomCreationRoute) {
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
                  _userData?['nombre'] ?? 'Usuario',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _userData?['email'] ?? '',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Habitaciones (Reservar)
          ListTile(
            leading: const Icon(Icons.bed),
            title: const Text('Habitaciones'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, roomListRoute);
            },
          ),
          // 🎯 Crear Habitación (Añadido al Drawer)
          ListTile(
            leading: const Icon(Icons.add_box, color: Colors.indigo),
            title: const Text('Crear Habitación'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, roomCreationRoute);
            },
          ),
          // Reservas
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Reservas'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/reservas');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Mi Perfil'),
            onTap: () {
              Navigator.pop(context);
              _showUserProfile(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Información'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/informacion');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _onLogoutPressed(context);
            },
          ),
        ],
      ),
    );
  }

  // --- Widget para construir las tarjetas de funcionalidades ---
  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.h)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.h),
        child: Container(
          padding: EdgeInsets.all(16.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12.h),
                decoration: BoxDecoration(
                  color: color.withAlpha((0.1 * 255).toInt()),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 30.h, color: color),
              ),
              SizedBox(height: 12.h),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyleHelper.instance.title16RegularInter.copyWith(
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Métodos Auxiliares ---

  void _showUserProfile(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.person, color: Colors.blue),
            SizedBox(width: 10),
            Text('Mi Perfil'),
          ],
        ),
        content: _userData == null
            ? const Text('No se pudo cargar el perfil')
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileItem('Nombre', _userData!['nombre'] ?? 'N/A'),
                  _buildProfileItem('Email', _userData!['email'] ?? 'N/A'),
                  _buildProfileItem('Documento', _userData!['documento'] ?? 'N/A'),
                  _buildProfileItem('Contacto', _userData!['contacto'] ?? 'N/A'),
                ],
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
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

    if (confirmed == true && mounted) {
      // Cerrar sesión
      await AuthService.logout();

      // Navegar a loginScreen y eliminar todas las rutas previas
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.loginScreen,
        (route) => false,
      );
    }
  }
}