import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'rpg_home.dart';
import 'effects/particles_background.dart';
import 'screens/pantalla_seleccion_avatar.dart';
import 'models/clase_rpg.dart'; // Asegura tener esta ruta con ClaseRPG

class PantallaCreacion extends StatefulWidget {
  const PantallaCreacion({super.key});

  @override
  State<PantallaCreacion> createState() => _PantallaCreacionState();
}

class _PantallaCreacionState extends State<PantallaCreacion>
    with TickerProviderStateMixin {
  final TextEditingController nombreController = TextEditingController();
  ClaseRPG? claseSeleccionada;
  bool datosCargados = false;
  late AnimationController _controller;
  late Animation<double> _fade;

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
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  Future<void> verificarDatosGuardados() async {
    final prefs = await SharedPreferences.getInstance();
    final nombre = prefs.getString('nombre_invocador');
    final clase = prefs.getString('clase_rpg');

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
        datosCargados = true;
      });
    }
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

  void mostrarDetallesClase(BuildContext context, ClaseRPG clase) {
    final String emojiNombre = claseEmojis[clase]!;
    final String titulo = emojiNombre.split(" ").sublist(1).join(" ");
    final String emoji = emojiNombre.split(" ").first;
    final String lore = miniLores[clase]!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black.withOpacity(0.87),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (_) {
        return FractionallySizedBox(
          heightFactor: 0.6,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.amberAccent,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  lore,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() => claseSeleccionada = clase);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.check),
                  label: const Text("Elegir esta clase"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
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

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PantallaSeleccionAvatar(claseSeleccionada: claseSeleccionada!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: datosCargados
          ? FadeTransition(
              opacity: _fade,
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/forest.png'),
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    colorFilter: ColorFilter.mode(
                      Colors.black54,
                      BlendMode.darken,
                    ),
                  ),
                ),
                child: Stack(
                  children: [
                    const ParticlesBackground(),
                    Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
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
                                  )
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
                            TextField(
                              controller: nombreController,
                              style: const TextStyle(color: Colors.white),
                              textAlign: TextAlign.start,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white10,
                                labelText: "Nombre del Invocador",
                                labelStyle:
                                    const TextStyle(color: Colors.white54),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
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
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: ClaseRPG.values.map((clase) {
                                final seleccionada = claseSeleccionada == clase;
                                return GestureDetector(
                                  onTap: () =>
                                      mostrarDetallesClase(context, clase),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: seleccionada
                                          ? Colors.amber.shade300
                                          : Colors.black.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(18),
                                      boxShadow: seleccionada
                                          ? [
                                              BoxShadow(
                                                color: Colors.amberAccent
                                                    .withOpacity(0.8),
                                                blurRadius: 12,
                                                spreadRadius: 1,
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
                              }).toList(),
                            ),
                            const SizedBox(height: 50),
                            ElevatedButton.icon(
                              onPressed: comenzarAventura,
                              icon: const Icon(Icons.auto_fix_high),
                              label: const Text("\u00a1Comenzar Aventura!"),
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
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const Center(child: CircularProgressIndicator(color: Colors.amber)),
    );
  }
}
