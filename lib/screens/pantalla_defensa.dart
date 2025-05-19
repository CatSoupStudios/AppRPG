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

class PantallaDefensa extends StatefulWidget {
  @override
  _PantallaDefensaState createState() => _PantallaDefensaState();
}

class _PantallaDefensaState extends State<PantallaDefensa> {
  int defensaXP = 0;
  int defensaNivel = 1;
  bool cargando = true;
  DateTime? ultimaGeneracion;
  DateTime? ultimaMisionPrincipal;
  List<int> indicesMisionesDia = [];
  Map<int, int> xpMiniMisiones = {};
  Map<int, bool> completadasHoy = {};
  late final Ticker _ticker;
  Duration tiempoRestante = Duration.zero;

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
    defensaXP = prefs.getInt('defensa_xp') ?? 0;
    defensaNivel = prefs.getInt('defensa_nivel') ?? 1;
    ultimaMisionPrincipal =
        _getDateTime(prefs.getString('ultima_mision_defensa'));
    ultimaGeneracion =
        _getDateTime(prefs.getString('ultima_generacion_defensa'));

    final mapaXpRaw = prefs.getStringList('xp_misiones_defensa') ?? [];
    xpMiniMisiones = {
      for (var e in mapaXpRaw)
        int.parse(e.split('|')[0]): int.parse(e.split('|')[1])
    };

    final completadasRaw = prefs.getStringList('completadas_defensa') ?? [];
    completadasHoy = {for (var i in completadasRaw) int.parse(i): true};

    indicesMisionesDia = (prefs.getStringList('misiones_defensa_dia') ?? [])
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
      await prefs.setStringList('misiones_defensa_dia',
          indicesMisionesDia.map((e) => e.toString()).toList());
      await prefs.setStringList('xp_misiones_defensa',
          xpMiniMisiones.entries.map((e) => '${e.key}|${e.value}').toList());
      await prefs.setStringList('completadas_defensa', []);
      await prefs.setString(
          'ultima_generacion_defensa', ahora.toIso8601String());
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
    defensaXP += xpGanada;
    ultimaMisionPrincipal = ahora;

    while (defensaXP >= xpNecesaria(defensaNivel)) {
      defensaXP -= xpNecesaria(defensaNivel);
      defensaNivel++;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('🛡️ ¡Subiste a nivel $defensaNivel en Defensa!')),
      );
    }

    await agregarXpDelDia(xpGanada);
    await prefs.setInt('defensa_xp', defensaXP);
    await prefs.setInt('defensa_nivel', defensaNivel);
    await prefs.setString('ultima_mision_defensa', ahora.toIso8601String());

    setState(() {});
  }

  Future<void> completarMiniMision(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final id = indicesMisionesDia[index];
    if (completadasHoy[id] == true) return;

    final xp = xpMiniMisiones[id] ?? 2;
    defensaXP += xp;
    completadasHoy[id] = true;

    while (defensaXP >= xpNecesaria(defensaNivel)) {
      defensaXP -= xpNecesaria(defensaNivel);
      defensaNivel++;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('🛡️ ¡Subiste a nivel $defensaNivel en Defensa!')),
      );
    }

    await agregarXpDelDia(xp);
    await prefs.setInt('defensa_xp', defensaXP);
    await prefs.setInt('defensa_nivel', defensaNivel);
    await prefs.setStringList(
        'completadas_defensa',
        completadasHoy.entries
            .where((e) => e.value)
            .map((e) => e.key.toString())
            .toList());

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final xpMax = xpNecesaria(defensaNivel);
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
                    value: defensaXP / xpMax,
                    backgroundColor:
                        isDarkMode ? Colors.grey[800] : Colors.grey[300],
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.amber),
                    minHeight: 12,
                  ),
                  const SizedBox(height: 10),
                  Text('$defensaXP / $xpMax XP',
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
                    onPressed:
                        puedeHacerPrincipal ? completarMisionPrincipal : null,
                    icon: const Icon(Icons.shield),
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
