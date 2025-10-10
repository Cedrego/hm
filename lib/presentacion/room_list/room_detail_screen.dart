import 'package:flutter/material.dart';
import 'reservation_list_screen.dart'; // Para navegar a hacer una reserva
import 'reservation_form_screen.dart'; // Pantalla de formulario de reserva
class RoomDetailScreen extends StatelessWidget {
  final Map<String, dynamic> room;

  const RoomDetailScreen({required this.room, super.key});

  @override
  Widget build(BuildContext context) {
    // Extraer datos de la habitación
    final String nombre = room['NombreHab'] ?? 'Habitación';
    final String descripcion = room['Descripcion'] ?? 'Sin descripción';
    final String imagen = room['ImagenUrl'] ?? '';
    final dynamic precioDia = room['PrecioDia'] ?? 0;
    final double precio = (precioDia is int) ? precioDia.toDouble() : (precioDia as double? ?? 0.0);
    final List<dynamic> serviciosAdicionales = room['ServiciosAdicional'] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFF00897B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00897B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            // Abrir menú
          },
        ),
        title: const Text(
          'Información de Habitación',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Imagen de la habitación
                      Container(
                        width: double.infinity,
                        height: 200,
                        color: Colors.grey[300],
                        child: imagen.isNotEmpty
                            ? Image.network(
                                imagen,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.hotel, size: 60, color: Colors.grey[400]),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Imagen no disponible',
                                          style: TextStyle(color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              )
                            : Center(
                                child: Icon(Icons.hotel, size: 80, color: Colors.grey[400]),
                              ),
                      ),

                      // Contenido de información
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nombre de la habitación con emoji
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    nombre,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Text(
                                  '🔑',
                                  style: TextStyle(fontSize: 24),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 4),
                            
                            // Precio
                            if (precio > 0)
                              Text(
                                'Minibar incluido',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            
                            const SizedBox(height: 12),
                            
                            // Descripción
                            Text(
                              descripcion,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[800],
                                height: 1.5,
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Servicios adicionales con viñetas
                            if (serviciosAdicionales.isNotEmpty) ...[
                              const Text(
                                'Servicios incluidos:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...serviciosAdicionales.map((servicio) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '• ',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[800],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          servicio.toString(),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              const SizedBox(height: 16),
                            ],
                            
                            // Precio destacado
                            if (precio > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  'USD \$${precio.toStringAsFixed(2)} por noche',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF00897B),
                                  ),
                                ),
                              ),
                            
                            const SizedBox(height: 8),
                            
                            // Nota sobre disponibilidad
                            Text(
                              '*Disponibilidad sujeta al sistema al momento de realizar la reserva.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Botones de navegación
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Botón Anterior
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
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
                      'Anterior',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Botón Reservar (destacado en verde)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Navegar a la pantalla de hacer reserva
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReservationFormScreen(room: room),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C853),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      'Reservar',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Botón Siguiente
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Navegar a la siguiente habitación (si existe)
                      // Por ahora solo cierra
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No hay más habitaciones'),
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
                      'Siguiente',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}