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

class PantallaDefensa extends StatefulWidget {
  @override
  _PantallaDefensaState createState() => _PantallaDefensaState();
}

class _PantallaDefensaState extends State<PantallaDefensa> {
  int defensaXP = 0;
  int defensaNivel = 1;
  DateTime? ultimaMisionPrincipal;
  bool cargando = true;
  Duration? tiempoRestantePrincipal;
  late final Ticker _ticker;

  final Duration cooldownMision = Duration(hours: 20);

  final List<MiniMision> todasLasMisiones = [
    MiniMision("Bloquea 10 ataques imaginarios 💥🛡️", 1),
    MiniMision("Medita bajo la lluvia 5 minutos 🌧️🧘", 1),
    MiniMision("Camina con un libro en la cabeza 📚😌", 1),
    MiniMision("Recibe sabiduría de tu abuela 👵✨", 1),
    MiniMision("Resiste 1 minuto de silencio absoluto 🤫🧠", 1),
    MiniMision("Lávate la cara con agua helada ❄️🧼", 1),
    MiniMision("Haz 20 respiraciones profundas 🌬️🫁", 1),
    MiniMision("Pon una alarma y no la pospongas mañana ⏰⚔️", 1),
    MiniMision("Evita enojarte durante una discusión 🧘‍♂️🔥", 1),
    MiniMision("Haz una lista de tus límites personales ✍️🛡️", 1),
    MiniMision("Escribe una carta a tu yo del pasado 📝🧍‍♂️", 1),
    MiniMision("Aguanta 1 minuto en posición de muro invisible 🧍‍♂️🧱", 2),
    MiniMision("Dúchate con agua fría durante 30 segundos 🚿❄️", 2),
    MiniMision("Ignora por completo una provocación digital 📱🚫", 1),
    MiniMision("Cierra los ojos y visualiza un escudo de luz ✨🛡️", 1),
    MiniMision("No revises redes por 1 hora 📵🧘", 1),
    MiniMision("Haz 10 sentadillas lentas 🏋️🧍", 1),
    MiniMision("Tómate un té sin azúcar y sin quejarte 🍵😑", 1),
    MiniMision("Perdona a alguien (aunque no se lo digas) 💔➡️💖", 2),
    MiniMision("Apaga tu teléfono por 20 minutos y solo respira 📴🫁", 1),
    MiniMision("Escribe tres cosas que te hieren y rómpelas 📝🔥", 2),
    MiniMision("Canta fuerte una canción de tu infancia 🎶🧒", 1),
    MiniMision("Mira al espejo y dite “hoy no me voy a romper” 🪞🗣️", 1),
    MiniMision("Aguanta 1 minuto en plancha 💪🛡️", 2),
    MiniMision("Haz contacto visual contigo en el espejo 30 seg 👀🪞", 1),
    MiniMision("Di “no” a algo que no quieres hacer hoy 🚫📆", 1),
    MiniMision("Dibuja un símbolo que represente tu fortaleza ✍️🌀", 1),
    MiniMision("Escribe lo que te haría sentir seguro y por qué 📝🏰", 1),
    MiniMision("Escucha música instrumental 10 min sin distracciones 🎻🧘", 1),
    MiniMision("Levántate sin mirar el celular por 15 minutos ☀️📵", 1),
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
      defensaXP = prefs.getInt('defensa_xp') ?? 0;
      defensaNivel = prefs.getInt('defensa_nivel') ?? 1;
      ultimaMisionPrincipal =
          _getDateTime(prefs.getString('ultima_mision_defensa'));
      ultimaGeneracion =
          _getDateTime(prefs.getString('ultima_generacion_defensa'));
      indicesMisionesDia = (prefs.getStringList('misiones_defensa_dia') ?? [])
          .map(int.parse)
          .toList();
      cooldownsMisiones = Map.fromEntries(
        (prefs.getStringList('cooldowns_misiones_defensa') ?? []).map((e) {
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
        'ultima_generacion_defensa', ultimaGeneracion!.toIso8601String());
    await prefs.setStringList('misiones_defensa_dia',
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
      defensaXP += 3;
      ultimaMisionPrincipal = DateTime.now();
      while (defensaXP >= xpNecesaria(defensaNivel)) {
        defensaXP -= xpNecesaria(defensaNivel);
        defensaNivel++;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('🛡️ ¡Subiste a nivel $defensaNivel en Defensa!')),
        );
      }
      tiempoRestantePrincipal = _calcularCooldown(ultimaMisionPrincipal);
    });
    await prefs.setInt('defensa_xp', defensaXP);
    await prefs.setInt('defensa_nivel', defensaNivel);
    await prefs.setString(
        'ultima_mision_defensa', ultimaMisionPrincipal!.toIso8601String());
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
      defensaXP += mision.xp;
      cooldownsMisiones[misionIndex] = DateTime.now();
      while (defensaXP >= xpNecesaria(defensaNivel)) {
        defensaXP -= xpNecesaria(defensaNivel);
        defensaNivel++;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('🛡️ ¡Subiste a nivel $defensaNivel en Defensa!')),
        );
      }
    });

    await prefs.setInt('defensa_xp', defensaXP);
    await prefs.setInt('defensa_nivel', defensaNivel);
    await prefs.setStringList(
      'cooldowns_misiones_defensa',
      cooldownsMisiones.entries
          .map((e) => '${e.key}|${e.value.toIso8601String()}')
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final xpMaxima = xpNecesaria(defensaNivel);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor:
            isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
        title: Text('🛡️ Misión de Defensa',
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
                  Text('Nivel: $defensaNivel',
                      style: TextStyle(
                          fontSize: 24,
                          color: isDarkMode
                              ? AppColors.darkAccent
                              : AppColors.lightText)),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: defensaXP / xpMaxima,
                    backgroundColor:
                        isDarkMode ? Colors.grey[800] : Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                    minHeight: 12,
                  ),
                  const SizedBox(height: 10),
                  Text('$defensaXP / $xpMaxima XP',
                      style: TextStyle(
                          color: isDarkMode
                              ? AppColors.darkSecondaryText
                              : AppColors.lightSecondaryText)),
                  const SizedBox(height: 30),
                  Text('🔰 Misión principal:',
                      style: TextStyle(
                          fontSize: 20,
                          color: isDarkMode
                              ? AppColors.darkAccent
                              : AppColors.lightText)),
                  const SizedBox(height: 10),
                  Text(
                      'Haz una sesión de 30 minutos de resistencia mental hoy.',
                      style: TextStyle(
                          color: isDarkMode
                              ? AppColors.darkSecondaryText
                              : AppColors.lightSecondaryText)),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _puedeHacerMisionPrincipal()
                        ? completarMisionPrincipal
                        : null,
                    icon: const Icon(Icons.shield),
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
                  Text('🧱 Mini-misiones del día:',
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
