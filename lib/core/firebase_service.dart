// lib/core/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hm/core/logger.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FirebaseService {
  static FirebaseService? _instance;
  FirebaseService._();
  
  static FirebaseService get instance {
    _instance ??= FirebaseService._();
    return _instance!;
  }

  late final FirebaseFirestore _firestore;
  bool _isInitialized = false;

  Future<void> initialize() async {
    try {
      if (kIsWeb) {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: "AIzaSyAxHo67XQDkjNe9lLIN_qvVmAQngU9vUOs",
            authDomain: "hostel-mochileros.firebaseapp.com",
            projectId: "hostel-mochileros",
            storageBucket: "hostel-mochileros.firebasestorage.app",
            messagingSenderId: "103969422555",
            appId: "1:103969422555:web:d045d43a7dfb7cea6c60fe",
            measurementId: "G-WS6RCDJ0MZ",
          ),
        );
      } else {
        await Firebase.initializeApp();
      }
      
      _firestore = FirebaseFirestore.instance;
      _isInitialized = true;
    } catch (e) {
      throw Exception('No se pudo inicializar Firebase: $e');
    }
  }

  void _checkInitialization() {
    if (!_isInitialized) {
      throw Exception('FirebaseService no está inicializado');
    }
  }

  // MÉTODO LOGIN (solo este por ahora para probar)
  Future<Map<String, dynamic>> login(String email, String password) async {
    _checkInitialization();
    
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
    _checkInitialization(); // ✅ VERIFICAR INICIALIZACIÓN
    
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
          AppLogger.i('📤 Subiendo imagen a Cloudinary...');
          imagenUrl = await _subirImagenACloudinary(datos['imagen']!);
          AppLogger.i('✅ Imagen subida exitosamente: $imagenUrl');
        } catch (e) {
          AppLogger.e('⚠️ Error subiendo imagen, continuando sin imagen: $e');
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

      AppLogger.i('💾 Guardando usuario en Firestore...');
      final docRef = await _firestore.collection('usuarios').add(userData);

      // Preparar respuesta sin password
      final responseData = Map<String, dynamic>.from(userData);
      responseData.remove('password');

      return {
        'success': true,
        'message': 'Usuario registrado exitosamente',
        'usuario': {'id': docRef.id, ...responseData},
      };
    } catch (e) {
      AppLogger.e('❌ Error en registro: $e');
      throw Exception('Error en registro: $e');
    }
  }

  // Obtener perfil de usuario
  Future<Map<String, dynamic>> getPerfil(String userId) async {
    _checkInitialization(); // ✅ VERIFICAR INICIALIZACIÓN
    
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

  // Obtener usuario por ID
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    _checkInitialization(); // ✅ VERIFICAR INICIALIZACIÓN
    
    try {
      AppLogger.i('🔍 Buscando usuario con ID: $userId');

      final doc = await _firestore.collection('usuarios').doc(userId).get();

      if (!doc.exists) {
        AppLogger.w('⚠️ Usuario no encontrado con ID: $userId');
        return null;
      }

      final userData = doc.data()!;

      // Crear copia segura sin password
      final userDataSafe = Map<String, dynamic>.from(userData);
      userDataSafe.remove('password');

      AppLogger.success(
        '✅ Usuario encontrado: ${userDataSafe['nombre'] ?? 'Sin nombre'}',
      );

      return {'id': doc.id, ...userDataSafe};
    } catch (e) {
      AppLogger.e('❌ Error obteniendo usuario $userId: $e');
      throw Exception('Error al cargar datos del usuario: $e');
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
    _checkInitialization(); // ✅ VERIFICAR INICIALIZACIÓN
    
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
    _checkInitialization(); // ✅ VERIFICAR INICIALIZACIÓN
    
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

  // Buscar habitaciones por nombre o servicios
  Stream<List<Map<String, dynamic>>> buscarHabitaciones(String query) {
    _checkInitialization();

    if (query.isEmpty) {
      // Si la búsqueda está vacía, retornar todas las habitaciones
      return getHabitaciones();
    }

    final queryLower = query.toLowerCase();

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
        )
        .map(
          (habitaciones) => habitaciones.where((habitacion) {
            final nombre = habitacion['nombre']?.toString().toLowerCase() ?? '';
            final servicios = List<String>.from(habitacion['servicios'] ?? []);

            // Buscar en el nombre
            final coincideNombre = nombre.contains(queryLower);

            // Buscar en los servicios
            final coincideServicios = servicios.any(
              (servicio) => servicio.toLowerCase().contains(queryLower),
            );

            return coincideNombre || coincideServicios;
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
    _checkInitialization(); // ✅ VERIFICAR INICIALIZACIÓN
    
    try {
      final habitacion = await getHabitacionPorId(idHabitacion);
      final precioTotal = _calcularPrecioTotal(
        fechaCheckIn,
        fechaCheckOut,
        habitacion?['precio'] ?? 0.0,
      );

      final docRef = await _firestore.collection('reservas').add({
        'idUsuario': idUsuario,
        'idHabitacion': idHabitacion,
        'fechaCheckIn': fechaCheckIn,
        'fechaCheckOut': fechaCheckOut,
        'precioTotal': precioTotal,
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
          'precioTotal': precioTotal,
          'estado': 'activa',
        },
      };
    } catch (e) {
      throw Exception('Error al crear reserva: $e');
    }
  }

  double _calcularPrecioTotal(
    String checkIn,
    String checkOut,
    double precioDiario,
  ) {
    final inicio = DateTime.parse(checkIn);
    final fin = DateTime.parse(checkOut);
    final dias = fin.difference(inicio).inDays;
    return dias * precioDiario;
  }

  // Obtener reservas por habitación
  Stream<List<Map<String, dynamic>>> getReservasPorHabitacion(
    String habitacionId,
  ) {
    _checkInitialization(); // ✅ VERIFICAR INICIALIZACIÓN
    
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
    _checkInitialization(); // ✅ VERIFICAR INICIALIZACIÓN
    
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
    _checkInitialization(); // ✅ VERIFICAR INICIALIZACIÓN
    
    await _firestore.collection('reservas').doc(reservaId).update({
      'estado': 'cancelada',
      'fechaCancelacion': FieldValue.serverTimestamp(),
    });
  }

  // MÉTODO PARA OBTENER TODAS LAS RESERVAS (Habitacion mas popular)
  Future<List<Map<String, dynamic>>> getTodasLasReservas() async {
    _checkInitialization(); // ✅ VERIFICAR INICIALIZACIÓN
    
    try {
      final querySnapshot = await _firestore
          .collection('reservas')
          .where('estado', isEqualTo: 'activa')
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {'id': doc.id, ...data};
      }).toList();
    } catch (e) {
      AppLogger.e('Error obteniendo reservas: $e');
      return [];
    }
  }

  // =========================================================================
  // 🖼️ MÉTODOS PRIVADOS - CLOUDINARY
  // =========================================================================

  // Subir imagen a Cloudinary
  Future<String> _subirImagenACloudinary(
    String base64Image, {
    String folder = 'usuarios',
  }) async {
    try {
      AppLogger.i('📤 Subiendo imagen a Cloudinary...');

      const cloudName = 'dexpqwsqp';
      const uploadPreset = 'hostel_mochileros';

      // Extraer solo la parte base64 (sin el prefix data:image/...)
      String cleanBase64 = base64Image;
      if (base64Image.contains(',')) {
        cleanBase64 = base64Image.split(',').last;
      }

      // ✅ USAR SUBCARPETAS DENTRO DE hostel_mochileros
      final subcarpeta = 'hostel_mochileros/$folder';

      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/upload',
      );

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..fields['folder'] = subcarpeta
        ..files.add(
          http.MultipartFile.fromString(
            'file',
            'data:image/jpeg;base64,$cleanBase64',
          ),
        );

      AppLogger.i('🌐 Enviando solicitud a Cloudinary - Carpeta: $subcarpeta');
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseData);

      if (response.statusCode == 200) {
        final imageUrl = jsonResponse['secure_url'];
        AppLogger.success(
          '✅ Imagen subida exitosamente a carpeta "$subcarpeta": $imageUrl',
        );
        return imageUrl;
      } else {
        throw Exception(
          'Error de Cloudinary: ${jsonResponse['error']['message']}',
        );
      }
    } catch (e) {
      AppLogger.e('❌ Error subiendo imagen a Cloudinary: $e');
      throw Exception('Error al subir imagen: $e');
    }
  }

  // Método para probar la conexión
  Future<void> probarConexion() async {
    _checkInitialization(); // ✅ VERIFICAR INICIALIZACIÓN
    
    try {
      await _firestore.collection('prueba').add({
        'mensaje': 'Conexión exitosa desde Hostel Mochileros',
        'timestamp': FieldValue.serverTimestamp(),
      });
      AppLogger.success('✅ CONEXIÓN EXITOSA con Firebase');
    } catch (e) {
      AppLogger.e('❌ ERROR de conexión: $e');
    }
  }

  // Obtener habitación por ID
  Future<Map<String, dynamic>?> getHabitacionPorId(String habitacionId) async {
    _checkInitialization(); // ✅ VERIFICAR INICIALIZACIÓN
    
    try {
      final doc = await _firestore
          .collection('habitaciones')
          .doc(habitacionId)
          .get();
      if (doc.exists) {
        return {'id': doc.id, ...doc.data()!};
      }
      return null;
    } catch (e) {
      AppLogger.e('Error obteniendo habitación $habitacionId: $e');
      throw Exception('Error al cargar datos de la habitación');
    }
  }
}
