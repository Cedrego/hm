import 'package:flutter/material.dart';
import '../../core/api_service.dart';
import '../../core/auth_service.dart';
import '../../routes/app_routes.dart'; 


class MisReservasScreen extends StatefulWidget {
  const MisReservasScreen({super.key});

  @override
  State<MisReservasScreen> createState() => _MisReservasScreenState();
}

class _MisReservasScreenState extends State<MisReservasScreen> {
  List<Map<String, dynamic>> reservas = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _cargarReservas();
  }

  Future<void> _cargarReservas() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Obtener ID del usuario logueado
      final userId = await AuthService.getUserId();
      
      if (userId == null || userId.isEmpty) {
        throw Exception('Usuario no autenticado');
      }

      print('🔍 Cargando reservas para usuario: $userId');
      
      // Llamar al API para obtener reservas
      final data = await ApiService.getReservasUsuario(userId);
      
      setState(() {
        reservas = data.map((e) => e as Map<String, dynamic>).toList();
        isLoading = false;
      });
      
      print('✅ Cargadas ${reservas.length} reservas');
    } catch (e) {
      print('❌ Error cargando reservas: $e');
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  String _formatearFecha(String? fecha) {
    if (fecha == null) return 'N/A';
    try {
      final partes = fecha.split('-');
      if (partes.length == 3) {
        return '${partes[2]}/${partes[1]}/${partes[0]}';
      }
      return fecha;
    } catch (e) {
      return fecha;
    }
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'confirmada':
        return Colors.green;
      case 'cancelada':
        return Colors.red;
      case 'completada':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
  // --- FUNCIÓN CLAVE ACTUALIZADA ---
  void _verDetallesReserva(Map<String, dynamic> reserva) {
    // Utilizamos Navigator.pushNamed y pasamos el objeto 'reserva' como argumento.
    // AppRoutes se encarga de extraerlo y pasarlo al constructor de ReservaDetalleScreen.
    Navigator.pushNamed(
      context,
      AppRoutes.misReservasDetalle,
      arguments: reserva, // Pasando la reserva como argumento
    );
  }
  // ---------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00897B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00897B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Mis Reservas',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _cargarReservas,
          ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    // Mientras carga
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF00897B)),
            SizedBox(height: 16),
            Text('Cargando reservas...', style: TextStyle(fontSize: 16)),
          ],
        ),
      );
    }

    // Si hay error
    if (errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 80, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Error al cargar reservas',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _cargarReservas,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00897B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Si no hay reservas
    if (reservas.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_busy, size: 100, color: Colors.grey[400]),
              const SizedBox(height: 24),
              const Text(
                'Aún no has realizado reservas',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Explora nuestras habitaciones y realiza tu primera reserva',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context); // Volver a la lista de habitaciones
                },
                icon: const Icon(Icons.hotel),
                label: const Text('Ver Habitaciones'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00897B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Mostrar lista de reservas
    return RefreshIndicator(
      onRefresh: _cargarReservas,
      color: const Color(0xFF00897B),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reservas.length,
        itemBuilder: (context, index) {
          final reserva = reservas[index];
          return _buildReservaCard(reserva);
        },
      ),
    );
  }

  Widget _buildReservaCard(Map<String, dynamic> reserva) {
    final habitacion = reserva['habitacion'] as Map<String, dynamic>?;
    final String nombreHab = habitacion?['nombre'] ?? 'Habitación';
    final String imagenUrl = habitacion?['imagen'] ?? '';
    final List<dynamic> servicios = habitacion?['servicios'] ?? [];
    final String estado = reserva['estado'] ?? 'Confirmada';
    final double precioTotal = (reserva['precioTotal'] ?? 0).toDouble();
    final int diasEstadia = reserva['diasEstadia'] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen de la habitación
          if (imagenUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  Image.network(
                    imagenUrl,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 160,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.hotel, size: 60, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                  // Badge de estado
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getEstadoColor(estado),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        estado,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Información de la reserva
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre de la habitación
                Text(
                  nombreHab,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),

                // Servicios (chips)
                if (servicios.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: servicios.take(3).map((servicio) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00897B).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF00897B).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          servicio.toString(),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF00897B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),

                // Fechas
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16, color: Color(0xFF00897B)),
                              const SizedBox(width: 8),
                              Text(
                                'Check-in',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatearFecha(reserva['fechaCheckIn']),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.event, size: 16, color: Color(0xFF00897B)),
                              const SizedBox(width: 8),
                              Text(
                                'Check-out',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatearFecha(reserva['fechaCheckOut']),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Estadía y precio
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00897B).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.nights_stay, size: 20, color: Color(0xFF00897B)),
                          const SizedBox(width: 8),
                          Text(
                            '$diasEstadia ${diasEstadia == 1 ? 'noche' : 'noches'}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'USD \$${precioTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00897B),
                        ),
                      ),
                    ],
                  ),
                ),

               // Botones (ahora en un Row)
                const SizedBox(height: 16),
                Row(
                  children: [
                     // Botón de Detalles (Llama a _verDetallesReserva)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _verDetallesReserva(reserva), 
                        icon: const Icon(Icons.info_outline, size: 18),
                        label: const Text('Ver Detalles'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200], 
                          foregroundColor: const Color(0xFF00897B), 
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12), // Espacio entre botones

                    // Botón de Cancelar (Solo si está confirmada)
                    Expanded(
                      child: (estado.toLowerCase() == 'confirmada')
                          ? OutlinedButton.icon(
                              onPressed: () {
                                _mostrarDialogoCancelar(reserva);
                              },
                              icon: const Icon(Icons.cancel_outlined, size: 18),
                              label: const Text('Cancelar'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            )
                          : Container(), // Si no está confirmada, deja un espacio vacío
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoCancelar(Map<String, dynamic> reserva) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('¿Cancelar Reserva?'),
        content: const Text('¿Estás seguro de que deseas cancelar esta reserva? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _cancelarReserva(reserva['idReserva'] ?? reserva['_id']);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sí, Cancelar'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelarReserva(String idReserva) async {
    try {
      // Aquí llamarías a tu API para cancelar
      // await ApiService.cancelarReserva(idReserva);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reserva cancelada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Recargar reservas
      _cargarReservas();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cancelar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}