import 'package:flutter/material.dart';

class ReservaDetalleScreen extends StatelessWidget {
  // La reserva completa se pasa como argumento al navegar
  final Map<String, dynamic> reserva;

  const ReservaDetalleScreen({super.key, required this.reserva});

  // Utilidad para formatear la fecha (copiada de misreservas_screen)
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

  // Utilidad para mostrar el diálogo de cancelación
  void _mostrarDialogoCancelar(BuildContext context, Map<String, dynamic> res) {
    // Esta es la implementación del diálogo que ya teníamos diseñado.
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: EdgeInsets.zero, 
        content: Container(
          width: double.maxFinite, 
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            children: [
              Text(
                '${res['habitacion']?['nombre'] ?? 'Reserva'}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Precio: USD \$${(res['precioTotal'] ?? 0).toStringAsFixed(2)} | Check-in: ${_formatearFecha(res['fechaCheckIn'])}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Mensaje de advertencia
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '¡ATENCIÓN! ',
                        style: TextStyle(
                          color: Colors.red[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: 'De cancelar una reserva a menos de 1 semana de la fecha de check-in, no se reembolsará el pago.',
                        style: TextStyle(
                          color: Colors.red[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 20),
              
              const Text(
                '¿Desea cancelar su reserva de todas formas?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300], 
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Mantener Reserva',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 10),
                  
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx); // Cerrar el diálogo 
                        // En un escenario real, aquí notificarías a misreservas_screen 
                        // para que llame a _cancelarReserva y recargue la lista.
                        // Por ahora, solo cerramos y mostramos una notificación.
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Simulando cancelación de reserva...'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        Navigator.pop(context); // Opcional: Volver a la lista de reservas
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black, 
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Cancelar Reserva',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final habitacion = reserva['habitacion'] as Map<String, dynamic>?;
    final String nombreHab = habitacion?['nombre'] ?? 'Habitación No Encontrada';
    final String descripcion = habitacion?['descripcion'] ?? 'Detalles no disponibles.';
    final String extras = habitacion?['extras'] ?? 'Jacuzzi, Minibar'; // Simulación de extras
    final String imagenUrl = habitacion?['imagen'] ?? '';
    final double precioDiario = (habitacion?['precio'] ?? 0.0).toDouble();
    
    // Información específica de la reserva
    final String checkIn = _formatearFecha(reserva['fechaCheckIn']);
    final String checkOut = _formatearFecha(reserva['fechaCheckOut']);
    final double precioTotal = (reserva['precioTotal'] ?? 0).toDouble();
    final String estadoReserva = reserva['estado'] ?? 'Confirmada';


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF00897B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detalle de Reserva',
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Tarjeta de Detalle (Simulando el diseño de la imagen)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: Image.network(
                      imagenUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.hotel, size: 80, color: Colors.grey),
                          ),
                        );
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nombre y Precio Diario
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                nombreHab,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              'USD \$${precioDiario.toStringAsFixed(2)} / día',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00897B),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 4),
                        Text(
                          extras,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Descripción
                        Text(
                          descripcion,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[800],
                            height: 1.5,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),

                        // Detalles de la Habitación (Items)
                        const Text(
                          'Incluye:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFeatureRow('2 Camas Dobles', Icons.bed, Colors.blueGrey),
                            _buildFeatureRow('2 Baños', Icons.bathtub, Colors.blueGrey),
                            _buildFeatureRow('1 Ducha', Icons.shower, Colors.blueGrey),
                            _buildFeatureRow('Vistas al Mar', Icons.wb_sunny, Colors.blueGrey),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 20),

                        // Información de la Reserva
                        const Text(
                          'Reserva:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        _buildInfoRow('Check-in', checkIn, Icons.calendar_today),
                        _buildInfoRow('Check-out', checkOut, Icons.event),
                        _buildInfoRow('Precio Total', 'USD \$${precioTotal.toStringAsFixed(2)}', Icons.monetization_on, color: Colors.green[700]),
                        _buildInfoRow('Estado', estadoReserva, Icons.check_circle, color: estadoReserva.toLowerCase() == 'confirmada' ? Colors.green : Colors.grey),

                        const SizedBox(height: 20),
                        
                        // Botones de la imagen (Anterior, Reservado, Eliminar)
                        Row(
                          children: [
                            // Botón 1: Anterior (Volver)
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black87,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  elevation: 0,
                                ),
                                child: const Text('Anterior', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                            
                            const SizedBox(width: 10),

                            // Botón 2: Estado (Reservado/Completado) - Simulación
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  // Función de estado, no hace nada por ahora
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey, // Gris para Reservado
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  elevation: 0,
                                ),
                                child: Text(estadoReserva, style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),

                            const SizedBox(width: 10),

                            // Botón 3: Eliminar (Activa el modal de cancelación)
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  _mostrarDialogoCancelar(context, reserva);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red[700], // Rojo oscuro para eliminar/cancelar
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  elevation: 0,
                                ),
                                child: const Text('Eliminar', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para las filas de características
  Widget _buildFeatureRow(String text, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }

  // Widget auxiliar para las filas de información de la reserva
  Widget _buildInfoRow(String label, String value, IconData icon, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color ?? Colors.black87),
          const SizedBox(width: 10),
          SizedBox(
            width: 100,
            child: Text('$label:', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700])),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color ?? Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
