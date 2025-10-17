import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // =========================================================================
  // 👤 USUARIOS
  // =========================================================================

  // Login - Verificar credenciales
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final query = await _firestore
          .collection('usuarios')
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception('Email o contraseña incorrectos');
      }

      final userDoc = query.docs.first;
      final userData = userDoc.data();

      // Eliminar password del response por seguridad
      final userDataSafe = Map<String, dynamic>.from(userData);
      userDataSafe.remove('password');

      return {
        'success': true,
        'message': 'Login exitoso',
        'usuario': {'id': userDoc.id, ...userDataSafe},
      };
    } catch (e) {
      throw Exception('Error en login: $e');
    }
  }

  // Registro
  Future<Map<String, dynamic>> registro(Map<String, dynamic> datos) async {
    try {
      // Verificar si el email ya existe
      final emailQuery = await _firestore
          .collection('usuarios')
          .where('email', isEqualTo: datos['email'])
          .limit(1)
          .get();

      if (emailQuery.docs.isNotEmpty) {
        throw Exception('El email ya está registrado');
      }

      String? imagenUrl;

      // ✅ SUBIR IMAGEN A CLOUDINARY SI EXISTE
      if (datos['imagen'] != null && datos['imagen'].toString().isNotEmpty) {
        try {
          print('📤 Subiendo imagen a Cloudinary...');
          imagenUrl = await _subirImagenACloudinary(datos['imagen']!);
          print('✅ Imagen subida exitosamente: $imagenUrl');
        } catch (e) {
          print('⚠️ Error subiendo imagen, continuando sin imagen: $e');
          // Continuar sin imagen - no bloquear el registro
        }
      }

      // Crear nuevo usuario
      final userData = Map<String, dynamic>.from(datos);
      userData.remove('imagen'); // Quitar base64
      
      // Agregar URL de Cloudinary si se subió
      if (imagenUrl != null) {
        userData['imagenUrl'] = imagenUrl;
      }

      print('💾 Guardando usuario en Firestore...');
      final docRef = await _firestore.collection('usuarios').add(userData);

      // Preparar respuesta sin password
      final responseData = Map<String, dynamic>.from(userData);
      responseData.remove('password');

      return {
        'success': true,
        'message': 'Usuario registrado exitosamente',
        'usuario': {
          'id': docRef.id,
          ...responseData
        }
      };
    } catch (e) {
      print('❌ Error en registro: $e');
      throw Exception('Error en registro: $e');
    }
  }

  // Obtener perfil de usuario
  Future<Map<String, dynamic>> getPerfil(String userId) async {
    try {
      final doc = await _firestore.collection('usuarios').doc(userId).get();

      if (!doc.exists) {
        throw Exception('Usuario no encontrado');
      }

      final userData = doc.data()!;
      userData.remove('password');

      return {
        'success': true,
        'usuario': {'id': doc.id, ...userData},
      };
    } catch (e) {
      throw Exception('Error al obtener perfil: $e');
    }
  }

  // =========================================================================
  // 🏨 HABITACIONES
  // =========================================================================

  // Crear habitación
  Future<Map<String, dynamic>> crearHabitacion({
    required String nombre,
    required String descripcion,
    required double precio,
    required List<String> servicios,
    String? imagenBase64,
  }) async {
    try {
      String? imagenUrl;

      // Subir imagen si se proporciona
      if (imagenBase64 != null) {
        imagenUrl = await _subirImagenACloudinary(
          imagenBase64,
          folder: 'habitaciones',
        );
      }

      final docRef = await _firestore.collection('habitaciones').add({
        'nombre': nombre,
        'descripcion': descripcion,
        'precio': precio,
        'servicios': servicios,
        'imagenUrl': imagenUrl,
        'disponible': true,
      });

      return {
        'success': true,
        'message': 'Habitación creada exitosamente',
        'habitacion': {
          'id': docRef.id,
          'nombre': nombre,
          'descripcion': descripcion,
          'precio': precio,
          'servicios': servicios,
          'imagenUrl': imagenUrl,
          'disponible': true,
        },
      };
    } catch (e) {
      throw Exception('Error al crear habitación: $e');
    }
  }

  // Obtener todas las habitaciones
  Stream<List<Map<String, dynamic>>> getHabitaciones() {
    return _firestore
        .collection('habitaciones')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'nombre': data['nombre'] ?? '',
              'descripcion': data['descripcion'] ?? '',
              'precio': (data['precio'] ?? 0.0).toDouble(),
              'servicios': List<String>.from(data['servicios'] ?? []),
              'imagenUrl': data['imagenUrl'],
              'disponible': data['disponible'] ?? true,
            };
          }).toList(),
        );
  }

  // =========================================================================
  // 📅 RESERVAS
  // =========================================================================

  // Crear reserva
  Future<Map<String, dynamic>> crearReserva({
    required String idUsuario,
    required String idHabitacion,
    required String fechaCheckIn,
    required String fechaCheckOut,
  }) async {
    try {
      final docRef = await _firestore.collection('reservas').add({
        'idUsuario': idUsuario,
        'idHabitacion': idHabitacion,
        'fechaCheckIn': fechaCheckIn,
        'fechaCheckOut': fechaCheckOut,
        'estado': 'activa',
        'fechaReserva': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'message': 'Reserva creada exitosamente',
        'reserva': {
          'id': docRef.id,
          'idUsuario': idUsuario,
          'idHabitacion': idHabitacion,
          'fechaCheckIn': fechaCheckIn,
          'fechaCheckOut': fechaCheckOut,
          'estado': 'activa',
        },
      };
    } catch (e) {
      throw Exception('Error al crear reserva: $e');
    }
  }

  // Obtener reservas por habitación
  Stream<List<Map<String, dynamic>>> getReservasPorHabitacion(
    String habitacionId,
  ) {
    return _firestore
        .collection('reservas')
        .where('idHabitacion', isEqualTo: habitacionId)
        .orderBy('fechaReserva', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return {'id': doc.id, ...data};
          }).toList(),
        );
  }

  // Obtener reservas por usuario
  Stream<List<Map<String, dynamic>>> getReservasPorUsuario(String usuarioId) {
    return _firestore
        .collection('reservas')
        .where('idUsuario', isEqualTo: usuarioId)
        .orderBy('fechaReserva', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return {'id': doc.id, ...data};
          }).toList(),
        );
  }

  // Cancelar reserva
  Future<void> cancelarReserva(String reservaId) async {
    await _firestore.collection('reservas').doc(reservaId).update({
      'estado': 'cancelada',
      'fechaCancelacion': FieldValue.serverTimestamp(),
    });
  }

  // =========================================================================
  // 🖼️ MÉTODOS PRIVADOS - CLOUDINARY
  // =========================================================================

  // Subir imagen a Cloudinary
  Future<String> _subirImagenACloudinary(String base64Image, {String folder = 'usuarios'}) async {
    try {
      print('📤 Subiendo imagen a Cloudinary...');
      
      const cloudName = 'dexpqwsqp';
      const uploadPreset = 'hostel_mochileros';

      // Extraer solo la parte base64 (sin el prefix data:image/...)
      String cleanBase64 = base64Image;
      if (base64Image.contains(',')) {
        cleanBase64 = base64Image.split(',').last;
      }

      // ✅ USAR SUBCARPETAS DENTRO DE hostel_mochileros
      final subcarpeta = 'hostel_mochileros/$folder';

      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/upload');
      
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..fields['folder'] = subcarpeta  // ← SUBCARPETA CORREGIDA
        ..files.add(http.MultipartFile.fromString(
          'file',
          'data:image/jpeg;base64,$cleanBase64',
        ));

      print('🌐 Enviando solicitud a Cloudinary - Carpeta: $subcarpeta');
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseData);

      if (response.statusCode == 200) {
        final imageUrl = jsonResponse['secure_url'];
        print('✅ Imagen subida exitosamente a carpeta "$subcarpeta": $imageUrl');
        return imageUrl;
      } else {
        throw Exception('Error de Cloudinary: ${jsonResponse['error']['message']}');
      }
    } catch (e) {
      print('❌ Error subiendo imagen a Cloudinary: $e');
      throw Exception('Error al subir imagen: $e');
    }
  }

  // Método para probar la conexión
  Future<void> probarConexion() async {
    try {
      await _firestore.collection('prueba').add({
        'mensaje': 'Conexión exitosa desde Hostel Mochileros',
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('✅ CONEXIÓN EXITOSA con Firebase');
    } catch (e) {
      print('❌ ERROR de conexión: $e');
    }
  }
}