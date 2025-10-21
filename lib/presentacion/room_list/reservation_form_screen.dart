import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/firebase_service.dart';
import '../../core/auth_service.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_calendar_picker.dart';
import '../../core/logger.dart';

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
  bool isLoadingAvailability = true;
  String? _errorMessage;
  Map<String, dynamic>? _userData;
  List<Map<String, DateTime>> _fechasOcupadas = [];
  final FirebaseService _firebaseService = FirebaseService.instance;
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
      // ✅ NORMALIZAR CON HORARIOS ESPECÍFICOS
      // Check-in: 12:00 PM (mediodía)
      final checkInNormalized = DateTime(
        checkInDate!.year, 
        checkInDate!.month, 
        checkInDate!.day,
        12, // 14:00 PM
        0,
        0,
      );
      // Check-out: 2:00 PM (14:00)
      final checkOutNormalized = DateTime(
        checkOutDate!.year, 
        checkOutDate!.month, 
        checkOutDate!.day,
        14, // 2:00 PM
        0,
        0,
      );
      return checkOutNormalized.difference(checkInNormalized).inDays;
    }
    return 0;
  }

  double get _totalPrice => _roomPrice * _durationInDays;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadFechasOcupadas();
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

  Future<void> _loadFechasOcupadas() async {
    try {
      setState(() {
        isLoadingAvailability = true;
      });

      final fechas = await _firebaseService.getFechasOcupadasHabitacion(_roomId);

      if (!mounted) return;

      setState(() {
        _fechasOcupadas = fechas;
        isLoadingAvailability = false;
      });

      AppLogger.success(
        '✅ Cargadas ${fechas.length} reservas activas para la habitación',
      );
    } catch (e) {
      AppLogger.e('❌ Error cargando disponibilidad: $e');
      if (!mounted) return;
      setState(() {
        isLoadingAvailability = false;
        _errorMessage = 'Error al cargar disponibilidad de la habitación';
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    if (isLoadingAvailability) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⏳ Cargando disponibilidad...'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => CustomCalendarPicker(
        initialDate: isCheckIn
            ? (checkInDate ?? DateTime.now())
            : (checkOutDate ?? (checkInDate ?? DateTime.now()).add(const Duration(days: 1))),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        fechasOcupadas: _fechasOcupadas,
        isCheckInPicker: isCheckIn,
        checkInDate: isCheckIn ? null : checkInDate,
        onDateSelected: (date) {
          setState(() {
            _errorMessage = null;
            if (isCheckIn) {
              checkInDate = date;
              // Si el checkOut está antes del nuevo checkIn, lo reseteamos
              if (checkOutDate != null &&
                  (checkOutDate!.isBefore(date) ||
                      checkOutDate!.isAtSameMomentAs(date))) {
                checkOutDate = null;
              }
            } else {
              checkOutDate = date;
            }
          });
        },
      ),
    );
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
      // ✅ VERIFICAR DISPONIBILIDAD ANTES DE CREAR LA RESERVA
      final disponible = await _firebaseService.verificarDisponibilidad(
        habitacionId: _roomId,
        checkIn: checkInDate!,
        checkOut: checkOutDate!,
      );

      if (!disponible) {
        if (!mounted) return;
        setState(() {
          _errorMessage =
              'Las fechas seleccionadas ya no están disponibles. Por favor, seleccione otras fechas.';
          isLoading = false;
        });
        // Recargar las fechas ocupadas
        await _loadFechasOcupadas();
        return;
      }

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
        AppRoutes.misReservas,
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
          onTap: isLoadingAvailability
              ? null
              : () => _selectDate(context, isCheckIn),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isLoadingAvailability
                  ? Colors.grey.shade100
                  : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    isLoadingAvailability
                        ? 'Cargando...'
                        : (date == null
                            ? 'Seleccionar fecha'
                            : DateFormat('dd/MM/yyyy').format(date)),
                    style: TextStyle(
                      fontSize: 16,
                      color: isLoadingAvailability || date == null
                          ? Colors.grey.shade600
                          : Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                isLoadingAvailability
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.grey.shade600,
                          ),
                        ),
                      )
                    : Icon(
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
                // 📅 INFORMACIÓN DE DISPONIBILIDAD
                if (!isLoadingAvailability && _fechasOcupadas.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Esta habitación tiene ${_fechasOcupadas.length} reserva(s) activa(s). Los días ocupados se mostrarán en rojo.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

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
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
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
