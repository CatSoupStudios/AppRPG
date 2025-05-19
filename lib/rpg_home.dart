import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/clase_rpg.dart';
import 'data/stats_base.dart';
import 'screens/pantalla_fuerza.dart';
import 'screens/pantalla_inteligencia.dart';
import 'screens/pantalla_defensa.dart';
import 'screens/pantalla_agilidad.dart';
import 'screens/pantalla_vitalidad.dart';
import 'screens/pantalla_suerte.dart';
import 'screens/pantalla_carisma.dart';
import 'utils/nivel_general.dart';
import 'screens/pantalla_settings.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'utils/colors.dart';
import 'screens/pantalla_calendario.dart';

class RPGHome extends StatefulWidget {
  const RPGHome({super.key});

  @override
  State<RPGHome> createState() => _RPGHomeState();
}

class _RPGHomeState extends State<RPGHome> with WidgetsBindingObserver {
  String? nombre;
  ClaseRPG? clase;
  File? imagenPerfil;
  Map<String, int> stats = {};
  int nivelGeneral = 0;

  final Map<String, String> statEmojis = {
    'fuerza': '💪',
    'inteligencia': '🧠',
    'defensa': '🛡️',
    'agilidad': '⚡',
    'vitalidad': '❤️',
    'suerte': '🍀',
    'carisma': '😎',
  };

  final List<String> frasesDiarias = [
    "🌀 Hoy eres más fuerte que ayer.",
    "🔥 El fuego interior nunca se apaga.",
    "⚡ El cambio es inevitable, el crecimiento es opcional.",
    "🛡️ Protege tu energía, no cualquiera la merece.",
    "🎯 Apunta a algo más alto que el miedo.",
    "📚 Cada día es un capítulo nuevo.",
    "💥 Nadie recuerda al que no arriesgó.",
    "🌙 Descansa, pero no te detengas.",
    "🧭 Pierde el rumbo para encontrarte.",
    "🏔️ Lo difícil es lo que vale la pena.",
    "🚀 Las excusas no te llevan a ningún lado.",
    "💀 El miedo también sangra.",
    "👁️ El que observa, entiende.",
    "🕯️ Si no hay luz, sé la chispa.",
    "💣 Explota tus límites.",
    "🌱 Evoluciona o repite.",
    "🧘‍♂️ Calma no es debilidad.",
    "🗡️ Sé firme, aunque tiemble la voz.",
    "🎭 Quítate la máscara. Sé tú.",
    "🪞 Tu reflejo también entrena.",
    "🚪Cierra puertas que ya no llevan a nada.",
    "🧠 La mente también se entrena.",
    "🌀 El caos también puede guiar.",
    "🏹 No fallaste, solo estás cargando el arco.",
    "💫 Agradece incluso lo que dolió.",
    "🌌 Eres más que tu pasado.",
    "🪓 Corta lo que te frena.",
    "📖 Escribe tu propia leyenda.",
    "🎮 El control está en tus manos.",
    "⏳ Aún hay tiempo. Hazlo épico."
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    cargarDatos();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      cargarDatos();
    }
  }

  Future<void> cargarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    final nombreGuardado = prefs.getString('nombre_invocador');
    final claseGuardada = prefs.getString('clase_rpg');
    final imagenPath = prefs.getString('imagen_perfil');

    ClaseRPG? claseSeleccionada;
    if (claseGuardada != null) {
      try {
        claseSeleccionada =
            ClaseRPG.values.firstWhere((c) => c.name == claseGuardada);
      } catch (e) {
        debugPrint('Clase no reconocida: $claseGuardada');
        claseSeleccionada = ClaseRPG.mago;
      }
    }

    final totalNivel = await obtenerNivelGeneral();

    setState(() {
      nombre = nombreGuardado;
      clase = claseSeleccionada;
      imagenPerfil = imagenPath != null ? File(imagenPath) : null;
      stats = clase != null ? statsPorClase[clase!]! : {};
      nivelGeneral = totalNivel;
    });
  }

  void abrirPantallaStat(String stat) {
    final lowerStat = stat.toLowerCase();
    if (lowerStat == 'fuerza') {
      Navigator.push(
              context, MaterialPageRoute(builder: (_) => PantallaFuerza()))
          .then((_) => cargarDatos());
    } else if (lowerStat == 'inteligencia') {
      Navigator.push(context,
              MaterialPageRoute(builder: (_) => PantallaInteligencia()))
          .then((_) => cargarDatos());
    } else if (lowerStat == 'defensa') {
      Navigator.push(
              context, MaterialPageRoute(builder: (_) => PantallaDefensa()))
          .then((_) => cargarDatos());
    } else if (lowerStat == 'agilidad') {
      Navigator.push(
              context, MaterialPageRoute(builder: (_) => PantallaAgilidad()))
          .then((_) => cargarDatos());
    } else if (lowerStat == 'vitalidad') {
      Navigator.push(
              context, MaterialPageRoute(builder: (_) => PantallaVitalidad()))
          .then((_) => cargarDatos());
    } else if (lowerStat == 'suerte') {
      Navigator.push(
              context, MaterialPageRoute(builder: (_) => PantallaSuerte()))
          .then((_) => cargarDatos());
    } else if (lowerStat == 'carisma') {
      Navigator.push(
              context, MaterialPageRoute(builder: (_) => PantallaCarisma()))
          .then((_) => cargarDatos());
    }
  }

  @override
  Widget build(BuildContext context) {
    final fraseDelDia =
        frasesDiarias[DateTime.now().day % frasesDiarias.length];
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    final frasesPorStat = {
      'fuerza': "Tu cuerpo, tu primer imperio.",
      'inteligencia': "Los sabios también luchan.",
      'defensa': "No todo lo que aguanta es débil.",
      'vitalidad': "Descansa. Renace. Sigue.",
      'suerte': "Hay quienes llaman azar a la intuición.",
      'carisma': "Presencia que no se puede enseñar.",
      'agilidad': "Moverse es decidir antes que el mundo.",
    };

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: imagenPerfil != null
                          ? Image.file(imagenPerfil!,
                              width: 72, height: 72, fit: BoxFit.cover)
                          : Container(
                              width: 72,
                              height: 72,
                              color: Colors.white24,
                              child: const Icon(Icons.person,
                                  size: 36, color: Colors.white70),
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  nombre != null
                                      ? '${nombre!.toUpperCase()} (lvl $nivelGeneral)'
                                      : "INVOCADOR",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? AppColors.lightBackground
                                        : AppColors.lightText,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.settings,
                                    color: isDarkMode
                                        ? AppColors.darkText
                                        : AppColors.lightText),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const PantallaSettings()),
                                  );
                                },
                              ),
                            ],
                          ),
                          if (clase != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 1),
                              child: Text(
                                claseEmojis[clase]!,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDarkMode
                                      ? AppColors.darkText
                                      : AppColors.lightText,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "📊 Tus Stats",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode
                          ? AppColors.lightBackground
                          : AppColors.lightText,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_month_rounded,
                        color: Colors.amber),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const PantallaCalendario(),
                      );
                    },
                  )
                ],
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: stats.entries.map((entry) {
                  final keyLower = entry.key.toLowerCase();
                  final emoji = statEmojis[keyLower] ?? '🔹';
                  final fraseStat =
                      frasesPorStat[keyLower] ?? "Stat desbloqueado.";

                  return GestureDetector(
                    onTap: () => abrirPantallaStat(entry.key),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.42,
                      constraints: const BoxConstraints(minHeight: 170),
                      padding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 14),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.white.withOpacity(0.03)
                            : Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(emoji, style: const TextStyle(fontSize: 36)),
                          const SizedBox(height: 10),
                          Text(
                            entry.key.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            fraseStat,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color:
                                  isDarkMode ? Colors.white54 : Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),
              Text(
                fraseDelDia,
                style: TextStyle(
                  color: isDarkMode
                      ? AppColors.darkSecondaryText
                      : AppColors.lightSecondaryText,
                  fontStyle: FontStyle.italic,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
