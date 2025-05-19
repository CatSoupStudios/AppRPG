import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'rpg_home.dart';
import './effects/particles_background.dart';

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

Map<ClaseRPG, String> miniLores = {
  ClaseRPG.mago:
      "Nacido bajo el eclipse rojo, el mago no aprendió magia... la recordó. Sus manos canalizan el conocimiento de civilizaciones extintas. En cada conjuro resuena un eco de los dioses olvidados. Su misión: desatar el potencial dormido en el universo.",
  ClaseRPG.paladin:
      "Forjado en la Orden de la Luz Celeste, el paladín fue entrenado no solo para luchar, sino para resistir. Su espada es justicia, y su armadura lleva los juramentos de generaciones pasadas. Cuando un paladín cae, se dice que una estrella se apaga.",
  ClaseRPG.barbaro:
      "Crecido entre montañas que nunca conocieron la paz, el bárbaro aprendió que la fuerza es lenguaje, y la furia, legado. Desprecia el oro, la fama y los templos: su alma arde solo por el rugido de la batalla.",
  ClaseRPG.nigromante:
      "Desterrado de la Academia de Arcanos por estudiar la vida tras la muerte, el nigromante cruzó el velo... y regresó. No invoca monstruos, sino memorias encarnadas. Cada esqueleto en su ejército fue alguna vez un traidor, un amante o un rey.",
  ClaseRPG.picaro:
      "Criado en las sombras de los callejones sin nombre, el pícaro aprendió que el mundo pertenece a quien se atreve a tomarlo. Ríe mientras roba, y mata mientras sonríe. En su mundo, la daga es más honesta que la palabra.",
  ClaseRPG.guardabosques:
      "Último de su clan, el guardabosques juró proteger las fronteras donde la civilización muere y la naturaleza comienza a hablar. Sus flechas no fallan, porque no apunta con los ojos... sino con la voluntad del bosque.",
  ClaseRPG.hechicero:
      "Bendecido —o maldito— con sangre celestial, el hechicero no aprendió magia, la heredó. Cada emoción desata un torbellino de poder que ni él mismo comprende. Es un milagro ambulante... o una catástrofe esperando pasar.",
  ClaseRPG.invocador:
      "En lo profundo de las catacumbas, el invocador firmó pactos con seres que no pueden ser nombrados. No lucha con armas, sino con ideas vivas. Cada criatura que llama es una parte de sí mismo... o algo que lo observa desde dentro.",
  ClaseRPG.artificiero:
      "De los escombros del imperio mecánico, surgió el artificiero: mitad herrero, mitad genio. Transforma la chatarra en maravillas, y el silencio en explosión. Donde otros ven ruinas, él ve posibilidades.",
  ClaseRPG.bardo:
      "Heredero de las canciones prohibidas, el bardo canta verdades que los reyes quieren olvidar. Sus versos inspiran ejércitos... o destruyen imperios. No es solo un artista: es un arma poética de precisión emocional.",
  ClaseRPG.draconido:
      "Hijo de una era olvidada, el dracónido lleva el fuego en la sangre y la eternidad en los ojos. Cada paso suyo hace temblar la tierra. Cuando despierta su furia ancestral, ni los cielos están a salvo.",
  ClaseRPG.brujo:
      "El brujo no reza... negocia. Hizo un trato con una entidad que habita en los márgenes de la realidad. A cambio de poder, entregó su nombre verdadero. Desde entonces, cada hechizo que lanza es una deuda pendiente.",
  ClaseRPG.asesino:
      "Nadie lo vio nacer. Nadie lo verá morir. El asesino es una idea más que un ser: el susurro antes del grito. Entrenado por una secta que se esconde entre los sueños, su misión nunca falla. Porque ya estás muerto antes de saberlo.",
  ClaseRPG.cazadorDeAlmas:
      "Desde el abismo entre mundos, el cazador de almas camina con un propósito: rastrear entidades que escaparon del juicio. No sirve a la vida ni a la muerte, sino al equilibrio. Su mirada atraviesa la carne... y revela lo que realmente eres.",
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
          ));
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
                          const ParticlesBackground(), // ✨ Encima del fondo, debajo del contenido
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 80),
                            child: Column(
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
                                          blurRadius: 10.0, color: Colors.amber)
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
                                                  size: 36,
                                                  color: Colors.white70)
                                              : null,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: TextField(
                                        controller: nombreController,
                                        style: const TextStyle(
                                            color: Colors.white),
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white10,
                                          labelText: "Nombre del Invocador",
                                          labelStyle: const TextStyle(
                                              color: Colors.white54),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 40),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: ClaseRPG.values.map((clase) {
                                    final seleccionada =
                                        claseSeleccionada == clase;
                                    return GestureDetector(
                                      onTap: () =>
                                          mostrarDetallesClase(context, clase),
                                      child: TweenAnimationBuilder<double>(
                                        tween: Tween<double>(
                                          begin: 1.0,
                                          end: seleccionada ? 1.05 : 1.0,
                                        ),
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeOutBack,
                                        builder: (context, scale, child) {
                                          return Transform.scale(
                                            scale: scale,
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 300),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 14,
                                                      vertical: 10),
                                              decoration: BoxDecoration(
                                                color: seleccionada
                                                    ? Colors.amber.shade300
                                                    : Colors.black
                                                        .withOpacity(0.3),
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                                boxShadow: seleccionada
                                                    ? [
                                                        BoxShadow(
                                                          color: Colors
                                                              .amberAccent
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
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
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
