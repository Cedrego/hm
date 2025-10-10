import 'package:flutter/material.dart';
import 'user_profile_screen.dart';

class ReservationListScreen extends StatefulWidget {
  final Map<String, dynamic> room;

  const ReservationListScreen({required this.room, super.key});

  @override
  State<ReservationListScreen> createState() => _ReservationListScreenState();
}

class _ReservationListScreenState extends State<ReservationListScreen> {
  List<Map<String, dynamic>> reservations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    // Llamar API aquí
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      reservations = [];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String roomName = widget.room['NombreHab'] ?? 'Habitación';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00897B),
        title: Text(roomName, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : reservations.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No hay reservas para esta habitación'),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: reservations.length,
                  itemBuilder: (context, index) {
                    final reservation = reservations[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(reservation['nombreUsuario'] ?? 'Usuario'),
                        subtitle: Text('Check-in: ${reservation['fechaCheckIn']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.info_outline),
                          onPressed: () {
                            // Navegar al perfil del usuario
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UserProfileScreen(
                                  user: reservation['usuario'] ?? {},
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}