import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://192.168.1.6:8081/api';

  // Login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Error en login');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Registro
  static Future<Map<String, dynamic>> registro(Map<String, String> datos) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/registro'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(datos),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Error en registro');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener perfil de usuario
  static Future<Map<String, dynamic>> getPerfil(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/perfil/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Error al obtener perfil');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

   static Future<Map<String, dynamic>> crearHabitacion({
    required String nombre,
    required String descripcion,
    required double precio,
    required List<String> servicios,
    String? imagenUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/habitaciones'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': nombre,
          'descripcion': descripcion,
          'precio': precio,
          'servicios': servicios,
          'imagenUrl': imagenUrl,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['success'] == true) {
          return responseData;
        } else {
          throw Exception(responseData['message'] ?? 'Error al crear habitación');
        }
      } else {
        throw Exception(responseData['message'] ?? 'Error del servidor (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener todas las habitaciones
  static Future<List<dynamic>> getHabitaciones() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/habitaciones'),
        headers: {'Content-Type': 'application/json'},
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData['habitaciones'] ?? [];
      } else {
        throw Exception('Error al obtener habitaciones');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
