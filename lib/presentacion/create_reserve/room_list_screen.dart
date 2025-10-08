import 'package:flutter/material.dart';
import 'room_models.dart';
import 'room_detail_screen.dart'; // Importa la pantalla de destino

class RoomListScreen extends StatelessWidget {
  const RoomListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF008080), // Fondo teal
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Ícono de menú
        leading: const Padding(
          padding: EdgeInsets.only(left: 10.0),
          child: Icon(Icons.menu, color: Colors.white), 
        ),
        title: const Text('Habitación Doble', style: TextStyle(color: Colors.white)),
        // Ícono de búsqueda
        actions: const [Padding(
          padding: EdgeInsets.only(right: 16.0),
          child: Icon(Icons.search, color: Colors.white),
        )],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10), 
          Expanded(
            child: Container(
              // Contenedor blanco redondeado para la lista
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: ListView.builder(
                itemCount: rooms.length,
                itemBuilder: (context, index) {
                  final room = rooms[index];
                  return RoomListItem(room: room);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RoomListItem extends StatelessWidget {
  final Room room;
  const RoomListItem({required this.room, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // NAVEGACIÓN: Lista -> Detalle
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoomDetailScreen(room: room),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            // Simulación del borde rosado en la habitación Matrimonial
            border: room.name == 'Habitacion Matrimonial' 
                ? Border.all(color: Colors.pink, width: 3) 
                : null,
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 2, blurRadius: 5)],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container( // Placeholder de la imagen
                  width: 100, 
                  height: 100, 
                  color: Colors.grey[300], 
                  // Usar Image.asset(room.imageUrl, fit: BoxFit.cover), si tienes las imágenes
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      room.description,
                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.info_outline, color: Colors.black),
            ],
          ),
        ),
      ),
    );
  }
}