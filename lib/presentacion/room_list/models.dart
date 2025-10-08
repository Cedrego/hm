
class Room {
  final String name;
  final String description;
  final String imageUrl;
  final bool isFamilyRoom;
  final bool hasJacuzzi;

  const Room({
    required this.name,
    required this.description,
    required this.imageUrl,
    this.isFamilyRoom = false,
    this.hasJacuzzi = false,
  });
}

class Reservation {
  final String roomName;
  final String services;
  final DateTime checkIn;
  final DateTime checkOut;
  final int nights;
  final double totalPrice;
  final User user; // El usuario que hizo la reserva

  Reservation({
    required this.roomName,
    required this.services,
    required this.checkIn,
    required this.checkOut,
    required this.nights,
    required this.totalPrice,
    required this.user,
  });
}

class User {
  final String nick;
  final String name;
  final String email;
  final String di; // Documento de Identidad
  final String contact;
  final String avatarUrl;

  User({
    required this.nick,
    required this.name,
    required this.email,
    required this.di,
    required this.contact,
    required this.avatarUrl,
  });
}