import 'package:flutter/material.dart';
import 'reservation_list_screen.dart'; 
import 'reservation_form_screen.dart'; 
import '../../core/auth_service.dart'; // Importar AuthService
import '../custom_app_bar.dart'; // Importar CustomAppBar
import '../app_drawer.dart'; // Importar AppDrawer
import '../../core/app_export.dart'; // Para AppRoutes

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

  Future<void> _onLogoutPressed(BuildContext context) async {
    // Lógica completa de confirmación de cierre de sesión
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmación'),
        content: const Text('¿Está seguro de cerrar sesión?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
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
      if (mounted) { 
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.loginScreen,
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUserData) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    // Extraer datos de la habitación
    final room = widget.room;
    final String nombre = room['NombreHab'] ?? 'Habitación';
    final String descripcion = room['Descripcion'] ?? 'Sin descripción';
    final String imagen = room['ImagenUrl'] ?? '';
    final dynamic precioDia = room['PrecioDia'] ?? 0;
    final double precio = (precioDia is int) ? precioDia.toDouble() : (precioDia as double? ?? 0.0);
    final List<dynamic> serviciosAdicionales = room['ServiciosAdicional'] ?? [];
    final int idHabitacion = room['idHabitacion'] ?? 0;


    return Scaffold(
      key: _scaffoldKey, // Asignar la key al Scaffold
      backgroundColor: Colors.grey[100],
      
      // 1. Usar CustomAppBar para el menú funcional
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
        onLogoutPressed: () => _onLogoutPressed(context),
        userData: _userData,
        isAdmin: _isAdmin,
      ),
      
      // 2. Usar AppDrawer para el menú lateral
      drawer: AppDrawer(
        userData: _userData,
        isAdmin: _isAdmin,
        onLogoutPressed: _onLogoutPressed,
      ),
      
      body: Stack(
        children: [
          SingleChildScrollView(
            // ... (resto del cuerpo de la pantalla de detalle)
            padding: const EdgeInsets.only(bottom: 100), // Espacio para el botón fijo
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sección de Imagen
                if (imagen.isNotEmpty)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                    child: Image.network(
                      imagen,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 250,
                          color: Colors.grey[300],
                          child: const Icon(Icons.hotel, size: 80, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              nombre,
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF00897B)),
                            ),
                          ),
                          Text(
                            '\$${precio.toStringAsFixed(2)}/noche',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF00897B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Botón para ver reservas (Solo visible para administradores)
                      if (_isAdmin)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.list_alt, color: Color(0xFF00897B)),
                              label: const Text('Ver Reservas de Habitación', style: TextStyle(color: Color(0xFF00897B))),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    // Pasa la habitación, incluyendo el ID
                                    builder: (context) => ReservationListScreen(room: widget.room), 
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFF00897B)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                        ),

                      const Text(
                        'Descripción',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        descripcion,
                        style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.5),
                      ),
                      const SizedBox(height: 20),

                      if (serviciosAdicionales.isNotEmpty) ...[
                        const Text(
                          'Servicios Incluidos',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: serviciosAdicionales.map((servicio) {
                            return _buildServiceChip(servicio.toString());
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Barra de navegación inferior (Botones de acción)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
              child: SafeArea(
                child: Row(
                  children: [
                    // Botón Anterior
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Navegar a la pantalla de formulario de reserva
                           Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReservationFormScreen(room: widget.room),
                              ),
                            );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00897B),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Reservar',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Botón Siguiente (puede ser otro botón si no hay navegación secuencial)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Simulación de acción secundaria o navegación (ej: Compartir)
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Función de Compartir (o Siguiente)'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Compartir',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper para mostrar los servicios como chips (reutilizado de room_list_screen)
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
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            servicio,
            style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}