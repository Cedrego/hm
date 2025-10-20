import 'package:flutter/material.dart';

/// Widget de calendario personalizado que muestra disponibilidad
/// - Verde: Días disponibles
/// - Rojo: Días ocupados
/// - Gris: Días no seleccionables (pasados)
class CustomCalendarPicker extends StatefulWidget {
  final DateTime? initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final List<Map<String, DateTime>> fechasOcupadas;
  final Function(DateTime) onDateSelected;
  final bool isCheckInPicker;
  final DateTime? checkInDate; // Para validar checkOut

  const CustomCalendarPicker({
    super.key,
    this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.fechasOcupadas,
    required this.onDateSelected,
    this.isCheckInPicker = true,
    this.checkInDate,
  });

  @override
  State<CustomCalendarPicker> createState() => _CustomCalendarPickerState();
}

class _CustomCalendarPickerState extends State<CustomCalendarPicker> {
  late DateTime _currentMonth;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _currentMonth = widget.initialDate ?? DateTime.now();
    _selectedDate = widget.initialDate;
  }

  /// Verifica si una fecha está ocupada
  bool _isDayOccupied(DateTime day) {
    for (final reserva in widget.fechasOcupadas) {
      final checkIn = reserva['checkIn']!;
      final checkOut = reserva['checkOut']!;

      // Normalizamos las fechas para comparar solo día/mes/año
      final dayNormalized = DateTime(day.year, day.month, day.day);
      final checkInNormalized = DateTime(checkIn.year, checkIn.month, checkIn.day);
      final checkOutNormalized = DateTime(checkOut.year, checkOut.month, checkOut.day);

      // Un día está ocupado si está entre checkIn (inclusive) y checkOut (exclusive)
      if (!dayNormalized.isBefore(checkInNormalized) &&
          dayNormalized.isBefore(checkOutNormalized)) {
        return true;
      }
    }
    return false;
  }

  /// Verifica si un día es seleccionable
  bool _isDaySelectable(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dayNormalized = DateTime(day.year, day.month, day.day);

    // No se pueden seleccionar días pasados
    if (dayNormalized.isBefore(today)) {
      return false;
    }

    // No se pueden seleccionar días ocupados
    if (_isDayOccupied(day)) {
      return false;
    }

    // Si es selector de checkOut, debe ser después del checkIn
    if (!widget.isCheckInPicker && widget.checkInDate != null) {
      final checkInNormalized = DateTime(
        widget.checkInDate!.year,
        widget.checkInDate!.month,
        widget.checkInDate!.day,
      );
      if (!dayNormalized.isAfter(checkInNormalized)) {
        return false;
      }
    }

    return true;
  }

  /// Obtiene el color de fondo para un día
  Color _getDayBackgroundColor(DateTime day) {
    if (!_isDaySelectable(day)) {
      return _isDayOccupied(day)
          ? Colors.red.shade100 // Ocupado
          : Colors.grey.shade200; // Pasado
    }
    return Colors.green.shade50; // Disponible
  }

  /// Obtiene el color del texto para un día
  Color _getDayTextColor(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dayNormalized = DateTime(day.year, day.month, day.day);

    if (dayNormalized.isBefore(today)) {
      return Colors.grey.shade400;
    }
    if (_isDayOccupied(day)) {
      return Colors.red.shade700;
    }
    return Colors.green.shade700;
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  void _onDayTapped(DateTime day) {
    if (_isDaySelectable(day)) {
      setState(() {
        _selectedDate = day;
      });
      widget.onDateSelected(day);
    }
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    
    final days = <DateTime>[];
    for (int i = 1; i <= lastDayOfMonth.day; i++) {
      days.add(DateTime(month.year, month.month, i));
    }
    return days;
  }

  int _getFirstDayOffset(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    return (firstDayOfMonth.weekday % 7); // 0 = Domingo, 6 = Sábado
  }

  /// Obtiene el nombre del mes y año en español
  String _getMonthYearString(DateTime date) {
    const meses = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${meses[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header con navegación de mes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _previousMonth,
                ),
                Text(
                  _getMonthYearString(_currentMonth),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00897B),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _nextMonth,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Días de la semana
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['D', 'L', 'M', 'M', 'J', 'V', 'S']
                  .map((day) => SizedBox(
                        width: 40,
                        child: Center(
                          child: Text(
                            day,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00897B),
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),

            const SizedBox(height: 8),

            // Grid de días
            _buildDaysGrid(),

            const SizedBox(height: 16),

            // Leyenda
            _buildLegend(),

            const SizedBox(height: 16),

            // Botones
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _selectedDate != null
                      ? () {
                          Navigator.pop(context);
                          widget.onDateSelected(_selectedDate!);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00897B),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Seleccionar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaysGrid() {
    final daysInMonth = _getDaysInMonth(_currentMonth);
    final firstDayOffset = _getFirstDayOffset(_currentMonth);

    return Wrap(
      children: [
        // Espacios vacíos antes del primer día
        ...List.generate(
          firstDayOffset,
          (index) => const SizedBox(width: 40, height: 40),
        ),
        // Días del mes
        ...daysInMonth.map((day) {
          final isSelected = _selectedDate != null &&
              day.year == _selectedDate!.year &&
              day.month == _selectedDate!.month &&
              day.day == _selectedDate!.day;

          return GestureDetector(
            onTap: () => _onDayTapped(day),
            child: Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF00897B)
                    : _getDayBackgroundColor(day),
                borderRadius: BorderRadius.circular(8),
                border: isSelected
                    ? Border.all(color: const Color(0xFF00897B), width: 2)
                    : null,
              ),
              child: Center(
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    color: isSelected ? Colors.white : _getDayTextColor(day),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem(Colors.green.shade50, Colors.green.shade700, 'Disponible'),
        _buildLegendItem(Colors.red.shade100, Colors.red.shade700, 'Ocupado'),
        _buildLegendItem(Colors.grey.shade200, Colors.grey.shade400, 'No disponible'),
      ],
    );
  }

  Widget _buildLegendItem(Color bgColor, Color textColor, String label) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: textColor),
        ),
      ],
    );
  }
}
