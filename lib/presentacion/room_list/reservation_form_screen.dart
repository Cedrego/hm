import 'package:flutter/material.dart';
import '../../core/api_service.dart';

class ReservationFormScreen extends StatefulWidget {
  final Map<String, dynamic> room;

  const ReservationFormScreen({required this.room, super.key});

  @override
  State<ReservationFormScreen> createState() => _ReservationFormScreenState();
}

class _ReservationFormScreenState extends State<ReservationFormScreen> {
  DateTime? checkInDate;
  DateTime? checkOutDate;
  bool isLoading = false;

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00897B),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          checkInDate = picked;
          // Si ya hay check-out y es antes del check-in, limpiarlo
          if (checkOutDate != null && checkOutDate!.isBefore(picked)) {
            checkOutDate = null;
          }
        } else {
          // Validar que check-out sea después de check-in
          if (checkInDate != null && picked.isAfter(checkInDate!)) {
            checkOutDate = picked;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('La fecha de check-out debe ser posterior al check-in'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      });
    }
  }

  int get numberOfNights {
    if (checkInDate != null && checkOutDate != null) {
      return checkOutDate!.difference(checkInDate!).inDays;
    }
    return 0;
  }

  double get totalPrice {
    final precio = (widget.room['PrecioDia'] is int) 
        ? (widget.room['PrecioDia'] as int).toDouble() 
        : (widget.room['PrecioDia'] as double? ?? 0.0);
    return precio * numberOfNights;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Seleccionar fecha';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _confirmarReserva() async {
    if (checkInDate == null || checkOutDate == null || numberOfNights <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona fechas válidas'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Aquí llamarías a tu API para crear la reserva
      // final resultado = await ApiService.crearReserva(...);
      
      // Simulación de llamada API
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        setState(() {
          isLoading = false;
        });

        // Mostrar diálogo de confirmación
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[600], size: 32),
                const SizedBox(width: 12),
                const Text('¡Reserva Confirmada!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tu reserva en ${widget.room['NombreHab']} ha sido confirmada.'),
                const SizedBox(height: 8),
                Text('Check-in: ${_formatDate(checkInDate)}'),
                Text('Check-out: ${_formatDate(checkOutDate)}'),
                Text('Total: USD \$${totalPrice.toStringAsFixed(2)}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Cerrar todo y volver a la lista de habitaciones
                  Navigator.of(context).pop(); // Cerrar diálogo
                  Navigator.of(context).pop(); // Cerrar formulario
                  Navigator.of(context).pop(); // Cerrar detalle
                },
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear reserva: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String nombre = widget.room['NombreHab'] ?? 'Habitación';
    final dynamic precioDia = widget.room['PrecioDia'] ?? 0;
    final double precio = (precioDia is int) ? precioDia.toDouble() : (precioDia as double? ?? 0.0);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00897B),
        title: const Text('Realizar Reserva', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre de la habitación
                Text(
                  nombre,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'USD \$${precio.toStringAsFixed(2)} por noche',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),

                // Fecha de Check-in
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00897B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.calendar_today, color: Color(0xFF00897B)),
                    ),
                    title: const Text('Check-in', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      _formatDate(checkInDate),
                      style: TextStyle(
                        color: checkInDate != null ? Colors.black87 : Colors.grey,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _selectDate(context, true),
                  ),
                ),

                const SizedBox(height: 12),

                // Fecha de Check-out
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00897B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.event, color: Color(0xFF00897B)),
                    ),
                    title: const Text('Check-out', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      _formatDate(checkOutDate),
                      style: TextStyle(
                        color: checkOutDate != null ? Colors.black87 : Colors.grey,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: checkInDate != null 
                        ? () => _selectDate(context, false)
                        : null,
                  ),
                ),

                const SizedBox(height: 24),

                // Resumen
                if (checkInDate != null && checkOutDate != null && numberOfNights > 0) ...[
                  Card(
                    elevation: 3,
                    color: const Color(0xFF00897B).withOpacity(0.05),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: const Color(0xFF00897B).withOpacity(0.3)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.receipt_long, color: Color(0xFF00897B)),
                              SizedBox(width: 8),
                              Text(
                                'Resumen de Reserva',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          _buildSummaryRow('Precio por noche', '\$${precio.toStringAsFixed(2)}'),
                          const SizedBox(height: 8),
                          _buildSummaryRow('Número de noches', '$numberOfNights'),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total:',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'USD \$${totalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00897B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Botón Confirmar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (checkInDate != null && checkOutDate != null && numberOfNights > 0 && !isLoading)
                        ? _confirmarReserva
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00897B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: Colors.grey[300],
                      elevation: 4,
                    ),
                    child: const Text(
                      'Confirmar Reserva',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
          
          // Loading overlay
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Procesando reserva...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}