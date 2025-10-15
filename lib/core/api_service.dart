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

  // Crear Habitación
  static Future<Map<String, dynamic>> crearHabitacion({
    required String nombre,
    required String descripcion,
    required double precio,
    required List<String> servicios,
    String? imagenBase64, // ← Cambio de imagenUrl a imagenBase64
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
        'imagen': imagenBase64, // ← Cambio de 'imagenUrl' a 'imagen'
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

      if (response.statusCode == 200 && responseData['success'] == true) {
        return responseData['habitaciones'];
      } else {
        throw Exception(responseData['message'] ?? 'Error al obtener habitaciones');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // =========================================================================
  // 🟢 Métodos de Reserva
  // =========================================================================

  // Crear Reserva
  static Future<Map<String, dynamic>> crearReserva({
    required String idUsuario,
    required String idHabitacion,
    required String fechaCheckIn,
    required String fechaCheckOut,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reservas'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'idUsuario': idUsuario,
          'idHabitacion': idHabitacion,
          'fechaCheckIn': fechaCheckIn,
          'fechaCheckOut': fechaCheckOut,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['success'] == true) {
          return responseData;
        } else {
          throw Exception(responseData['message'] ?? 'Error al crear reserva');
        }
      } else {
        throw Exception(responseData['message'] ?? 'Error del servidor (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
/*
  // Obtener Reservas por Habitación
  static Future<List<dynamic>> getReservasPorHabitacion(String idHabitacion) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reservas/$idHabitacion'),
        headers: {'Content-Type': 'application/json'},
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return responseData['reservas'];
      } else {
        throw Exception(responseData['message'] ?? 'Error al obtener reservas');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
  */
  
// Obtener reservas de una habitación
static Future<List<dynamic>> getReservasPorHabitacion(String habitacionId) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/reservas/habitacion/$habitacionId'),
      headers: {'Content-Type': 'application/json'},
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return responseData['reservas'] ?? [];
    } else {
      throw Exception('Error al obtener reservas');
    }
  } catch (e) {
    throw Exception('Error de conexión: $e');
  }
}

// Obtener reservas de un usuario
static Future<List<dynamic>> getReservasUsuario(String usuarioId) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/reservas/usuario/$usuarioId'),
      headers: {'Content-Type': 'application/json'},
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return responseData['reservas'] ?? [];
    } else {
      throw Exception('Error al obtener reservas del usuario');
    }
  } catch (e) {
    throw Exception('Error de conexión: $e');
  }
}
}