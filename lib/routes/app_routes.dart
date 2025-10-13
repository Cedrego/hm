import 'package:flutter/material.dart';
import 'package:hm/presentacion/main_page/main_page.dart';
import '../presentacion/registration_screen/registration_screen.dart';
import '../presentacion/login_screen/login_screen.dart';
import '../presentacion/room_creation_screen/room_creation_screen.dart';
import '../presentacion/app_navigation_screen/app_navigation_screen.dart';
import '../presentacion/profile/profileScreen.dart';
import '../presentacion/room_list/room_list_screen.dart';
import '../presentacion/room_list/room_detail_screen.dart';
import '../presentacion/reservas/misreservas_screen.dart';
import '../presentacion/reservas/reserva_detalle_screen.dart';

class AppRoutes {
  static const String registrationScreen = '/registration_screen';
  static const String loginScreen = '/login_screen';
  static const String mainPage = '/main_page';
  static const String appNavigationScreen = '/app_navigation_screen';
  static const String initialRoute = '/login_screen';
  static const String roomCreationScreen = '/room_creation_screen';
  static const String profileScreen = '/profile';
  static const String roomListScreen = '/room_list_screen';
  static const String roomDetailScreen = '/room_detail_screen';
  static const String misReservas = '/mis-reservas';
  static const String misReservasDetalle = '/mis-reservas-detalle';

  static Map<String, WidgetBuilder> get routes => {
    registrationScreen: (context) => RegistrationScreen(),
    loginScreen: (context) => LoginScreen(),
    roomCreationScreen: (context) => RoomCreationScreen(),
    mainPage: (context) => MainPage(),
    appNavigationScreen: (context) => AppNavigationScreen(),
    profileScreen: (context) {
      final userData = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ?? {};
      return ProfileScreen(userData: userData);
    },
    roomListScreen: (context) => const RoomListScreen(),
    roomDetailScreen: (context) {
      final Map<String, dynamic> room = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return RoomDetailScreen(room: room);
    },
    misReservas: (context) => const MisReservasScreen(),
    misReservasDetalle: (context) {
      // 1. Obtener los argumentos que se pasaron a esta ruta.
      final arguments = ModalRoute.of(context)!.settings.arguments;
      // 2. Asegurarse de que el argumento sea un Map<String, dynamic> (que es la reserva).
      final Map<String, dynamic> reserva = arguments as Map<String, dynamic>;
      // 3. Crear la pantalla, pasando el argumento 'reserva' requerido.
      return ReservaDetalleScreen(reserva: reserva);
    },
  };
}
