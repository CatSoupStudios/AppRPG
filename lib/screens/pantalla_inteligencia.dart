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

class PantallaInteligencia extends StatefulWidget {
  @override
  _PantallaInteligenciaState createState() => _PantallaInteligenciaState();
}

class _PantallaInteligenciaState extends State<PantallaInteligencia> {
  int inteligenciaXP = 0;
  int inteligenciaNivel = 1;
  bool cargando = true;
  DateTime? ultimaGeneracion;
  DateTime? ultimaMisionPrincipal;
  List<int> indicesMisionesDia = [];
  Map<int, int> xpMiniMisiones = {};
  Map<int, bool> completadasHoy = {};
  late final Ticker _ticker;
  Duration tiempoRestante = Duration.zero;

  final List<MiniMision> todasLasMisiones = [
    MiniMision("Leer 5 páginas de un libro 📖🧠", 1),
    MiniMision("Ver un video educativo 📺🎓", 1),
    MiniMision("Resolver un acertijo lógico 🧩🧠", 2),
    MiniMision("Meditar 10 minutos 🧘🌀", 1),
    MiniMision("Escribir una idea o reflexión ✍️💭", 1),
    MiniMision("Escuchar un podcast de ciencia 🎧🔬", 1),
    MiniMision("Aprender una palabra nueva en otro idioma 🗣️🌍", 1),
    MiniMision("Memorizar 3 datos random 🧠🎲", 1),
    MiniMision("Hacer 5 operaciones matemáticas ➗🧠", 2),
    MiniMision("Investigar algo que no entiendas 🔎📚", 2),
    MiniMision("Leer un artículo científico 📄🔬", 1),
    MiniMision("Subrayar 3 ideas importantes 🖍️✨", 1),
    MiniMision("Escribir una micro historia 📝📖", 1),
    MiniMision("Resolver un Sudoku fácil 🧠🔢", 2),
    MiniMision("Describir lo que aprendiste hoy 💡🧠", 1),
    MiniMision("Aprender una técnica de estudio 🧠📘", 1),
    MiniMision("Explicar algo con tus palabras 🗯️🤔", 1),
    MiniMision("Aprender algo sobre filosofía 📚🧠", 2),
    MiniMision("Escuchar meditación guiada 🎧🧘", 1),
    MiniMision("Buscar cómo funciona algo ⚙️🔍", 2),
    MiniMision("Buscar el origen de una palabra 🧬🔠", 1),
    MiniMision("Ver una TED Talk 🎙️💡", 1),
    MiniMision("Leer sobre otra cultura 🌎📘", 1),
    MiniMision("Escribir lo que sentiste al meditar 🧘‍♂️📝", 1),
    MiniMision("Contemplar sin celular 10 mins 🧠📵", 1),
    MiniMision("Visualizar tu día ideal 🌄🧠", 1),
    MiniMision("Escribir una idea que cambió tu vida ✍️💫", 2),
    MiniMision("Describir una emoción sin usar su nombre 🧠🎭", 2),
    MiniMision("Leer un mito o leyenda clásica 📜🐉", 1),
    MiniMision("Ver un documental corto 🎥🧠", 1),
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
    inteligenciaXP = prefs.getInt('inteligencia_xp') ?? 0;
    inteligenciaNivel = prefs.getInt('inteligencia_nivel') ?? 1;
    ultimaMisionPrincipal =
        _getDateTime(prefs.getString('ultima_mision_inteligencia'));
    ultimaGeneracion =
        _getDateTime(prefs.getString('ultima_generacion_inteligencia'));

    final mapaXpRaw = prefs.getStringList('xp_misiones_inteligencia') ?? [];
    xpMiniMisiones = {
      for (var e in mapaXpRaw)
        int.parse(e.split('|')[0]): int.parse(e.split('|')[1])
    };

    final completadasRaw =
        prefs.getStringList('completadas_inteligencia') ?? [];
    completadasHoy = {for (var i in completadasRaw) int.parse(i): true};

    indicesMisionesDia =
        (prefs.getStringList('misiones_inteligencia_dia') ?? [])
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
      await prefs.setStringList('misiones_inteligencia_dia',
          indicesMisionesDia.map((e) => e.toString()).toList());
      await prefs.setStringList('xp_misiones_inteligencia',
          xpMiniMisiones.entries.map((e) => '${e.key}|${e.value}').toList());
      await prefs.setStringList('completadas_inteligencia', []);
      await prefs.setString(
          'ultima_generacion_inteligencia', ahora.toIso8601String());
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
    inteligenciaXP += xpGanada;
    ultimaMisionPrincipal = ahora;

    while (inteligenciaXP >= xpNecesaria(inteligenciaNivel)) {
      inteligenciaXP -= xpNecesaria(inteligenciaNivel);
      inteligenciaNivel++;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '🧠 ¡Subiste a nivel $inteligenciaNivel en Inteligencia!')),
      );
    }

    await agregarXpDelDia(xpGanada);
    await prefs.setInt('inteligencia_xp', inteligenciaXP);
    await prefs.setInt('inteligencia_nivel', inteligenciaNivel);
    await prefs.setString(
        'ultima_mision_inteligencia', ahora.toIso8601String());

    setState(() {});
  }

  Future<void> completarMiniMision(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final id = indicesMisionesDia[index];
    if (completadasHoy[id] == true) return;

    final xp = xpMiniMisiones[id] ?? 2;
    inteligenciaXP += xp;
    completadasHoy[id] = true;

    while (inteligenciaXP >= xpNecesaria(inteligenciaNivel)) {
      inteligenciaXP -= xpNecesaria(inteligenciaNivel);
      inteligenciaNivel++;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '🧠 ¡Subiste a nivel $inteligenciaNivel en Inteligencia!')),
      );
    }

    await agregarXpDelDia(xp);
    await prefs.setInt('inteligencia_xp', inteligenciaXP);
    await prefs.setInt('inteligencia_nivel', inteligenciaNivel);
    await prefs.setStringList(
        'completadas_inteligencia',
        completadasHoy.entries
            .where((e) => e.value)
            .map((e) => e.key.toString())
            .toList());

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final xpMax = xpNecesaria(inteligenciaNivel);
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
        title: Text('🧠 Misión de Inteligencia',
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
                  Text('Nivel: $inteligenciaNivel',
                      style: TextStyle(
                          fontSize: 24,
                          color: isDarkMode
                              ? AppColors.darkAccent
                              : AppColors.lightText)),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: inteligenciaXP / xpMax,
                    backgroundColor:
                        isDarkMode ? Colors.grey[800] : Colors.grey[300],
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.amber),
                    minHeight: 12,
                  ),
                  const SizedBox(height: 10),
                  Text('$inteligenciaXP / $xpMax XP',
                      style: TextStyle(
                          color: isDarkMode
                              ? AppColors.darkSecondaryText
                              : AppColors.lightSecondaryText)),
                  const SizedBox(height: 30),
                  Text('📘 Misión principal:',
                      style: TextStyle(
                          fontSize: 20,
                          color: isDarkMode
                              ? AppColors.darkAccent
                              : AppColors.lightText)),
                  const SizedBox(height: 10),
                  Text(
                      'Haz una sesión de 30 minutos de aprendizaje profundo hoy.',
                      style: TextStyle(
                          color: isDarkMode
                              ? AppColors.darkSecondaryText
                              : AppColors.lightSecondaryText)),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed:
                        puedeHacerPrincipal ? completarMisionPrincipal : null,
                    icon: const Icon(Icons.psychology_alt),
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
