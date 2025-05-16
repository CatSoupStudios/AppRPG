import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pantalla_creacion.dart';
import '../providers/theme_provider.dart';

class SelectorInicialScreen extends StatefulWidget {
  const SelectorInicialScreen({super.key});

  @override
  State<SelectorInicialScreen> createState() => _SelectorInicialScreenState();
}

class _SelectorInicialScreenState extends State<SelectorInicialScreen> {
  String? idiomaSeleccionado;
  ThemeMode? modoSeleccionado;

  void guardarPreferenciasYContinuar() async {
    if (idiomaSeleccionado == null || modoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Selecciona un idioma y un modo de tema."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('idioma', idiomaSeleccionado!);
    await prefs.setString(
        'tema', modoSeleccionado == ThemeMode.dark ? 'oscuro' : 'claro');
    await prefs.setBool('selector_completado', true); // ✅ Se guarda el flag

    // Actualiza el tema global
    final provider = Provider.of<ThemeProvider>(context, listen: false);
    provider.toggleTheme(modoSeleccionado == ThemeMode.dark);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const PantallaCreacion()),
    );
  }

  Widget buildIdiomaButton(String idioma, String label, String bandera) {
    final seleccionado = idiomaSeleccionado == idioma;
    return ElevatedButton(
      onPressed: () => setState(() => idiomaSeleccionado = idioma),
      style: ElevatedButton.styleFrom(
        backgroundColor: seleccionado ? Colors.amber : Colors.white10,
        foregroundColor: seleccionado ? Colors.black : Colors.white70,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text('$label $bandera', style: const TextStyle(fontSize: 16)),
    );
  }

  Widget buildTemaButton(ThemeMode modo, String label, IconData icono) {
    final seleccionado = modoSeleccionado == modo;
    return ElevatedButton.icon(
      onPressed: () => setState(() => modoSeleccionado = modo),
      icon: Icon(icono),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: seleccionado ? Colors.amber : Colors.white10,
        foregroundColor: seleccionado ? Colors.black : Colors.white70,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.4),
                BlendMode.darken,
              ),
              child: Image.asset(
                'assets/creacion.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Selecciona Idioma',
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      buildIdiomaButton('es', 'Español', '🇲🇽'),
                      buildIdiomaButton('en', 'English', '🇺🇸'),
                      buildIdiomaButton('ru', 'Русский', '🇷🇺'),
                    ],
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Modo de pantalla',
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      buildTemaButton(ThemeMode.light, 'Claro', Icons.wb_sunny),
                      buildTemaButton(
                          ThemeMode.dark, 'Oscuro', Icons.nightlight_round),
                    ],
                  ),
                  const SizedBox(height: 50),
                  ElevatedButton.icon(
                    onPressed: guardarPreferenciasYContinuar,
                    icon: const Icon(Icons.arrow_forward_ios),
                    label: const Text('Continuar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 16),
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
