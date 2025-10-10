import 'package:flutter/material.dart';
import '../../core/api_service.dart';

class RoomListScreen extends StatefulWidget {
  final Map<String, dynamic>? user;

  const RoomListScreen({this.user, super.key});

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  List<dynamic> habitaciones = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _cargarHabitaciones();
  }

  Future<void> _cargarHabitaciones() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      print('🔄 Cargando habitaciones desde la API...');
      final data = await ApiService.getHabitaciones();
      
      setState(() {
        habitaciones = data;
        isLoading = false;
      });
      
      print('✅ ${habitaciones.length} habitaciones cargadas');
    } catch (e) {
      print('❌ Error al cargar habitaciones: $e');
      setState(() {
        errorMessage = 'Error al cargar habitaciones: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF00897B),
        title: const Text(
          'Habitaciones Disponibles',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          if (widget.user != null)
            IconButton(
              icon: const Icon(Icons.person, color: Colors.white),
              onPressed: () {},
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _cargarHabitaciones,
        color: const Color(0xFF00897B),
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
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
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
                          final habitacion = habitaciones[index];
                          return _buildRoomListItem(habitacion);
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

  Widget _buildRoomListItem(Map<String, dynamic> room) {
    final String nombre = room['NombreHab'] ?? 'Habitación';
    final String descripcion = room['Descripcion'] ?? 'Sin descripción';
    final String imagen = room['ImagenUrl'] ?? room['imagen'] ?? '';
    final double precio = (room['PrecioDia'] ?? room['precio'] ?? 0).toDouble();
    final List<dynamic> serviciosAdicionales = room['ServiciosAdicional'] ?? [];

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
                  Text(
                    nombre,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  if (serviciosAdicionales.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: serviciosAdicionales.take(3).map((servicio) {
                          return Container(
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
                          );
                        }).toList(),
                      ),
                    ),
                  if (serviciosAdicionales.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '+${serviciosAdicionales.length - 3} más',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  Text(
                    descripcion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDetalleHabitacion(habitacion),
    );
  }

  Widget _buildDetalleHabitacion(Map<String, dynamic> habitacion) {
    final String nombre = habitacion['NombreHab'] ?? 'Habitación';
    final String descripcion = habitacion['Descripcion'] ?? 'Sin descripción';
    final String imagen = habitacion['ImagenUrl'] ?? habitacion['imagen'] ?? '';
    final double precio = (habitacion['PrecioDia'] ?? habitacion['precio'] ?? 0).toDouble();
    final List<dynamic> servicios = habitacion['ServiciosAdicional'] ?? [];
    final int idHabitacion = habitacion['idHabitacion'] ?? 0;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (imagen.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            imagen,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
                                height: 200,
                                color: Colors.grey[300],
                                child: const Icon(Icons.hotel, size: 80, color: Colors.grey),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              nombre,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00897B),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'ID: $idHabitacion',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${precio.toStringAsFixed(2)} / noche',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00897B),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Descripción',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        descripcion,
                        style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.5),
                      ),
                      const SizedBox(height: 20),
                      if (servicios.isNotEmpty) ...[
                        const Text(
                          'Servicios Adicionales',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: servicios.map((servicio) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00897B).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF00897B).withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getServiceIcon(servicio.toString()),
                                    size: 18,
                                    color: const Color(0xFF00897B),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    servicio.toString(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF00897B),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Reservando: $nombre'),
                                backgroundColor: const Color(0xFF00897B),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00897B),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Reservar Ahora',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

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