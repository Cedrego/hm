import 'package:mongo_dart/mongo_dart.dart';

class MongoService {
  final String uri;
  late Db db;

  MongoService(this.uri);

  Future<void> connect() async {
    db = Db(uri);
    await db.open();
    print('Conectado a MongoDB');
  }

  Future<void> close() async {
    await db.close();
    print('Desconectado de MongoDB');
  }

  // Obtener todos los usuarios
  Future<List<Map<String, dynamic>>> getUsuarios() async {
    final collection = db.collection('usuarios');
    return await collection.find().toList();
  }

  // Buscar usuario por email
  Future<Map<String, dynamic>?> findUserByEmail(String email) async {
    final collection = db.collection('usuarios');
    final usuario = await collection.findOne(where.eq('email', email.toLowerCase()));
    return usuario;
  }

  // Buscar usuario por ID
  Future<Map<String, dynamic>?> findUserById(String id) async {
    try {
      final collection = db.collection('usuarios');
      final usuario = await collection.findOne(where.id(ObjectId.fromHexString(id)));
      return usuario;
    } catch (e) {
      print('Error al buscar usuario por ID: $e');
      return null;
    }
  }

  // Crear nuevo usuario
  Future<void> createUser(Map<String, dynamic> usuario) async {
    final collection = db.collection('usuarios');
    await collection.insert(usuario);
    print('Usuario creado: ${usuario['email']}');
  }

  // Actualizar usuario
  Future<bool> updateUser(String id, Map<String, dynamic> updates) async {
    try {
      final collection = db.collection('usuarios');
      final result = await collection.update(
        where.id(ObjectId.fromHexString(id)),
        modify.set('nombre', updates['nombre'])
              .set('contacto', updates['contacto'])
              .set('fechaActualizacion', DateTime.now().toIso8601String())
      );
      return result['nModified'] > 0;
    } catch (e) {
      print('Error al actualizar usuario: $e');
      return false;
    }
  }
  // Buscar usuario por documento de identidad
  Future<Map<String, dynamic>?> findUserByDocument(String documento) async {
    try {
      print('🔍 Buscando usuario por documento: $documento');
      final collection = db.collection('usuarios');
      final usuario = await collection.findOne(where.eq('documento', documento));
      
      if (usuario != null) {
        print('✅ Usuario encontrado con documento: ${usuario['nombre']}');
      } else {
        print('⚠️ No se encontró usuario con documento: $documento');
      }
      
      return usuario;
    } catch (e) {
      print('❌ Error al buscar usuario por documento: $e');
      return null;
    }
  }
}
