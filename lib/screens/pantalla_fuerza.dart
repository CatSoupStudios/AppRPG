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

class PantallaFuerza extends StatefulWidget {
  @override
  _PantallaFuerzaState createState() => _PantallaFuerzaState();
}

class _PantallaFuerzaState extends State<PantallaFuerza> {
  int fuerzaXP = 0;
  int fuerzaNivel = 1;
  DateTime? ultimaMisionPrincipal;
  bool cargando = true;
  Duration? tiempoRestantePrincipal;
  late final Ticker _ticker;

  final Duration cooldownMision = Duration(hours: 20);

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
      fuerzaXP = prefs.getInt('fuerza_xp') ?? 0;
      fuerzaNivel = prefs.getInt('fuerza_nivel') ?? 1;
      ultimaMisionPrincipal =
          _getDateTime(prefs.getString('ultima_mision_fuerza'));
      ultimaGeneracion =
          _getDateTime(prefs.getString('ultima_generacion_fuerza'));
      indicesMisionesDia = (prefs.getStringList('misiones_fuerza_dia') ?? [])
          .map(int.parse)
          .toList();
      cooldownsMisiones = Map.fromEntries(
        (prefs.getStringList('cooldowns_misiones_fuerza') ?? []).map((e) {
          final split = e.split('|');
          return MapEntry(int.parse(split[0]), _getDateTime(split[1])!);
        }),
      );

      if (_debeRegenerar()) {
        _generarMisionesDelDia();
      }

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
        'ultima_generacion_fuerza', ultimaGeneracion!.toIso8601String());
    await prefs.setStringList('misiones_fuerza_dia',
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
      fuerzaXP += 3;
      ultimaMisionPrincipal = DateTime.now();
      while (fuerzaXP >= xpNecesaria(fuerzaNivel)) {
        fuerzaXP -= xpNecesaria(fuerzaNivel);
        fuerzaNivel++;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('💪 ¡Subiste a nivel $fuerzaNivel en Fuerza!')),
        );
      }
      tiempoRestantePrincipal = _calcularCooldown(ultimaMisionPrincipal);
    });
    await prefs.setInt('fuerza_xp', fuerzaXP);
    await prefs.setInt('fuerza_nivel', fuerzaNivel);
    await prefs.setString(
        'ultima_mision_fuerza', ultimaMisionPrincipal!.toIso8601String());
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
      fuerzaXP += mision.xp;
      cooldownsMisiones[misionIndex] = DateTime.now();
      while (fuerzaXP >= xpNecesaria(fuerzaNivel)) {
        fuerzaXP -= xpNecesaria(fuerzaNivel);
        fuerzaNivel++;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('💪 ¡Subiste a nivel $fuerzaNivel en Fuerza!')),
        );
      }
    });

    await prefs.setInt('fuerza_xp', fuerzaXP);
    await prefs.setInt('fuerza_nivel', fuerzaNivel);
    await prefs.setStringList(
        'cooldowns_misiones_fuerza',
        cooldownsMisiones.entries
            .map((e) => '${e.key}|${e.value.toIso8601String()}')
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    final xpMaxima = xpNecesaria(fuerzaNivel);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
          : SingleChildScrollView(
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
                    value: fuerzaXP / xpMaxima,
                    backgroundColor:
                        isDarkMode ? Colors.grey[800] : Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                    minHeight: 12,
                  ),
                  const SizedBox(height: 10),
                  Text('$fuerzaXP / $xpMaxima XP',
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
                  Text('Realiza 30 minutos de ejercicio físico intenso hoy.',
                      style: TextStyle(
                          color: isDarkMode
                              ? AppColors.darkSecondaryText
                              : AppColors.lightSecondaryText)),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _puedeHacerMisionPrincipal()
                        ? completarMisionPrincipal
                        : null,
                    icon: const Icon(Icons.fitness_center),
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
                        '⏳ Puedes volver a entrenar en: ${_formatearDuracion(tiempoRestantePrincipal!)}',
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
