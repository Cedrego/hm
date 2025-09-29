import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import '../../widgets/register_form_container.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0XFFFFFFFF),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.h),
          child: Column(
            children: [
              SizedBox(height: 20.h),
              Text(
                'Hostel Mochileros',
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Irish Grover',
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                        
                        RegisterFormContainer(
                          title: 'Iniciar Sesión',
                          fields: [
                            CustomFormField(
                              label: 'Email',
                              hintText: 'Ingrese su Email',
                              keyboardType: TextInputType.emailAddress,
                              controller: emailController,
                              validator: _validateEmail,
                            ),
                            CustomFormField(
                              label: 'Contraseña',
                              hintText: 'Ingrese su contraseña',
                              obscureText: true,
                              controller: passwordController,
                              validator: _validatePassword,
                            ),
                          ],
                        ),
                        SizedBox(height: 30.h),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: double.infinity,
                              constraints: BoxConstraints(maxWidth: 500.h),
                              child: ElevatedButton(
                                onPressed: _onLoginPressed,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: appTheme.blue_gray_900,
                                  foregroundColor: appTheme.gray_100,
                                  padding: EdgeInsets.symmetric(
                                    vertical: 15.h,
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
                                  'Iniciar Sesión',
                                  style: TextStyle(
                                    fontSize: 18.fSize,
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
                                  '¿Aun no tiene una cuenta?',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16.fSize,
                                  ),
                                ),
                                SizedBox(width: 8.h),
                                TextButton(
                                  onPressed: () => _onRegisterPressed(context),
                                  child: Text(
                                    'Registrarse',
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
                        SizedBox(
                          height: MediaQuery.of(context).viewInsets.bottom > 0 
                              ? MediaQuery.of(context).viewInsets.bottom + 20.h
                              : MediaQuery.of(context).size.height * 0.1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Email requerido';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
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
      emailController.clear();
      passwordController.clear();
      print('Login pressed - Email: ${emailController.text}');
    }
  }

  void _onRegisterPressed(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.registrationScreen);
  }
}
