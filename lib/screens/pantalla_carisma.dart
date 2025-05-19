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

class PantallaCarisma extends StatefulWidget {
  @override
  _PantallaCarismaState createState() => _PantallaCarismaState();
}

class _PantallaCarismaState extends State<PantallaCarisma> {
  int carismaXP = 0;
  int carismaNivel = 1;
  bool cargando = true;
  DateTime? ultimaGeneracion;
  DateTime? ultimaMisionPrincipal;
  List<int> indicesMisionesDia = [];
  Map<int, int> xpMiniMisiones = {};
  Map<int, bool> completadasHoy = {};
  late final Ticker _ticker;
  Duration tiempoRestante = Duration.zero;

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
    carismaXP = prefs.getInt('carisma_xp') ?? 0;
    carismaNivel = prefs.getInt('carisma_nivel') ?? 1;
    ultimaMisionPrincipal =
        _getDateTime(prefs.getString('ultima_mision_carisma'));
    ultimaGeneracion =
        _getDateTime(prefs.getString('ultima_generacion_carisma'));

    final mapaXpRaw = prefs.getStringList('xp_misiones_carisma') ?? [];
    xpMiniMisiones = {
      for (var e in mapaXpRaw)
        int.parse(e.split('|')[0]): int.parse(e.split('|')[1])
    };

    final completadasRaw = prefs.getStringList('completadas_carisma') ?? [];
    completadasHoy = {for (var i in completadasRaw) int.parse(i): true};

    indicesMisionesDia = (prefs.getStringList('misiones_carisma_dia') ?? [])
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
      await prefs.setStringList('misiones_carisma_dia',
          indicesMisionesDia.map((e) => e.toString()).toList());
      await prefs.setStringList('xp_misiones_carisma',
          xpMiniMisiones.entries.map((e) => '${e.key}|${e.value}').toList());
      await prefs.setStringList('completadas_carisma', []);
      await prefs.setString(
          'ultima_generacion_carisma', ahora.toIso8601String());
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
    carismaXP += xpGanada;
    ultimaMisionPrincipal = ahora;

    while (carismaXP >= xpNecesaria(carismaNivel)) {
      carismaXP -= xpNecesaria(carismaNivel);
      carismaNivel++;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('😎 ¡Subiste a nivel $carismaNivel en Carisma!')),
      );
    }

    await agregarXpDelDia(xpGanada);
    await prefs.setInt('carisma_xp', carismaXP);
    await prefs.setInt('carisma_nivel', carismaNivel);
    await prefs.setString('ultima_mision_carisma', ahora.toIso8601String());

    setState(() {});
  }

  Future<void> completarMiniMision(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final id = indicesMisionesDia[index];
    if (completadasHoy[id] == true) return;

    final xp = xpMiniMisiones[id] ?? 2;
    carismaXP += xp;
    completadasHoy[id] = true;

    while (carismaXP >= xpNecesaria(carismaNivel)) {
      carismaXP -= xpNecesaria(carismaNivel);
      carismaNivel++;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('😎 ¡Subiste a nivel $carismaNivel en Carisma!')),
      );
    }

    await agregarXpDelDia(xp);
    await prefs.setInt('carisma_xp', carismaXP);
    await prefs.setInt('carisma_nivel', carismaNivel);
    await prefs.setStringList(
        'completadas_carisma',
        completadasHoy.entries
            .where((e) => e.value)
            .map((e) => e.key.toString())
            .toList());

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final xpMax = xpNecesaria(carismaNivel);
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
                    value: carismaXP / xpMax,
                    backgroundColor:
                        isDarkMode ? Colors.grey[800] : Colors.grey[300],
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.amber),
                    minHeight: 12,
                  ),
                  const SizedBox(height: 10),
                  Text('$carismaXP / $xpMax XP',
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
                              : AppColors.lightSecondaryText)),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed:
                        puedeHacerPrincipal ? completarMisionPrincipal : null,
                    icon: const Icon(Icons.mic),
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
