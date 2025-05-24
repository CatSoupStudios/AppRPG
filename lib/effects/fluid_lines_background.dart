import 'package:flutter/material.dart';
import 'package:animated_background/animated_background.dart';

class FluidLinesBackground extends StatefulWidget {
  final Widget? child; // Puedes poner contenido encima si quieres
  const FluidLinesBackground({super.key, this.child});

  @override
  State<FluidLinesBackground> createState() => _FluidLinesBackgroundState();
}

class _FluidLinesBackgroundState extends State<FluidLinesBackground>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      behaviour: BubblesBehaviour(
        options: BubbleOptions(
          bubbleCount: 18, // Más burbujas, para fondo dinámico
          minTargetRadius: 12, // Burbujas pequeñas
          maxTargetRadius: 26, // ... y no tan grandes
          // Puedes agregar más opciones aquí si la versión lo permite
        ),
      ),
      vsync: this,
      child: widget.child ?? const SizedBox(),
    );
  }
}
