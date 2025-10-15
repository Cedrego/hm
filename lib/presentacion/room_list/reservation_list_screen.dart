// lib/presentacion/room_list/reservation_list_screen.dart

import 'package:flutter/material.dart';
import '../../core/auth_service.dart'; 
import '../custom_app_bar.dart'; 
import '../app_drawer.dart'; 
import '../../core/app_export.dart'; 
import '../../core/api_service.dart'; // Para cargar reservas
import 'package:intl/intl.dart'; // Importar intl para formatear fechas y dinero
import 'user_profile_screen.dart'; // Asumiendo que tienes esta pantalla para ver el perfil del usuario

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
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadReservations();
  }

  // --- Lógica de Carga de Datos ---
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
        // Opcional: mostrar un error de carga de usuario
      });
    }
  }

  Future<void> _loadReservations() async {
    if (!mounted) return;
    setState(() {
      _isLoadingReservations = true;
      _errorMessage = '';
    });

    try {
      final idHabitacion = widget.room['idHabitacion'] ?? '';
      if (idHabitacion.isEmpty) {
        throw Exception('ID de habitación no encontrado.');
      }
      
      final fetchedReservations = await ApiService.getReservasPorHabitacion(idHabitacion);
      
      if (!mounted) return;
      setState(() {
        reservations = fetchedReservations;
      });

    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingReservations = false;
      });
    }
  }
  
  // --- Lógica de Navegación y Cierre de Sesión ---
  void onLogoutPressed(BuildContext context) {
    AuthService.logout();
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.loginScreen, (route) => false);
  }
  
  void _showReservationDetails(Map<String, dynamic> reservation) {
    // Aquí puedes implementar una vista de detalles o un diálogo
    final user = reservation['usuario'] ?? {};
    if (user.isNotEmpty) {
      // Navegar al perfil del usuario (si está disponible)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UserProfileScreen(user: user),
        ),
      );
    } else {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datos de usuario no disponibles.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    
    // Si los datos de usuario no han cargado, mostrar un spinner
    if (_isLoadingUserData) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
        onLogoutPressed: () => onLogoutPressed(context),
        userData: _userData,
        isAdmin: _isAdmin,
      ),
      drawer: AppDrawer(
        userData: _userData,
        isAdmin: _isAdmin,
        onLogoutPressed: onLogoutPressed,
      ),
      backgroundColor: const Color(0xFFF4F4F4),
      body: _isLoadingReservations
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 50),
                        const SizedBox(height: 16),
                        Text(
                          'Error al cargar reservas: $_errorMessage',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
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
                  ),
                )
              : reservations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_busy, size: 80, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          const Text('No hay reservas para esta habitación', style: TextStyle(fontSize: 18, color: Color(0xFF555555))),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: reservations.length,
                      itemBuilder: (context, index) {
                        final reservation = reservations[index];
                        final String userName = reservation['nombreUsuario'] ?? 'Usuario Desconocido';
                        final String checkIn = reservation['fechaCheckIn'] ?? 'N/A';
                        final double total = (reservation['precioTotal'] as num?)?.toDouble() ?? 0.0;

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