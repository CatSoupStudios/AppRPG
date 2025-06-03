import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

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
import '../effects/fluid_lines_background.dart';
import 'screens/pantalla_mochila.dart';
import 'screens/pantalla_tienda.dart';
import 'utils/stamina.dart';

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
  bool fondoAnimado = true;
  bool cargandoPrefs = true;
  String? bannerFondoUrl;
  int staminaActual = staminaMax; // <-- NUEVO: Variable de stamina

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
    cargarStamina(); // <-- NUEVO: Carga stamina al iniciar

    _cargarFondoAnimado().then((_) async {
      await actualizarXPGeneralSiEsNuevoDia();
      await cargarDatos();
      await cargarFondoPersonalizado();
    });
  }

  // --- NUEVO: Método para cargar stamina desde SharedPreferences ---
  Future<void> cargarStamina() async {
    int s = await getStamina();
    setState(() {
      staminaActual = s;
    });
  }

  Future<void> cargarFondoPersonalizado() async {
    final prefs = await SharedPreferences.getInstance();
    final fondoId = prefs.getString('banner_fondo');
    final bannersStrings = prefs.getStringList('banners_comprados') ?? [];
    if (fondoId != null && bannersStrings.isNotEmpty) {
      final bannersList = bannersStrings
          .map((e) => json.decode(e) as Map<String, dynamic>)
          .toList();
      final banner = bannersList.firstWhere(
        (b) => b['id'].toString() == fondoId,
        orElse: () => <String, dynamic>{}, // 👈 AQUÍ
      );
      setState(() {
        bannerFondoUrl = banner.isNotEmpty ? banner['url'] : null;
      });
    } else {
      setState(() {
        bannerFondoUrl = null;
      });
    }
  }

  Future<void> _cargarFondoAnimado() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      fondoAnimado = prefs.getBool('fondoAnimado') ?? true;
      cargandoPrefs = false;
    });
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
      _cargarFondoAnimado();
      cargarFondoPersonalizado();
      cargarStamina(); // <-- NUEVO: Recarga stamina al volver del background
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

    final nombreGuardado = prefs.getString('nombre_invocador') ?? 'Invocador';
    final claseGuardada = prefs.getString('clase') ?? 'mago';
    final avatarNombre = prefs.getString('avatar') ??
        prefs.getString('avatar_seleccionado')?.split('/').last ??
        'mago-1.png';

    ClaseRPG? claseSeleccionada;
    try {
      claseSeleccionada =
          ClaseRPG.values.firstWhere((c) => c.name == claseGuardada);
    } catch (e) {
      claseSeleccionada = ClaseRPG.mago;
    }

    final totalNivel = await obtenerNivelGeneral();

    setState(() {
      nombre = nombreGuardado;
      clase = claseSeleccionada;
      avatarSeleccionadoPath = 'assets/avatars/$claseGuardada/$avatarNombre';
      stats = clase != null ? statsPorClase[clase!]! : {};
      nivelGeneral = totalNivel;
    });

    await actualizarRacha();
    final nuevaRacha = prefs.getInt('racha_actual') ?? 0;
    setState(() {
      rachaActual = nuevaRacha;
    });

    await cargarStamina(); // <-- NUEVO: Refresca stamina también al cargar datos
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
          .then((_) {
        cargarDatos();
        cargarFondoPersonalizado();
        cargarStamina(); // <-- NUEVO: Refresca stamina al volver de stat
      });
    } else if (lowerStat == 'inteligencia') {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => PantallaInteligencia())).then((_) {
        cargarDatos();
        cargarFondoPersonalizado();
        cargarStamina();
      });
    } else if (lowerStat == 'defensa') {
      Navigator.push(
              context, MaterialPageRoute(builder: (_) => PantallaDefensa()))
          .then((_) {
        cargarDatos();
        cargarFondoPersonalizado();
        cargarStamina();
      });
    } else if (lowerStat == 'agilidad') {
      Navigator.push(
              context, MaterialPageRoute(builder: (_) => PantallaAgilidad()))
          .then((_) {
        cargarDatos();
        cargarFondoPersonalizado();
        cargarStamina();
      });
    } else if (lowerStat == 'vitalidad') {
      Navigator.push(
              context, MaterialPageRoute(builder: (_) => PantallaVitalidad()))
          .then((_) {
        cargarDatos();
        cargarFondoPersonalizado();
        cargarStamina();
      });
    } else if (lowerStat == 'suerte') {
      Navigator.push(
              context, MaterialPageRoute(builder: (_) => PantallaSuerte()))
          .then((_) {
        cargarDatos();
        cargarFondoPersonalizado();
        cargarStamina();
      });
    } else if (lowerStat == 'carisma') {
      Navigator.push(
              context, MaterialPageRoute(builder: (_) => PantallaCarisma()))
          .then((_) {
        cargarDatos();
        cargarFondoPersonalizado();
        cargarStamina();
      });
    }
  }

  void _abrirPantallaMochila() {
    Navigator.of(context)
        .push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          PantallaMochila(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        final tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        final opacityTween = Tween<double>(begin: 0.0, end: 1.0);

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation.drive(opacityTween),
            child: child,
          ),
        );
      },
    ))
        .then((_) {
      cargarFondoPersonalizado();
      cargarStamina(); // <-- NUEVO: Refresca stamina al volver de mochila
    });
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

    if (cargandoPrefs) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final List<_AccesoDirectoItem> accesos = [
      _AccesoDirectoItem(
        icon: Icons.person,
        tooltip: "Perfil",
        onTap: () => showGeneralDialog(
          context: context,
          barrierDismissible: true,
          barrierLabel: "Perfil",
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (_, __, ___) => PantallaPerfil(),
          transitionBuilder: (_, animation, __, child) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -1),
              end: Offset.zero,
            ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
            child: child,
          ),
        ),
      ),
      _AccesoDirectoItem(
        icon: Icons.calendar_month,
        tooltip: "Calendario",
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const PantallaCalendario(),
        ),
      ),
      _AccesoDirectoItem(
        icon: Icons.backpack,
        tooltip: "Mochila",
        onTap: _abrirPantallaMochila,
      ),
      _AccesoDirectoItem(
        icon: Icons.storefront,
        tooltip: "Tienda",
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PantallaTienda()),
        ),
      ),
      _AccesoDirectoItem(
        icon: Icons.settings,
        tooltip: "Ajustes",
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PantallaSettings()),
        ).then((_) => _cargarFondoAnimado()),
      ),
    ];

    // --- BARRA DE STAMINA --- //
    Widget barraStamina() {
      final percent = staminaActual / staminaMax;
      Color barraColor;
      if (percent > 0.7) {
        barraColor = Colors.greenAccent.shade700;
      } else if (percent > 0.3) {
        barraColor = Colors.amber.shade700;
      } else {
        barraColor = Colors.redAccent.shade700;
      }

      return Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Stamina",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDarkMode
                    ? Colors.cyanAccent.shade100
                    : Colors.deepPurple[800],
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                children: [
                  Container(
                    height: 22,
                    width: double.infinity,
                    color: isDarkMode
                        ? Colors.white10
                        : Colors.deepPurple.withOpacity(0.08),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 550),
                    curve: Curves.easeOut,
                    height: 22,
                    width: (MediaQuery.of(context).size.width * percent - 40)
                        .clamp(0.0, double.infinity),
                    decoration: BoxDecoration(
                      color: barraColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  Positioned.fill(
                    child: Center(
                      child: Text(
                        "$staminaActual / $staminaMax",
                        style: TextStyle(
                          color: percent > 0.3
                              ? Colors.white
                              : Colors.white.withOpacity(0.85),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 2,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    // --- FIN BARRA DE STAMINA --- //

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      body: Stack(
        children: [
          if (bannerFondoUrl != null)
            Positioned.fill(
              child: Image.network(
                bannerFondoUrl!,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          if (fondoAnimado)
            Positioned.fill(child: FluidLinesBackground(child: Container())),
          if (bannerFondoUrl != null)
            Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // FOTO, NOMBRE, CLASE
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: avatarSeleccionadoPath != null
                            ? Image.asset(
                                avatarSeleccionadoPath!,
                                width: 85,
                                height: 85,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 85,
                                height: 85,
                                color: Colors.white24,
                                child: const Icon(Icons.person,
                                    size: 40, color: Colors.white70),
                              ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nombre != null
                                ? '${nombre!.toUpperCase()} (lvl $nivelGeneral)'
                                : "INVOCADOR",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode
                                  ? Colors.cyanAccent.shade100
                                  : Colors.deepPurple[800],
                              shadows: [
                                Shadow(
                                  blurRadius: 3,
                                  color: isDarkMode
                                      ? Colors.black.withOpacity(0.5)
                                      : Colors.white.withOpacity(0.45),
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (clase != null)
                            Text(
                              claseEmojis[clase]!,
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.amber,
                              ),
                            ),
                          const SizedBox(height: 10),
                          // Frase del día DEBAJO de la foto y la clase
                          Container(
                            width: 185,
                            child: Text(
                              fraseDelDia,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: Colors.cyanAccent.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // BARRA DE STAMINA AQUÍ MISMO 👇
                  barraStamina(),

                  const SizedBox(height: 14),
                  Text(
                    "⚡STATS DEL INVOCADOR",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.cyanAccent.shade100,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // GRID DE STATS (O lo que tengas aquí)
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: stats.entries.map((entry) {
                        final keyLower = entry.key.toLowerCase();
                        final emoji = statEmojis[keyLower] ?? '🔹';
                        final fraseStat =
                            frasesPorStat[keyLower] ?? "Stat desbloqueado.";

                        return GestureDetector(
                          onTap: () => abrirPantallaStat(entry.key),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                  color: Colors.cyanAccent.withOpacity(0.3)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.cyanAccent.withOpacity(0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(emoji,
                                    style: const TextStyle(fontSize: 34)),
                                const SizedBox(height: 10),
                                Text(entry.key.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.cyanAccent.shade100,
                                    )),
                                const SizedBox(height: 6),
                                Text(fraseStat,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.white.withOpacity(0.5)))
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // FILA DE ACCESOS DIRECTOS, ABAJO DE TODO Y CENTRADO
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 6),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: accesos.map((item) {
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 7.0),
                            child: FloatingActionButton(
                              heroTag: item.tooltip,
                              backgroundColor: isDarkMode
                                  ? Colors.deepPurple
                                  : Colors.white.withOpacity(0.93),
                              mini: true,
                              tooltip: item.tooltip,
                              onPressed: item.onTap,
                              child: Icon(
                                item.icon,
                                size: 22,
                                color: isDarkMode
                                    ? Colors.white
                                    : Colors.deepPurple[700],
                                shadows: [
                                  if (!isDarkMode)
                                    Shadow(
                                      blurRadius: 2,
                                      color: Colors.black.withOpacity(0.2),
                                      offset: Offset(1, 1),
                                    ),
                                ],
                              ),
                              elevation: isDarkMode ? 4 : 7,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: isDarkMode
                                    ? BorderSide.none
                                    : const BorderSide(
                                        color: Colors.deepPurple, width: 1.1),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper para accesos directos
class _AccesoDirectoItem {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  _AccesoDirectoItem({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });
}
