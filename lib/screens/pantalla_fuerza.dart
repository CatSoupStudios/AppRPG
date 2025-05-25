import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/scheduler.dart';
import 'dart:math';
import '../utils/colors.dart';
import '../utils/xp_diaria.dart'; // Cambia la ruta si tu archivo está en otra carpeta

class MiniMision {
  final String descripcion;
  final int xp;

  MiniMision(this.descripcion, this.xp);
}

class PantallaFuerza extends StatefulWidget {
  @override
  _PantallaFuerzaState createState() => _PantallaFuerzaState();
}

class _PantallaFuerzaState extends State<PantallaFuerza> {
  int fuerzaXP = 0;
  int fuerzaNivel = 1;
  bool cargando = true;
  DateTime? ultimaGeneracion;
  DateTime? ultimaMisionPrincipal;
  List<int> indicesMisionesDia = [];
  Map<int, int> xpMiniMisiones = {};
  Map<int, bool> completadasHoy = {};
  late final Ticker _ticker;
  Duration tiempoRestante = Duration.zero;

  // --------- Animación de palomita ---------
  bool showCheckAnimation = false;
  int? indexAnimado; // (por si luego quieres saber cuál mini-misión animar)
  // -----------------------------------------

  String? nombreInvocador;

  final List<MiniMision> todasLasMisiones = [
    MiniMision("Hacer 10 lagartijas 💪🔥", 1),
    MiniMision("3 sets de 15 sentadillas 🦵🏽💢", 1),
    MiniMision("Subir escaleras 5 veces 🏃‍♂️⛰️", 1),
    MiniMision("Plank por 1 minuto 🧱⏱️", 1),
    MiniMision("Ayudar con tarea física pesada 🧰💥", 2),
    MiniMision("Cargar cosas 10 min 📦💪", 2),
    MiniMision("Caminar con peso 15 min 🥾🎒", 2),
    MiniMision("20 burpees 🔥😤", 2),
    MiniMision("Rutina rápida de brazos (10 min) 💪⏳", 2),
    MiniMision("2 sets de 20 saltos en cuclillas 🏋️‍♂️🌀", 1),
    MiniMision("Hacer rutina HIIT de 20+ min ⚡🔥", 3),
    MiniMision("Cargar mochilas pesadas 10 min 🎒💢", 2),
    MiniMision("Flexiones + plancha + sentadillas combo 💥🛠️", 3),
    MiniMision("Levantar cubetas llenas 5 veces 🪣💪", 2),
    MiniMision("Barrer patio intensamente 20 min 🧹🔥", 2),
    MiniMision("Trote corto con mochila 🏃🎒", 2),
    MiniMision("Push-ups sobre una mano (con apoyo) ✋😮‍💨", 2),
    MiniMision("Prensa de piernas casera (objeto pesado) 🦿🏋️‍♀️", 2),
    MiniMision("Abdominales + sentadillas (combo) 🧍‍♂️💣", 2),
    MiniMision("Limpiar cuarto intensamente 🧽💥", 1),
    MiniMision("Tender cama y ordenar sin parar (5 min) 🛏️⏱️", 1),
    MiniMision("Cargar galones de agua por 5 min 💧🪣", 2),
    MiniMision("Mover muebles pesados (ayuda) 🪑💪", 2),
    MiniMision("Estiramientos con tensión de fuerza 🧘‍♂️💢", 1),
    MiniMision("Práctica de box o golpes al aire (shadow) 🥊👊", 2),
    MiniMision("Lanzar objeto pesado varias veces 🪨🏹", 2),
    MiniMision("Saltos en caja o escalón 📦⬆️", 1),
    MiniMision("Dips con silla (3 sets) 🪑↕️", 1),
    MiniMision("Arrastrar mochila pesada por 10 min 🎒➡️💢", 2),
    MiniMision("Mini circuito: 5 flexiones, 10 sentadillas, 15 saltos 🔁🔥", 2),
  ];

  @override
  void initState() {
    super.initState();
    cargarDatos();
    _ticker = Ticker((_) {
      if (!mounted) return;
      setState(() {
        tiempoRestante = _calcularRestante();
      });
    })
      ..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  Duration _calcularRestante() {
    final ahora = DateTime.now();
    final siguiente = DateTime(ahora.year, ahora.month, ahora.day + 1);
    return siguiente.difference(ahora);
  }

  DateTime? _getDateTime(String? str) {
    if (str == null) return null;
    return DateTime.tryParse(str);
  }

  bool _esHoy(DateTime? dt) {
    if (dt == null) return false;
    final ahora = DateTime.now();
    return ahora.year == dt.year &&
        ahora.month == dt.month &&
        ahora.day == dt.day;
  }

  int xpNecesaria(int nivel) => 10 + (nivel - 1) * 5;

  Future<void> cargarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    fuerzaXP = prefs.getInt('fuerza_xp') ?? 0;
    fuerzaNivel = prefs.getInt('fuerza_nivel') ?? 1;
    ultimaMisionPrincipal =
        _getDateTime(prefs.getString('ultima_mision_fuerza'));
    ultimaGeneracion =
        _getDateTime(prefs.getString('ultima_generacion_fuerza'));
    nombreInvocador = prefs.getString('nombre_invocador') ?? "Invocador";

    // XP aleatoria persistente
    final mapaXpRaw = prefs.getStringList('xp_misiones_fuerza') ?? [];
    xpMiniMisiones = {
      for (var e in mapaXpRaw)
        int.parse(e.split('|')[0]): int.parse(e.split('|')[1])
    };

    // Completadas
    final completadasRaw = prefs.getStringList('completadas_fuerza') ?? [];
    completadasHoy = {for (var i in completadasRaw) int.parse(i): true};

    // Misiones del día
    indicesMisionesDia = (prefs.getStringList('misiones_fuerza_dia') ?? [])
        .map(int.parse)
        .toList();

    final ahora = DateTime.now();
    if (!_esHoy(ultimaGeneracion)) {
      final random = Random();
      final nuevas = <int>{};
      while (nuevas.length < 5) {
        nuevas.add(random.nextInt(todasLasMisiones.length));
      }
      indicesMisionesDia = nuevas.toList();
      xpMiniMisiones = {
        for (var i in indicesMisionesDia) i: random.nextInt(9) + 2,
      };
      completadasHoy = {};
      await prefs.setStringList('misiones_fuerza_dia',
          indicesMisionesDia.map((e) => e.toString()).toList());
      await prefs.setStringList('xp_misiones_fuerza',
          xpMiniMisiones.entries.map((e) => '${e.key}|${e.value}').toList());
      await prefs.setStringList('completadas_fuerza', []);
      await prefs.setString(
          'ultima_generacion_fuerza', ahora.toIso8601String());
    }

    setState(() {
      cargando = false;
    });
  }

  // ----------- MODAL DE SUBIR NIVEL -----------
  void mostrarDialogoNivel(int nivel) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final size = MediaQuery.of(context).size;
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          elevation: 0,
          child: Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.85)
                  : Colors.white.withOpacity(0.9),
            ),
            child: Stack(
              children: [
                // Animación de confeti en fondo
                Positioned.fill(
                  child: Lottie.asset(
                    'assets/animations/confeti.json',
                    fit: BoxFit.cover,
                    repeat: false,
                  ),
                ),

                // Contenido centrado encima del confeti
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        nombreInvocador ?? 'Invocador',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                          shadows: [
                            Shadow(
                              color:
                                  isDarkMode ? Colors.white38 : Colors.black26,
                              blurRadius: 14,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '¡Subiste a Nivel $nivel!',
                        style: const TextStyle(
                          fontSize: 32,
                          color: Colors.amber,
                          fontWeight: FontWeight.w700,
                          shadows: [
                            Shadow(color: Colors.black45, blurRadius: 12),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 36, vertical: 16),
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Aceptar'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ----------- FIN MODAL -----------

  Future<void> completarMisionPrincipal() async {
    setState(() {
      showCheckAnimation = true;
      indexAnimado = null;
    });

    final ahora = DateTime.now();
    if (_esHoy(ultimaMisionPrincipal)) return;
    final prefs = await SharedPreferences.getInstance();

    final xpGanada = Random().nextInt(11) + 5;
    fuerzaXP += xpGanada;
    ultimaMisionPrincipal = ahora;

    while (fuerzaXP >= xpNecesaria(fuerzaNivel)) {
      fuerzaXP -= xpNecesaria(fuerzaNivel);
      fuerzaNivel++;
      mostrarDialogoNivel(fuerzaNivel); // Muestra el modal
    }

    await agregarXpDelDia(xpGanada); // Descomenta si tienes esta función
    await prefs.setInt('fuerza_xp', fuerzaXP);
    await prefs.setInt('fuerza_nivel', fuerzaNivel);
    await prefs.setString('ultima_mision_fuerza', ahora.toIso8601String());

    setState(() {});
  }

  Future<void> completarMiniMision(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final id = indicesMisionesDia[index];
    if (completadasHoy[id] == true) return;

    setState(() {
      showCheckAnimation = true;
      indexAnimado = index;
    });

    final xp = xpMiniMisiones[id] ?? 2;
    fuerzaXP += xp;
    completadasHoy[id] = true;

    while (fuerzaXP >= xpNecesaria(fuerzaNivel)) {
      fuerzaXP -= xpNecesaria(fuerzaNivel);
      fuerzaNivel++;
      mostrarDialogoNivel(fuerzaNivel); // Muestra el modal
    }

    await agregarXpDelDia(xp); // Descomenta si tienes esta función
    await prefs.setInt('fuerza_xp', fuerzaXP);
    await prefs.setInt('fuerza_nivel', fuerzaNivel);
    await prefs.setStringList(
        'completadas_fuerza',
        completadasHoy.entries
            .where((e) => e.value)
            .map((e) => e.key.toString())
            .toList());

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final xpMax = xpNecesaria(fuerzaNivel);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final puedeHacerPrincipal = !_esHoy(ultimaMisionPrincipal);

    String _formatearDuracion(Duration d) {
      final h = d.inHours;
      final m = d.inMinutes % 60;
      final s = d.inSeconds % 60;
      return '${h}h ${m}m ${s}s';
    }

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor:
            isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
        title: Text('💪 Misión de Fuerza',
            style: TextStyle(
                color: isDarkMode ? AppColors.darkText : AppColors.lightText)),
        iconTheme: IconThemeData(
            color: isDarkMode ? AppColors.darkText : AppColors.lightText),
        elevation: 0,
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : Stack(
              alignment: Alignment.center,
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nivel: $fuerzaNivel',
                          style: TextStyle(
                              fontSize: 24,
                              color: isDarkMode
                                  ? AppColors.darkAccent
                                  : AppColors.lightText)),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: fuerzaXP / xpMax,
                        backgroundColor:
                            isDarkMode ? Colors.grey[800] : Colors.grey[300],
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.amber),
                        minHeight: 12,
                      ),
                      const SizedBox(height: 10),
                      Text('$fuerzaXP / $xpMax XP',
                          style: TextStyle(
                              color: isDarkMode
                                  ? AppColors.darkSecondaryText
                                  : AppColors.lightSecondaryText)),
                      const SizedBox(height: 30),
                      Text('🏋️ Misión principal:',
                          style: TextStyle(
                              fontSize: 20,
                              color: isDarkMode
                                  ? AppColors.darkAccent
                                  : AppColors.lightText)),
                      const SizedBox(height: 10),
                      Text(
                          'Realiza 30 minutos de ejercicio físico intenso hoy.',
                          style: TextStyle(
                              color: isDarkMode
                                  ? AppColors.darkSecondaryText
                                  : AppColors.lightSecondaryText)),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: puedeHacerPrincipal
                            ? completarMisionPrincipal
                            : null,
                        icon: const Icon(Icons.fitness_center),
                        label: Text(puedeHacerPrincipal
                            ? 'Completar misión (+XP aleatoria)'
                            : 'Ya completada hoy'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
                      if (!puedeHacerPrincipal)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                              '⏳ Nuevo intento en: ${_formatearDuracion(tiempoRestante)}',
                              style: TextStyle(
                                  color: isDarkMode
                                      ? AppColors.darkSecondaryText
                                      : AppColors.lightSecondaryText)),
                        ),
                      const SizedBox(height: 40),
                      Text('🎯 Mini-misiones del día:',
                          style: TextStyle(
                              fontSize: 20,
                              color: isDarkMode
                                  ? AppColors.darkAccent
                                  : AppColors.lightText)),
                      const SizedBox(height: 10),
                      ...List.generate(indicesMisionesDia.length, (i) {
                        final idx = indicesMisionesDia[i];
                        final mision = todasLasMisiones[idx];
                        final hecha = completadasHoy[idx] == true;
                        final xp = xpMiniMisiones[idx] ?? 2;

                        return Card(
                          color: isDarkMode
                              ? (hecha ? Colors.grey[900] : Colors.black)
                              : (hecha ? Colors.grey[300] : Colors.white),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(
                              mision.descripcion,
                              style: TextStyle(
                                color: isDarkMode
                                    ? AppColors.darkText
                                    : AppColors.lightText,
                              ),
                            ),
                            subtitle: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '+${xp} XP',
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.amber[300]
                                        : Colors.amber[800],
                                  ),
                                ),
                                if (hecha)
                                  const Text(
                                    '⏳ Disponible mañana',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: hecha
                                ? const Icon(Icons.check, color: Colors.grey)
                                : IconButton(
                                    icon: const Icon(Icons.check_circle,
                                        color: Colors.amber),
                                    onPressed: () => completarMiniMision(i),
                                  ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                // ANIMACIÓN DE PALOMITA LOCAL
                if (showCheckAnimation)
                  Center(
                    child: Lottie.asset(
                      'assets/animations/palimita.json',
                      width: 200,
                      height: 200,
                      repeat: false,
                      onLoaded: (composition) {
                        Future.delayed(composition.duration, () {
                          if (mounted) {
                            setState(() {
                              showCheckAnimation = false;
                              indexAnimado = null;
                            });
                          }
                        });
                      },
                    ),
                  ),
              ],
            ),
    );
  }
}
