import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/scheduler.dart';
import 'dart:math';

import '../utils/colors.dart';
import '../utils/xp_diaria.dart';
import '../data/misiones_vitalidad.dart';
import '../widgets/modal_subir_nivel.dart';
import '../widgets/palomita_check.dart';
import '../utils/progreso.dart';
import '../widgets/drop_banner.dart';
import '../utils/monedas.dart';
import '../utils/pociones.dart';
import '../utils/stamina.dart';

class PantallaVitalidad extends StatefulWidget {
  @override
  _PantallaVitalidadState createState() => _PantallaVitalidadState();
}

class _PantallaVitalidadState extends State<PantallaVitalidad> {
  int vitalidadXP = 0;
  int vitalidadNivel = 1;
  bool cargando = true;
  DateTime? ultimaGeneracion;
  DateTime? ultimaMisionPrincipal;
  List<int> indicesMisionesDia = [];
  Map<int, int> xpMiniMisiones = {};
  Map<int, bool> completadasHoy = {};
  late final Ticker _ticker;
  Duration tiempoRestante = Duration.zero;

  bool showCheckAnimation = false;
  int? indexAnimado;

  String? nombreInvocador;
  List<String> misionesGeneradas = [];

  String dropTexto = "";
  bool showDropBanner = false;

  int staminaActual = staminaMax;
  bool cargandoStamina = true;

  @override
  void initState() {
    super.initState();
    cargarDatos();
    cargarStamina();
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

    vitalidadXP = prefs.getInt('vitalidad_xp') ?? 0;
    vitalidadNivel = prefs.getInt('vitalidad_nivel') ?? 1;

    ultimaMisionPrincipal =
        _getDateTime(prefs.getString('ultima_mision_vitalidad'));
    ultimaGeneracion =
        _getDateTime(prefs.getString('ultima_generacion_vitalidad'));

    nombreInvocador = prefs.getString('nombre_invocador') ?? "Invocador";

    final mapaXpRaw = prefs.getStringList('xp_misiones_vitalidad') ?? [];
    xpMiniMisiones = {
      for (var e in mapaXpRaw)
        int.parse(e.split('|')[0]): int.parse(e.split('|')[1])
    };

    final completadasRaw = prefs.getStringList('completadas_vitalidad') ?? [];
    completadasHoy = {for (var i in completadasRaw) int.parse(i): true};

    indicesMisionesDia = (prefs.getStringList('misiones_vitalidad_dia') ?? [])
        .map(int.parse)
        .toList();

    final ahora = DateTime.now();

    if (!_esHoy(ultimaGeneracion)) {
      final nuevas = <int>{};
      final todas = generarMisionesVitalidad(vitalidadNivel);
      misionesGeneradas = todas;

      final random = Random();

      while (nuevas.length < 5) {
        nuevas.add(random.nextInt(todas.length));
      }

      indicesMisionesDia = nuevas.toList();

      xpMiniMisiones = {
        for (var i in indicesMisionesDia) i: random.nextInt(9) + 2,
      };

      completadasHoy = {};

      await prefs.setStringList('misiones_vitalidad_dia',
          indicesMisionesDia.map((e) => e.toString()).toList());
      await prefs.setStringList('xp_misiones_vitalidad',
          xpMiniMisiones.entries.map((e) => '${e.key}|${e.value}').toList());
      await prefs.setStringList('completadas_vitalidad', []);
      await prefs.setString(
          'ultima_generacion_vitalidad', ahora.toIso8601String());
    } else {
      misionesGeneradas = generarMisionesVitalidad(vitalidadNivel);
    }

    setState(() {
      cargando = false;
    });
  }

  Future<void> cargarStamina() async {
    int s = await getStamina();
    setState(() {
      staminaActual = s;
      cargandoStamina = false;
    });
  }

  Future<bool> intentarGastarStamina(int costo) async {
    bool exito = await gastarStamina(costo);
    if (!exito) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title:
              const Text("Sin stamina", style: TextStyle(color: Colors.amber)),
          content: const Text(
            "No tienes suficiente stamina para completar esta misión. Usa una poción desde tu mochila o espera a mañana.",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              child: const Text("Ok", style: TextStyle(color: Colors.amber)),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      );
      return false;
    }
    await cargarStamina();
    return true;
  }

  Future<void> completarMisionPrincipal() async {
    if (!_esHoy(ultimaMisionPrincipal)) {
      bool puede = await intentarGastarStamina(20);
      if (!puede) return;

      setState(() {
        showCheckAnimation = true;
        indexAnimado = null;
      });

      final ahora = DateTime.now();
      final prefs = await SharedPreferences.getInstance();

      final xpGanada = Random().nextInt(11) + 5;
      vitalidadXP += xpGanada;
      ultimaMisionPrincipal = ahora;

      while (vitalidadXP >= xpNecesaria(vitalidadNivel)) {
        vitalidadXP -= xpNecesaria(vitalidadNivel);
        vitalidadNivel++;
        await mostrarDialogoSubirNivel(
          context,
          nombreInvocador: nombreInvocador ?? 'Invocador',
          nivel: vitalidadNivel,
        );
      }

      int oroDrop = Random().nextInt(6) + 10; // 10-15 oro
      bool dropPocion = true; // 100% probabilidad para prueba

      await ganarMonedas(oroDrop);

      if (dropPocion) {
        int valorPocion = Random().nextBool() ? 10 : 20;
        await ganarPocion(valorPocion);
      }

      await agregarXpDelDia(xpGanada);
      await prefs.setInt('vitalidad_xp', vitalidadXP);
      await prefs.setInt('vitalidad_nivel', vitalidadNivel);
      await prefs.setString('ultima_mision_vitalidad', ahora.toIso8601String());
      await sumarMisionCompletada();

      String texto = "+$oroDrop 🪙";
      if (dropPocion) texto += "    +1 🧪";

      await Future.delayed(const Duration(milliseconds: 0));
      mostrarDropBanner(texto);

      setState(() {});
    }
  }

  Future<void> completarMiniMision(int index) async {
    final id = indicesMisionesDia[index];
    if (completadasHoy[id] == true) return;

    bool puede = await intentarGastarStamina(10);
    if (!puede) return;

    final prefs = await SharedPreferences.getInstance();

    setState(() {
      showCheckAnimation = true;
      indexAnimado = index;
    });

    final xp = xpMiniMisiones[id] ?? 2;
    vitalidadXP += xp;
    completadasHoy[id] = true;

    while (vitalidadXP >= xpNecesaria(vitalidadNivel)) {
      vitalidadXP -= xpNecesaria(vitalidadNivel);
      vitalidadNivel++;
      await mostrarDialogoSubirNivel(
        context,
        nombreInvocador: nombreInvocador ?? 'Invocador',
        nivel: vitalidadNivel,
      );
    }

    int oroDrop = Random().nextInt(3) + 1; // 1-3 oro
    bool dropPocion = Random().nextDouble() < 0.1;

    await ganarMonedas(oroDrop);

    if (dropPocion) {
      int valorPocion = Random().nextBool() ? 10 : 20;
      await ganarPocion(valorPocion);
    }

    await agregarXpDelDia(xp);
    await prefs.setInt('vitalidad_xp', vitalidadXP);
    await prefs.setInt('vitalidad_nivel', vitalidadNivel);
    await prefs.setStringList(
        'completadas_vitalidad',
        completadasHoy.entries
            .where((e) => e.value)
            .map((e) => e.key.toString())
            .toList());

    await sumarMisionCompletada();

    String texto = "+$oroDrop 🪙";
    if (dropPocion) texto += "    +1 🧪";

    await Future.delayed(const Duration(milliseconds: 500));
    mostrarDropBanner(texto);

    setState(() {});
  }

  void mostrarDropBanner(String texto) async {
    setState(() {
      dropTexto = texto;
      showDropBanner = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      showDropBanner = false;
    });
  }

  String _formatearDuracion(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    return '${h}h ${m}m ${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final xpMax = xpNecesaria(vitalidadNivel);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final puedeHacerPrincipal = !cargando && !_esHoy(ultimaMisionPrincipal);
    final puedeMisionPrincipal = puedeHacerPrincipal && staminaActual >= 20;

    Widget barraStamina() {
      final percent = staminaActual / staminaMax;
      return Padding(
        padding: const EdgeInsets.only(bottom: 20.0, top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Stamina",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDarkMode ? Colors.amber[200] : Colors.amber[800],
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
                        : Colors.amber.withOpacity(0.08),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOut,
                    height: 22,
                    width: (MediaQuery.of(context).size.width * percent - 40)
                        .clamp(0.0, double.infinity),
                    decoration: BoxDecoration(
                      color: Colors.amber[700],
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  Positioned.fill(
                    child: Center(
                      child: Text(
                        "$staminaActual / $staminaMax",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          shadows: [
                            Shadow(
                              color: Colors.white.withOpacity(0.25),
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

    if (cargandoStamina) {
      return Scaffold(
        backgroundColor:
            isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor:
            isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
        title: Text('❤️ Misión de Vitalidad',
            style: TextStyle(
                color: isDarkMode ? AppColors.darkText : AppColors.lightText)),
        iconTheme: IconThemeData(
            color: isDarkMode ? AppColors.darkText : AppColors.lightText),
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                barraStamina(),
                Text('Nivel: $vitalidadNivel',
                    style: TextStyle(
                        fontSize: 24,
                        color: isDarkMode
                            ? AppColors.darkAccent
                            : AppColors.lightText)),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: xpMax > 0 ? vitalidadXP / xpMax : 0,
                  backgroundColor:
                      isDarkMode ? Colors.grey[800] : Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                  minHeight: 12,
                ),
                const SizedBox(height: 10),
                Text('$vitalidadXP / $xpMax XP',
                    style: TextStyle(
                        color: isDarkMode
                            ? AppColors.darkSecondaryText
                            : AppColors.lightSecondaryText)),
                const SizedBox(height: 30),
                Text('❤️ Misión principal:',
                    style: TextStyle(
                        fontSize: 20,
                        color: isDarkMode
                            ? AppColors.darkAccent
                            : AppColors.lightText)),
                const SizedBox(height: 10),
                Text(
                    'Cuida tu cuerpo y mente: date un respiro y haz una pausa consciente hoy.',
                    style: TextStyle(
                        color: isDarkMode
                            ? AppColors.darkSecondaryText
                            : AppColors.lightSecondaryText)),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed:
                      puedeMisionPrincipal ? completarMisionPrincipal : null,
                  icon: const Icon(Icons.favorite_rounded),
                  label: Text(
                    puedeHacerPrincipal
                        ? staminaActual >= 20
                            ? 'Completar misión (+XP +oro)'
                            : 'Sin stamina'
                        : 'Ya completada hoy',
                  ),
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
                              : AppColors.lightSecondaryText),
                    ),
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
                  final mision = misionesGeneradas[idx];
                  final hecha = completadasHoy[idx] == true;
                  final xp = xpMiniMisiones[idx] ?? 2;
                  final puedeMini = !hecha && staminaActual >= 10;

                  return Card(
                    color: isDarkMode
                        ? (hecha ? Colors.grey[900] : Colors.black)
                        : (hecha ? Colors.grey[300] : Colors.white),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(mision,
                          style: TextStyle(
                              color: isDarkMode
                                  ? AppColors.darkText
                                  : AppColors.lightText)),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '+${xp} XP',
                            style: TextStyle(
                                color: isDarkMode
                                    ? Colors.amber[300]
                                    : Colors.amber[800]),
                          ),
                          if (hecha)
                            const Text('⏳ Disponible mañana',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey)),
                          if (!hecha && staminaActual < 10)
                            const Text(
                              'Sin stamina',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.amber),
                            ),
                        ],
                      ),
                      trailing: hecha
                          ? const Icon(Icons.check, color: Colors.grey)
                          : IconButton(
                              icon: const Icon(Icons.check_circle,
                                  color: Colors.amber),
                              onPressed: puedeMini
                                  ? () => completarMiniMision(i)
                                  : null,
                            ),
                    ),
                  );
                }),
              ],
            ),
          ),
          if (showCheckAnimation)
            Align(
              alignment: Alignment.center,
              child: PalomitaCheck(
                show: showCheckAnimation,
                onComplete: () {
                  setState(() {
                    showCheckAnimation = false;
                    indexAnimado = null;
                  });
                },
              ),
            ),
          if (showDropBanner)
            Align(
              alignment: Alignment.topCenter,
              child: DropBanner(
                texto: dropTexto,
                show: showDropBanner,
              ),
            ),
        ],
      ),
    );
  }
}
