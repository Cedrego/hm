import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/firebase_service.dart';
import '../../core/auth_service.dart';
import '../../core/app_export.dart';

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
  String? _errorMessage;
  Map<String, dynamic>? _userData;
  final FirebaseService _firebaseService = FirebaseService();
  final currencyFormatter = NumberFormat.currency(
    locale: 'es_ES',
    symbol: '\$',
    decimalDigits: 2,
  );

  double get _roomPrice => (widget.room['precio'] as num?)?.toDouble() ?? 0.0;
  String get _roomId => widget.room['id'] ?? '';
  String get _roomName => widget.room['nombre'] ?? 'Habitación Desconocida';

  int get _durationInDays {
    if (checkInDate != null && checkOutDate != null) {
      return checkOutDate!.difference(checkInDate!).inDays;
    }
    return 0;
  }

  double get _totalPrice => _roomPrice * _durationInDays;

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
      });
    } catch (e) {
      if (!mounted) return;
    }
  }

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn
          ? (checkInDate ?? DateTime.now())
          : (checkOutDate ??
                (checkInDate ?? DateTime.now()).add(const Duration(days: 1))),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      selectableDayPredicate: (DateTime date) {
        if (!isCheckIn && checkInDate != null && date.isBefore(checkInDate!)) {
          return false;
        }
        return true;
      },
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF00897B)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _errorMessage = null;
        if (isCheckIn) {
          checkInDate = picked;
          if (checkOutDate != null &&
              (checkOutDate!.isBefore(picked) ||
                  checkOutDate!.isAtSameMomentAs(picked))) {
            checkOutDate = null;
          }
        } else {
          checkOutDate = picked;
        }
      });
    }
  }

  Future<void> _confirmReservation() async {
    if (checkInDate == null || checkOutDate == null) {
      setState(() {
        _errorMessage = 'Debe seleccionar ambas fechas (Check-in y Check-out).';
      });
      return;
    }

    if (_userData == null || _userData!['id'] == null) {
      setState(() {
        _errorMessage =
            'Error: No se pudo obtener el ID de usuario para la reserva.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      _errorMessage = null;
    });

    try {
      final idUsuario = _userData!['id'];

      await _firebaseService.crearReserva(
        idUsuario: idUsuario,
        idHabitacion: _roomId,
        fechaCheckIn: checkInDate!.toIso8601String().substring(0, 10),
        fechaCheckOut: checkOutDate!.toIso8601String().substring(0, 10),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Reserva creada exitosamente!'),
          backgroundColor: Color(0xFF00897B),
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.popUntil(
        context,
        ModalRoute.withName(AppRoutes.roomListScreen),
      );
      Navigator.pushNamed(
        context,
        AppRoutes.reservationListScreen,
        arguments: widget.room,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget _buildDateSelector({
    required String label,
    required DateTime? date,
    required bool isCheckIn,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF00897B),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _selectDate(context, isCheckIn),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    date == null
                        ? 'Seleccionar fecha'
                        : DateFormat('dd/MM/yyyy').format(date),
                    style: TextStyle(
                      fontSize: 16,
                      color: date == null ? Colors.grey.shade600 : Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.calendar_today,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: Text(
          'Reservar: $_roomName',
          style: const TextStyle(
            color: Color(0xFF333333),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF333333)),
        elevation: 1,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Fechas de Estancia',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00897B),
                          ),
                        ),
                        const Divider(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDateSelector(
                                label: 'Check-in',
                                date: checkInDate,
                                isCheckIn: true,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildDateSelector(
                                label: 'Check-out',
                                date: checkOutDate,
                                isCheckIn: false,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Resumen de Pago',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00897B),
                          ),
                        ),
                        const Divider(height: 24),
                        _buildSummaryRow(
                          'Precio por Noche',
                          currencyFormatter.format(_roomPrice),
                        ),
                        const SizedBox(height: 8),
                        _buildSummaryRow(
                          'Días de Estancia',
                          '$_durationInDays días',
                        ),
                        const Divider(height: 24, thickness: 1.5),
                        _buildSummaryRow(
                          'Precio Total',
                          currencyFormatter.format(_totalPrice),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      '❌ Error: $_errorMessage',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _confirmReservation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00897B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 3,
                    ),
                    child: const Text(
                      'Confirmar Reserva',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),

          if (isLoading)
            Container(
              color: Colors.black.withAlpha(128),
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
        Text(label, style: const TextStyle(fontSize: 16)),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
