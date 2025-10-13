import 'package:flutter/material.dart';
import '../../core/auth_service.dart'; 
import '../custom_app_bar.dart'; 
import '../app_drawer.dart'; 
import '../../core/app_export.dart'; 
import '../../core/api_service.dart'; // Para cargar reservas
import 'package:intl/intl.dart'; // Importar intl para formatear fechas y dinero

class ReservationListScreen extends StatefulWidget {
  final Map<String, dynamic> room;

  const ReservationListScreen({required this.room, super.key});

  @override
  State<ReservationListScreen> createState() => _ReservationListScreenState();
}

class _ReservationListScreenState extends State<ReservationListScreen> {
  // CLAVE GLOBAL para el Drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // La lista debe ser dinámica ya que es el resultado del API
  List<dynamic> reservations = [];
  
  bool _isLoadingReservations = true;
  bool _isLoadingUserData = true;
  
  Map<String, dynamic>? _userData;
  bool get _isAdmin => _userData?['rol'] == 'admin';
  final currencyFormatter = NumberFormat.currency(locale: 'es_ES', symbol: '\$', decimalDigits: 2);

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadReservations();
  }

  // --- Lógica de Auth y Drawer (Mantenida) ---
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

  Future<void> _loadReservations() async {
    setState(() {
      _isLoadingReservations = true;
    });

    try {
      final int roomId = widget.room['idHabitacion'] ?? 0;
      if (roomId == 0) {
        throw Exception("ID de habitación no válido.");
      }
      // Llamada simulada al API:
      // final List<dynamic> loadedReservations = await ApiService.getReservationsByRoom(roomId);
      
      // Simulación de datos del API para esta habitación:
      await Future.delayed(const Duration(milliseconds: 500));
      final List<Map<String, dynamic>> loadedReservations = [
        {
          'idReserva': 101,
          'idUsuario': 1,
          'nombreUsuario': 'Juan Pérez',
          'fechaCheckIn': '2024-11-01',
          'fechaCheckOut': '2024-11-05',
          'precioTotal': 163.60, // 4 noches * 40.90
        },
        {
          'idReserva': 102,
          'idUsuario': 2,
          'nombreUsuario': 'Ana García',
          'fechaCheckIn': '2024-11-06',
          'fechaCheckOut': '2024-11-08',
          'precioTotal': 81.80, // 2 noches * 40.90
        },
      ];
      
      if (!mounted) return;
      setState(() {
        reservations = loadedReservations;
        _isLoadingReservations = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingReservations = false;
      });
      _mostrarError('Error al cargar reservas: ${e.toString()}');
    }
  }

  Future<void> _onLogoutPressed(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmación'),
        content: const Text('¿Está seguro de cerrar sesión?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
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
      if (mounted) { 
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.loginScreen,
          (route) => false,
        );
      }
    }
  }
  
  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
      ),
    );
  }

  // --- Nueva Lógica de Detalle de Reserva ---
  void _showReservationDetails(Map<String, dynamic> reservation) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          final String checkIn = reservation['fechaCheckIn'] ?? 'N/A';
          final String checkOut = reservation['fechaCheckOut'] ?? 'N/A';
          final double total = reservation['precioTotal'] ?? 0.0;
          final String cliente = reservation['nombreUsuario'] ?? 'Usuario Desconocido';
          
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Detalles de la Reserva',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF00897B)),
                  ),
                  const Divider(height: 30),

                  _buildDetailRow(
                    icon: Icons.person_outline,
                    label: 'Cliente',
                    value: cliente,
                  ),
                  _buildDetailRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Check-in',
                    value: checkIn,
                  ),
                  _buildDetailRow(
                    icon: Icons.calendar_month_outlined,
                    label: 'Check-out',
                    value: checkOut,
                  ),
                  _buildDetailRow(
                    icon: Icons.payments_outlined,
                    label: 'Precio Total',
                    value: currencyFormatter.format(total),
                    isHighlight: true,
                  ),
                  _buildDetailRow(
                    icon: Icons.vpn_key_outlined,
                    label: 'ID de Reserva',
                    value: reservation['idReserva']?.toString() ?? 'N/A',
                  ),

                  const SizedBox(height: 30),
                  // Botón de acción adicional (Ej. Cancelar reserva)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context); // Cerrar BottomSheet
                        // Lógica de cancelación
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Simulación: Cancelando reserva ${reservation['idReserva']}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                      icon: const Icon(Icons.cancel_outlined, color: Colors.white),
                      label: const Text('Cancelar Reserva', style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow({required IconData icon, required String label, required String value, bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF00897B), size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
              color: isHighlight ? Colors.black : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget Principal ---
  @override
  Widget build(BuildContext context) {
    if (_isLoadingUserData) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    // Si no es admin, restringe el acceso (lógica de administrador mantenida)
    if (!_isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mostrarError('Acceso denegado: solo administradores pueden ver listas de reservas.');
        if (Navigator.canPop(context)) {
          Navigator.pop(context); 
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.mainPage); 
        }
      });
      return const SizedBox.shrink(); 
    }
    
    final String roomName = widget.room['NombreHab'] ?? 'Habitación';

    return Scaffold(
      key: _scaffoldKey, // Asignar la key
      backgroundColor: Colors.grey[100],
      
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
        onLogoutPressed: () => _onLogoutPressed(context),
        userData: _userData,
        isAdmin: _isAdmin,
      ),
      
      drawer: AppDrawer(
        userData: _userData,
        isAdmin: _isAdmin,
        onLogoutPressed: _onLogoutPressed,
      ),
      
      body: _isLoadingReservations
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00897B)))
          : reservations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy_outlined, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text(
                        'No hay reservas para esta habitación',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _loadReservations,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00897B),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: reservations.length,
                  itemBuilder: (context, index) {
                    final reservation = reservations[index] as Map<String, dynamic>;
                    final String userName = reservation['nombreUsuario'] ?? 'Usuario';
                    final String checkIn = reservation['fechaCheckIn'] ?? 'N/A';
                    final double total = reservation['precioTotal'] ?? 0.0;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF00897B),
                          child: Icon(Icons.receipt_long, color: Colors.white),
                        ),
                        title: Text(
                          'Reserva de $userName',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Check-in: $checkIn\nTotal: ${currencyFormatter.format(total)}'),
                        isThreeLine: true,
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => _showReservationDetails(reservation),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadReservations,
        backgroundColor: const Color(0xFF00897B),
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}