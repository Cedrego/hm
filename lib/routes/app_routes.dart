import 'package:flutter/material.dart';
import 'package:hm/presentacion/main_page/main_page.dart';
import '../presentacion/registration_screen/registration_screen.dart';
import '../presentacion/login_screen/login_screen.dart';
import '../presentacion/room_creation_screen/room_creation_screen.dart';
import '../presentacion/app_navigation_screen/app_navigation_screen.dart';
import '../presentacion/profile/profileScreen.dart';
import '../presentacion/room_list/room_list_screen.dart';
import '../presentacion/room_list/room_detail_screen.dart';

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
  };
}
