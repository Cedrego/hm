import 'package:flutter/material.dart';

class UserProfileScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const UserProfileScreen({required this.user, super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  List<Map<String, dynamic>> reservations = []; // Temporal, luego viene de API
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    // Aquí llamarías a tu API
    // final data = await ApiService.getReservasUsuario(widget.user['_id']);
    await Future.delayed(const Duration(seconds: 1)); // Simulación
    setState(() {
      reservations = []; // Vacío por ahora
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String nick =
        widget.user['nick'] ?? widget.user['nombre'] ?? 'Usuario';
    final String nombre = widget.user['nombre'] ?? 'Sin nombre';
    final String email = widget.user['email'] ?? 'Sin email';
    final String di =
        widget.user['di'] ?? widget.user['cedula'] ?? 'Sin documento';
    final String contacto =
        widget.user['telefono'] ?? widget.user['contacto'] ?? 'Sin contacto';
    final String avatarUrl =
        widget.user['avatarUrl'] ?? widget.user['avatar'] ?? '';

    return Scaffold(
      body: Container(
        color: const Color(0xFF00897B),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Perfil de Usuario',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white,
                          child: avatarUrl.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    avatarUrl,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Text(
                                      nombre[0].toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 48,
                                        color: Color(0xFF00897B),
                                      ),
                                    ),
                                  ),
                                )
                              : Text(
                                  nombre[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 48,
                                    color: Color(0xFF00897B),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 24),

                        // Info Card
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                _buildInfoRow('Nick', nick),
                                const Divider(),
                                _buildInfoRow('Nombre', nombre),
                                const Divider(),
                                _buildInfoRow('Email', email),
                                const Divider(),
                                _buildInfoRow('Documento', di),
                                const Divider(),
                                _buildInfoRow('Contacto', contacto),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        const Text(
                          'Mis Reservas',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Reservas
                        if (isLoading)
                          const CircularProgressIndicator(color: Colors.white)
                        else if (reservations.isEmpty)
                          const Card(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.event_busy,
                                    size: 60,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text('No hay reservas registradas'),
                                ],
                              ),
                            ),
                          )
                        else
                          ...reservations.map(
                            (res) => _buildReservationCard(res),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildReservationCard(Map<String, dynamic> reservation) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[300],
              ),
              child: const Icon(Icons.hotel, size: 40, color: Colors.grey),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reservation['nombreHabitacion'] ?? 'Habitación',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Check-in: ${reservation['fechaCheckIn']}'),
                  Text('Check-out: ${reservation['fechaCheckOut']}'),
                  Text('Total: USD \$${reservation['precioTotal']}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
