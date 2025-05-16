import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/scheduler.dart';
import 'dart:math';
import '../utils/colors.dart';

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
  DateTime? ultimaMisionPrincipal;
  bool cargando = true;
  Duration? tiempoRestantePrincipal;
  late final Ticker _ticker;

  final Duration cooldownMision = Duration(hours: 20);

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

  List<int> indicesMisionesDia = [];
  Map<int, DateTime> cooldownsMisiones = {};
  DateTime? ultimaGeneracion;

  @override
  void initState() {
    super.initState();
    cargarDatos();
    _ticker = Ticker((_) {
      if (!mounted) return;
      setState(() {
        tiempoRestantePrincipal = _calcularCooldown(ultimaMisionPrincipal);
      });
    })
      ..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  Future<void> cargarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      agilidadXP = prefs.getInt('agilidad_xp') ?? 0;
      agilidadNivel = prefs.getInt('agilidad_nivel') ?? 1;
      ultimaMisionPrincipal =
          _getDateTime(prefs.getString('ultima_mision_agilidad'));
      ultimaGeneracion =
          _getDateTime(prefs.getString('ultima_generacion_agilidad'));
      indicesMisionesDia = (prefs.getStringList('misiones_agilidad_dia') ?? [])
          .map(int.parse)
          .toList();
      cooldownsMisiones = Map.fromEntries(
        (prefs.getStringList('cooldowns_misiones_agilidad') ?? []).map((e) {
          final split = e.split('|');
          return MapEntry(int.parse(split[0]), _getDateTime(split[1])!);
        }),
      );

      if (_debeRegenerar()) _generarMisionesDelDia();

      tiempoRestantePrincipal = _calcularCooldown(ultimaMisionPrincipal);
      cargando = false;
    });
  }

  bool _debeRegenerar() {
    if (ultimaGeneracion == null) return true;
    return DateTime.now().difference(ultimaGeneracion!) >= cooldownMision;
  }

  void _generarMisionesDelDia() async {
    final prefs = await SharedPreferences.getInstance();
    final random = Random();
    final indices = <int>{};
    while (indices.length < 5) {
      indices.add(random.nextInt(todasLasMisiones.length));
    }
    indicesMisionesDia = indices.toList();
    ultimaGeneracion = DateTime.now();
    await prefs.setString(
        'ultima_generacion_agilidad', ultimaGeneracion!.toIso8601String());
    await prefs.setStringList('misiones_agilidad_dia',
        indicesMisionesDia.map((e) => e.toString()).toList());
  }

  DateTime? _getDateTime(String? str) {
    if (str == null) return null;
    return DateTime.tryParse(str);
  }

  Duration? _calcularCooldown(DateTime? ultima) {
    if (ultima == null) return null;
    final restante = cooldownMision - DateTime.now().difference(ultima);
    return restante.isNegative ? null : restante;
  }

  String _formatearDuracion(Duration duracion) {
    final horas = duracion.inHours;
    final minutos = duracion.inMinutes % 60;
    final segundos = duracion.inSeconds % 60;
    return '${horas}h ${minutos}m ${segundos}s';
  }

  int xpNecesaria(int nivel) => 10 + (nivel - 1) * 5;

  Future<void> completarMisionPrincipal() async {
    if (!_puedeHacerMisionPrincipal()) return;
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      agilidadXP += 3;
      ultimaMisionPrincipal = DateTime.now();
      while (agilidadXP >= xpNecesaria(agilidadNivel)) {
        agilidadXP -= xpNecesaria(agilidadNivel);
        agilidadNivel++;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('⚡ ¡Subiste a nivel $agilidadNivel en Agilidad!')),
        );
      }
      tiempoRestantePrincipal = _calcularCooldown(ultimaMisionPrincipal);
    });
    await prefs.setInt('agilidad_xp', agilidadXP);
    await prefs.setInt('agilidad_nivel', agilidadNivel);
    await prefs.setString(
        'ultima_mision_agilidad', ultimaMisionPrincipal!.toIso8601String());
  }

  bool _puedeHacerMisionPrincipal() {
    return ultimaMisionPrincipal == null ||
        DateTime.now().difference(ultimaMisionPrincipal!) >= cooldownMision;
  }

  Future<void> completarMiniMision(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final misionIndex = indicesMisionesDia[index];
    final mision = todasLasMisiones[misionIndex];
    if (cooldownsMisiones[misionIndex] != null &&
        DateTime.now().difference(cooldownsMisiones[misionIndex]!) <
            cooldownMision) return;

    setState(() {
      agilidadXP += mision.xp;
      cooldownsMisiones[misionIndex] = DateTime.now();
      while (agilidadXP >= xpNecesaria(agilidadNivel)) {
        agilidadXP -= xpNecesaria(agilidadNivel);
        agilidadNivel++;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('⚡ ¡Subiste a nivel $agilidadNivel en Agilidad!')),
        );
      }
    });

    await prefs.setInt('agilidad_xp', agilidadXP);
    await prefs.setInt('agilidad_nivel', agilidadNivel);
    await prefs.setStringList(
      'cooldowns_misiones_agilidad',
      cooldownsMisiones.entries
          .map((e) => '${e.key}|${e.value.toIso8601String()}')
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final xpMaxima = xpNecesaria(agilidadNivel);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
                    value: agilidadXP / xpMaxima,
                    backgroundColor:
                        isDarkMode ? Colors.grey[800] : Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                    minHeight: 12,
                  ),
                  const SizedBox(height: 10),
                  Text('$agilidadXP / $xpMaxima XP',
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
                    onPressed: _puedeHacerMisionPrincipal()
                        ? completarMisionPrincipal
                        : null,
                    icon: const Icon(Icons.flash_on),
                    label: Text(_puedeHacerMisionPrincipal()
                        ? 'Completar misión (+3 XP)'
                        : 'Ya completada (20h cooldown)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                  if (!_puedeHacerMisionPrincipal() &&
                      tiempoRestantePrincipal != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '⏳ Próxima sesión disponible en: ${_formatearDuracion(tiempoRestantePrincipal!)}',
                        style: TextStyle(
                            color: isDarkMode
                                ? AppColors.darkSecondaryText
                                : AppColors.lightSecondaryText),
                      ),
                    ),
                  const SizedBox(height: 40),
                  Text('⚡ Mini-misiones del día:',
                      style: TextStyle(
                          fontSize: 20,
                          color: isDarkMode
                              ? AppColors.darkAccent
                              : AppColors.lightText)),
                  const SizedBox(height: 10),
                  ...List.generate(indicesMisionesDia.length, (i) {
                    final idx = indicesMisionesDia[i];
                    final mision = todasLasMisiones[idx];
                    final enCooldown = cooldownsMisiones[idx] != null &&
                        DateTime.now().difference(cooldownsMisiones[idx]!) <
                            cooldownMision;
                    final tiempoRestante =
                        _calcularCooldown(cooldownsMisiones[idx]);

                    return Card(
                      color: isDarkMode
                          ? (enCooldown ? Colors.grey[900] : Colors.black)
                          : (enCooldown ? Colors.grey[300] : Colors.white),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(mision.descripcion,
                            style: TextStyle(
                                color: isDarkMode
                                    ? AppColors.darkText
                                    : AppColors.lightText)),
                        subtitle: Text('+${mision.xp} XP',
                            style: TextStyle(
                                color: isDarkMode
                                    ? Colors.amber[300]
                                    : Colors.amber[800])),
                        trailing: enCooldown
                            ? Text('⏳ ${_formatearDuracion(tiempoRestante!)}',
                                style: TextStyle(
                                    color: isDarkMode
                                        ? AppColors.darkSecondaryText
                                        : AppColors.lightSecondaryText))
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
