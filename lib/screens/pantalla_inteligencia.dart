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

class PantallaInteligencia extends StatefulWidget {
  @override
  _PantallaInteligenciaState createState() => _PantallaInteligenciaState();
}

class _PantallaInteligenciaState extends State<PantallaInteligencia> {
  int inteligenciaXP = 0;
  int inteligenciaNivel = 1;
  DateTime? ultimaMisionPrincipal;
  bool cargando = true;
  Duration? tiempoRestantePrincipal;
  late final Ticker _ticker;

  final Duration cooldownMision = Duration(hours: 20);

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
      inteligenciaXP = prefs.getInt('inteligencia_xp') ?? 0;
      inteligenciaNivel = prefs.getInt('inteligencia_nivel') ?? 1;
      ultimaMisionPrincipal =
          _getDateTime(prefs.getString('ultima_mision_inteligencia'));
      ultimaGeneracion =
          _getDateTime(prefs.getString('ultima_generacion_inteligencia'));
      indicesMisionesDia =
          (prefs.getStringList('misiones_inteligencia_dia') ?? [])
              .map(int.parse)
              .toList();
      cooldownsMisiones = Map.fromEntries(
        (prefs.getStringList('cooldowns_misiones_inteligencia') ?? []).map((e) {
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
        'ultima_generacion_inteligencia', ultimaGeneracion!.toIso8601String());
    await prefs.setStringList('misiones_inteligencia_dia',
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
      inteligenciaXP += 3;
      ultimaMisionPrincipal = DateTime.now();
      while (inteligenciaXP >= xpNecesaria(inteligenciaNivel)) {
        inteligenciaXP -= xpNecesaria(inteligenciaNivel);
        inteligenciaNivel++;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '🧠 ¡Subiste a nivel $inteligenciaNivel en Inteligencia!')),
        );
      }
      tiempoRestantePrincipal = _calcularCooldown(ultimaMisionPrincipal);
    });
    await prefs.setInt('inteligencia_xp', inteligenciaXP);
    await prefs.setInt('inteligencia_nivel', inteligenciaNivel);
    await prefs.setString(
        'ultima_mision_inteligencia', ultimaMisionPrincipal!.toIso8601String());
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
      inteligenciaXP += mision.xp;
      cooldownsMisiones[misionIndex] = DateTime.now();
      while (inteligenciaXP >= xpNecesaria(inteligenciaNivel)) {
        inteligenciaXP -= xpNecesaria(inteligenciaNivel);
        inteligenciaNivel++;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '🧠 ¡Subiste a nivel $inteligenciaNivel en Inteligencia!')),
        );
      }
    });

    await prefs.setInt('inteligencia_xp', inteligenciaXP);
    await prefs.setInt('inteligencia_nivel', inteligenciaNivel);
    await prefs.setStringList(
      'cooldowns_misiones_inteligencia',
      cooldownsMisiones.entries
          .map((e) => '${e.key}|${e.value.toIso8601String()}')
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final xpMaxima = xpNecesaria(inteligenciaNivel);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
                    value: inteligenciaXP / xpMaxima,
                    backgroundColor:
                        isDarkMode ? Colors.grey[800] : Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                    minHeight: 12,
                  ),
                  const SizedBox(height: 10),
                  Text('$inteligenciaXP / $xpMaxima XP',
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
                    onPressed: _puedeHacerMisionPrincipal()
                        ? completarMisionPrincipal
                        : null,
                    icon: const Icon(Icons.psychology_alt),
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
                  Text('🎓 Mini-misiones del día:',
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
