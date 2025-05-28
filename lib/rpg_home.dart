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
  String? bannerFondoUrl; // <- Para el fondo personalizado

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
    _cargarFondoAnimado().then((_) async {
      await actualizarXPGeneralSiEsNuevoDia();
      await cargarDatos();
      await cargarFondoPersonalizado(); // <--- carga el fondo personalizado al iniciar
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
      cargarFondoPersonalizado(); // <--- recarga el fondo al volver
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
      });
    } else if (lowerStat == 'inteligencia') {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => PantallaInteligencia())).then((_) {
        cargarDatos();
        cargarFondoPersonalizado();
      });
    } else if (lowerStat == 'defensa') {
      Navigator.push(
              context, MaterialPageRoute(builder: (_) => PantallaDefensa()))
          .then((_) {
        cargarDatos();
        cargarFondoPersonalizado();
      });
    } else if (lowerStat == 'agilidad') {
      Navigator.push(
              context, MaterialPageRoute(builder: (_) => PantallaAgilidad()))
          .then((_) {
        cargarDatos();
        cargarFondoPersonalizado();
      });
    } else if (lowerStat == 'vitalidad') {
      Navigator.push(
              context, MaterialPageRoute(builder: (_) => PantallaVitalidad()))
          .then((_) {
        cargarDatos();
        cargarFondoPersonalizado();
      });
    } else if (lowerStat == 'suerte') {
      Navigator.push(
              context, MaterialPageRoute(builder: (_) => PantallaSuerte()))
          .then((_) {
        cargarDatos();
        cargarFondoPersonalizado();
      });
    } else if (lowerStat == 'carisma') {
      Navigator.push(
              context, MaterialPageRoute(builder: (_) => PantallaCarisma()))
          .then((_) {
        cargarDatos();
        cargarFondoPersonalizado();
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
        .then((_) =>
            cargarFondoPersonalizado()); // <-- Recarga el fondo al volver de la mochila
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

    Widget contenido = SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
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
                        ).then((_) => _cargarFondoAnimado());
                      },
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.person_rounded, color: Colors.amber),
                      onPressed: () => showGeneralDialog(
                        context: context,
                        barrierDismissible: true,
                        barrierLabel: "Perfil",
                        transitionDuration: const Duration(milliseconds: 400),
                        pageBuilder: (_, __, ___) => PantallaPerfil(),
                        transitionBuilder: (_, animation, __, child) =>
                            SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, -1),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                              parent: animation, curve: Curves.easeInOut)),
                          child: child,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_month_rounded,
                          color: Colors.amber),
                      onPressed: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const PantallaCalendario(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.backpack_rounded,
                          color: Colors.amber),
                      tooltip: "Ver drops y mejoras",
                      onPressed: _abrirPantallaMochila,
                    ),
                    IconButton(
                      icon: const Icon(Icons.storefront_rounded,
                          color: Colors.amber),
                      tooltip: "Abrir tienda",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => PantallaTienda()),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 0),
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
                      color: Colors.black
                          .withOpacity(0.22), // SIEMPRE NEGRO TRANSLÚCIDO
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.09),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withOpacity(0.10),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 36)),
                        const SizedBox(height: 10),
                        Text(entry.key.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            )),
                        const SizedBox(height: 8),
                        Text(fraseStat,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color:
                                  isDarkMode ? Colors.white54 : Colors.black45,
                            )),
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
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: isDarkMode
                    ? AppColors.darkSecondaryText
                    : AppColors.lightSecondaryText,
              ),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      body: Stack(
        children: [
          // 1. Banner personalizado (al fondo)
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
          // 2. Fondo animado, siempre encima del banner (o solo si fondoAnimado es true)
          if (fondoAnimado)
            Positioned.fill(
              child: FluidLinesBackground(child: Container()),
            ),
          // 3. Overlay oscuro para legibilidad (solo si hay banner)
          if (bannerFondoUrl != null)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.30),
              ),
            ),
          // 4. El contenido/UI de la app, siempre arriba de todo
          contenido,
        ],
      ),
    );
  }
}
