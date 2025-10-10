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

  Future<List<Map<String, dynamic>>> getHabitaciones() async {
    try {
      print('🏨 Obteniendo todas las habitaciones...');
      final collection = db.collection('habitaciones');
      final habitaciones = await collection.find().toList();
      print('✅ Encontradas ${habitaciones.length} habitaciones');
      return habitaciones;
    } catch (e) {
      print('❌ Error al obtener habitaciones: $e');
      return [];
    }
  } // Obtener habitaciones por servicio adicional
  Future<List<Map<String, dynamic>>> getHabitacionesByServicio(String servicio) async {
    try {
      print('🔍 Buscando habitaciones con servicio: $servicio');
      final collection = db.collection('habitaciones');
      final habitaciones = await collection.find(
        where.eq('ServicioAdicional', servicio)
      ).toList();
      print('✅ Encontradas ${habitaciones.length} habitaciones con servicio $servicio');
      return habitaciones;
    } catch (e) {
      print('❌ Error al buscar habitaciones por servicio: $e');
      return [];
    }
  }
 
 // ✨ NUEVO: Obtener el siguiente idHabitacion
  Future<int> getNextIdHabitacion() async {
    try {
      print('🔢 Obteniendo siguiente idHabitacion...');
      final collection = db.collection('habitaciones');
      
      // Buscar la habitación con el idHabitacion más alto
      final ultimaHabitacion = await collection
          .find(where.sortBy('idHabitacion', descending: true).limit(1))
          .toList();
      
      // Si no hay habitaciones, empezar desde 1
      if (ultimaHabitacion.isEmpty) {
        print('📌 Primera habitación, asignando ID: 1');
        return 1;
      }
      
      // Obtener el último ID y sumarle 1
      final ultimoId = ultimaHabitacion[0]['idHabitacion'] as int? ?? 0;
      final nuevoId = ultimoId + 1;
      
      print('✅ Siguiente idHabitacion: $nuevoId');
      return nuevoId;
    } catch (e) {
      print('❌ Error al obtener siguiente idHabitacion: $e');
      return 1; // Por defecto empezar en 1
    }
  }

  // 🔄 MODIFICADO: Crear nueva habitación con idHabitacion auto-incremental
  Future<Map<String, dynamic>> createHabitacion(Map<String, dynamic> habitacion) async {
    try {
      print('📝 Creando nueva habitación...');
      print('🏨 Nombre: ${habitacion['NombreHab']}');
      
      // Obtener el siguiente ID numérico
      final nuevoIdHabitacion = await getNextIdHabitacion();
      
      // Agregar el idHabitacion al documento
      habitacion['idHabitacion'] = nuevoIdHabitacion;
      
      // Agregar fecha de creación si no existe
      habitacion['FechaCreacion'] = habitacion['FechaCreacion'] ?? DateTime.now().toIso8601String();
      habitacion['Activa'] = habitacion['Activa'] ?? true;
      
      final collection = db.collection('habitaciones');
      final result = await collection.insertOne(habitacion);
      
      if (result.isSuccess) {
        print('✅ Habitación creada exitosamente!');
        print('🆔 MongoDB ID: ${result.id}');
        print('🔢 idHabitacion: $nuevoIdHabitacion');
        habitacion['_id'] = result.id;
        return habitacion;
      } else {
        print('❌ Fallo al insertar habitación');
        throw Exception('Error al insertar habitación en MongoDB');
      }
    } catch (e) {
      print('❌ Error al crear habitación: $e');
      rethrow;
    }
  }

  // 🆕 NUEVO: Buscar habitación por idHabitacion numérico
  Future<Map<String, dynamic>?> findHabitacionById(int idHabitacion) async {
    try {
      print('🔍 Buscando habitación por idHabitacion: $idHabitacion');
      final collection = db.collection('habitaciones');
      final habitacion = await collection.findOne(where.eq('idHabitacion', idHabitacion));
      
      if (habitacion != null) {
        print('✅ Habitación encontrada: ${habitacion['NombreHab']}');
      } else {
        print('⚠️ No se encontró habitación con idHabitacion: $idHabitacion');
      }
      
      return habitacion;
    } catch (e) {
      print('❌ Error al buscar habitación por ID: $e');
      return null;
    }
  }


  // Actualizar habitación
  Future<bool> updateHabitacion(String id, Map<String, dynamic> updates) async {
    try {
      print('📝 Actualizando habitación ID: $id');
      final collection = db.collection('habitaciones');
      
      final result = await collection.updateOne(
        where.id(ObjectId.fromHexString(id)),
        modify.set('NombreHab', updates['NombreHab'])
              .set('Descripcion', updates['Descripcion'])
              .set('ServicioAdicional', updates['ServicioAdicional'])
              .set('PrecioDia', updates['PrecioDia'])
              .set('ImagenId', updates['ImagenId']),
      );
      
      final success = result.isSuccess && result.nModified > 0;
      
      if (success) {
        print('✅ Habitación actualizada exitosamente');
      } else {
        print('⚠️ No se modificó ninguna habitación');
      }
      
      return success;
    } catch (e) {
      print('❌ Error al actualizar habitación: $e');
      return false;
    }
  }

  // Eliminar habitación
  Future<bool> deleteHabitacion(String id) async {
    try {
      print('🗑️ Eliminando habitación ID: $id');
      final collection = db.collection('habitaciones');
      
      final result = await collection.deleteOne(where.id(ObjectId.fromHexString(id)));
      
      final success = result.isSuccess && result.nRemoved > 0;
      
      if (success) {
        print('✅ Habitación eliminada exitosamente');
      } else {
        print('⚠️ No se eliminó ninguna habitación');
      }
      
      return success;
    } catch (e) {
      print('❌ Error al eliminar habitación: $e');
      return false;
    }
  }

  // Contar habitaciones
  Future<int> countHabitaciones() async {
    try {
      final collection = db.collection('habitaciones');
      final count = await collection.count();
      print('📊 Total de habitaciones: $count');
      return count;
    } catch (e) {
      print('❌ Error al contar habitaciones: $e');
      return 0;
    }
  }
}
