import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../core/auth_service.dart';
import '../custom_app_bar.dart';
import '../app_drawer.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await AuthService.getUserData();
      if (!mounted) return;
      setState(() {
        _userData = userData;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al cargar los datos del usuario.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String roomListRoute = AppRoutes.roomListScreen;
    final String roomCreationRoute = AppRoutes.roomCreationScreen;
    final String MisreservationsRoute = AppRoutes.misReservas;
    final String profileRoute = AppRoutes.profileScreen;
    final String informationRoute = '/informacion';
    final bool isAdmin = _userData?['rol'] == 'admin';

    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
        onLogoutPressed: () => _onLogoutPressed(context),
        userData: _userData,
        isAdmin: isAdmin,
      ),
      drawer: _isLoading
        ? null
        : AppDrawer(
            userData: _userData,
            isAdmin: isAdmin,
            onLogoutPressed: _onLogoutPressed,
          ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Bienvenido${_userData?['nombre'] != null ? ', ${_userData!['nombre'].split(' ')[0]}' : ''}!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _userData?['email'] ?? 'Has iniciado sesión exitosamente',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.0,
                      children: [
                        _buildFeatureCard(
                          icon: Icons.bed,
                          title: 'Habitaciones',
                          color: Colors.blue,
                          onTap: () {
                            Navigator.pushNamed(context, roomListRoute);
                          },
                        ),
                        if (isAdmin)
                          _buildFeatureCard(
                            icon: Icons.add_box,
                            title: 'Crear Habitación',
                            color: Colors.indigo,
                            onTap: () {
                              Navigator.pushNamed(context, roomCreationRoute);
                            },
                          ),
                        _buildFeatureCard(
                          icon: Icons.calendar_today,
                          title: 'Reservas',
                          color: Colors.green,
                          onTap: () {
                            Navigator.pushNamed(context, MisreservationsRoute);
                          },
                        ),
                        _buildFeatureCard(
                          icon: Icons.person,
                          title: 'Perfil',
                          color: Colors.orange,
                          onTap: () {
                            // ✅ CORREGIDO: Pasar userData correctamente
                            if (_userData != null) {
                              Navigator.pushNamed(
                                context, 
                                profileRoute, 
                                arguments: _userData,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: Datos de usuario no disponibles')),
                              );
                            }
                          },
                        ),
                        _buildFeatureCard(
                          icon: Icons.info,
                          title: 'Información',
                          color: Colors.purple,
                          onTap: () {
                            Navigator.pushNamed(context, informationRoute);
                          },
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 30, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
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
      await AuthService.logout();
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.loginScreen,
        (route) => false,
      );
    }
  }
}