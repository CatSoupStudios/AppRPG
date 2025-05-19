import 'dart:math';
import 'package:flutter/material.dart';

class ParticlesBackground extends StatefulWidget {
  const ParticlesBackground({super.key});

  @override
  _ParticlesBackgroundState createState() => _ParticlesBackgroundState();
}

class _ParticlesBackgroundState extends State<ParticlesBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();
  final int numParticles = 25;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _particles = List.generate(numParticles, (_) => _randomParticle());
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..addListener(() {
        setState(() {
          for (var p in _particles) {
            p.update();
          }
        });
      });
    _controller.repeat();
  }

  _Particle _randomParticle() {
    return _Particle(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      dx: (_random.nextDouble() - 0.5) * 0.0015,
      dy: (_random.nextDouble() - 0.5) * 0.0015,
      size: 1.2 + _random.nextDouble() * 1.5,
      opacity: 0.85 + _random.nextDouble() * 0.15,
    );
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _ParticlesPainter(_particles),
        child: Container(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _Particle {
  double x, y, dx, dy, size, opacity;

  _Particle({
    required this.x,
    required this.y,
    required this.dx,
    required this.dy,
    required this.size,
    required this.opacity,
  });

  void update() {
    x += dx;
    y += dy;

    if (x < -0.1 || x > 1.1) dx *= -1;
    if (y < -0.1 || y > 1.1) dy *= -1;
  }
}

class _ParticlesPainter extends CustomPainter {
  final List<_Particle> particles;

  _ParticlesPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (var p in particles) {
      paint.color =
          const Color(0xFFFFD966).withOpacity(p.opacity); // ámbar neón
      paint.maskFilter = MaskFilter.blur(BlurStyle.normal, 1.5); // blur sutil ✨
      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
