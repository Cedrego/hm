import 'package:shelf/shelf.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../service/mongo_service.dart';

class LoginHandler {
  final MongoService mongoService;

  LoginHandler(this.mongoService);

  Future<Response> handleLogin(Request request) async {
    try {
      // Leer el body de la petición
      final body = await request.readAsString();
      final data = jsonDecode(body);

      // Validar que vengan email y password
      if (data['email'] == null || data['password'] == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'message': 'Email y contraseña son requeridos'
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final email = data['email'].toString().trim().toLowerCase();
      final password = data['password'].toString();

      // Buscar usuario en la base de datos
      final usuario = await mongoService.findUserByEmail(email);

      if (usuario == null) {
        return Response(401,
          body: jsonEncode({
            'success': false,
            'message': 'Credenciales inválidas'
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Verificar contraseña (con hash)
      final bytes = utf8.encode(password);
      final digest = sha256.convert(bytes);
      final passwordHash = digest.toString();
      
      if (usuario['password'] != passwordHash) {
        return Response(401,
          body: jsonEncode({
            'success': false,
            'message': 'Credenciales inválidas'
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Login exitoso - devolver datos del usuario (sin la contraseña) + ROL
      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Login exitoso',
          'usuario': {
            'id': usuario['_id'].toString(),
            'email': usuario['email'],
            'nombre': usuario['nombre'],
            'documento': usuario['documento'],
            'contacto': usuario['contacto'],
            'rol': usuario['rol'] ?? 'invitado', // ← AGREGADO: incluir rol
            'imagen': usuario['imagen'],
            'activo': usuario['activo'] ?? true,
          }
        }),
        headers: {'Content-Type': 'application/json'},
      );

    } catch (e) {
      print('Error en login: $e');
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