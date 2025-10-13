import 'package:hm_server/hm_server.dart' as hm_server;
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:hm_server/service/mongo_service.dart';
import 'package:hm_server/config/config.dart';
import 'package:hm_server/handlers/login_handler.dart';
import 'package:hm_server/handlers/registro_handler.dart';
import 'package:hm_server/handlers/habitacion_handler.dart';
import 'package:hm_server/handlers/reserva_handler.dart';

void main() async {
  // Conectar a MongoDB
  final mongoService = MongoService(mongoUri);
  await mongoService.connect();

  // Inicializar handlers
  final loginHandler = LoginHandler(mongoService);
  final registroHandler = RegistroHandler(mongoService);
  final habitacionHandler = HabitacionHandler(mongoService);
  final reservaHandler = ReservaHandler(mongoService);

  // Configuración de las rutas (endpoints)
  final appRouter = Router();

  // Middleware para CORS
  Middleware corsHeaders() {
    return createMiddleware(
      requestHandler: (Request request) {
        if (request.method == 'OPTIONS') {
          return Response.ok('', headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
            'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept, Authorization',
          });
        }
        return null;
      },
      responseHandler: (Response response) {
        return response.change(headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept, Authorization',
        });
      },
    );
  }

  // Endpoint de prueba
  appRouter.get('/api/saludo', (Request request) {
    return Response.ok('Hola desde tu servidor Dart!');
  });

  // Endpoint para login
  appRouter.post('/api/login', loginHandler.handleLogin);

  // Endpoint para registro
  appRouter.post('/api/registro', registroHandler.handleRegistro);

  appRouter.post('/api/habitaciones', habitacionHandler.crearHabitacion);
  appRouter.get('/api/habitaciones', habitacionHandler.getHabitaciones);

 // Rutas de Reservas
  appRouter.post('/api/reservas', reservaHandler.crearReserva);
  appRouter.get('/api/reservas/habitacion/<idHabitacion>', reservaHandler.getReservasByHabitacion);
  

  // Endpoint para obtener usuarios (para pruebas)
  appRouter.get('/api/usuarios', (Request request) async {
    final usuarios = await mongoService.getUsuarios();
    return Response.ok(
      usuarios.toString(),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // Endpoint para obtener perfil de usuario
  appRouter.get('/api/perfil/<id>', (Request request, String id) async {
    final usuario = await mongoService.findUserById(id);
    
    if (usuario == null) {
      return Response.notFound(
        '{"success": false, "message": "Usuario no encontrado"}',
        headers: {'Content-Type': 'application/json'},
      );
    }

    // Eliminar la contraseña antes de enviar
    usuario.remove('password');

    return Response.ok(
      '{"success": true, "usuario": ${usuario.toString()}}',
      headers: {'Content-Type': 'application/json'},
    );
  });

  // Manejador con middleware
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addHandler(appRouter);

  // Iniciar el servidor
  final port = 8081;
  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);

  print('═══════════════════════════════════════════════════');
  print('🚀 Servidor Dart escuchando en http://${server.address.host}:${server.port}');
  print('═══════════════════════════════════════════════════');
  print('Endpoints disponibles:');
  print('  GET  /api/saludo');
  print('  POST /api/login');
  print('  POST /api/registro');
  print('  GET  /api/usuarios');
  print('  GET  /api/perfil/<id>');
  print('  POST /api/reservas');
  print('  GET  /api/reservas/habitacion/<idHabitacion>');
  print('═══════════════════════════════════════════════════');
}
