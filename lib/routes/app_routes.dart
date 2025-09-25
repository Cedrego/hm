import 'package:flutter/material.dart';
import '../presentacion/registration_screen/registration_screen.dart';
import '../presentacion/login_screen/login_screen.dart';

import '../presentacion/app_navigation_screen/app_navigation_screen.dart';

class AppRoutes {
  static const String registrationScreen = '/registration_screen';
  static const String loginScreen = '/login_screen';

  static const String appNavigationScreen = '/app_navigation_screen';
  static const String initialRoute =
      '/login_screen'; // Changed: Set LoginScreen as initial route

  static Map<String, WidgetBuilder> get routes => {
        registrationScreen: (context) => RegistrationScreen(),
        loginScreen: (context) => LoginScreen(),
        appNavigationScreen: (context) => AppNavigationScreen()
      };
}
