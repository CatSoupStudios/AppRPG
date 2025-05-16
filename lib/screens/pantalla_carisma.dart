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

class PantallaCarisma extends StatefulWidget {
  @override
  _PantallaCarismaState createState() => _PantallaCarismaState();
}

class _PantallaCarismaState extends State<PantallaCarisma> {
  int carismaXP = 0;
  int carismaNivel = 1;
  DateTime? ultimaMisionPrincipal;
  bool cargando = true;
  Duration? tiempoRestantePrincipal;
  late final Ticker _ticker;

  final Duration cooldownMision = Duration(hours: 20);

  final List<MiniMision> todasLasMisiones = [
    MiniMision("Haz contacto visual con 3 personas hoy 👀💥", 1),
    MiniMision("Sonríe intencionalmente a alguien que no conoces 😄✨", 1),
    MiniMision("Hazle un cumplido genuino a alguien hoy 🗣️❤️", 1),
    MiniMision("Escucha a alguien sin interrumpir por 2 minutos 👂🕰️", 1),
    MiniMision("Mira al espejo y di algo positivo de ti 🪞💬", 1),
    MiniMision("Grábate diciendo algo que crees con fuerza 🎤🔥", 2),
    MiniMision("Cuéntale algo bueno de tu día a alguien 🗣️🌞", 1),
    MiniMision("Haz una pregunta profunda a alguien 🤔🧠", 2),
    MiniMision("Comparte una historia personal corta 📖💭", 1),
    MiniMision("Inicia una conversación con alguien nuevo 👋😌", 2),
    MiniMision("Vístete como realmente te gusta hoy 👕😎", 1),
    MiniMision("Di algo que piensas aunque te dé pena 💭🫣", 2),
    MiniMision("Haz reír a alguien intencionalmente 😂💥", 1),
    MiniMision("Escribe una carta o mensaje sincero 💌🫂", 2),
    MiniMision("Expresa desacuerdo con respeto ✋🤝", 1),
    MiniMision("Sube una foto o video siendo tú sin filtros 📷🙌", 2),
    MiniMision("Llama a alguien en vez de solo mandar texto 📞🤗", 1),
    MiniMision("Recuerda el nombre de alguien nuevo 🧠📛", 1),
    MiniMision("Haz una pregunta en público o grupo 💬😳", 2),
    MiniMision("Comparte una recomendación sincera 📚🎬", 1),
    MiniMision("Evita hablar mal de alguien por todo un día 🙊🚫", 2),
    MiniMision("Da las gracias de forma creativa 🙏🎨", 1),
    MiniMision("Haz un mini discurso frente al espejo 🎙️🪞", 1),
    MiniMision("Saluda con energía al entrar a un lugar 👋⚡", 1),
    MiniMision("Muestra entusiasmo al escuchar algo que te cuenten 😃👂", 1),
    MiniMision("Practica decir “no” con firmeza y respeto ❌🧘", 2),
    MiniMision("Conecta con alguien hablando de algo profundo 🌌🗣️", 2),
    MiniMision("Publica una opinión sincera sin miedo 💬🔥", 2),
    MiniMision("Pide retroalimentación sincera a alguien 📝😅", 2),
    MiniMision("Hazte notar sin esforzarte. Solo sé tú 😎💫", 1),
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
      carismaXP = prefs.getInt('carisma_xp') ?? 0;
      carismaNivel = prefs.getInt('carisma_nivel') ?? 1;
      ultimaMisionPrincipal =
          _getDateTime(prefs.getString('ultima_mision_carisma'));
      ultimaGeneracion =
          _getDateTime(prefs.getString('ultima_generacion_carisma'));
      indicesMisionesDia = (prefs.getStringList('misiones_carisma_dia') ?? [])
          .map(int.parse)
          .toList();
      cooldownsMisiones = Map.fromEntries(
        (prefs.getStringList('cooldowns_misiones_carisma') ?? []).map((e) {
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
        'ultima_generacion_carisma', ultimaGeneracion!.toIso8601String());
    await prefs.setStringList('misiones_carisma_dia',
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
      carismaXP += 3;
      ultimaMisionPrincipal = DateTime.now();
      while (carismaXP >= xpNecesaria(carismaNivel)) {
        carismaXP -= xpNecesaria(carismaNivel);
        carismaNivel++;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('😎 ¡Subiste a nivel $carismaNivel en Carisma!')),
        );
      }
      tiempoRestantePrincipal = _calcularCooldown(ultimaMisionPrincipal);
    });
    await prefs.setInt('carisma_xp', carismaXP);
    await prefs.setInt('carisma_nivel', carismaNivel);
    await prefs.setString(
        'ultima_mision_carisma', ultimaMisionPrincipal!.toIso8601String());
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
      carismaXP += mision.xp;
      cooldownsMisiones[misionIndex] = DateTime.now();
      while (carismaXP >= xpNecesaria(carismaNivel)) {
        carismaXP -= xpNecesaria(carismaNivel);
        carismaNivel++;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('😎 ¡Subiste a nivel $carismaNivel en Carisma!')),
        );
      }
    });

    await prefs.setInt('carisma_xp', carismaXP);
    await prefs.setInt('carisma_nivel', carismaNivel);
    await prefs.setStringList(
      'cooldowns_misiones_carisma',
      cooldownsMisiones.entries
          .map((e) => '${e.key}|${e.value.toIso8601String()}')
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final xpMaxima = xpNecesaria(carismaNivel);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor:
            isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
        title: Text('😎 Misión de Carisma',
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
                  Text('Nivel: $carismaNivel',
                      style: TextStyle(
                          fontSize: 24,
                          color: isDarkMode
                              ? AppColors.darkAccent
                              : AppColors.lightText)),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: carismaXP / xpMaxima,
                    backgroundColor:
                        isDarkMode ? Colors.grey[800] : Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                    minHeight: 12,
                  ),
                  const SizedBox(height: 10),
                  Text('$carismaXP / $xpMaxima XP',
                      style: TextStyle(
                          color: isDarkMode
                              ? AppColors.darkSecondaryText
                              : AppColors.lightSecondaryText)),
                  const SizedBox(height: 30),
                  Text('🎤 Misión principal:',
                      style: TextStyle(
                          fontSize: 20,
                          color: isDarkMode
                              ? AppColors.darkAccent
                              : AppColors.lightText)),
                  const SizedBox(height: 10),
                  Text(
                    'Exprésate con autenticidad durante 30 minutos. Sin máscaras. Sin filtros.',
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
                    icon: const Icon(Icons.mic),
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
                  Text('😎 Mini-misiones del día:',
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
