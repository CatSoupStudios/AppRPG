import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import '../data/frases_por_avatar.dart';

import '../rpg_home.dart';
import '../models/clase_rpg.dart';
import '../effects/particles_background.dart';

class PantallaSeleccionAvatar extends StatefulWidget {
  final ClaseRPG claseSeleccionada;

  const PantallaSeleccionAvatar({super.key, required this.claseSeleccionada});

  @override
  State<PantallaSeleccionAvatar> createState() =>
      _PantallaSeleccionAvatarState();
}

class _PantallaSeleccionAvatarState extends State<PantallaSeleccionAvatar> {
  int _indiceSeleccionado = 0;

  late final PageController _pageController;
  late final List<String> _avatarPaths;
  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);

    final clase = widget.claseSeleccionada.name;

    _avatarPaths = List.generate(
      5,
      (i) => 'assets/avatars/$clase/$clase-${i + 1}.png',
    );
  }

  Future<void> _reproducirSonidoEspada() async {
    await _player.play(AssetSource('sounds/sword-tap.mp3'));
  }

  Future<void> guardarAvatarYContinuar() async {
    final prefs = await SharedPreferences.getInstance();

    final clase = widget.claseSeleccionada.name;
    final path = _avatarPaths[_indiceSeleccionado];
    final nombreArchivo = path.split('/').last; // Extrae 'mago-3.png'

    await prefs.setString('clase', clase);
    await prefs.setString('avatar', nombreArchivo);

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const RPGHome(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clase = widget.claseSeleccionada.name;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const ParticlesBackground(),
          Positioned(
            top: 40,
            left: 16,
            child: GestureDetector(
              onTap: () async {
                await _reproducirSonidoEspada();
                Navigator.pop(context);
              },
              behavior: HitTestBehavior.translucent,
              child: Container(
                padding: const EdgeInsets.all(16),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.yellowAccent,
                  size: 28,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 64),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _avatarPaths.length,
                    physics: const ClampingScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() => _indiceSeleccionado = index);
                    },
                    itemBuilder: (context, index) {
                      final path = _avatarPaths[index];
                      final descripcion = frasesPorClase[clase]?[index] ?? "";
                      final esSeleccionado = index == _indiceSeleccionado;

                      return Transform.scale(
                        scale: esSeleccionado ? 1.0 : 0.92,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: Image.asset(path, fit: BoxFit.cover),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                descripcion,
                                style: const TextStyle(
                                  color: Colors.amberAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: guardarAvatarYContinuar,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text("Confirmar Avatar"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 36, vertical: 14),
                    textStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
