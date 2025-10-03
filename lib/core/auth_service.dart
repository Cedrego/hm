import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthService {
  // Claves para SharedPreferences
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _userDataKey = 'userData';
  static const String _userIdKey = 'userId';
  static const String _userEmailKey = 'userEmail';

  // Verificar si el usuario está logueado
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Guardar sesión del usuario
  static Future<void> saveUserSession(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_userDataKey, jsonEncode(userData));
    await prefs.setString(_userIdKey, userData['id'] ?? '');
    await prefs.setString(_userEmailKey, userData['email'] ?? '');
    
    print('✅ Sesión guardada: ${userData['email']}');
  }

  // Obtener datos del usuario actual
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_userDataKey);
    
    if (userDataString != null) {
      return jsonDecode(userDataString);
    }
    return null;
  }

  // Obtener ID del usuario actual
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  // Obtener email del usuario actual
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  // Cerrar sesión
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_userDataKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userEmailKey);
    
    print('✅ Sesión cerrada');
  }

  // Limpiar todos los datos (útil para desarrollo)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('✅ Todos los datos limpiados');
  }
}
