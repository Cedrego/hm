import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthService {
  // Claves para SharedPreferences
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _userDataKey = 'userData';
  static const String _userIdKey = 'userId';
  static const String _userEmailKey = 'userEmail';
  static const String _userRolKey = 'userRol'; // ← NUEVO

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
    await prefs.setString(_userRolKey, userData['rol'] ?? 'invitado'); // ← NUEVO
    
    print('✅ Sesión guardada: ${userData['email']} - Rol: ${userData['rol']}');
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

  // ← NUEVO: Obtener rol del usuario actual
  static Future<String> getUserRol() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRolKey) ?? 'invitado';
  }

  // ← NUEVO: Verificar si el usuario es admin
  static Future<bool> isAdmin() async {
    final rol = await getUserRol();
    return rol == 'admin';
  }

  // ← NUEVO: Verificar si el usuario es invitado
  static Future<bool> isInvitado() async {
    final rol = await getUserRol();
    return rol == 'invitado';
  }

  // Cerrar sesión
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_userDataKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userRolKey); // ← NUEVO
    
    print('✅ Sesión cerrada');
  }

  // Limpiar todos los datos (útil para desarrollo)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('✅ Todos los datos limpiados');
  }
}