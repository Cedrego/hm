import 'package:flutter/material.dart';
import 'dart:convert';
import '../../core/auth_service.dart';
import '../custom_app_bar.dart';
import '../app_drawer.dart';
import '../../core/app_export.dart';
import '../../core/firebase_service.dart';
import 'package:intl/intl.dart';
import 'user_profile_screen.dart';

class ReservationListScreen extends StatefulWidget {
  final Map<String, dynamic> room;

  const ReservationListScreen({required this.room, super.key});

  @override
  State<ReservationListScreen> createState() => _ReservationListScreenState();
}

class _ReservationListScreenState extends State<ReservationListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseService firebaseService = FirebaseService.instance;

  List<Map<String, dynamic>> reservations = [];
  bool _isLoadingReservations = true;
  bool _isLoadingUserData = true;
  Map<String, dynamic>? _userData;
  bool get _isAdmin => _userData?['rol'] == 'admin';
  final currencyFormatter = NumberFormat.currency(
    locale: 'es_ES',
    symbol: '\$',
    decimalDigits: 2,
  );
  String _errorMessage = '';

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
        _isLoadingUserData = false;
      });
      _loadReservations(); 
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingUserData = false;
      });
      _loadReservations(); 
    }
  }

  Future<void> _loadReservations() async {
    if (!mounted) return;

    if (_isLoadingUserData) {
      return;
    }
    
    if (_userData == null) {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'No se pudo obtener la sesión del usuario.';
          _isLoadingReservations = false;
        });
        return;
    }


    setState(() {
      _isLoadingReservations = true;
      _errorMessage = '';
    });

    try {
      Stream<List<Map<String, dynamic>>> reservationStream;
      final idUsuario = _userData!['id'] as String;

      if (_isAdmin) {
        final idHabitacion = widget.room['id'] ?? '';
        
        if (idHabitacion.isEmpty) {
           // Si no se pasó ID de habitación, se carga solo las del Admin (comportamiento por defecto)
           // NOTA: Esto no es ideal si el Admin quiere ver *todas* las reservas.
           // Para ver *todas* las reservas, se debería crear una función específica en FirebaseService.
           reservationStream = firebaseService.getReservasPorUsuario(idUsuario);
        } else {
           // Muestra reservas de una habitación específica (Admin)
           reservationStream = firebaseService.getReservasPorHabitacion(idHabitacion);
        }
      } else {
        // Muestra reservas del usuario logueado
        reservationStream = firebaseService.getReservasPorUsuario(idUsuario);
      }

      reservationStream.listen(
        (listaReservas) {
          if (mounted) {
            setState(() {
              reservations = listaReservas;
              _isLoadingReservations = false;
            });
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _errorMessage = error.toString();
              _isLoadingReservations = false;
            });
          }
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoadingReservations = false;
      });
    }
  }

  Future<void> _onLogoutPressed() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmación'),
        content: const Text('¿Está seguro de cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
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

      if (!mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.loginScreen,
          (route) => false,
        );
      });
    }
  }

  void _showReservationDetails(Map<String, dynamic> reservation) async {
    // Usamos el idUsuario que viene en el documento de reserva
    final userId = reservation['idUsuario'];
    
    if (userId != null && userId is String) {
      try {
        final userData = await firebaseService.getUserById(userId);
        
        if (userData != null && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UserProfileScreen(user: userData),
            ),
          );
        } else {
          _showError('Usuario no encontrado');
        }
      } catch (e) {
        _showError('Error al cargar datos del usuario');
      }
    } else {
      _showError('ID de usuario no disponible');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Color _getStatusColor(String estado) {
    switch (estado) {
      case 'activa':
        return Colors.green;
      case 'cancelada':
        return Colors.red;
      case 'completada':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String estado) {
    switch (estado) {
      case 'activa':
        return 'Activa';
      case 'cancelada':
        return 'Cancelada';
      case 'completada':
        return 'Completada';
      default:
        return estado;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUserData) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
        onLogoutPressed: _onLogoutPressed,
        userData: _userData,
        isAdmin: _isAdmin,
      ),
      drawer: AppDrawer(
        userData: _userData,
        isAdmin: _isAdmin,
        onLogoutPressed: _onLogoutPressed,
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
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 50,
                    ),
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
                  Text(
                    // Mensaje adaptado al rol del usuario
                    _isAdmin
                        ? (widget.room['id']?.isNotEmpty ?? false)
                            ? 'No hay reservas para esta habitación'
                            : 'No hay reservas registradas para el administrador'
                        : 'No tienes reservas activas', 
                    style: const TextStyle(fontSize: 18, color: Color(0xFF555555)),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: reservations.length,
              itemBuilder: (context, index) {
                final reservation = reservations[index];
                
                // 🎯 USAMOS LAS NUEVAS CLAVES ADJUNTADAS POR FIREBASE SERVICE
                final String userName = reservation['nombreUsuario'] ?? 'Usuario Desconocido';
                final String roomName = reservation['nombreHabitacion'] ?? 'Habitación (N/A)';
                // Si la imagen es URL, usamos 'imagenUrlHabitacion'
                final String roomImageUrl = reservation['imagenUrlHabitacion'] ?? ''; 
                
                final String checkIn = reservation['fechaCheckIn'] ?? 'N/A';
                final String checkOut = reservation['fechaCheckOut'] ?? 'N/A';
                final String estado = reservation['estado'] ?? 'activa';
                final double total =
                    (reservation['precioTotal'] as num?)?.toDouble() ?? 0.0;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(estado),
                      child: roomImageUrl.isNotEmpty
                          ? ClipOval(
                              child: Image.network( // 🎯 USAMOS Image.network para URL
                                roomImageUrl,
                                fit: BoxFit.cover,
                                width: 56.0, 
                                height: 56.0,
                                // Fallback si la imagen no carga
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.receipt_long,
                                    color: Colors.white,
                                  );
                                },
                              ),
                            )
                          : const Icon(
                              Icons.receipt_long,
                              color: Colors.white,
                            ),
                    ),
                    title: Text(
                      _isAdmin 
                          ? 'Reserva: $userName - $roomName' 
                          : 'Reserva para $roomName', 
                      softWrap: true, 
                      maxLines: 2,    
                      overflow: TextOverflow.ellipsis, 
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Check-in: $checkIn'),
                        Text('Check-out: $checkOut'),
                        Text('Total: ${currencyFormatter.format(total)}'),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(estado).withAlpha(26),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _getStatusColor(estado)),
                          ),
                          child: Text(
                            _getStatusText(estado),
                            style: TextStyle(
                              fontSize: 12,
                              color: _getStatusColor(estado),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
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