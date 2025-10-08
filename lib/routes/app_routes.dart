import 'package:flutter/material.dart';
import 'package:hm/presentacion/main_page/main_page.dart';
import '../presentacion/registration_screen/registration_screen.dart';
import '../presentacion/login_screen/login_screen.dart';
import '../presentacion/room_creation_screen/room_creation_screen.dart';
import '../presentacion/app_navigation_screen/app_navigation_screen.dart';

import '../presentacion/create_reserve/room_list_screen.dart';
import '../presentacion/create_reserve/room_detail_screen.dart';
import '../presentacion/create_reserve/room_models.dart';

class AppRoutes {
  static const String registrationScreen = '/registration_screen';
  static const String loginScreen = '/login_screen';
  static const String mainPage = '/main_page';
  static const String appNavigationScreen = '/app_navigation_screen';
  static const String initialRoute = '/login_screen';
  static const String roomCreationScreen = '/room_creation_screen';

  static const String roomListScreen = '/room_list_screen';
  static const String roomDetailScreen = '/room_detail_screen';

  static Map<String, WidgetBuilder> get routes => {
    registrationScreen: (context) => RegistrationScreen(),
    loginScreen: (context) => LoginScreen(),
    roomCreationScreen: (context) => RoomCreationScreen(),
    mainPage: (context) => MainPage(),
    appNavigationScreen: (context) => AppNavigationScreen(),
 
    roomListScreen: (context) => const RoomListScreen(),
    roomDetailScreen: (context) {
      final settings = ModalRoute.of(context)!.settings;
      final room = settings.arguments as Room; 
      return RoomDetailScreen(room: room);
    },
  };
}
