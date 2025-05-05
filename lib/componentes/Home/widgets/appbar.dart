import 'package:flutter/material.dart';

/// Barra de aplicación personalizada que implementa [PreferredSizeWidget]
///
/// Características:
/// - Color de fondo verde claro (#C8EAD2)
/// - Bordes redondeados en la parte inferior
/// - Altura fija de 100px
/// - Contiene título "Inicio" y logo de la aplicación
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity, // Ancho completo de la pantalla
        decoration: const BoxDecoration(
          color: Color(0xFFC8EAD2), // Color de fondo verde claro
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20), // Bordes redondeados abajo
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20), // Padding horizontal
        height: preferredSize.height, // Altura definida por preferredSize
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Espacio entre elementos
          children: [
            // Título "Inicio"
            const Text(
              'Inicio',
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
                color: Color(0xDD000000), // Negro con 87% de opacidad
              ),
            ),
            
            // Logo de la aplicación
            Image.asset(
              'assets/logo/logo_app.png',
              width: 80,
              height: 80,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100); // Altura fija de 100px
}