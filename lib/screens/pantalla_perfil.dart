import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../rpg_home.dart';
import '../utils/colors.dart';

class PantallaPerfil extends StatefulWidget {
  const PantallaPerfil({super.key});

  @override
  State<PantallaPerfil> createState() => _PantallaPerfilState();
}

class _PantallaPerfilState extends State<PantallaPerfil> {
  String nombreInvocador = 'Invocador';
  String clase = 'mago';
  String avatarNombre = 'mago-1.png';

  Map<String, int> nivelesStats = {
    'Fuerza': 1,
    'Inteligencia': 1,
    'Defensa': 1,
    'Agilidad': 1,
    'Vitalidad': 1,
    'Suerte': 1,
    'Carisma': 1,
  };

  int nivelGeneral = 7;
  int misionesCompletadas = 0;

  @override
  void initState() {
    super.initState();
    cargarDatos();
    cargarMisionesCompletadas();
  }

  Future<void> cargarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nombreInvocador = prefs.getString('nombre_invocador') ?? 'Invocador';
      clase = prefs.getString('clase') ?? 'mago';
      avatarNombre = prefs.getString('avatar') ??
          prefs.getString('avatar_seleccionado')?.split('/').last ??
          'mago-1.png';

      nivelesStats['Fuerza'] = prefs.getInt('fuerza_nivel') ?? 1;
      nivelesStats['Inteligencia'] = prefs.getInt('inteligencia_nivel') ?? 1;
      nivelesStats['Defensa'] = prefs.getInt('defensa_nivel') ?? 1;
      nivelesStats['Agilidad'] = prefs.getInt('agilidad_nivel') ?? 1;
      nivelesStats['Vitalidad'] = prefs.getInt('vitalidad_nivel') ?? 1;
      nivelesStats['Suerte'] = prefs.getInt('suerte_nivel') ?? 1;
      nivelesStats['Carisma'] = prefs.getInt('carisma_nivel') ?? 1;

      nivelGeneral = nivelesStats.values.fold(0, (a, b) => a + b);
    });
  }

  Future<void> cargarMisionesCompletadas() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      misionesCompletadas = prefs.getInt('misiones_completadas') ?? 0;
    });
  }

  Future<int> obtenerLifetimeXp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('xp_general') ?? 0;
  }

  Future<void> _guardarNuevoNombre(String nuevoNombre) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nombre_invocador', nuevoNombre);
    setState(() {
      nombreInvocador = nuevoNombre;
    });
  }

  void _mostrarDialogoEditarNombre(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    TextEditingController _controller =
        TextEditingController(text: nombreInvocador);

    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: const Text('Editar nombre de invocador'),
          message: CupertinoTextField(
            controller: _controller,
            placeholder: 'Nuevo nombre',
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            placeholderStyle: TextStyle(
              color: isDarkMode ? Colors.white54 : Colors.black38,
            ),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[850] : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                final nuevoNombre = _controller.text.trim();
                if (nuevoNombre.isNotEmpty) {
                  _guardarNuevoNombre(nuevoNombre);
                  Navigator.pop(context);
                }
              },
              child: const Text('Guardar'),
              isDefaultAction: true,
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final avatarPath = 'assets/avatars/$clase/$avatarNombre';

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 220,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(avatarPath),
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                  child: Container(
                    alignment: Alignment.bottomLeft,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.25),
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    padding:
                        const EdgeInsets.only(left: 16, bottom: 16, right: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              nombreInvocador,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(blurRadius: 8, color: Colors.black45),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => _mostrarDialogoEditarNombre(context),
                              child: const Icon(Icons.edit,
                                  size: 18, color: Colors.white70),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Nivel General: $nivelGeneral',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                            shadows: [
                              Shadow(blurRadius: 4, color: Colors.black38),
                            ],
                          ),
                        ),
                        FutureBuilder<int>(
                          future: obtenerLifetimeXp(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData)
                              return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Row(
                                children: [
                                  const Icon(Icons.auto_awesome_rounded,
                                      color: Colors.amber, size: 18),
                                  const SizedBox(width: 6),
                                  Text(
                                    "XP de por vida: ${snapshot.data}",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: isDarkMode
                                          ? Colors.amberAccent
                                          : Colors.deepOrange,
                                      shadows: [
                                        const Shadow(
                                          blurRadius: 3,
                                          color: Colors.black26,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Wrap(
                    spacing: 20,
                    runSpacing: 16,
                    children: nivelesStats.entries.map((entry) {
                      final emoji = _emojiDeStat(entry.key);
                      return Container(
                        width: MediaQuery.of(context).size.width / 2 - 40,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              isDarkMode ? Colors.grey[900] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$emoji ${entry.key}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Nivel ${entry.value}',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDarkMode
                                    ? Colors.amber[200]
                                    : Colors.amber[800],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(
                    height: 36), // más espacio visual abajo de los stats
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '✅ Misiones Completadas en Total: $misionesCompletadas',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.amber),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const RPGHome(),
                      transitionsBuilder: (_, animation, __, child) =>
                          FadeTransition(opacity: animation, child: child),
                      transitionDuration: const Duration(milliseconds: 400),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _emojiDeStat(String stat) {
    switch (stat) {
      case 'Fuerza':
        return '💪';
      case 'Inteligencia':
        return '🧠';
      case 'Defensa':
        return '🛡️';
      case 'Agilidad':
        return '🌀';
      case 'Vitalidad':
        return '❤️';
      case 'Suerte':
        return '🍀';
      case 'Carisma':
        return '😎';
      default:
        return '✨';
    }
  }
}
