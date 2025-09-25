import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_form_container.dart';

class RegistrationScreen extends StatelessWidget {
  RegistrationScreen({Key? key}) : super(key: key);

  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController documentController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0XFFFFFFFF),
        appBar: AppBar(
          backgroundColor: Color(0XFFFFFFFF),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Color(0XFF343330)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Registro de Usuario',
            style: TextStyleHelper.instance.title20RegularRoboto
                .copyWith(color: Color(0XFF000000)),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 20.h),
          child: Form(
            key: formKey,
            child: CustomFormContainer(
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
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value!)) {
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
              primaryButtonText: 'Registrarse',
              onPrimaryPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  // Handle registration logic here
                  _clearForm();
                  // Changed: Navigate back to login after successful registration
                  Navigator.pop(context);
                  print('Registration successful');
                }
              },
              secondaryButtonText: 'Iniciar Sesión',
              onSecondaryPressed: () {
                // Changed: Use Navigator.pop to go back to login screen
                Navigator.pop(context);
              },
              descriptiveText: '¿Ya tiene una cuenta?',
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
