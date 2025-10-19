import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import '../../core/firebase_service.dart';
import '../../widgets/register_form_container.dart';
import '../../core/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final firebaseService = FirebaseService.instance;
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

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
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1,
                        ),
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
                                onPressed: _isLoading
                                    ? null
                                    : () => _onLoginPressed(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: appTheme.blueGray900,
                                  foregroundColor: appTheme.gray100,
                                  padding: EdgeInsets.symmetric(
                                    vertical: 15.h,
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
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : Text(
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

  Future<void> _onLoginPressed(BuildContext context) async {
    // Validar el formulario
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    // Mostrar indicador de carga
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await firebaseService.login(
        emailController.text.trim(),
        passwordController.text,
      );

      // Verificar que la respuesta sea exitosa
      if (response['success'] == true && response['usuario'] != null) {
        final userData = response['usuario'];

        // Guardar sesión del usuario
        await AuthService.saveUserSession(userData);

        // Mostrar mensaje de éxito
        if (mounted) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('¡Bienvenido ${userData['nombre']}!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          // Navegar a la página principal
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
    } catch (e) {
      // Mostrar error
      if (mounted) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      // Ocultar indicador de carga
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onRegisterPressed(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.registrationScreen);
  }
}
