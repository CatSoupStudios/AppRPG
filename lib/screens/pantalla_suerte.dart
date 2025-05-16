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

class PantallaSuerte extends StatefulWidget {
  @override
  _PantallaSuerteState createState() => _PantallaSuerteState();
}

class _PantallaSuerteState extends State<PantallaSuerte> {
  int suerteXP = 0;
  int suerteNivel = 1;
  DateTime? ultimaMisionPrincipal;
  bool cargando = true;
  Duration? tiempoRestantePrincipal;
  late final Ticker _ticker;

  final Duration cooldownMision = Duration(hours: 20);

  final List<MiniMision> todasLasMisiones = [
    MiniMision("Tira una moneda para tomar una decisión hoy 🪙🤞", 1),
    MiniMision("Haz algo sin planearlo y fluye con lo que venga 🎲✨", 1),
    MiniMision("Deja que alguien mas elija por ti en algo pequeño 👤🍀", 1),
    MiniMision("Compra un boleto de raspa y gana o crea uno casero 🎫🧃", 2),
    MiniMision(
        "Escribe tres cosas buenas que te pasaron por accidente 📜🔮", 1),
    MiniMision("Elige un número al azar y úsalo todo el día 🔢🎯", 1),
    MiniMision("Tira un dado real o virtual y haz lo que salga 🎲🧠", 2),
    MiniMision("Camina por una ruta distinta a la habitual 🛣️🌀", 1),
    MiniMision("Habla con alguien nuevo (en linea o en persona) 🗣️🌍", 1),
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
      suerteXP = prefs.getInt('suerte_xp') ?? 0;
      suerteNivel = prefs.getInt('suerte_nivel') ?? 1;
      ultimaMisionPrincipal =
          _getDateTime(prefs.getString('ultima_mision_suerte'));
      ultimaGeneracion =
          _getDateTime(prefs.getString('ultima_generacion_suerte'));
      indicesMisionesDia = (prefs.getStringList('misiones_suerte_dia') ?? [])
          .map(int.parse)
          .toList();
      cooldownsMisiones = Map.fromEntries(
        (prefs.getStringList('cooldowns_misiones_suerte') ?? []).map((e) {
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
        'ultima_generacion_suerte', ultimaGeneracion!.toIso8601String());
    await prefs.setStringList('misiones_suerte_dia',
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
      suerteXP += 3;
      ultimaMisionPrincipal = DateTime.now();
      while (suerteXP >= xpNecesaria(suerteNivel)) {
        suerteXP -= xpNecesaria(suerteNivel);
        suerteNivel++;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('🍀 ¡Subiste a nivel $suerteNivel en Suerte!')),
        );
      }
      tiempoRestantePrincipal = _calcularCooldown(ultimaMisionPrincipal);
    });
    await prefs.setInt('suerte_xp', suerteXP);
    await prefs.setInt('suerte_nivel', suerteNivel);
    await prefs.setString(
        'ultima_mision_suerte', ultimaMisionPrincipal!.toIso8601String());
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
      suerteXP += mision.xp;
      cooldownsMisiones[misionIndex] = DateTime.now();
      while (suerteXP >= xpNecesaria(suerteNivel)) {
        suerteXP -= xpNecesaria(suerteNivel);
        suerteNivel++;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('🍀 ¡Subiste a nivel $suerteNivel en Suerte!')),
        );
      }
    });

    await prefs.setInt('suerte_xp', suerteXP);
    await prefs.setInt('suerte_nivel', suerteNivel);
    await prefs.setStringList(
      'cooldowns_misiones_suerte',
      cooldownsMisiones.entries
          .map((e) => '${e.key}|${e.value.toIso8601String()}')
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final xpMaxima = xpNecesaria(suerteNivel);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
                    value: suerteXP / xpMaxima,
                    backgroundColor:
                        isDarkMode ? Colors.grey[800] : Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                    minHeight: 12,
                  ),
                  const SizedBox(height: 10),
                  Text('$suerteXP / $xpMaxima XP',
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
                    onPressed: _puedeHacerMisionPrincipal()
                        ? completarMisionPrincipal
                        : null,
                    icon: const Icon(Icons.casino),
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
