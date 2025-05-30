import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/scheduler.dart';
import 'dart:math';

import '../utils/colors.dart';
import '../utils/xp_diaria.dart';
import '../data/misiones_agilidad.dart';
import '../widgets/modal_subir_nivel.dart';
import '../widgets/palomita_check.dart';
import '../utils/progreso.dart';
import '../widgets/drop_banner.dart';
import '../utils/monedas.dart';
import '../utils/pociones.dart';

class PantallaAgilidad extends StatefulWidget {
  @override
  _PantallaAgilidadState createState() => _PantallaAgilidadState();
}

class _PantallaAgilidadState extends State<PantallaAgilidad> {
  int agilidadXP = 0;
  int agilidadNivel = 1;
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
    agilidadXP = prefs.getInt('agilidad_xp') ?? 0;
    agilidadNivel = prefs.getInt('agilidad_nivel') ?? 1;
    ultimaMisionPrincipal =
        _getDateTime(prefs.getString('ultima_mision_agilidad'));
    ultimaGeneracion =
        _getDateTime(prefs.getString('ultima_generacion_agilidad'));
    nombreInvocador = prefs.getString('nombre_invocador') ?? "Invocador";

    final mapaXpRaw = prefs.getStringList('xp_misiones_agilidad') ?? [];
    xpMiniMisiones = {
      for (var e in mapaXpRaw)
        int.parse(e.split('|')[0]): int.parse(e.split('|')[1])
    };

    final completadasRaw = prefs.getStringList('completadas_agilidad') ?? [];
    completadasHoy = {for (var i in completadasRaw) int.parse(i): true};

    indicesMisionesDia = (prefs.getStringList('misiones_agilidad_dia') ?? [])
        .map(int.parse)
        .toList();

    final ahora = DateTime.now();
    if (!_esHoy(ultimaGeneracion)) {
      final nuevas = <int>{};
      final todas = generarMisionesAgilidad(agilidadNivel);
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

      await prefs.setStringList('misiones_agilidad_dia',
          indicesMisionesDia.map((e) => e.toString()).toList());
      await prefs.setStringList('xp_misiones_agilidad',
          xpMiniMisiones.entries.map((e) => '${e.key}|${e.value}').toList());
      await prefs.setStringList('completadas_agilidad', []);
      await prefs.setString(
          'ultima_generacion_agilidad', ahora.toIso8601String());
    } else {
      misionesGeneradas = generarMisionesAgilidad(agilidadNivel);
    }

    setState(() {
      cargando = false;
    });
  }

  Future<void> completarMisionPrincipal() async {
    setState(() {
      showCheckAnimation = true;
      indexAnimado = null;
    });

    final ahora = DateTime.now();
    if (_esHoy(ultimaMisionPrincipal)) return;
    final prefs = await SharedPreferences.getInstance();

    final xpGanada = Random().nextInt(11) + 5;
    agilidadXP += xpGanada;
    ultimaMisionPrincipal = ahora;

    while (agilidadXP >= xpNecesaria(agilidadNivel)) {
      agilidadXP -= xpNecesaria(agilidadNivel);
      agilidadNivel++;
      await mostrarDialogoSubirNivel(
        context,
        nombreInvocador: nombreInvocador ?? 'Invocador',
        nivel: agilidadNivel,
      );
    }

    await agregarXpDelDia(xpGanada);
    await prefs.setInt('agilidad_xp', agilidadXP);
    await prefs.setInt('agilidad_nivel', agilidadNivel);
    await prefs.setString('ultima_mision_agilidad', ahora.toIso8601String());
    await sumarMisionCompletada();

    int oroDrop = Random().nextInt(6) + 10; // 10-15 oro
    bool dropPocion = Random().nextDouble() < 0.6;

    await ganarMonedas(oroDrop);
    if (dropPocion) await ganarPocion();

    String texto = "+$oroDrop 🪙";
    if (dropPocion) texto += "    +1 🧪";

    await Future.delayed(const Duration(milliseconds: 0));
    mostrarDropBanner(texto);

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
    agilidadXP += xp;
    completadasHoy[id] = true;

    while (agilidadXP >= xpNecesaria(agilidadNivel)) {
      agilidadXP -= xpNecesaria(agilidadNivel);
      agilidadNivel++;
      await mostrarDialogoSubirNivel(
        context,
        nombreInvocador: nombreInvocador ?? 'Invocador',
        nivel: agilidadNivel,
      );
    }

    await agregarXpDelDia(xp);
    await prefs.setInt('agilidad_xp', agilidadXP);
    await prefs.setInt('agilidad_nivel', agilidadNivel);
    await prefs.setStringList(
        'completadas_agilidad',
        completadasHoy.entries
            .where((e) => e.value)
            .map((e) => e.key.toString())
            .toList());

    await sumarMisionCompletada();

    int oroDrop = Random().nextInt(3) + 1; // 1-3 oro
    bool dropPocion = Random().nextDouble() < 0.08;

    await ganarMonedas(oroDrop);
    if (dropPocion) await ganarPocion();

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

  @override
  Widget build(BuildContext context) {
    final xpMax = xpNecesaria(agilidadNivel);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final puedeHacerPrincipal = !cargando && !_esHoy(ultimaMisionPrincipal);

    String _formatearDuracion(Duration d) {
      final h = d.inHours;
      final m = d.inMinutes % 60;
      final s = d.inSeconds % 60;
      return '${h}h ${m}m ${s}s';
    }

    final misionPrincipalDescripcion = cargando
        ? 'Cargando misión principal...'
        : 'Realiza al menos 10 minutos de ejercicios de velocidad, equilibrio o reacción.';

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor:
            isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
        title: Text('⚡ Misión de Agilidad',
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
                Text('Nivel: $agilidadNivel',
                    style: TextStyle(
                        fontSize: 24,
                        color: isDarkMode
                            ? AppColors.darkAccent
                            : AppColors.lightText)),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: xpMax > 0 ? agilidadXP / xpMax : 0,
                  backgroundColor:
                      isDarkMode ? Colors.grey[800] : Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                  minHeight: 12,
                ),
                const SizedBox(height: 10),
                Text('$agilidadXP / $xpMax XP',
                    style: TextStyle(
                        color: isDarkMode
                            ? AppColors.darkSecondaryText
                            : AppColors.lightSecondaryText)),
                const SizedBox(height: 30),
                Text('⚡ Misión principal:',
                    style: TextStyle(
                        fontSize: 20,
                        color: isDarkMode
                            ? AppColors.darkAccent
                            : AppColors.lightText)),
                const SizedBox(height: 10),
                Text(misionPrincipalDescripcion,
                    style: TextStyle(
                        color: isDarkMode
                            ? AppColors.darkSecondaryText
                            : AppColors.lightSecondaryText)),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: puedeHacerPrincipal && !cargando
                      ? completarMisionPrincipal
                      : null,
                  icon: const Icon(Icons.directions_run),
                  label: Text(puedeHacerPrincipal && !cargando
                      ? 'Completar misión (+XP +oro)'
                      : cargando
                          ? 'Cargando...'
                          : 'Ya completada hoy'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
                if (!puedeHacerPrincipal && !cargando)
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
                  final mision = misionesGeneradas.isNotEmpty
                      ? misionesGeneradas[idx]
                      : 'Cargando...';
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
