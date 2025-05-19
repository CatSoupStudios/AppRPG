import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/scheduler.dart';
import 'dart:math';
import '../utils/colors.dart';
import '../utils/xp_diaria.dart';

class MiniMision {
  final String descripcion;
  final int xp;

  MiniMision(this.descripcion, this.xp);
}

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

  final List<MiniMision> todasLasMisiones = [
    MiniMision("Saltos en tijera durante 1 minuto 🦿⏱️", 1),
    MiniMision("Correr 5 sprints de 20 metros 🏃💨", 1),
    MiniMision("Subir y bajar escaleras 3 veces sin parar 🪜🔥", 1),
    MiniMision("Saltar la cuerda durante 2 minutos 🪢⏱️", 1),
    MiniMision("Hacer 15 saltos laterales rápidos ↔️⚡", 1),
    MiniMision("Tocar 10 objetos distintos en 30 seg 🔲🕐", 2),
    MiniMision("Seguir ritmo de una canción con palmas 🎶👏", 1),
    MiniMision("Equilibrio sobre un pie por 30 seg 🦶🧘‍♂️", 1),
    MiniMision("Caminata rápida de 10 min sin detenerse 🚶‍♂️💨", 1),
    MiniMision("Hacer shadowboxing 2 minutos 🥊👊", 2),
    MiniMision("Mini parkour en casa (sin romper nada) 🧗‍♂️🌀", 2),
    MiniMision("Jugar a reacción con luz/sonido 🎮⚡", 2),
    MiniMision("Hacer 20 jumping jacks 🔁🕺", 1),
    MiniMision("Correr en el lugar durante 1 min 🏃‍♂️🕐", 1),
    MiniMision("Saltar a un escalón o caja 10 veces 📦⬆️", 1),
    MiniMision("Agacharse y levantarse rápido 15 veces ⬇️⬆️", 1),
    MiniMision("Jugar un juego de ritmo tipo 'Just Dance' 🕺🎵", 2),
    MiniMision("Atrapar una pelota lanzada al azar ⚾🤚", 2),
    MiniMision("Caminar en línea recta con los ojos cerrados 🚶‍♀️😵", 2),
    MiniMision("Deslizarse bajo una mesa o silla (con cuidado) 🪑🧍‍♂️", 1),
    MiniMision("Tocar tus pies sin doblar las rodillas 🙆‍♂️🧘", 1),
    MiniMision("Balancear un objeto sobre tu cabeza 1 min 🧢⚖️", 1),
    MiniMision("Seguir un patrón de colores con velocidad 🎨🧠", 2),
    MiniMision("Subir escalones a ritmo de canción 🎵⏫", 1),
    MiniMision("Reacción a palmadas (alguien o app) 👏⚡", 2),
    MiniMision("Carrera de obstáculos en tu casa 🛋️🚧", 2),
    MiniMision("Saltos cortos sobre una línea 30 seg ↕️🦶", 1),
    MiniMision("Repetir una serie de pasos de memoria 🧠👟", 2),
    MiniMision("Practicar girar y estabilizar rápido 🔄🧍", 1),
    MiniMision("Saltar 5 veces con giros de 180° 🔁🕺", 2),
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
    agilidadXP = prefs.getInt('agilidad_xp') ?? 0;
    agilidadNivel = prefs.getInt('agilidad_nivel') ?? 1;
    ultimaMisionPrincipal =
        _getDateTime(prefs.getString('ultima_mision_agilidad'));
    ultimaGeneracion =
        _getDateTime(prefs.getString('ultima_generacion_agilidad'));

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
      await prefs.setStringList('misiones_agilidad_dia',
          indicesMisionesDia.map((e) => e.toString()).toList());
      await prefs.setStringList('xp_misiones_agilidad',
          xpMiniMisiones.entries.map((e) => '${e.key}|${e.value}').toList());
      await prefs.setStringList('completadas_agilidad', []);
      await prefs.setString(
          'ultima_generacion_agilidad', ahora.toIso8601String());
    }

    setState(() {
      cargando = false;
    });
  }

  Future<void> completarMisionPrincipal() async {
    final ahora = DateTime.now();
    if (_esHoy(ultimaMisionPrincipal)) return;
    final prefs = await SharedPreferences.getInstance();

    final xpGanada = Random().nextInt(11) + 5;
    agilidadXP += xpGanada;
    ultimaMisionPrincipal = ahora;

    while (agilidadXP >= xpNecesaria(agilidadNivel)) {
      agilidadXP -= xpNecesaria(agilidadNivel);
      agilidadNivel++;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('⚡ ¡Subiste a nivel $agilidadNivel en Agilidad!')),
      );
    }

    await agregarXpDelDia(xpGanada);
    await prefs.setInt('agilidad_xp', agilidadXP);
    await prefs.setInt('agilidad_nivel', agilidadNivel);
    await prefs.setString('ultima_mision_agilidad', ahora.toIso8601String());

    setState(() {});
  }

  Future<void> completarMiniMision(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final id = indicesMisionesDia[index];
    if (completadasHoy[id] == true) return;

    final xp = xpMiniMisiones[id] ?? 2;
    agilidadXP += xp;
    completadasHoy[id] = true;

    while (agilidadXP >= xpNecesaria(agilidadNivel)) {
      agilidadXP -= xpNecesaria(agilidadNivel);
      agilidadNivel++;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('⚡ ¡Subiste a nivel $agilidadNivel en Agilidad!')),
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

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final xpMax = xpNecesaria(agilidadNivel);
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
        title: Text('⚡ Misión de Agilidad',
            style: TextStyle(
                color: isDarkMode ? AppColors.darkText : AppColors.lightText)),
        iconTheme: IconThemeData(
            color: isDarkMode ? AppColors.darkText : AppColors.lightText),
        elevation: 0,
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : SingleChildScrollView(
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
                    value: agilidadXP / xpMax,
                    backgroundColor:
                        isDarkMode ? Colors.grey[800] : Colors.grey[300],
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.amber),
                    minHeight: 12,
                  ),
                  const SizedBox(height: 10),
                  Text('$agilidadXP / $xpMax XP',
                      style: TextStyle(
                          color: isDarkMode
                              ? AppColors.darkSecondaryText
                              : AppColors.lightSecondaryText)),
                  const SizedBox(height: 30),
                  Text('🚀 Misión principal:',
                      style: TextStyle(
                          fontSize: 20,
                          color: isDarkMode
                              ? AppColors.darkAccent
                              : AppColors.lightText)),
                  const SizedBox(height: 10),
                  Text(
                      'Haz una sesión de velocidad y coordinación por 30 minutos.',
                      style: TextStyle(
                          color: isDarkMode
                              ? AppColors.darkSecondaryText
                              : AppColors.lightSecondaryText)),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed:
                        puedeHacerPrincipal ? completarMisionPrincipal : null,
                    icon: const Icon(Icons.flash_on),
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
    );
  }
}
