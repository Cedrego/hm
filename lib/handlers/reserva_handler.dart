import 'package:shelf/shelf.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../service/mongo_service.dart';

class ReservaHandler {
  final MongoService mongoService;

  ReservaHandler(this.mongoService);

  // =========================================================================
  // 1. CREAR RESERVA (POST /api/reservas)
  // =========================================================================
  Future<Response> crearReserva(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      // --- 1. Extracción y Validación de Campos ---
      final String? idUsuario = data['idUsuario']?.toString();
      final String? idHabitacionStr = data['idHabitacion']?.toString(); // 🟢 Cambiado a Str temporal
      final String? checkInStr = data['fechaCheckIn']?.toString();
      final String? checkOutStr = data['fechaCheckOut']?.toString();

      if (idUsuario == null || idHabitacionStr == null || checkInStr == null || checkOutStr == null) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'message': 'Faltan campos requeridos (idUsuario, idHabitacion, fechas)'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
      
      // 🟢 CORRECCIÓN CLAVE: Parsear idHabitacion a entero
      final int? idHabitacion = int.tryParse(idHabitacionStr);
      if (idHabitacion == null || idHabitacion <= 0) {
           return Response.badRequest(
            body: jsonEncode({'success': false, 'message': 'El idHabitacion proporcionado no es válido o debe ser numérico.'}),
            headers: {'Content-Type': 'application/json'},
          );
      }

      // --- 2. Validación y Cálculo de Días ---
      final DateTime checkIn = DateTime.parse(checkInStr);
      final DateTime checkOut = DateTime.parse(checkOutStr);

      if (checkOut.isBefore(checkIn) || checkOut.isAtSameMomentAs(checkIn)) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'message': 'La fecha de Check-out debe ser posterior a la de Check-in.'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
      
      final int diasEstadia = checkOut.difference(checkIn).inDays;

      // --- 3. Obtener Precio por Noche (Cálculo en el Servidor) ---
      // 🟢 CORRECCIÓN: Usando el método correcto findHabitacionById
      final habitacion = await mongoService.findHabitacionById(idHabitacion); 

      if (habitacion == null) {
         return Response.notFound(
          jsonEncode({'success': false, 'message': 'Habitación no encontrada'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final double precioDia = (habitacion['PrecioDia'] as num?)?.toDouble() ?? 0.0;
      
      if (precioDia <= 0.0) {
          return Response.internalServerError(
            body: jsonEncode({'success': false, 'message': 'Precio de habitación no válido o faltante.'}),
            headers: {'Content-Type': 'application/json'},
        );
      }
      
      final double precioTotal = diasEstadia * precioDia;

      // --- 4. Preparar Datos para MongoDB ---
      final reservaData = {
        'idUsuario': idUsuario, 
        'idHabitacion': idHabitacion, // 🟢 Almacenado como INT
        'fechaCheckIn': checkInStr,
        'fechaCheckOut': checkOutStr,
        'precioTotal': precioTotal, 
        'precioDiaHabitacion': precioDia,
        'diasEstadia': diasEstadia,
        'fechaReserva': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        'estado': 'Confirmada',
      };

      // --- 5. Guardar en Base de Datos ---
      final nuevaReserva = await mongoService.createReserva(reservaData);

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Reserva creada exitosamente',
          'reserva': {
            'id': nuevaReserva['_id'].toString(),
            'idUsuario': nuevaReserva['idUsuario'],
            'idHabitacion': nuevaReserva['idHabitacion'],
            'precioTotal': nuevaReserva['precioTotal'],
          }
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('💥 Error al crear reserva: $e');
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'message': 'Error del servidor al procesar reserva: ${e.toString()}'
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // =========================================================================
  // 2. OBTENER RESERVAS POR HABITACIÓN (GET /api/reservas/habitacion/{idHabitacion})
  // =========================================================================
  Future<Response> getReservasByHabitacion(Request request) async {
    try {
      final parts = request.url.pathSegments;
      if (parts.length < 3) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'message': 'ID de habitación faltante'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
      final idHabitacionStr = parts.last;

      // 🟢 CORRECCIÓN: Usando el método correcto findReservasByHabitacion
      final reservas = await mongoService.findReservasByHabitacion(idHabitacionStr);

      // --- Búsqueda de Usuario y Transformación ---
      final reservasTransformadas = await Future.wait(reservas.map((reserva) async {
        
        final String userId = reserva['idUsuario'].toString();
        
        // Lookup de usuario usando findUserById (asumimos que idUsuario es el _id de Mongo)
        final userDoc = await mongoService.findUserById(userId); 
        
        // Extraer los datos que interesan
        final nombreUsuario = userDoc?['nombre'] ?? 'Usuario Desconocido'; 
        final documentoUsuario = userDoc?['documento'] ?? 'N/A';
        
        return {
          'idReserva': reserva['_id'].toString(),
          'idUsuario': userId,
          'nombreUsuario': nombreUsuario,
          'documentoUsuario': documentoUsuario,
          'fechaCheckIn': reserva['fechaCheckIn'],
          'fechaCheckOut': reserva['fechaCheckOut'],
          'precioTotal': reserva['precioTotal'],
          'estado': reserva['estado'],
          // Devolvemos el objeto completo del usuario
          'usuario': userDoc != null ? {
              'id': userDoc['_id'].toString(),
              'email': userDoc['email'],
              'nombre': userDoc['nombre'],
              'documento': userDoc['documento'],
              'contacto': userDoc['contacto'],
              'rol': userDoc['rol'] ?? 'invitado',
              'imagen': userDoc['imagen'],
              'activo': userDoc['activo'] ?? true,
          } : null,
        };
      }));

      return Response.ok(
        jsonEncode({
          'success': true,
          'reservas': reservasTransformadas,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('💥 Error al obtener reservas: $e');
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'message': 'Error del servidor: ${e.toString()}'
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
  // 3. OBTENER RESERVAS POR USUARIO
Future<Response> getReservasByUsuario(Request request) async {
  try {
    final parts = request.url.pathSegments;
    if (parts.length < 3) {
      return Response.badRequest(
        body: jsonEncode({'success': false, 'message': 'ID de usuario faltante'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
    final idUsuario = parts.last; // Obtener el último segmento de la URL

    final reservas = await mongoService.findReservasByUsuario(idUsuario);

    final reservasTransformadas = await Future.wait(reservas.map((reserva) async {
      final int idHabitacion = reserva['idHabitacion'] as int;
      final habitacion = await mongoService.findHabitacionById(idHabitacion);
      
      return {
        'idReserva': reserva['idReserva'] ?? reserva['_id'].toString(),
        'idUsuario': reserva['idUsuario'],
        'idHabitacion': idHabitacion,
        'fechaCheckIn': reserva['fechaCheckIn'],
        'fechaCheckOut': reserva['fechaCheckOut'],
        'diasEstadia': reserva['diasEstadia'] ?? 0,
        'precioTotal': reserva['precioTotal'],
        'estado': reserva['estado'] ?? 'Confirmada',
        'fechaReserva': reserva['fechaReserva'],
        'habitacion': habitacion != null ? {
          'nombre': habitacion['NombreHab'],
          'descripcion': habitacion['Descripcion'],
          'imagen': habitacion['ImagenUrl'],
          'servicios': habitacion['ServiciosAdicional'] ?? [],
        } : null,
      };
    }));

    return Response.ok(
      jsonEncode({'success': true, 'reservas': reservasTransformadas}),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    print('💥 Error: $e');
    return Response.internalServerError(
      body: jsonEncode({'success': false, 'message': 'Error: ${e.toString()}'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}
  // 4. OBTENER TODAS LAS RESERVAS
  Future<Response> getAllReservas(Request request) async {
    try {
      final reservas = await mongoService.getAllReservas();

      return Response.ok(
        jsonEncode({
          'success': true,
          'count': reservas.length,
          'reservas': reservas
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('💥 Error: $e');
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'message': 'Error: ${e.toString()}'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // 5. CANCELAR RESERVA
Future<Response> cancelarReserva(Request request) async {
  try {
    final parts = request.url.pathSegments;
    if (parts.length < 2) {
      return Response.badRequest(
        body: jsonEncode({'success': false, 'message': 'ID de reserva faltante'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
    final id = parts[parts.length - 2]; // Penúltimo segmento (antes de "cancelar")

    final success = await mongoService.cancelarReserva(id);

    if (success) {
      return Response.ok(
        jsonEncode({'success': true, 'message': 'Reserva cancelada'}),
        headers: {'Content-Type': 'application/json'},
      );
    } else {
      return Response.notFound(
        jsonEncode({'success': false, 'message': 'Reserva no encontrada'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  } catch (e) {
    print('💥 Error: $e');
    return Response.internalServerError(
      body: jsonEncode({'success': false, 'message': 'Error: ${e.toString()}'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}
}