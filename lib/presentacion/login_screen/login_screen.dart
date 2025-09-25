import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_form_container.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0XFFFFFFFF),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 40.h),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CustomFormContainer(
                  title: 'Iniciar Sesión',
                  fields: [
                    CustomFormField(
                      label: 'Email',
                      hintText: 'Ingrese su Email',
                      keyboardType: TextInputType.emailAddress,
                      inputMargin: EdgeInsets.only(left: 4.h),
                      controller: emailController,
                      validator: _validateEmail,
                    ),
                    CustomFormField(
                      label: 'Contraseña',
                      hintText: 'Ingrese su contraseña',
                      obscureText: true,
                      inputMargin: EdgeInsets.only(left: 4.h),
                      topMargin: 12.h,
                      controller: passwordController,
                      validator: _validatePassword,
                    ),
                  ],
                  primaryButtonText: 'Iniciar Sesión',
                  onPrimaryPressed: _onLoginPressed,
                  secondaryButtonText: 'Registrarse',
                  onSecondaryPressed: () => _onRegisterPressed(context),
                  descriptiveText: '¿Aun no tiene una cuenta? Cree una',
                  isFullWidthButtons: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Email requerido';
    }
    if (!(value?.contains('@') ?? false)) {
      return 'Ingrese un email válido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Contraseña requerida';
    }
    if ((value?.length ?? 0) < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  void _onLoginPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      // Clear form fields after successful validation
      emailController.clear();
      passwordController.clear();

      // Handle login logic here
      print('Login pressed - Email: ${emailController.text}');
    }
  }

  void _onRegisterPressed(BuildContext context) {
    // Changed: Use Navigator.pushNamed for proper screen navigation
    Navigator.pushNamed(context, AppRoutes.registrationScreen);
  }
}
