import 'package:shelf/shelf.dart';
import 'dart:convert';
import '../service/mongo_service.dart';

class HabitacionHandler {
  final MongoService mongoService;

  HabitacionHandler(this.mongoService);

  Future<Response> crearHabitacion(Request request) async {
    try {
      final body = await request.readAsString();
      print('📥 Request body: $body');
      
      final data = jsonDecode(body);

      // Validaciones
      if (data['nombre'] == null || data['nombre'].toString().trim().isEmpty) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'message': 'El nombre de la habitación es requerido'
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      if (data['descripcion'] == null || data['descripcion'].toString().trim().isEmpty) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'message': 'La descripción es requerida'
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      if (data['precio'] == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'message': 'El precio es requerido'
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Preparar datos con los nombres de campos correctos
      final habitacionData = {
        'NombreHab': data['nombre'].toString().trim(),
        'Descripcion': data['descripcion'].toString().trim(),
        'ServicioAdicional': data['servicios'] ?? [],
        'PrecioDia': data['precio'],
        'imagen': data['imagen'] ?? 'vacio',
        'fechaCreacion': DateTime.now().toIso8601String(),
        'disponible': true,
      };

      print('🏨 Creando habitación: ${habitacionData['NombreHab']}');
     print('🖼️ Imagen base64 length: ${habitacionData['imagen']?.toString().length ?? 0}'); // DEBUG
      // Crear habitación
      final habitacion = await mongoService.createHabitacion(habitacionData);

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Habitación creada exitosamente',
          'habitacion': {
            'id': habitacion['_id'].toString(),
            'nombre': habitacion['NombreHab'],
            'descripcion': habitacion['Descripcion'],
            'precio': habitacion['PrecioDia'],
            'servicios': habitacion['ServicioAdicional'],
            'imagen': habitacion['imagen'],
          },
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('💥 Error al crear habitación: $e');
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'message': 'Error del servidor: ${e.toString()}'
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> getHabitaciones(Request request) async {
    try {
      print('📋 Obteniendo lista de habitaciones...');
      
      final habitaciones = await mongoService.getHabitaciones();

      // Transformar los datos para que el frontend los entienda
      final habitacionesTransformadas = habitaciones.map((hab) {
        return {
          'idHabitacion': hab['_id'].toString(),
          'nombre': hab['NombreHab'],
          'descripcion': hab['Descripcion'],
          'precio': hab['PrecioDia'],
          'servicios': hab['ServicioAdicional'],
          'imagen': hab['imagen'] ?? 'vacio',
          'disponible': hab['disponible'] ?? true,
          'fechaCreacion': hab['fechaCreacion'],
        };
      }).toList();

      return Response.ok(
        jsonEncode({
          'success': true,
          'habitaciones': habitacionesTransformadas,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('💥 Error al obtener habitaciones: $e');
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'message': 'Error del servidor: ${e.toString()}'
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}