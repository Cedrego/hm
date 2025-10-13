import 'package:flutter/material.dart';
import '../../core/api_service.dart';
import '../../core/auth_service.dart'; 
import '../custom_app_bar.dart'; 
import '../app_drawer.dart'; 
import '../../core/app_export.dart'; // Para AppRoutes

class RoomListScreen extends StatefulWidget {
  // 🟢 Eliminado el parámetro 'user' ya que se carga con AuthService.
  const RoomListScreen({super.key}); 

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  bool _isLoadingUserData = true;
  Map<String, dynamic>? _userData;
  bool get _isAdmin => _userData?['rol'] == 'admin';

  List<dynamic> habitaciones = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _cargarHabitaciones();
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

  Future<void> _cargarHabitaciones() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final data = await ApiService.getHabitaciones();
      
      if (!mounted) return;
      setState(() {
        habitaciones = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Error al cargar habitaciones: $e';
        isLoading = false;
      });
    }
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
    
    return Scaffold(
      key: _scaffoldKey, // 🟢 Asignar la key al Scaffold
      backgroundColor: Colors.grey[100],
      
      // 🟢 USANDO CUSTOMAPPBAR 🟢
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
        onLogoutPressed: () => _onLogoutPressed(context),
        userData: _userData,
        isAdmin: _isAdmin,
      ),
      
      // 🟢 USANDO APPDRAWER 🟢
      drawer: AppDrawer(
        userData: _userData,
        isAdmin: _isAdmin,
        onLogoutPressed: _onLogoutPressed,
      ),
      
      // La lógica del cuerpo se mantiene igual.
      body: RefreshIndicator(
        onRefresh: _cargarHabitaciones,
        color: const Color(0xFF00897B),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF00897B)),
              )
            : errorMessage.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error al cargar habitaciones',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            errorMessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _cargarHabitaciones,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00897B),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  )
                : habitaciones.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.hotel_outlined, size: 80, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No hay habitaciones disponibles',
                              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: _cargarHabitaciones,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Actualizar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00897B),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: habitaciones.length,
                        itemBuilder: (context, index) {
                          return _buildRoomListItem(habitaciones[index] as Map<String, dynamic>);
                        },
                      ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _cargarHabitaciones,
        backgroundColor: const Color(0xFF00897B),
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  // Se mantienen el resto de los métodos auxiliares:
  // _buildRoomListItem, _mostrarDetalleHabitacion, _buildDetalleHabitacion,
  // _getServiceIcon, _getServiceColor.
  // Dentro de la clase _RoomListScreenState
// ...

Widget _buildRoomListItem(Map<String, dynamic> room) {
    // 🟢 CORRECCIÓN: Usamos las claves de la respuesta de la API ('nombre', 'descripcion', 'precio')
    final String nombre = (room['nombre'] as String?) ?? 'Habitación sin nombre';
    final String descripcion = (room['descripcion'] as String?) ?? 'Sin descripción';
    
    // Asumimos que 'precio' es un número (int o double)
    final double precio = (room['precio'] as num?)?.toDouble() ?? 0.0;
    
    // La clave de la imagen de la API es 'imagenUrl'
    final String imagen = (room['imagenUrl'] as String?) ?? '';
    
    // 🟢 CORRECCIÓN: La clave de servicios de la API es 'servicios'
    final List<String> serviciosAdicionales = (room['servicios'] as List<dynamic>?)
        ?.map((s) => s.toString())
        .toList() ?? [];


    return GestureDetector(
      onTap: () => _mostrarDetalleHabitacion(room),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[300],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imagen.isNotEmpty
                    ? (imagen.startsWith('http')
                        ? Image.network(
                            imagen,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.hotel, size: 40, color: Colors.grey);
                            },
                          )
                        : Image.asset(
                            imagen,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.hotel, size: 40, color: Colors.grey);
                            },
                          ))
                    : const Icon(Icons.hotel, size: 40, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🟢 Ahora usa el nombre correcto de la API
                  Text(
                    nombre,
                    maxLines: 2, 
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),

                  // Servicios (Usando la clave 'servicios' corregida)
                  if (serviciosAdicionales.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: SizedBox(
                        height: 25, 
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: serviciosAdicionales.map((servicio) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 4.0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getServiceColor(servicio.toString()),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _getServiceIcon(servicio.toString()),
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        servicio.toString(),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  
                  // 🟢 Ahora usa la descripción correcta de la API
                  Text(
                    descripcion,
                    maxLines: 10,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),

                  // 🟢 Ahora usa el precio correcto de la API
                  if (precio > 0)
                    Text(
                      '\$${precio.toStringAsFixed(2)} / noche',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00897B),
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
            Icon(Icons.info_outline, color: Colors.grey[600], size: 24),
          ],
        ),
      ),
    );
  }
  void _mostrarDetalleHabitacion(Map<String, dynamic> habitacion) {
    // Navegar a la pantalla de detalle de habitación usando rutas con argumentos
    if (mounted) {
      Navigator.pushNamed(
        context,
        AppRoutes.roomDetailScreen,
        arguments: habitacion,
      );
    }
  }

  // ⚠️ NOTA: El método _buildDetalleHabitacion y el showModalBottomSheet han sido
  // reemplazados por la navegación a AppRoutes.roomDetailScreen, tal como se
  // corrigió en el _buildRoomListItem para mantener la consistencia con la arquitectura.
  // Si deseas volver a usar el BottomSheet, usa la versión anterior.
  // Mantenemos los helpers de servicio por si se usan en el detalle del BottomSheet.

  IconData _getServiceIcon(String servicio) {
    final servicioLower = servicio.toLowerCase();
    if (servicioLower.contains('jacuzzi')) return Icons.hot_tub;
    if (servicioLower.contains('wifi')) return Icons.wifi;
    if (servicioLower.contains('minibar')) return Icons.local_bar;
    if (servicioLower.contains('servicio al cuarto') || servicioLower.contains('room service')) {
      return Icons.room_service;
    }
    if (servicioLower.contains('tv')) return Icons.tv;
    if (servicioLower.contains('aire') || servicioLower.contains('ac')) {
      return Icons.ac_unit;
    }
    return Icons.check_circle;
  }

  Color _getServiceColor(String servicio) {
    final servicioLower = servicio.toLowerCase();
    if (servicioLower.contains('jacuzzi')) return Colors.blue.shade400;
    if (servicioLower.contains('wifi')) return Colors.purple.shade400;
    if (servicioLower.contains('minibar')) return Colors.orange.shade400;
    if (servicioLower.contains('servicio al cuarto')) return Colors.green.shade400;
    if (servicioLower.contains('tv')) return Colors.indigo.shade400;
    return Colors.teal.shade400;
  }
}