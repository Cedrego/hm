import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/firebase_service.dart';
import '../../core/auth_service.dart';
import '../custom_app_bar.dart';
import '../app_drawer.dart';
import '../../core/app_export.dart';

class RoomListScreen extends StatefulWidget {
  const RoomListScreen({super.key});

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseService firebaseService = FirebaseService.instance;

  bool _isLoadingUserData = true;
  Map<String, dynamic>? _userData;
  bool get _isAdmin => _userData?['rol'] == 'admin';

  List<Map<String, dynamic>> habitaciones = [];
  List<Map<String, dynamic>> habitacionesFiltradas = [];
  bool isLoading = true;
  String errorMessage = '';

  // Controlador para el campo de búsqueda
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _cargarHabitaciones();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      // Escuchar el stream de habitaciones
      firebaseService.getHabitaciones().listen(
        (listaHabitaciones) {
          if (mounted) {
            setState(() {
              habitaciones = listaHabitaciones;
              _aplicarFiltroBusqueda();
              isLoading = false;
            });
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              errorMessage = 'Error al cargar habitaciones: $error';
              isLoading = false;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Error al cargar habitaciones: $e';
          isLoading = false;
        });
      }
    }
  }

  void _aplicarFiltroBusqueda() {
    if (_searchQuery.isEmpty) {
      setState(() {
        habitacionesFiltradas = List.from(habitaciones);
      });
      return;
    }

    final query = _searchQuery.toLowerCase();
    setState(() {
      habitacionesFiltradas = habitaciones.where((habitacion) {
        final nombre = habitacion['nombre']?.toString().toLowerCase() ?? '';
        final servicios = List<String>.from(habitacion['servicios'] ?? []);

        // Buscar en el nombre
        final coincideNombre = nombre.contains(query);

        // Buscar en los servicios
        final coincideServicios = servicios.any(
          (servicio) => servicio.toLowerCase().contains(query),
        );

        return coincideNombre || coincideServicios;
      }).toList();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _aplicarFiltroBusqueda();
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
    });
    _aplicarFiltroBusqueda();
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
    if (_isLoadingUserData) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[100],

      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
        onLogoutPressed: _onLogoutPressed,
        userData: _userData,
        isAdmin: _isAdmin,
      ),

      drawer: AppDrawer(
        userData: _userData,
        isAdmin: _isAdmin,
        onLogoutPressed: _onLogoutPressed,
      ),

      body: RefreshIndicator(
        onRefresh: _cargarHabitaciones,
        color: const Color(0xFF00897B),
        child: Column(
          children: [
            // Barra de búsqueda
            _buildSearchBar(),

            // Lista de habitaciones
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF00897B),
                      ),
                    )
                  : errorMessage.isNotEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error al cargar habitaciones',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              errorMessage,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : habitacionesFiltradas.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No hay habitaciones disponibles'
                                : 'No se encontraron resultados',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (_searchQuery.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Búsqueda: "$_searchQuery"',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton(
                              onPressed: _clearSearch,
                              child: const Text('Limpiar búsqueda'),
                            ),
                          ],
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
                      itemCount: habitacionesFiltradas.length,
                      itemBuilder: (context, index) {
                        return _buildRoomListItem(habitacionesFiltradas[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _cargarHabitaciones,
        backgroundColor: const Color(0xFF00897B),
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Buscar habitaciones por nombre o servicios...',
          prefixIcon: const Icon(Icons.search, color: Color(0xFF00897B)),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: _clearSearch,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00897B), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildRoomListItem(Map<String, dynamic> room) {
    final String nombre = room['nombre'] ?? 'Habitación sin nombre';
    final String descripcion = room['descripcion'] ?? 'Sin descripción';
    final double precio = (room['precio'] ?? 0.0).toDouble();
    final String? imagenUrl = room['imagenUrl'];
    final bool disponible = room['disponible'] ?? true;

    final List<String> serviciosAdicionales = List<String>.from(
      room['servicios'] ?? [],
    );

    return GestureDetector(
      onTap: () => _mostrarDetalleHabitacion(room),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: disponible ? Colors.grey.shade300 : Colors.red.shade300,
          ),
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
            _buildRoomImage(imagenUrl, disponible),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre con indicador de disponibilidad
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          nombre,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: disponible ? Colors.black : Colors.grey,
                          ),
                        ),
                      ),
                      if (!disponible)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'NO DISPONIBLE',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.red.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Servicios
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getServiceColor(servicio),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _getServiceIcon(servicio),
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        servicio,
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

                  // Descripción
                  Text(
                    descripcion,
                    maxLines: 10,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: disponible ? Colors.grey[600] : Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Precio
                  if (precio > 0)
                    Text(
                      '\$${precio.toStringAsFixed(2)} / noche',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: disponible
                            ? const Color(0xFF00897B)
                            : Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.info_outline,
              color: disponible ? Colors.grey[600] : Colors.grey[400],
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomImage(String? imagenUrl, bool disponible) {
    // Si no hay imagen o es "vacio"
    if (imagenUrl == null || imagenUrl.isEmpty) {
      return Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: disponible ? Colors.grey[300] : Colors.grey[200],
        ),
        child: Icon(
          Icons.hotel,
          size: 40,
          color: disponible ? Colors.grey : Colors.grey[400],
        ),
      );
    }

    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: !disponible ? Colors.grey[100] : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: imagenUrl,
              fit: BoxFit.cover,
              width: 70,
              height: 70,
              placeholder: (context, url) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.hotel, size: 30, color: Colors.grey),
              ),
              errorWidget: (context, url, error) {
                return Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.hotel, size: 30, color: Colors.grey),
                );
              },
            ),
            if (!disponible)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: Icon(Icons.block, color: Colors.white, size: 24),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _mostrarDetalleHabitacion(Map<String, dynamic> habitacion) {
    if (mounted) {
      Navigator.pushNamed(
        context,
        AppRoutes.roomDetailScreen,
        arguments: habitacion,
      );
    }
  }

  IconData _getServiceIcon(String servicio) {
    final servicioLower = servicio.toLowerCase();
    if (servicioLower.contains('jacuzzi')) return Icons.hot_tub;
    if (servicioLower.contains('wifi')) return Icons.wifi;
    if (servicioLower.contains('minibar')) return Icons.local_bar;
    if (servicioLower.contains('servicio al cuarto') ||
        servicioLower.contains('room service')) {
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
