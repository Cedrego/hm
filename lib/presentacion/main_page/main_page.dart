import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_export.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
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
  onPressed: () async {
    final navigator = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmación'),
        content: const Text('¿Está seguro de cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => navigator.pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => navigator.pop(true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      // Guardar estado de logout
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);

      // Navegar a loginScreen y eliminar todas las rutas previas
      navigator.pushNamedAndRemoveUntil(
        AppRoutes.loginScreen,
        (route) => false,
      );
    }
  },
),

        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menú',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.bed),
              title: const Text('Habitaciones'),
              onTap: () {
                Navigator.pop(context);
                // Navegar a la pantalla de Habitaciones
                Navigator.pushNamed(context, '/habitaciones');
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Reservas'),
              onTap: () {
                Navigator.pop(context);
                // Navegar a la pantalla de Reservas
                Navigator.pushNamed(context, '/reservas');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Perfil'),
              onTap: () {
                Navigator.pop(context);
                // Navegar a la pantalla de Perfil
                Navigator.pushNamed(context, '/perfil');
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Información'),
              onTap: () {
                Navigator.pop(context);
                // Navegar a la pantalla de Información
                Navigator.pushNamed(context, '/informacion');
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bienvenida
              Text(
                '¡Bienvenido!',
                style: TextStyleHelper.instance.headline24SemiBoldInter
                    .copyWith(color: Colors.black),
              ),
              SizedBox(height: 10.h),
              Text(
                'Has iniciado sesión exitosamente en Hostel Mochileros',
                style: TextStyleHelper.instance.title16RegularInter.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 30.h),

              // Tarjetas de funcionalidades en grid 2x2
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.h,
                  mainAxisSpacing: 16.h,
                  childAspectRatio: 1.0,
                  children: [
                    _buildFeatureCard(
                      icon: Icons.bed,
                      title: 'Habitaciones',
                      color: Colors.blue,
                      onTap: () {
                        Navigator.pushNamed(context, '/habitaciones');
                      },
                    ),
                    _buildFeatureCard(
                      icon: Icons.calendar_today,
                      title: 'Reservas',
                      color: Colors.green,
                      onTap: () {
                        Navigator.pushNamed(context, '/reservas');
                      },
                    ),
                    _buildFeatureCard(
                      icon: Icons.person,
                      title: 'Perfil',
                      color: Colors.orange,
                      onTap: () {
                        Navigator.pushNamed(context, '/perfil');
                      },
                    ),
                    _buildFeatureCard(
                      icon: Icons.info,
                      title: 'Información',
                      color: Colors.purple,
                      onTap: () {
                        Navigator.pushNamed(context, '/informacion');
                      },
                    ),
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
}
