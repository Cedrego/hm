import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final VoidCallback onLogoutPressed;
  final Map<String, dynamic>? userData;
  final bool isAdmin;

  const CustomAppBar({
    super.key,
    required this.scaffoldKey,
    required this.onLogoutPressed,
    required this.userData,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Determinar si se puede retroceder.
    // canPop será falso en la pantalla raíz (MainPage) y verdadero en cualquier otra pantalla que haya sido navegada.
    final bool canGoBack = ModalRoute.of(context)?.canPop ?? false;

    // 2. Definir el widget leading (izquierda) basado en canGoBack.
    Widget leadingWidget;

    if (canGoBack) {
      // Si podemos retroceder, mostramos el botón de flecha.
      leadingWidget = IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          // Navegar hacia atrás en el stack de navegación.
          Navigator.pop(context);
        },
      );
    } else {
      // Si estamos en la raíz (MainPage), mostramos el botón de menú para abrir el Drawer.
      leadingWidget = IconButton(
        icon: const Icon(Icons.menu, color: Colors.black),
        onPressed: () {
          scaffoldKey.currentState?.openDrawer();
        },
      );
    }

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Text(
        'Hostel Mochileros',
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      // 3. Asignar el widget leading condicional.
      leading: leadingWidget, 
      actions: [
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.black),
          onPressed: onLogoutPressed,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}