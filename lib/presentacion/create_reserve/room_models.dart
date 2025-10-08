import 'package:flutter/material.dart';

// Definición de la clase Room
class Room {
  final String name;
  final String description;
  final String imageUrl;
  final String pricePerDay;
  final String details;

  // Constructor constante para permitir listas constantes y ser más eficiente
  const Room({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.pricePerDay,
    required this.details,
  });
}

// Datos de ejemplo constantes que simulan tu base de datos
final List<Room> rooms = const [
  const Room(
    name: 'Habitación Doble Vista al Mar',
    description: 'Minibar incluido. Un espacio acogedor y moderno, equipado con minibar privado.',
    imageUrl: 'assets/room_sea.jpg',
    pricePerDay: '35USD / dia',
    details: '2 Camas Dobles\n1 Baño\nVentana con vista al mar',
  ),
  const Room(
    name: 'Habitacion Matrimonial',
    description: 'Jacuzzi, Minivar. Habitación matrimonial con jacuzzi privado y minibar, ideal para una estancia de relax y confort.',
    imageUrl: 'assets/room_matrimonial.jpg',
    pricePerDay: '30USD / dia',
    details: '2 Camas Dobles\n2 Baños\n1 Ducha',
  ),
  const Room(
    name: 'Habitación Doble Estándar',
    description: 'Jacuzzi, Minivar. Con un estilo limpio y elegante, esta habitación te ofrece todo lo necesario para tu descanso.',
    imageUrl: 'assets/room_standard.jpg',
    pricePerDay: '25USD / dia',
    details: '1 Cama King\n1 Baño\nServicio al cuarto',
  ),
  const Room(
    name: 'Habitación Doble Minimalista',
    description: 'Diseñada para el descanso y la inspiración, esta habitación ofrece un ambiente de paz.',
    imageUrl: 'assets/room_minimalist.jpg',
    pricePerDay: '28USD / dia',
    details: '1 Cama Doble\n1 Baño\nDecoración moderna',
  ),
];