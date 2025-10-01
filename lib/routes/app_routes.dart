import 'package:flutter/material.dart';
import 'package:hm/presentacion/main_page/main_page.dart';
import '../presentacion/registration_screen/registration_screen.dart';
import '../presentacion/login_screen/login_screen.dart';

import '../presentacion/app_navigation_screen/app_navigation_screen.dart';

class AppRoutes {
  static const String registrationScreen = '/registration_screen';
  static const String loginScreen = '/login_screen';
  static const String mainPage = '/main_page';
  static const String appNavigationScreen = '/app_navigation_screen';
  static const String initialRoute = '/login_screen';

  static Map<String, WidgetBuilder> get routes => {
    registrationScreen: (context) => RegistrationScreen(),
    loginScreen: (context) => LoginScreen(),
    mainPage: (context) => MainPage(),
    appNavigationScreen: (context) => AppNavigationScreen(),
  };
}
