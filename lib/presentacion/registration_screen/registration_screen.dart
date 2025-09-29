import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Agregar este import

import '../../core/app_export.dart';
import '../../widgets/register_form_container.dart';

class RegistrationScreen extends StatelessWidget {
  RegistrationScreen({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController documentController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
          statusBarIconBrightness: Brightness.dark, // Iconos oscuros
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
                SizedBox(height: 30.h),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 500.h,
                      child: ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState?.validate() ?? false) {
                            _clearForm();
                            Navigator.pop(context);
                            print('Registration successful');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appTheme.blue_gray_900,
                          foregroundColor: appTheme.gray_100,
                          padding: EdgeInsets.symmetric(
                            vertical: 8.h,
                            horizontal: 30.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.h),
                            side: BorderSide(
                              color: appTheme.blue_gray_900,
                              width: 1.h,
                            ),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
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

  void _clearForm() {
    emailController.clear();
    nameController.clear();
    documentController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    contactController.clear();
  }
}
