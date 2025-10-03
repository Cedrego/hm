import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import '../../widgets/register_form_container.dart';
import '../../core/api_service.dart';

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
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController contactController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Imagen
  final ImagePicker _picker = ImagePicker();
  File? _imagenFile;
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
      print('📷 Seleccionando imagen...'); // DEBUG
      
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final bytes = await File(pickedFile.path).readAsBytes();
        setState(() {
          _imagenFile = File(pickedFile.path);
          _imagenBase64 = base64Encode(bytes);
        });
        
        print('✅ Imagen seleccionada: ${bytes.length} bytes'); // DEBUG
      } else {
        print('⚠️ No se seleccionó ninguna imagen'); // DEBUG
      }
    } catch (e) {
      print('❌ Error al seleccionar imagen: $e'); // DEBUG
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: $e'),
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
                            child: _imagenFile != null
                                ? CircleAvatar(
                                    radius: 28.h,
                                    backgroundImage: FileImage(_imagenFile!),
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
                        onPressed: _isLoading ? null : () => _onRegistroPressed(context),
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
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
    print('🔵 BOTÓN DE REGISTRO PRESIONADO'); // DEBUG
    
    // Validar el formulario
    if (!(formKey.currentState?.validate() ?? false)) {
      print('❌ Validación del formulario falló'); // DEBUG
      return;
    }
    
    print('✅ Validación del formulario exitosa'); // DEBUG

    // Mostrar indicador de carga
    setState(() {
      _isLoading = true;
    });
    
    print('⏳ Indicador de carga activado'); // DEBUG

    try {
      // Preparar datos para enviar, incluye la imagen base64 si existe
      final datos = {
        'email': emailController.text.trim(),
        'nombre': nameController.text.trim(),
        'documento': documentController.text.trim(),
        'password': passwordController.text,
        'contacto': contactController.text.trim(),
        'imagen': _imagenBase64 ?? 'vacio', // aquí se envía la imagen
      };

      print('📦 Datos preparados para enviar:'); // DEBUG
      print('   Email: ${datos['email']}'); // DEBUG
      print('   Nombre: ${datos['nombre']}'); // DEBUG
      print('   Tiene imagen: ${_imagenBase64 != null ? "SÍ" : "NO"}'); // DEBUG

      // Llamar al API de registro
      print('🌐 Llamando a ApiService.registro()...'); // DEBUG
      final response = await ApiService.registro(datos);
      
      print('📥 Respuesta recibida: $response'); // DEBUG

      // Verificar que el registro fue exitoso
      if (response['success'] == true) {
        print('✅ Registro exitoso!'); // DEBUG
        
        // Limpiar formulario
        _clearForm();

        // Mostrar mensaje de éxito
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Usuario registrado exitosamente'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          print('✅ SnackBar de éxito mostrado'); // DEBUG

          // Volver a la pantalla de login después de un breve delay
          await Future.delayed(Duration(seconds: 1));
          if (mounted) {
            print('⬅️ Navegando de vuelta al login'); // DEBUG
            Navigator.pop(context);
          }
        }
      } else {
        print('⚠️ Registro falló: ${response['message']}'); // DEBUG
        throw Exception(response['message'] ?? 'Error desconocido');
      }
    } catch (e) {
      print('❌ ERROR EN REGISTRO: $e'); // DEBUG
      
      // Mostrar error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        
        print('❌ SnackBar de error mostrado'); // DEBUG
      }
    } finally {
      // Ocultar indicador de carga
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        print('⏳ Indicador de carga desactivado'); // DEBUG
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
      _imagenFile = null;
      _imagenBase64 = null;
    });
    
    print('🧹 Formulario limpiado'); // DEBUG
  }
}