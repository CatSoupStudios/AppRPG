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

class PantallaSuerte extends StatefulWidget {
  @override
  _PantallaSuerteState createState() => _PantallaSuerteState();
}

class _PantallaSuerteState extends State<PantallaSuerte> {
  int suerteXP = 0;
  int suerteNivel = 1;
  bool cargando = true;
  DateTime? ultimaGeneracion;
  DateTime? ultimaMisionPrincipal;
  List<int> indicesMisionesDia = [];
  Map<int, int> xpMiniMisiones = {};
  Map<int, bool> completadasHoy = {};
  late final Ticker _ticker;
  Duration tiempoRestante = Duration.zero;

  final List<MiniMision> todasLasMisiones = [
    MiniMision("Tira una moneda para tomar una decisión hoy 🪙🤞", 1),
    MiniMision("Haz algo sin planearlo y fluye con lo que venga 🎲✨", 1),
    MiniMision("Deja que alguien más elija por ti en algo pequeño 👤🍀", 1),
    MiniMision("Compra un boleto de raspa y gana o crea uno casero 🎫🧃", 2),
    MiniMision(
        "Escribe tres cosas buenas que te pasaron por accidente 📜🔮", 1),
    MiniMision("Elige un número al azar y úsalo todo el día 🔢🎯", 1),
    MiniMision("Tira un dado real o virtual y haz lo que salga 🎲🧠", 2),
    MiniMision("Camina por una ruta distinta a la habitual 🛣️🌀", 1),
    MiniMision("Habla con alguien nuevo (en línea o en persona) 🗣️🌍", 1),
    MiniMision("Acepta una propuesta inesperada hoy 📩🫣", 2),
    MiniMision("Busca una moneda tirada en la calle 🪙👀", 1),
    MiniMision("Prueba una comida nueva o que nunca pides 🍱🎰", 1),
    MiniMision("Haz una lista de coincidencias que te han marcado ✍️🧿", 2),
    MiniMision("Usa algo de ropa que no te pones seguido 👕🎲", 1),
    MiniMision("Ve a un lugar nuevo dentro de tu ciudad 🧭🏙️", 2),
    MiniMision("Acepta un error como una señal positiva 🔄💫", 1),
    MiniMision("Escoge un libro y abre una página al azar. Léela 📖🔮", 1),
    MiniMision("Haz un deseo y tíralo al universo 🌌💭", 1),
    MiniMision("Usa un número favorito en algo hoy 🔢❤️", 1),
    MiniMision(
        "Escribe una historia improvisada con 3 palabras random ✍️🎲", 2),
    MiniMision("Cierra los ojos y elige algo de una lista 🍽️👁️", 1),
    MiniMision("Pide un consejo y síguelo sin cuestionarlo 🧙‍♂️🔮", 2),
    MiniMision("Haz algo que normalmente evitarías por miedo 😨🍀", 2),
    MiniMision("Regala algo pequeño a alguien al azar 🎁😊", 1),
    MiniMision("Toma una decisión rápido, sin pensar de más ⚡🌀", 1),
    MiniMision("Haz algo que dependa 100% del azar hoy 🎯🎲", 2),
    MiniMision("Busca un trébol real o digital ☘️🔍", 1),
    MiniMision("Usa algo de la suerte tuyo o inventa uno 🧤✨", 1),
    MiniMision("Escribe lo bueno que salió de algo inesperado 📜🌈", 1),
    MiniMision("Deja que tu instinto elija algo por ti hoy 🧠🔁", 2),
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
    suerteXP = prefs.getInt('suerte_xp') ?? 0;
    suerteNivel = prefs.getInt('suerte_nivel') ?? 1;
    ultimaMisionPrincipal =
        _getDateTime(prefs.getString('ultima_mision_suerte'));
    ultimaGeneracion =
        _getDateTime(prefs.getString('ultima_generacion_suerte'));

    final mapaXpRaw = prefs.getStringList('xp_misiones_suerte') ?? [];
    xpMiniMisiones = {
      for (var e in mapaXpRaw)
        int.parse(e.split('|')[0]): int.parse(e.split('|')[1])
    };

    final completadasRaw = prefs.getStringList('completadas_suerte') ?? [];
    completadasHoy = {for (var i in completadasRaw) int.parse(i): true};

    indicesMisionesDia = (prefs.getStringList('misiones_suerte_dia') ?? [])
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
      await prefs.setStringList('misiones_suerte_dia',
          indicesMisionesDia.map((e) => e.toString()).toList());
      await prefs.setStringList('xp_misiones_suerte',
          xpMiniMisiones.entries.map((e) => '${e.key}|${e.value}').toList());
      await prefs.setStringList('completadas_suerte', []);
      await prefs.setString(
          'ultima_generacion_suerte', ahora.toIso8601String());
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
    suerteXP += xpGanada;
    ultimaMisionPrincipal = ahora;

    while (suerteXP >= xpNecesaria(suerteNivel)) {
      suerteXP -= xpNecesaria(suerteNivel);
      suerteNivel++;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('🍀 ¡Subiste a nivel $suerteNivel en Suerte!')),
      );
    }

    await agregarXpDelDia(xpGanada);
    await prefs.setInt('suerte_xp', suerteXP);
    await prefs.setInt('suerte_nivel', suerteNivel);
    await prefs.setString('ultima_mision_suerte', ahora.toIso8601String());

    setState(() {});
  }

  Future<void> completarMiniMision(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final id = indicesMisionesDia[index];
    if (completadasHoy[id] == true) return;

    final xp = xpMiniMisiones[id] ?? 2;
    suerteXP += xp;
    completadasHoy[id] = true;

    while (suerteXP >= xpNecesaria(suerteNivel)) {
      suerteXP -= xpNecesaria(suerteNivel);
      suerteNivel++;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('🍀 ¡Subiste a nivel $suerteNivel en Suerte!')),
      );
    }

    await agregarXpDelDia(xp);
    await prefs.setInt('suerte_xp', suerteXP);
    await prefs.setInt('suerte_nivel', suerteNivel);
    await prefs.setStringList(
        'completadas_suerte',
        completadasHoy.entries
            .where((e) => e.value)
            .map((e) => e.key.toString())
            .toList());

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final xpMax = xpNecesaria(suerteNivel);
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
        title: Text('🍀 Misión de Suerte',
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
                  Text('Nivel: $suerteNivel',
                      style: TextStyle(
                          fontSize: 24,
                          color: isDarkMode
                              ? AppColors.darkAccent
                              : AppColors.lightText)),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: suerteXP / xpMax,
                    backgroundColor:
                        isDarkMode ? Colors.grey[800] : Colors.grey[300],
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.amber),
                    minHeight: 12,
                  ),
                  const SizedBox(height: 10),
                  Text('$suerteXP / $xpMax XP',
                      style: TextStyle(
                          color: isDarkMode
                              ? AppColors.darkSecondaryText
                              : AppColors.lightSecondaryText)),
                  const SizedBox(height: 30),
                  Text('🎯 Misión principal:',
                      style: TextStyle(
                          fontSize: 20,
                          color: isDarkMode
                              ? AppColors.darkAccent
                              : AppColors.lightText)),
                  const SizedBox(height: 10),
                  Text(
                    'Haz algo que dependa completamente del azar. Sin pensar. Solo hazlo.',
                    style: TextStyle(
                        color: isDarkMode
                            ? AppColors.darkSecondaryText
                            : AppColors.lightSecondaryText),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed:
                        puedeHacerPrincipal ? completarMisionPrincipal : null,
                    icon: const Icon(Icons.casino),
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
                  Text('🎲 Mini-misiones del día:',
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
