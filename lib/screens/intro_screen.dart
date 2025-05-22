import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pantalla_creacion.dart';
import '../rpg_home.dart';
import 'selector_inicial_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..forward();

    _scaleAnimation = Tween<double>(begin: 1.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Timer para cambiar de pantalla después de la animación
    Future.delayed(const Duration(seconds: 4), () async {
      final prefs = await SharedPreferences.getInstance();
      final selectorCompletado = prefs.getBool('selector_completado') ?? false;
      final nombre = prefs.getString('nombre_invocador');

      if (selectorCompletado && nombre != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RPGHome()),
        );
      } else if (selectorCompletado) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PantallaCreacion()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 600),
            pageBuilder: (_, __, ___) => const SelectorInicialScreen(),
            transitionsBuilder: (_, animation, __, child) => FadeTransition(
              opacity: animation,
              child: child,
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        // 👈 Esto centra el contenido
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: SizedBox.expand(
                // 👈 Esto asegura que ocupe toda la pantalla
                child: Image.asset(
                  'assets/solo_leveling_intro.png', // <-- asegúrate de usar esta
                  fit: BoxFit
                      .cover, // 👈 Esto hace que la imagen se estire sin deformarse
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
