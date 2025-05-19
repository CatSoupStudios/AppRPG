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

  final List<MiniMision> todasLasMisiones = [
    MiniMision("Dormir mínimo 7 horas esta noche 🛏️💤", 1),
    MiniMision("Tomar 8 vasos de agua hoy 💧🫗", 1),
    MiniMision("Salir a tomar el sol 10 minutos ☀️😌", 1),
    MiniMision("Comer al menos una fruta 🍎🌿", 1),
    MiniMision("Estirarte por 5 minutos 🧘‍♂️🤸", 1),
    MiniMision("Evitar bebidas azucaradas hoy 🚫🥤", 1),
    MiniMision("Cocinar algo saludable tú mismo 🥗👨‍🍳", 2),
    MiniMision("Tomarte un descanso sin pantalla 📵🛋️", 1),
    MiniMision("Escuchar música que te relaje 🎶🧘", 1),
    MiniMision("Bañarte con calma, disfrutando el momento 🚿🫧", 1),
    MiniMision("Preparar tu cama antes de dormir 🛌💫", 1),
    MiniMision("Cenar ligero y temprano 🌙🥣", 1),
    MiniMision("Caminar al aire libre 15 minutos 🚶‍♂️🌳", 2),
    MiniMision("Practicar respiración consciente 3 minutos 🌬️🫁", 1),
    MiniMision("Evitar quejarte durante 1 hora 🧘‍♀️🤐", 1),
    MiniMision("Disfrutar conscientemente tu comida 🍽️🧠", 1),
    MiniMision("Dormir una siesta reparadora (máx 30min) 💤⏳", 1),
    MiniMision("Tomarte un té o infusión caliente 🍵🌿", 1),
    MiniMision("Agradecer 3 cosas antes de dormir 🙏🛌", 2),
    MiniMision("Hablar amablemente contigo mismo 🪞💖", 2),
    MiniMision("Reducir cafeína hoy ☕⬇️", 1),
    MiniMision("Leer algo que te calme antes de dormir 📖😴", 1),
    MiniMision("Evitar el celular 30 min antes de dormir 📱🚫", 2),
    MiniMision("Hacer una rutina de higiene personal completa 🧼🪥", 1),
    MiniMision("Decirle algo bonito a alguien hoy 💬❤️", 1),
    MiniMision("Usar ropa cómoda y limpia todo el día 👕🧼", 1),
    MiniMision("No compararte con nadie por hoy 🙅‍♂️🧠", 2),
    MiniMision("Dedicarte 5 minutos solo para ti ⏳❤️", 1),
    MiniMision("Desconectarte 1 hora de todo 🔌🌌", 2),
    MiniMision("Ver el cielo y respirar profundo por 1 min 🌤️🫁", 1),
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
    vitalidadXP = prefs.getInt('vitalidad_xp') ?? 0;
    vitalidadNivel = prefs.getInt('vitalidad_nivel') ?? 1;
    ultimaMisionPrincipal =
        _getDateTime(prefs.getString('ultima_mision_vitalidad'));
    ultimaGeneracion =
        _getDateTime(prefs.getString('ultima_generacion_vitalidad'));

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
      await prefs.setStringList('misiones_vitalidad_dia',
          indicesMisionesDia.map((e) => e.toString()).toList());
      await prefs.setStringList('xp_misiones_vitalidad',
          xpMiniMisiones.entries.map((e) => '${e.key}|${e.value}').toList());
      await prefs.setStringList('completadas_vitalidad', []);
      await prefs.setString(
          'ultima_generacion_vitalidad', ahora.toIso8601String());
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
    vitalidadXP += xpGanada;
    ultimaMisionPrincipal = ahora;

    while (vitalidadXP >= xpNecesaria(vitalidadNivel)) {
      vitalidadXP -= xpNecesaria(vitalidadNivel);
      vitalidadNivel++;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('❤️ ¡Subiste a nivel $vitalidadNivel en Vitalidad!')),
      );
    }

    await agregarXpDelDia(xpGanada);
    await prefs.setInt('vitalidad_xp', vitalidadXP);
    await prefs.setInt('vitalidad_nivel', vitalidadNivel);
    await prefs.setString('ultima_mision_vitalidad', ahora.toIso8601String());

    setState(() {});
  }

  Future<void> completarMiniMision(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final id = indicesMisionesDia[index];
    if (completadasHoy[id] == true) return;

    final xp = xpMiniMisiones[id] ?? 2;
    vitalidadXP += xp;
    completadasHoy[id] = true;

    while (vitalidadXP >= xpNecesaria(vitalidadNivel)) {
      vitalidadXP -= xpNecesaria(vitalidadNivel);
      vitalidadNivel++;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('❤️ ¡Subiste a nivel $vitalidadNivel en Vitalidad!')),
      );
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

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final xpMax = xpNecesaria(vitalidadNivel);
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
        title: Text('❤️ Misión de Vitalidad',
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
                  Text('Nivel: $vitalidadNivel',
                      style: TextStyle(
                          fontSize: 24,
                          color: isDarkMode
                              ? AppColors.darkAccent
                              : AppColors.lightText)),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: vitalidadXP / xpMax,
                    backgroundColor:
                        isDarkMode ? Colors.grey[800] : Colors.grey[300],
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.amber),
                    minHeight: 12,
                  ),
                  const SizedBox(height: 10),
                  Text('$vitalidadXP / $xpMax XP',
                      style: TextStyle(
                          color: isDarkMode
                              ? AppColors.darkSecondaryText
                              : AppColors.lightSecondaryText)),
                  const SizedBox(height: 30),
                  Text('🫀 Misión principal:',
                      style: TextStyle(
                          fontSize: 20,
                          color: isDarkMode
                              ? AppColors.darkAccent
                              : AppColors.lightText)),
                  const SizedBox(height: 10),
                  Text(
                    'Dedica 30 minutos solo para ti. Sin culpa. Sin interrupciones.',
                    style: TextStyle(
                        color: isDarkMode
                            ? AppColors.darkSecondaryText
                            : AppColors.lightSecondaryText),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed:
                        puedeHacerPrincipal ? completarMisionPrincipal : null,
                    icon: const Icon(Icons.favorite),
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
                  Text('💓 Mini-misiones del día:',
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
