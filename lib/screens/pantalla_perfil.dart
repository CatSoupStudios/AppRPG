import 'package:flutter/material.dart';
import '../rpg_home.dart';
import '../utils/colors.dart';

class PantallaPerfil extends StatelessWidget {
  const PantallaPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // 🔙 Flechita para regresar a RPGHome
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.amber),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const RPGHome(),
                      transitionsBuilder: (_, animation, __, child) =>
                          FadeTransition(opacity: animation, child: child),
                      transitionDuration: const Duration(milliseconds: 400),
                    ),
                  );
                },
              ),
            ),

            // 🧍 Contenido del perfil
            Center(
              child: Text(
                "Pantalla de Perfil",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? AppColors.lightText : AppColors.darkText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
