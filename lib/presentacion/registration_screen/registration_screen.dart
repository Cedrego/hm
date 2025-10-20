import 'dart:convert';
import 'dart:io'; // Se mantiene, aunque ya no se usa para File en la selección de imágenes
import 'dart:typed_data'; // Nuevo: Necesario para Uint8List
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hm/core/logger.dart';
import '../../core/app_export.dart';
import '../../widgets/register_form_container.dart';
import '../../core/firebase_service.dart';
import '../../core/auth_service.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController documentController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController contactController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final FirebaseService _firebaseService = FirebaseService.instance;
  bool _isLoading = false;

  // Imagen
  final ImagePicker _picker = ImagePicker();
  Uint8List? _imagenBytes; // 🎯 Nuevo: Almacena los bytes de la imagen
  String? _imagenBase64;

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    documentController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    contactController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarImagen() async {
    try {
      AppLogger.i('📷 Seleccionando imagen...');

      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        // 🎯 Corrección: Leer los bytes directamente del XFile.
        // Esto es compatible con Web, Desktop, iOS y Android.
        final bytes = await pickedFile.readAsBytes(); 
        
        setState(() {
          _imagenBytes = bytes;
          _imagenBase64 = base64Encode(bytes);
        });

        AppLogger.d('✅ Imagen seleccionada: ${bytes.length} bytes');
      } else {
        AppLogger.i('⚠️ No se seleccionó ninguna imagen');
      }
    } catch (e) {
      AppLogger.e('❌ Error al seleccionar imagen: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al seleccionar imagen: ${e.toString().replaceAll('Unsupported operation: _Namespace', 'Operación no soportada en esta plataforma o permisos insuficientes.')}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0XFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0XFF343330)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Registro de Usuario',
          style: TextStyleHelper.instance.title20RegularRoboto.copyWith(
            color: Color(0XFF000000),
          ),
        ),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 20.h),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                RegisterFormContainer(
                  title: 'Registrarse',
                  fields: [
                    CustomFormField(
                      label: 'Email',
                      hintText: 'Ingrese un Email valido',
                      keyboardType: TextInputType.emailAddress,
                      controller: emailController,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Email es requerido';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value!)) {
                          return 'Ingrese un email válido';
                        }
                        return null;
                      },
                    ),
                    CustomFormField(
                      label: 'Nombre',
                      hintText: 'Ingrese su nombre completo',
                      controller: nameController,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Nombre es requerido';
                        }
                        return null;
                      },
                    ),
                    CustomFormField(
                      label: 'Documento de Identidad',
                      hintText: 'Ingrese su documento de identidad',
                      controller: documentController,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Documento de identidad es requerido';
                        }
                        return null;
                      },
                    ),
                    CustomFormField(
                      label: 'Contraseña',
                      hintText: 'Ingrese su contraseña',
                      obscureText: true,
                      controller: passwordController,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Contraseña es requerida';
                        }
                        if ((value?.length ?? 0) < 6) {
                          return 'La contraseña debe tener al menos 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    CustomFormField(
                      label: 'Confirmar Contraseña',
                      hintText: 'Ingrese su contraseña nuevamente',
                      obscureText: true,
                      controller: confirmPasswordController,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Confirmar contraseña es requerido';
                        }
                        if (value != passwordController.text) {
                          return 'Las contraseñas no coinciden';
                        }
                        return null;
                      },
                    ),
                    CustomFormField(
                      label: 'Contacto',
                      hintText: 'Ingrese un numero para contactarlo',
                      keyboardType: TextInputType.phone,
                      controller: contactController,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Contacto es requerido';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                // Widget para seleccionar imagen + vista previa
                Padding(
                  padding: EdgeInsets.only(top: 12.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Imagen (opcional)',
                        style: TextStyle(
                          fontSize: 14.fSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _seleccionarImagen,
                            // 🎯 Uso de _imagenBytes para la vista previa
                            child: _imagenBytes != null 
                                ? CircleAvatar(
                                    radius: 28.h,
                                    // 🎯 Uso de MemoryImage para bytes en memoria
                                    backgroundImage: MemoryImage(_imagenBytes!), 
                                  )
                                : CircleAvatar(
                                    radius: 28.h,
                                    child: Icon(Icons.photo, size: 28.h),
                                  ),
                          ),
                          SizedBox(width: 12.h),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _seleccionarImagen,
                              icon: Icon(Icons.upload_file),
                              label: Text('Seleccionar imagen'),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30.h),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 500.h,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () => _onRegistroPressed(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appTheme.blueGray900,
                          foregroundColor: appTheme.gray100,
                          padding: EdgeInsets.symmetric(
                            vertical: 8.h,
                            horizontal: 30.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.h),
                            side: BorderSide(
                              color: appTheme.blueGray900,
                              width: 1.h,
                            ),
                          ),
                          elevation: 0,
                          disabledBackgroundColor: Colors.grey,
                        ),
                        child: _isLoading
                            ? SizedBox(
                                height: 20.h,
                                width: 20.h,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                'Registrarse',
                                style: TextStyle(
                                  fontSize: 20.fSize,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¿Ya tiene una cuenta?',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16.fSize,
                          ),
                        ),
                        SizedBox(width: 8.h),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Iniciar Sesión',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.fSize,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onRegistroPressed(BuildContext context) async {
    AppLogger.i('🔵 BOTÓN DE REGISTRO PRESIONADO');

    // Validar el formulario
    if (!(formKey.currentState?.validate() ?? false)) {
      AppLogger.e('❌ Validación del formulario falló');
      return;
    }

    AppLogger.i('✅ Validación del formulario exitosa');

    // Mostrar indicador de carga
    setState(() {
      _isLoading = true;
    });

    AppLogger.i('⏳ Indicador de carga activado');

    try {
      final datos = {
        'email': emailController.text.trim(),
        'nombre': nameController.text.trim(),
        'documento': documentController.text.trim(),
        'password': passwordController.text,
        'contacto': contactController.text.trim(),
        'imagen': _imagenBase64,
        'rol': 'huesped',
      };

      AppLogger.i('📦 Datos preparados para enviar:');
      AppLogger.d('   Email: ${datos['email']}');
      AppLogger.d('   Nombre: ${datos['nombre']}');
      AppLogger.d('   Tiene imagen: ${_imagenBase64 != null ? "SÍ" : "NO"}');

      AppLogger.i('🔥 Llamando a FirebaseService.registro()...');
      final response = await _firebaseService.registro(datos);

      AppLogger.i('📥 Respuesta recibida: $response');

      if (response['success'] == true) {
        AppLogger.success('✅ Registro exitoso!');

        if (response['usuario'] != null) {
          await AuthService.saveUserSession(response['usuario']);
          AppLogger.success('✅ Sesión guardada automáticamente');
        }

        _clearForm();

        if (mounted) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response['message'] ?? 'Usuario registrado exitosamente',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          AppLogger.i('✅ SnackBar de éxito mostrado');

          await Future.delayed(const Duration(seconds: 1));
          if (mounted) {
            AppLogger.i('🏠 Navegando a MainPage (ya logueado)');
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // ignore: use_build_context_synchronously
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.mainPage,
                (route) => false,
              );
            });
          }
        }
      } else {
        AppLogger.e('⚠️ Registro falló: ${response['message']}');
        throw Exception(response['message'] ?? 'Error desconocido');
      }
    } catch (e) {
      AppLogger.e('❌ ERROR EN REGISTRO: $e');

      if (mounted) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );

        AppLogger.i('❌ SnackBar de error mostrado');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        AppLogger.i('⏳ Indicador de carga desactivado');
      }
    }
  }

  void _clearForm() {
    emailController.clear();
    nameController.clear();
    documentController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    contactController.clear();

    // Limpiar imagen
    setState(() {
      _imagenBytes = null; // 🎯 Limpieza de la nueva variable
      _imagenBase64 = null;
    });

    AppLogger.i('🧹 Formulario limpiado');
  }
}