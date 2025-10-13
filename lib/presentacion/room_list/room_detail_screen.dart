import 'package:flutter/material.dart';
import 'reservation_list_screen.dart'; 
import 'reservation_form_screen.dart'; 
import '../../core/auth_service.dart'; // Importar AuthService
import '../custom_app_bar.dart'; // Importar CustomAppBar
import '../app_drawer.dart'; // Importar AppDrawer
import '../../core/app_export.dart'; // Para AppRoutes
import 'package:intl/intl.dart'; // Para formato de moneda

class RoomDetailScreen extends StatefulWidget {
  final Map<String, dynamic> room;

  const RoomDetailScreen({required this.room, super.key});

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  // CLAVE GLOBAL para el Drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  // Estados de usuario
  bool _isLoadingUserData = true;
  Map<String, dynamic>? _userData;
  bool get _isAdmin => _userData?['rol'] == 'admin';
  final currencyFormatter = NumberFormat.currency(locale: 'es_ES', symbol: '\$', decimalDigits: 2);


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
        _isLoadingUserData = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingUserData = false;
      });
      // Manejar error de carga de datos de usuario si es necesario
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extraer datos de la habitación
    final room = widget.room;
    final String nombre = room['nombre'] ?? 'Habitación';
    final String descripcion = room['descripcion'] ?? 'Sin descripción';
    final String imagen = room['imagenUrl'] ?? '';
    final dynamic precioDia = room['precio'] ?? 0;
    final double precio = (precioDia is int) ? precioDia.toDouble() : (precioDia as double? ?? 0.0);
    final List<dynamic> serviciosAdicionales = room['servicios'] ?? [];
    final String idHabitacion = room['id'] ?? '';

    // Manejar el cierre de sesión desde el CustomAppBar
    void onLogoutPressed(BuildContext context) {
      AuthService.logout();
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.loginScreen, (route) => false);
    }
    
    // Mostrar un indicador de carga si los datos del usuario no están listos
    if (_isLoadingUserData) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
        onLogoutPressed: () => onLogoutPressed(context),
        userData: _userData,
        isAdmin: _isAdmin,
      ),
      drawer: AppDrawer(
        userData: _userData,
        isAdmin: _isAdmin,
        onLogoutPressed: onLogoutPressed,
      ),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              // 1. Imagen Principal
              _buildImageSection(imagen),

              // 2. Contenido Principal
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre y Precio
                    _buildNameAndPrice(nombre, precio),
                    const SizedBox(height: 16),
                    
                    // Descripción
                    const Text(
                      'Descripción',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      descripcion,
                      style: const TextStyle(fontSize: 16, height: 1.5, color: Color(0xFF555555)),
                    ),
                    const SizedBox(height: 20),

                    // Servicios
                    const Text(
                      'Servicios Incluidos',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                    ),
                    const SizedBox(height: 10),
                    _buildServicesChips(serviciosAdicionales),
                    const SizedBox(height: 80), // Espacio para el Fixed Bottom Bar
                  ],
                ),
              ),
            ],
          ),
          
          // 3. Barra de Botones Inferior Fija
          _buildBottomButtonBar(context, idHabitacion, room),
        ],
      ),
    );
  }

  // Helper para la sección de la imagen
  Widget _buildImageSection(String imagenUrl) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Image.network(
        imagenUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.image_not_supported, size: 50, color: Colors.grey.shade400),
              const Text('Imagen no disponible', style: TextStyle(color: Color(0xFF555555))),
            ],
          ),
        ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
              color: const Color(0xFF00897B),
            ),
          );
        },
      ),
    );
  }

  // Helper para nombre y precio
  Widget _buildNameAndPrice(String nombre, double precio) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            nombre,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFF00897B),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              currencyFormatter.format(precio),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            const Text(
              '/ Noche',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF555555),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper para mostrar los servicios como chips (reutilizado de room_list_screen)
  Widget _buildServicesChips(List<dynamic> serviciosAdicionales) {
    if (serviciosAdicionales.isEmpty) {
      return const Text('No se especificaron servicios adicionales.');
    }
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: serviciosAdicionales.map((servicio) {
        return _buildServiceChip(servicio.toString());
      }).toList(),
    );
  }

  // Helper para el chip de servicio
  Widget _buildServiceChip(String servicio) {
    final servicioLower = servicio.toLowerCase();
    IconData icon;
    Color color;

    if (servicioLower.contains('jacuzzi')) {
      icon = Icons.hot_tub;
      color = Colors.blue.shade400;
    } else if (servicioLower.contains('wifi')) {
      icon = Icons.wifi;
      color = Colors.purple.shade400;
    } else if (servicioLower.contains('minibar')) {
      icon = Icons.local_bar;
      color = Colors.orange.shade400;
    } else if (servicioLower.contains('servicio al cuarto') || servicioLower.contains('room service')) {
      icon = Icons.room_service;
      color = Colors.green.shade400;
    } else {
      icon = Icons.check_circle;
      color = Colors.teal.shade400;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            servicio,
            style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // Helper para la barra de botones inferior fija
  Widget _buildBottomButtonBar(BuildContext context, String idHabitacion, Map<String, dynamic> room) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Botón Ver Reservas (Solo para Admin)
            if (_isAdmin)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.reservationListScreen,
                      arguments: room,
                    );
                  },
                  icon: const Icon(Icons.list_alt, color: Colors.white),
                  label: const Text(
                    'Ver Reservas',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF333333),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            
            if (_isAdmin) const SizedBox(width: 12),

            // Botón Reservar Ahora (Para todos los usuarios)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                   Navigator.pushNamed(
                    context,
                    AppRoutes.reservationFormScreen,
                    arguments: room,
                  );
                },
                icon: const Icon(Icons.calendar_month, color: Colors.white),
                label: const Text(
                  'Reservar Ahora',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00897B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}