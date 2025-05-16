import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'rpg_home.dart';

enum ClaseRPG {
  mago,
  paladin,
  barbaro,
  nigromante,
  picaro,
  guardabosques,
  hechicero,
  invocador,
  artificiero,
  bardo,
  draconido,
  brujo,
  asesino,
  cazadorDeAlmas,
}

Map<ClaseRPG, String> claseEmojis = {
  ClaseRPG.mago: "🧙‍♂️ Mago",
  ClaseRPG.paladin: "🛡️ Paladín",
  ClaseRPG.barbaro: "💪 Bárbaro",
  ClaseRPG.nigromante: "💀 Nigromante",
  ClaseRPG.picaro: "🗡️ Pícaro",
  ClaseRPG.guardabosques: "🏹 Guardabosques",
  ClaseRPG.hechicero: "✨ Hechicero",
  ClaseRPG.invocador: "📜 Invocador",
  ClaseRPG.artificiero: "⚙️ Artificiero",
  ClaseRPG.bardo: "🎵 Bardo",
  ClaseRPG.draconido: "🐉 Dracónido",
  ClaseRPG.brujo: "🔮 Brujo",
  ClaseRPG.asesino: "🥷 Asesino",
  ClaseRPG.cazadorDeAlmas: "👁️‍🗨️ Cazador de Almas",
};

class PantallaCreacion extends StatefulWidget {
  const PantallaCreacion({super.key});

  @override
  State<PantallaCreacion> createState() => _PantallaCreacionState();
}

class _PantallaCreacionState extends State<PantallaCreacion>
    with TickerProviderStateMixin {
  final TextEditingController nombreController = TextEditingController();
  ClaseRPG? claseSeleccionada;
  File? imagenPerfil;
  bool datosCargados = false;
  late AnimationController _controller;
  late Animation<double> _fade;
  late AnimationController _avatarController;
  late Animation<double> _avatarScale;

  final List<String> nombresEpicos = [
    "Kael",
    "Vharion",
    "Elira",
    "Draven",
    "Sylthra",
    "Tzarek",
    "Nymeria",
    "Aegis",
    "Thorne",
    "Iskra",
    "Zalthor",
    "Lyra",
    "Oryn",
    "Riven",
    "Maelis",
    "Thalos",
    "Zephira",
    "Noctar"
  ];

  @override
  void initState() {
    super.initState();
    verificarDatosGuardados();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    _avatarController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _avatarScale =
        CurvedAnimation(parent: _avatarController, curve: Curves.easeOutBack);
    _avatarController.forward();
  }

  void generarNombreYClase() {
    final random = Random();
    final nombre = nombresEpicos[random.nextInt(nombresEpicos.length)];
    final clase = ClaseRPG.values[random.nextInt(ClaseRPG.values.length)];
    setState(() {
      nombreController.text = nombre;
      claseSeleccionada = clase;
    });
  }

  Future<void> verificarDatosGuardados() async {
    final prefs = await SharedPreferences.getInstance();
    final nombre = prefs.getString('nombre_invocador');
    final clase = prefs.getString('clase_rpg');
    final imagenPath = prefs.getString('imagen_perfil');

    if (nombre != null && clase != null) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const RPGHome(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    } else {
      setState(() {
        if (imagenPath != null) imagenPerfil = File(imagenPath);
        datosCargados = true;
      });
    }
  }

  Future<void> seleccionarImagen() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imagenPerfil = File(pickedFile.path);
      });
    }
  }

  Future<void> comenzarAventura() async {
    if (nombreController.text.trim().isEmpty || claseSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Completa todos los campos antes de continuar"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nombre_invocador', nombreController.text.trim());
    await prefs.setString('clase_rpg', claseSeleccionada!.name);
    if (imagenPerfil != null) {
      await prefs.setString('imagen_perfil', imagenPerfil!.path);
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const RPGHome(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: datosCargados
          ? FadeTransition(
              opacity: _fade,
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height,
                  ),
                  child: IntrinsicHeight(
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/forest.png'),
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                          colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.5),
                            BlendMode.darken,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 80),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 10),
                            Text(
                              "SOLO LEVELING",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'OptimusPrinceps',
                                color: Colors.amberAccent,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                                shadows: [
                                  Shadow(
                                    blurRadius: 10.0,
                                    color: Colors.amber,
                                    offset: Offset(0, 0),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "Transforma tu vida. Un paso a la vez.",
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 40),

                            // Avatar + Nombre
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ScaleTransition(
                                  scale: _avatarScale,
                                  child: GestureDetector(
                                    onTap: seleccionarImagen,
                                    child: CircleAvatar(
                                      radius: 55,
                                      backgroundColor: Colors.white12,
                                      backgroundImage: imagenPerfil != null
                                          ? FileImage(imagenPerfil!)
                                          : null,
                                      child: imagenPerfil == null
                                          ? const Icon(Icons.add_a_photo,
                                              size: 36, color: Colors.white70)
                                          : null,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: TextField(
                                    controller: nombreController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white10,
                                      labelText: "Nombre del Invocador",
                                      labelStyle: const TextStyle(
                                          color: Colors.white54),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 40),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Elige tu clase:",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.casino,
                                      color: Colors.amber),
                                  onPressed: generarNombreYClase,
                                )
                              ],
                            ),
                            const SizedBox(height: 12),

                            // CLASES CON EFECTO ANIMADO 🔥
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: ClaseRPG.values.map((clase) {
                                final seleccionada = claseSeleccionada == clase;

                                return GestureDetector(
                                  onTap: () {
                                    setState(() => claseSeleccionada = clase);
                                  },
                                  child: TweenAnimationBuilder<double>(
                                    tween: Tween<double>(
                                        begin: 1.0,
                                        end: seleccionada ? 1.05 : 1.0),
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOutBack,
                                    builder: (context, scale, child) {
                                      return Transform.scale(
                                        scale: scale,
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: seleccionada
                                                ? Colors.amber.shade300
                                                : Colors.black.withOpacity(0.3),
                                            borderRadius:
                                                BorderRadius.circular(18),
                                            boxShadow: seleccionada
                                                ? [
                                                    BoxShadow(
                                                      color: Colors.amberAccent
                                                          .withOpacity(0.8),
                                                      blurRadius: 12,
                                                      spreadRadius: 1,
                                                      offset: Offset(0, 0),
                                                    )
                                                  ]
                                                : [],
                                          ),
                                          child: Text(
                                            claseEmojis[clase]!,
                                            style: TextStyle(
                                              color: seleccionada
                                                  ? Colors.black
                                                  : Colors.white70,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 50),
                            ElevatedButton.icon(
                              onPressed: comenzarAventura,
                              icon: const Icon(Icons.auto_fix_high),
                              label: const Text("¡Comenzar Aventura!"),
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
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          : const Center(child: CircularProgressIndicator(color: Colors.amber)),
    );
  }
}
