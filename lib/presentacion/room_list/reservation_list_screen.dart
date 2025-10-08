// Datos de ejemplo para simular la lista de reservas
import 'package:flutter/material.dart';

import 'models.dart';
import 'user_profile_screen.dart';

final User user1 = User(
    nick: 'Mari<3',
    name: 'Maria Hernandez',
    email: 'mari123@example.com',
    di: '7894523-1',
    contact: '091456482',
    avatarUrl: 'assets/user1.jpg'
);
// ... más usuarios

// Simulación de las reservas de la Habitación Familiar
final List<Reservation> familyRoomReservations = [
  Reservation(
    roomName: 'Habitación Familiar',
    services: 'Jacuzzi privado',
    checkIn: DateTime(2025, 9, 23),
    checkOut: DateTime(2025, 9, 27),
    nights: 4,
    totalPrice: 136,
    user: user1,
  ),
  // ... más reservas con diferentes usuarios/fechas
];

class ReservationListScreen extends StatelessWidget {
  final Room room;

  const ReservationListScreen({required this.room, super.key});

  @override
  Widget build(BuildContext context) {
    // Aquí puedes filtrar las reservas reales por room.name
    final List<Reservation> reservations = familyRoomReservations;

    return Scaffold(
      appBar: AppBar(
        title: Text('[10207]${room.name}'), // Título con el nombre de la Habitación
        leading: const Icon(Icons.menu),
        actions: const [Padding(
          padding: EdgeInsets.only(right: 8.0),
          child: Icon(Icons.search),
        )],
      ),
      body: ListView.builder(
        itemCount: reservations.length,
        itemBuilder: (context, index) {
          final reservation = reservations[index];
          return ReservationListItem(
            reservation: reservation,
            // NAVEGACIÓN 2: Al tocar el icono de información "i"
            onInfoTap: () {
              // Navega al Perfil, pasando el objeto User
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfileScreen(user: reservation.user),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Widget para un elemento de la lista de reservas (simulado)
class ReservationListItem extends StatelessWidget {
  final Reservation reservation;
  final VoidCallback onInfoTap;

  const ReservationListItem({
    required this.reservation,
    required this.onInfoTap,
    super.key
  });

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  @override
  Widget build(BuildContext context) {
    // Usar el diseño de la imagen 1, donde la imagen es el avatar del usuario
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      // Fila seleccionada simulada con un color de borde
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: reservation.user.name == 'Maria Hernandez' ? Colors.pink : Colors.transparent, // Simula el borde rosado de la imagen
            width: 3,
          ),
        ),
        child: ListTile(
          leading: CircleAvatar(
            radius: 30,
            // Simulación de la imagen del usuario
            backgroundImage: AssetImage(reservation.user.avatarUrl),
          ),
          title: Text(reservation.roomName, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• ${reservation.services}'),
              Text('Check-in: ${_formatDate(reservation.checkIn)}'),
              Text('Check-out: ${_formatDate(reservation.checkOut)}'),
              Text('Noches: ${reservation.nights}'),
              Text('Precio total: USD ${reservation.totalPrice}'),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.black),
            onPressed: onInfoTap, // Llama a la navegación al Perfil
          ),
        ),
      ),
    );
  }
}