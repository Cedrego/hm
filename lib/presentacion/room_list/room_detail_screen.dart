import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart'; // ← AGREGAR PARA CLOUDINARY
import '../../core/auth_service.dart';
import '../custom_app_bar.dart';
import '../app_drawer.dart';
import '../../core/app_export.dart';
import 'package:intl/intl.dart';

class RoomDetailScreen extends StatefulWidget {
  final Map<String, dynamic> room;

  const RoomDetailScreen({required this.room, super.key});

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isLoadingUserData = true;
  Map<String, dynamic>? _userData;
  bool get _isAdmin => _userData?['rol'] == 'admin';
  final currencyFormatter = NumberFormat.currency(
    locale: 'es_ES',
    symbol: '\$',
    decimalDigits: 2,
  );

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

  @override
  Widget build(BuildContext context) {
    final room = widget.room;
    final String nombre = room['nombre'] ?? 'Habitación';
    final String descripcion = room['descripcion'] ?? 'Sin descripción';
    final String imagenUrl =
        room['imagenUrl'] ?? ''; // ← YA USA imagenUrl (CORRECTO)
    final dynamic precioDia = room['precio'] ?? 0;
    final double precio = (precioDia is int)
        ? precioDia.toDouble()
        : (precioDia as double? ?? 0.0);
    final List<dynamic> serviciosAdicionales = room['servicios'] ?? [];
    final String idHabitacion =
        room['id'] ?? ''; // ← CAMBIO: 'id' en lugar de 'idHabitacion'
    final bool disponible =
        room['disponible'] ?? true; // ← AGREGAR DISPONIBILIDAD

    if (_isLoadingUserData) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
        onLogoutPressed: _onLogoutPressed, // ← SIN PARÁMETRO
        userData: _userData,
        isAdmin: _isAdmin,
      ),
      drawer: AppDrawer(
        userData: _userData,
        isAdmin: _isAdmin,
        onLogoutPressed: _onLogoutPressed, // ← SIN PARÁMETRO
      ),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              // 1. Imagen Principal
              _buildImageSection(
                imagenUrl,
                disponible,
              ), // ← AGREGAR DISPONIBILIDAD
              // 2. Contenido Principal
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre y Precio
                    _buildNameAndPrice(
                      nombre,
                      precio,
                      disponible,
                    ), // ← AGREGAR DISPONIBILIDAD
                    const SizedBox(height: 16),

                    // Descripción
                    const Text(
                      'Descripción',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      descripcion,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: disponible
                            ? Color(0xFF555555)
                            : Colors.grey[400], // ← ESTADO DISPONIBLE
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Servicios
                    const Text(
                      'Servicios Incluidos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildServicesChips(
                      serviciosAdicionales,
                      disponible,
                    ), // ← AGREGAR DISPONIBILIDAD
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),

          // 3. Barra de Botones Inferior Fija
          _buildBottomButtonBar(
            context,
            idHabitacion,
            room,
            disponible,
          ), // ← AGREGAR DISPONIBILIDAD
        ],
      ),
    );
  }

  // ✅ MÉTODO ACTUALIZADO PARA CLOUDINARY CON DISPONIBILIDAD
  Widget _buildImageSection(String imagenUrl, bool disponible) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // ✅ USAR CACHED NETWORK IMAGE PARA CLOUDINARY
          imagenUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: imagenUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 250,
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(color: Color(0xFF00897B)),
                  ),
                  errorWidget: (context, url, error) =>
                      _buildPlaceholderImage(),
                )
              : _buildPlaceholderImage(),

          // Overlay si no está disponible
          if (!disponible)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.block, size: 50, color: Colors.white),
                    SizedBox(height: 8),
                    Text(
                      'NO DISPONIBLE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Widget auxiliar para imagen placeholder
  Widget _buildPlaceholderImage() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.hotel, size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(
            'Imagen no disponible',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildNameAndPrice(String nombre, double precio, bool disponible) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nombre,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: disponible ? Color(0xFF00897B) : Colors.grey,
                ),
              ),
              if (!disponible)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    'No disponible para reservas',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              currencyFormatter.format(precio),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: disponible ? Colors.redAccent : Colors.grey,
              ),
            ),
            Text(
              '/ Noche',
              style: TextStyle(
                fontSize: 14,
                color: disponible ? Color(0xFF555555) : Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServicesChips(
    List<dynamic> serviciosAdicionales,
    bool disponible,
  ) {
    if (serviciosAdicionales.isEmpty) {
      return Text(
        'No se especificaron servicios adicionales.',
        style: TextStyle(color: disponible ? Color(0xFF555555) : Colors.grey),
      );
    }
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: serviciosAdicionales.map((servicio) {
        return _buildServiceChip(servicio.toString(), disponible);
      }).toList(),
    );
  }
  
  Widget _buildServiceChip(String servicio, bool disponible) {
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
    } else if (servicioLower.contains('servicio al cuarto') ||
        servicioLower.contains('room service')) {
      icon = Icons.room_service;
      color = Colors.green.shade400;
    } else {
      icon = Icons.check_circle;
      color = Colors.teal.shade400;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(disponible ? 26 : 13),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(disponible ? 76 : 26)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: disponible ? color : Colors.grey),
          const SizedBox(width: 6),
          Text(
            servicio,
            style: TextStyle(
              fontSize: 14,
              color: disponible ? color : Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtonBar(
    BuildContext context,
    String idHabitacion,
    Map<String, dynamic> room,
    bool disponible,
  ) {
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
              color: Colors.black.withAlpha(26),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
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
            if (!_isAdmin)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: disponible
                      ? () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.reservationFormScreen,
                            arguments: room,
                          );
                        }
                      : null,
                  icon: Icon(
                    Icons.calendar_month,
                    color: disponible ? Colors.white : Colors.grey,
                  ),
                  label: Text(
                    disponible ? 'Reservar Ahora' : 'No Disponible',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: disponible ? Colors.white : Colors.grey,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: disponible
                        ? Color(0xFF00897B)
                        : Colors.grey.shade300,
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
