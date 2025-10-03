import 'package:shelf/shelf.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../service/mongo_service.dart';

class RegistroHandler {
  final MongoService mongoService;

  RegistroHandler(this.mongoService);

  Future<Response> handleRegistro(Request request) async {
    try {
      // Leer el body de la petición
      final body = await request.readAsString();
      final data = jsonDecode(body);

      // Validar campos requeridos
      final requiredFields = ['email', 'nombre', 'documento', 'password', 'contacto'];
      for (final field in requiredFields) {
        if (data[field] == null || data[field].toString().trim().isEmpty) {
          return Response.badRequest(
            body: jsonEncode({
              'success': false,
              'message': 'El campo $field es requerido'
            }),
            headers: {'Content-Type': 'application/json'},
          );
        }
      }

      final email = data['email'].toString().trim().toLowerCase();
      final documento = data['documento'].toString().trim(); // <-- DEFINIR AQUÍ
      
      // Validar formato de email
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'message': 'Email inválido'
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Verificar si el email ya está registrado
      final existenteEmail = await mongoService.findUserByEmail(email);
      if (existenteEmail != null) {
        return Response(409,
          body: jsonEncode({
            'success': false,
            'message': 'El email ya está registrado'
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Verificar si el documento ya está registrado
      final existenteDocumento = await mongoService.findUserByDocument(documento);
      if (existenteDocumento != null) {
        return Response(409,
          body: jsonEncode({
            'success': false,
            'message': 'El documento de identidad ya está registrado'
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }
      
      // Hash de la contraseña
      final passwordHash = sha256.convert(
        utf8.encode(data['password'].toString())
      ).toString();

      // Crear el nuevo usuario
      final nuevoUsuario = {
        'email': email,
        'nombre': data['nombre'].toString().trim(),
        'documento': documento,
        'password': passwordHash,
        'contacto': data['contacto'].toString().trim(),
        'imagen': (data['imagen'] != null && data['imagen'] != 'vacio') ? data['imagen'] : null,
        'activo': true
      };

      await mongoService.createUser(nuevoUsuario);

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Usuario registrado exitosamente'
        }),
        headers: {'Content-Type': 'application/json'},
      );

    } catch (e) {
      print('Error en registro: $e');
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'message': 'Error del servidor'
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}