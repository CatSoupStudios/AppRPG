import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'models/clase_rpg.dart';
import 'data/stats_base.dart';
import 'screens/pantalla_fuerza.dart';
import 'screens/pantalla_inteligencia.dart';
import 'screens/pantalla_defensa.dart';
import 'screens/pantalla_agilidad.dart';
import 'screens/pantalla_vitalidad.dart';
import 'screens/pantalla_suerte.dart';
import 'screens/pantalla_carisma.dart';
import 'screens/pantalla_settings.dart';
import 'screens/pantalla_calendario.dart';
import 'utils/nivel_general.dart';
import 'utils/xp_diaria.dart';
import 'utils/colors.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import './data/frases_diarias.dart';
import 'screens/pantalla_perfil.dart';

class RPGHome extends StatefulWidget {
  const RPGHome({super.key});

  @override
  State<RPGHome> createState() => _RPGHomeState();
}

class _RPGHomeState extends State<RPGHome> with WidgetsBindingObserver {
  String? nombre;
  ClaseRPG? clase;
  String? avatarSeleccionadoPath;
  Map<String, int> stats = {};
  int nivelGeneral = 0;
  int rachaActual = 0;

  final Map<String, String> statEmojis = {
    'fuerza': '💪',
    'inteligencia': '🧠',
    'defensa': '🛡️',
    'agilidad': '⚡',
    'vitalidad': '❤️',
    'suerte': '🍀',
    'carisma': '😎',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    actualizarXPGeneralSiEsNuevoDia().then((_) => cargarDatos());
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

  Future<void> actualizarXPGeneralSiEsNuevoDia() async {
    final prefs = await SharedPreferences.getInstance();
    final hoy = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final ultimaFecha = prefs.getString('ultima_fecha') ?? '';

    if (hoy != ultimaFecha) {
      await procesarXpDelDiaAnteriorYAplicar();
      await prefs.setString('ultima_fecha', hoy);
    }
  }

  Future<void> cargarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    final nombreGuardado = prefs.getString('nombre_invocador');
    final claseGuardada = prefs.getString('clase_rpg');
    final avatarPath = prefs.getString('avatar_seleccionado');

    ClaseRPG? claseSeleccionada;
    if (claseGuardada != null) {
      try {
        claseSeleccionada =
            ClaseRPG.values.firstWhere((c) => c.name == claseGuardada);
      } catch (e) {
        claseSeleccionada = ClaseRPG.mago;
      }
    }

    final totalNivel = await obtenerNivelGeneral();

    setState(() {
      nombre = nombreGuardado;
      clase = claseSeleccionada;
      avatarSeleccionadoPath = avatarPath;
      stats = clase != null ? statsPorClase[clase!]! : {};
      nivelGeneral = totalNivel;
    });

    await actualizarRacha();
    final nuevaRacha = prefs.getInt('racha_actual') ?? 0;
    setState(() {
      rachaActual = nuevaRacha;
    });
  }

  Future<void> actualizarRacha() async {
    final prefs = await SharedPreferences.getInstance();
    final hoy = DateTime.now();
    final hoyStr = DateFormat('yyyy-MM-dd').format(hoy);
    final ayer = hoy.subtract(const Duration(days: 1));
    final ayerStr = DateFormat('yyyy-MM-dd').format(ayer);

    List<String> diasActivos = prefs.getStringList('dias_activos') ?? [];

    if (!diasActivos.contains(hoyStr)) {
      diasActivos.add(hoyStr);
      await prefs.setStringList('dias_activos', diasActivos);
    }

    final ultimoDia = prefs.getString('ultimo_dia_activo');
    int racha = prefs.getInt('racha_actual') ?? 0;

    if (ultimoDia == ayerStr) {
      racha += 1;
    } else if (ultimoDia != hoyStr) {
      racha = 1;
    }

    await prefs.setString('ultimo_dia_activo', hoyStr);
    await prefs.setInt('racha_actual', racha);
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
              // 🔘 Cabecera ajustada
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔽 Solo bajamos esta parte izquierda
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      children: [
                        ClipOval(
                          child: avatarSeleccionadoPath != null
                              ? Image.asset(
                                  avatarSeleccionadoPath!,
                                  width: 72,
                                  height: 72,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 72,
                                  height: 72,
                                  color: Colors.white24,
                                  child: const Icon(Icons.person,
                                      size: 36, color: Colors.white70),
                                ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
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
                            const SizedBox(height: 2),
                            if (clase != null)
                              Text(
                                claseEmojis[clase]!,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDarkMode
                                      ? AppColors.darkText
                                      : AppColors.lightText,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // 🔧👤📅 Íconos fijos
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(Icons.settings_rounded,
                            color: isDarkMode
                                ? AppColors.darkText
                                : AppColors.lightText),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const PantallaSettings()),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.person_rounded,
                            color: Colors.amber),
                        onPressed: () {
                          showGeneralDialog(
                            context: context,
                            barrierDismissible: true,
                            barrierLabel: "Perfil",
                            transitionDuration:
                                const Duration(milliseconds: 400),
                            pageBuilder: (_, __, ___) => const PantallaPerfil(),
                            transitionBuilder: (_, animation, __, child) {
                              final curved = CurvedAnimation(
                                  parent: animation, curve: Curves.easeInOut);
                              return SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, -1),
                                  end: Offset.zero,
                                ).animate(curved),
                                child: child,
                              );
                            },
                          );
                        },
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
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // 📊 Título
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

              const SizedBox(height: 20),

              // Stats
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

              // Frase final del día
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
