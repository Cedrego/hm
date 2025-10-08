
import 'package:flutter/material.dart';

import 'models.dart';

class UserProfileScreen extends StatelessWidget {
  final User user;

  const UserProfileScreen({required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    // Simulación de las reservas del usuario para la parte inferior de la imagen 3
    final List<Reservation> userReservations = [
      // Una reserva (como el ejemplo en la imagen 3)
      Reservation(
        roomName: 'Habitación Familiar',
        services: 'Jacuzzi privado',
        checkIn: DateTime(2025, 9, 23),
        checkOut: DateTime(2025, 9, 27),
        nights: 4,
        totalPrice: 136,
        user: user,
      ),
      // ... más reservas simuladas
    ];

    return Scaffold(
      // Usar un Container para simular el fondo teal
      body: Container(
        color: const Color(0xFF008080),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barra superior y botón de menú (simulado)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Icon(Icons.menu, color: Colors.white, size: 30),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Avatar del usuario
                        CircleAvatar(
                          radius: 60,
                          // Simulación de la imagen
                          backgroundImage: AssetImage(user.avatarUrl),
                        ),
                        const SizedBox(height: 20),

                        // Detalles del Usuario
                        Text('Nick: ${user.nick}', style: const TextStyle(color: Colors.white)),
                        Text('Nombre: ${user.name}', style: const TextStyle(color: Colors.white)),
                        Text('Email: ${user.email}', style: const TextStyle(color: Colors.white)),
                        Text('DI: ${user.di}', style: const TextStyle(color: Colors.white)),
                        Text('Contacto: ${user.contact}', style: const TextStyle(color: Colors.white)),
                        const SizedBox(height: 30),

                        // Título Reservas
                        const Text('Reservas:', style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                        )),
                        const SizedBox(height: 10),

                        // Lista de Reservas del Usuario
                        ...userReservations.map((res) => UserReservationCard(reservation: res)).toList(),
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
}

// Widget para mostrar una reserva en la pantalla de perfil (imagen 3)
class UserReservationCard extends StatelessWidget {
  final Reservation reservation;

  const UserReservationCard({required this.reservation, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen de la Habitación (simulada)
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[300],
              ),
              // child: Image.asset('assets/room_image.jpg', fit: BoxFit.cover),
            ),
            const SizedBox(width: 15),
            // Detalles de la Reserva
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(reservation.roomName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('• ${reservation.services}'),
                  // Simulación de los datos específicos de la imagen 3
                  Text('Check-in: 23/09/2025'),
                  Text('Check-out: 27/09/2025'),
                  Text('Noches: ${reservation.nights}'),
                  Text('Precio total: USD ${reservation.totalPrice}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}