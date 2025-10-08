import 'package:flutter/material.dart';
// Asume que models.dart contiene las clases Room, Reservation, User
import 'models.dart';
import 'reservation_list_screen.dart';

class RoomListScreen extends StatelessWidget {
  const RoomListScreen({super.key});
  // Lista de ejemplo (simulando datos)
  final List<Room> rooms = const [
    // Add 'const' here
   Room(
      name: 'Habitación Doble Vista al Mar',
      description: 'Un espacio moderno equipado con minibar privado...',
      imageUrl: 'assets/room1.jpg',
    ),
    // Add 'const' here
   Room(
      name: 'Habitación Familiar',
      description: 'Habitación matrimonial con Jacuzzi privado...',
      imageUrl: 'assets/room2.jpg',
      isFamilyRoom: true,
      hasJacuzzi: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habitación Doble'), // Título dinámico si es necesario
        leading: const Icon(Icons.menu),
        actions: const [Padding(
          padding: EdgeInsets.only(right: 8.0),
          child: Icon(Icons.search),
        )],
      ),
      body: ListView.builder(
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          final room = rooms[index];
          return RoomListItem(
            room: room,
            // 🎯 NAVEGACIÓN 1: Al tocar la tarjeta de la habitación
            onTap: () {
              // Navega a la pantalla de Reservas, pasando la información de la habitación
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReservationListScreen(room: room),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Widget para un elemento de la lista (simulado para el diseño)
class RoomListItem extends StatelessWidget {
  final Room room;
  final VoidCallback onTap;

  const RoomListItem({required this.room, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        // Diseño de la tarjeta similar a la imagen 2
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          leading: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              // Simulación de imagen (reemplazar con Image.asset o Image.network)
              color: Colors.grey[300],
            ),
            // child: Image.asset(room.imageUrl, fit: BoxFit.cover),
          ),
          title: Text(room.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(room.description, maxLines: 3, overflow: TextOverflow.ellipsis),
          trailing: const Icon(Icons.info_outline),
        ),
      ),
    );
  }
}