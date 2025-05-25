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

  @override
  void initState() {
    super.initState();
    cargarDatos();
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

  Future<int> obtenerLifetimeXp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('xp_general') ?? 0;
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
            // 📸 Imagen de perfil como fondo superior
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
                    padding: const EdgeInsets.only(left: 16, bottom: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                        const SizedBox(height: 8),
                        // ⭐️ XP de por vida
                        FutureBuilder<int>(
                          future: obtenerLifetimeXp(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData)
                              return const SizedBox.shrink();
                            return Row(
                              children: [
                                const Icon(Icons.auto_awesome_rounded,
                                    color: Colors.amber, size: 28),
                                const SizedBox(width: 8),
                                Text(
                                  "XP de por vida: ${snapshot.data}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isDarkMode
                                        ? Colors.amberAccent
                                        : Colors.deepOrange,
                                    shadows: [
                                      Shadow(
                                          blurRadius: 4, color: Colors.black26),
                                    ],
                                  ),
                                ),
                              ],
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
              ],
            ),

            // 🔙 Flecha encima de todo
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
