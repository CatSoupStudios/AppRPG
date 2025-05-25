import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

Future<void> mostrarDialogoSubirNivel(
  BuildContext context, {
  required String nombreInvocador,
  required int nivel,
}) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  final size = MediaQuery.of(context).size;

  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        elevation: 0,
        child: Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.black.withOpacity(0.85)
                : Colors.white.withOpacity(0.9),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Lottie.asset(
                  'assets/animations/confeti.json',
                  fit: BoxFit.cover,
                  repeat: false,
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      nombreInvocador,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                        shadows: [
                          Shadow(
                            color: isDarkMode ? Colors.white38 : Colors.black26,
                            blurRadius: 14,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '¡Subiste a Nivel $nivel!',
                      style: const TextStyle(
                        fontSize: 32,
                        color: Colors.amber,
                        fontWeight: FontWeight.w700,
                        shadows: [
                          Shadow(color: Colors.black45, blurRadius: 12),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 36, vertical: 16),
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Aceptar'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
