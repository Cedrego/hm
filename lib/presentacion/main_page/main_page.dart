import 'package:flutter/material.dart';
import 'package:hm/core/logger.dart';
import '../../core/app_export.dart';
import '../../core/auth_service.dart';
import '../../core/firebase_service.dart';
import '../custom_app_bar.dart';
import '../app_drawer.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseService _firebaseService = FirebaseService();

  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  Map<String, dynamic>? _habitacionPopular;
  bool _isLoadingHabitacionPopular = false;

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

      // ✅ CARGAR HABITACIÓN POPULAR SOLO SI ES HUÉSPED
      if (_userData?['rol'] == 'huesped') {
        _cargarHabitacionPopular();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar los datos del usuario.')),
      );
    }
  }

  // ✅ NUEVO MÉTODO: Cargar habitación más popular
  Future<void> _cargarHabitacionPopular() async {
    if (!mounted) return;

    setState(() {
      _isLoadingHabitacionPopular = true;
    });

    try {
      // Obtener todas las reservas para contar por habitación
      final reservasSnapshot = await _firebaseService.getTodasLasReservas();

      // Contar reservas por habitación
      final Map<String, int> contadorReservas = {};

      for (final reserva in reservasSnapshot) {
        final habitacionId = reserva['idHabitacion'];
        if (habitacionId != null) {
          contadorReservas[habitacionId] =
              (contadorReservas[habitacionId] ?? 0) + 1;
        }
      }

      // Encontrar la habitación con más reservas
      String? habitacionIdMasPopular;
      int maxReservas = 0;

      contadorReservas.forEach((habitacionId, cantidad) {
        if (cantidad > maxReservas) {
          maxReservas = cantidad;
          habitacionIdMasPopular = habitacionId;
        }
      });

      // Obtener datos de la habitación más popular
      if (habitacionIdMasPopular != null) {
        final habitacionesSnapshot = await _firebaseService
            .getHabitaciones()
            .first;
        final habitacionPopular = habitacionesSnapshot.firstWhere(
          (habitacion) => habitacion['id'] == habitacionIdMasPopular,
          orElse: () => {},
        );

        if (habitacionPopular.isNotEmpty && mounted) {
          setState(() {
            _habitacionPopular = habitacionPopular;
          });
        }
      }
    } catch (e) {
      AppLogger.e('Error cargando habitación popular: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingHabitacionPopular = false;
        });
      }
    }
  }

  Future<void> _onLogoutPressed() async {
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

      if (!mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.loginScreen,
          (route) => false,
        );
      });
    }
  }

  // ✅ NUEVO MÉTODO: Navegar al detalle de la habitación popular
  void _verDetalleHabitacionPopular() {
    if (_habitacionPopular != null) {
      Navigator.pushNamed(
        context,
        AppRoutes.roomDetailScreen,
        arguments: _habitacionPopular,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = _userData?['rol'] == 'admin';
    final bool isHuesped = _userData?['rol'] == 'huesped';

    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
        onLogoutPressed: _onLogoutPressed,
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
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
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
                          _userData?['email'] ??
                              'Has iniciado sesión exitosamente',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildFeatureCards(isAdmin: isAdmin),
                        if (isHuesped) ...[
                          const SizedBox(height: 30),
                          _buildHabitacionPopularSection(),
                          const SizedBox(height: 20),
                        ] else
                          const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                _buildFooter(),
              ],
            ),
    );
  }

  Widget _buildFeatureCards({required bool isAdmin}) {
    final List<Widget> featureCards = [
      _buildFeatureCard(
        icon: Icons.bed,
        title: 'Habitaciones',
        color: Colors.blue,
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.roomListScreen);
        },
      ),
      if (isAdmin)
        _buildFeatureCard(
          icon: Icons.add_box,
          title: 'Crear Habitación',
          color: Colors.indigo,
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.roomCreationScreen);
          },
        ),
      _buildFeatureCard(
        icon: Icons.calendar_today,
        title: 'Reservas',
        color: Colors.green,
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.misReservas);
        },
      ),
      _buildFeatureCard(
        icon: Icons.person,
        title: 'Perfil',
        color: Colors.orange,
        onTap: () {
          if (_userData != null) {
            Navigator.pushNamed(
              context,
              AppRoutes.profileScreen,
              arguments: _userData,
            );
          }
        },
      ),
    ];

    if (!isAdmin) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: featureCards[0]),
              const SizedBox(width: 16),
              Expanded(child: featureCards[1]),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 2 - 20,
                child: featureCards[2],
              ),
            ),
          ),
        ],
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.0,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: featureCards,
    );
  }

  // ✅ NUEVO WIDGET: Sección de habitación popular
  Widget _buildHabitacionPopularSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🏆 Habitación Más Popular',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'La habitación favorita de nuestros huéspedes',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),

        if (_isLoadingHabitacionPopular)
          _buildHabitacionPopularLoading()
        else if (_habitacionPopular != null)
          _buildHabitacionPopularCard()
        else
          _buildHabitacionPopularEmpty(),
      ],
    );
  }

  // ✅ Widget para loading de habitación popular
  Widget _buildHabitacionPopularLoading() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text(
            'Buscando la habitación más popular...',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ✅ Widget para tarjeta de habitación popular
  Widget _buildHabitacionPopularCard() {
    final nombre = _habitacionPopular!['nombre'] ?? 'Habitación Popular';
    final descripcion = _habitacionPopular!['descripcion'] ?? 'Sin descripción';
    final precio = (_habitacionPopular!['precio'] ?? 0.0).toDouble();
    final imagenUrl = _habitacionPopular!['imagenUrl'];
    final disponible = _habitacionPopular!['disponible'] ?? true;

    return GestureDetector(
      onTap: _verDetalleHabitacionPopular,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withAlpha(26),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Imagen de la habitación
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: imagenUrl != null && imagenUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imagenUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.hotel,
                            size: 40,
                            color: Colors.grey[400],
                          );
                        },
                      ),
                    )
                  : Icon(Icons.hotel, size: 40, color: Colors.grey[400]),
            ),
            const SizedBox(width: 12),
            // Información de la habitación
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        'Más Reservada',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nombre,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    descripcion,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${precio.toStringAsFixed(2)} / noche',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00897B),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: disponible ? Colors.green[50] : Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: disponible
                                ? Colors.green.shade200
                                : Colors.red.shade200,
                          ),
                        ),
                        child: Text(
                          disponible ? 'Disponible' : 'No Disponible',
                          style: TextStyle(
                            fontSize: 10,
                            color: disponible
                                ? Colors.green[800]
                                : Colors.red[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // ✅ Widget cuando no hay habitación popular
  Widget _buildHabitacionPopularEmpty() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Row(
        children: [
          Icon(Icons.hotel, size: 24, color: Colors.grey),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Pronto tendremos información sobre nuestras habitaciones más populares',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
        ],
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
                  color: color.withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 30, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF00897B),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Hostel Mochileros',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tu hogar lejos de casa',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white70,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(color: Colors.white54, height: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFooterItem(Icons.location_on, 'Av. Principal 123'),
              _buildFooterItem(Icons.phone, '+1 234 567 890'),
              _buildFooterItem(Icons.email, 'info@hostelmochileros.com'),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.access_time, size: 14, color: Colors.white70),
              SizedBox(width: 4),
              Text(
                'Check-in: 14:00 | Check-out: 12:00',
                style: TextStyle(fontSize: 11, color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            '© 2025 Hostel Mochileros. Todos los derechos reservados.',
            style: TextStyle(fontSize: 9, color: Colors.white60),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFooterItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, size: 14, color: Colors.white70),
        const SizedBox(height: 2),
        Text(
          text,
          style: const TextStyle(fontSize: 9, color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
