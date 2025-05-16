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

class PantallaVitalidad extends StatefulWidget {
  @override
  _PantallaVitalidadState createState() => _PantallaVitalidadState();
}

class _PantallaVitalidadState extends State<PantallaVitalidad> {
  int vitalidadXP = 0;
  int vitalidadNivel = 1;
  DateTime? ultimaMisionPrincipal;
  bool cargando = true;
  Duration? tiempoRestantePrincipal;
  late final Ticker _ticker;

  final Duration cooldownMision = Duration(hours: 20);

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
      vitalidadXP = prefs.getInt('vitalidad_xp') ?? 0;
      vitalidadNivel = prefs.getInt('vitalidad_nivel') ?? 1;
      ultimaMisionPrincipal =
          _getDateTime(prefs.getString('ultima_mision_vitalidad'));
      ultimaGeneracion =
          _getDateTime(prefs.getString('ultima_generacion_vitalidad'));
      indicesMisionesDia = (prefs.getStringList('misiones_vitalidad_dia') ?? [])
          .map(int.parse)
          .toList();
      cooldownsMisiones = Map.fromEntries(
        (prefs.getStringList('cooldowns_misiones_vitalidad') ?? []).map((e) {
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
        'ultima_generacion_vitalidad', ultimaGeneracion!.toIso8601String());
    await prefs.setStringList('misiones_vitalidad_dia',
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
      vitalidadXP += 3;
      ultimaMisionPrincipal = DateTime.now();
      while (vitalidadXP >= xpNecesaria(vitalidadNivel)) {
        vitalidadXP -= xpNecesaria(vitalidadNivel);
        vitalidadNivel++;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('❤️ ¡Subiste a nivel $vitalidadNivel en Vitalidad!')),
        );
      }
      tiempoRestantePrincipal = _calcularCooldown(ultimaMisionPrincipal);
    });
    await prefs.setInt('vitalidad_xp', vitalidadXP);
    await prefs.setInt('vitalidad_nivel', vitalidadNivel);
    await prefs.setString(
        'ultima_mision_vitalidad', ultimaMisionPrincipal!.toIso8601String());
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
      vitalidadXP += mision.xp;
      cooldownsMisiones[misionIndex] = DateTime.now();
      while (vitalidadXP >= xpNecesaria(vitalidadNivel)) {
        vitalidadXP -= xpNecesaria(vitalidadNivel);
        vitalidadNivel++;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('❤️ ¡Subiste a nivel $vitalidadNivel en Vitalidad!')),
        );
      }
    });

    await prefs.setInt('vitalidad_xp', vitalidadXP);
    await prefs.setInt('vitalidad_nivel', vitalidadNivel);
    await prefs.setStringList(
      'cooldowns_misiones_vitalidad',
      cooldownsMisiones.entries
          .map((e) => '${e.key}|${e.value.toIso8601String()}')
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final xpMaxima = xpNecesaria(vitalidadNivel);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
                    value: vitalidadXP / xpMaxima,
                    backgroundColor:
                        isDarkMode ? Colors.grey[800] : Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                    minHeight: 12,
                  ),
                  const SizedBox(height: 10),
                  Text('$vitalidadXP / $xpMaxima XP',
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
                              : AppColors.lightSecondaryText)),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _puedeHacerMisionPrincipal()
                        ? completarMisionPrincipal
                        : null,
                    icon: const Icon(Icons.favorite),
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
