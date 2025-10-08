import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import 'room_models.dart';

// =================================================================
// PANTALLA DE INFORMACIÓN DE HABITACIÓN (IMAGEN 3)
// =================================================================

class RoomDetailScreen extends StatelessWidget {
  final Room room;

  const RoomDetailScreen({required this.room, super.key});

  static const Color _kReserveColor = Color(0xFF00C853); // Verde para el botón

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFF008080), // Fondo teal
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Barra de Título y Menú
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.menu, color: Colors.white, size: 30),
                      SizedBox(width: 10),
                      Text('Informacion de Habitación', style: TextStyle(color: Colors.white, fontSize: 18)),
                    ],
                  ),
                ),
                
                // Contenedor principal de la tarjeta blanca
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 20.0),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Imagen de la habitación (Placeholder)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            height: 250,
                            width: double.infinity,
                            color: Colors.grey[300], 
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Título y Precio
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(room.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
                            Text(
                              room.pricePerDay.split(' ')[0], // Muestra solo '30USD'
                              style: TextStyle(fontSize: 18, color: Colors.blue.shade700, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Text(room.description.split('. ')[0], style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 10),
                        
                        // Descripción detallada
                        Text(room.description.split('. ')[1], style: const TextStyle(color: Colors.black)),
                        const SizedBox(height: 10),

                        // Detalles con bullets
                        ...room.details.split('\n').map((detail) => Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text('• $detail', style: const TextStyle(color: Colors.black)),
                        )).toList(),
                        
                        const SizedBox(height: 20),
                        
                        // Nota
                        const Text(
                          'Nota: El precio final será calculado por el sistema al momento de realizar la reserva.', 
                          style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12, color: Colors.black54)
                        ),
                        const SizedBox(height: 30),

                        // Botones de Navegación
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildButton('Anterior', Colors.black45, () => Navigator.pop(context)),
                            
                            // ACCIÓN CLAVE: Abrir Diálogo de Reserva
                            _buildButton('Reservar', _kReserveColor, () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return ReservationDialog(roomName: room.name);
                                },
                              );
                            }),
                            
                            _buildButton('Siguiente', Colors.black45, () {
                              // Lógica para ir a la siguiente habitación
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }
}


// =================================================================
// DIÁLOGO DE CREAR RESERVA (IMAGEN 1)
// =================================================================

class ReservationDialog extends StatefulWidget {
  final String roomName;
  const ReservationDialog({required this.roomName, super.key});

  @override
  State<ReservationDialog> createState() => _ReservationDialogState();
}

class _ReservationDialogState extends State<ReservationDialog> {
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  final DateFormat _dateFormat = DateFormat('d/M/yyyy');

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.pink, 
            colorScheme: const ColorScheme.light(primary: Colors.pink, onPrimary: Colors.white), 
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = picked;
          if (_checkOutDate != null && _checkOutDate!.isBefore(_checkInDate!)) {
            _checkOutDate = null;
          }
        } else {
          _checkOutDate = picked;
          if (_checkInDate != null && _checkOutDate!.isBefore(_checkInDate!)) {
            _checkInDate = null; 
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('¿Desea reservar esta habitación?', style: TextStyle(fontSize: 16, color: Colors.black)),
          Text(
            widget.roomName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Check-in
            const Text('Fecha de Check-in', style: TextStyle(color: Colors.black54)),
            _buildDateField(context, _checkInDate, (picked) => _selectDate(context, true)),
            const SizedBox(height: 15),

            // Check-out
            const Text('Fecha de Check-out', style: TextStyle(color: Colors.black54)),
            _buildDateField(context, _checkOutDate, (picked) => _selectDate(context, false)),
          ],
        ),
      ),
      actions: <Widget>[
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (_checkInDate != null && _checkOutDate != null)
                ? () {
                    // Lógica para realizar la reserva
                    print('Reserva de ${widget.roomName} del $_checkInDate al $_checkOutDate');
                    Navigator.of(context).pop(); // Cierra el modal
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A1B9A), // Púrpura oscuro
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            child: const Text('Realizar Reserva', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(BuildContext context, DateTime? date, Function(DateTime?) onTap) {
    // Helper para el campo de fecha con borde rosado
    return GestureDetector(
      onTap: () => onTap(date),
      child: Container(
        margin: const EdgeInsets.only(top: 5),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.pink, width: 2), 
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date == null ? 'Seleccionar fecha' : _dateFormat.format(date),
              style: TextStyle(fontSize: 16, color: date == null ? Colors.grey : Colors.black),
            ),
            const Icon(Icons.calendar_today, color: Colors.pink),
          ],
        ),
      ),
    );
  }
}