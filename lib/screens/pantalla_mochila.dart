import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/colors.dart';
import '../providers/theme_provider.dart';
import '../utils/pociones.dart';

class PantallaMochila extends StatefulWidget {
  const PantallaMochila({super.key});

  @override
  State<PantallaMochila> createState() => _PantallaMochilaState();
}

class _PantallaMochilaState extends State<PantallaMochila>
    with SingleTickerProviderStateMixin {
  int monedas = 0;
  int pociones = 0;
  List<Map<String, dynamic>> bannersComprados = [];
  bool cargando = true;
  late AnimationController _controller;
  bool mostrarGaleria = false;
  String? bannerFondoId;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();
    cargarInventario();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> cargarInventario() async {
    final prefs = await SharedPreferences.getInstance();
    final totalMonedas = prefs.getInt('monedas') ?? 0;
    final totalPociones = await obtenerPociones();
    final bannersStrings = prefs.getStringList('banners_comprados') ?? [];
    final fondo = prefs.getString('banner_fondo');

    setState(() {
      monedas = totalMonedas;
      pociones = totalPociones;
      bannersComprados = bannersStrings
          .map((e) => json.decode(e) as Map<String, dynamic>)
          .toList();
      bannerFondoId = fondo;
      cargando = false;
    });
  }

  void abrirGaleria() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      bannerFondoId = prefs.getString('banner_fondo');
      mostrarGaleria = true;
    });
  }

  void cerrarGaleria() {
    setState(() {
      mostrarGaleria = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: mostrarGaleria
          ? null
          : AppBar(
              backgroundColor: isDarkMode
                  ? AppColors.darkBackground
                  : AppColors.lightBackground,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.amber),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text(
                "🎒 Mochila",
                style: TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
      body: cargando
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : SafeArea(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: mostrarGaleria
                    ? _buildGaleria(context)
                    : _buildResumenInventario(context),
              ),
            ),
    );
  }

  Widget _buildResumenInventario(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 32, left: 0, right: 0, bottom: 0),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withOpacity(0.85),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.14),
                  blurRadius: 20,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ORO
                Row(
                  children: [
                    RotationTransition(
                      turns: _controller,
                      child: const Icon(Icons.monetization_on,
                          color: Colors.amber, size: 38),
                    ),
                    const SizedBox(width: 18),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Oro",
                            style: TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                                fontSize: 19)),
                        Text(
                          "$monedas monedas",
                          style: TextStyle(
                            color: Colors.amber[200],
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // POCIONES
                Row(
                  children: [
                    const Icon(Icons.science,
                        color: Colors.lightBlueAccent, size: 34),
                    const SizedBox(width: 18),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Pociones",
                            style: TextStyle(
                                color: Colors.lightBlueAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 19)),
                        Text(
                          "$pociones pociones",
                          style: TextStyle(
                            color: Colors.lightBlue[200],
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // BANNERS
                bannersComprados.isNotEmpty
                    ? GestureDetector(
                        onTap: abrirGaleria,
                        child: Row(
                          children: [
                            const Icon(Icons.image,
                                color: Colors.purpleAccent, size: 34),
                            const SizedBox(width: 18),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Banners",
                                    style: TextStyle(
                                        color: Colors.purpleAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 19)),
                                Text(
                                  "${bannersComprados.length} banners",
                                  style: TextStyle(
                                    color: Colors.purple[200],
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const Text(
                                  "Toca para ver tu galería",
                                  style: TextStyle(
                                    color: Colors.amber,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            const Icon(Icons.chevron_right, color: Colors.amber)
                          ],
                        ),
                      )
                    : Opacity(
                        opacity: 0.6,
                        child: Row(
                          children: [
                            const Icon(Icons.image_outlined,
                                color: Colors.purple, size: 34),
                            const SizedBox(width: 18),
                            const Text("Sin banners aún",
                                style: TextStyle(
                                  color: Colors.purple,
                                  fontSize: 15,
                                )),
                          ],
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGaleria(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Container(
      color: isDark
          ? AppColors.darkBackground.withOpacity(0.98)
          : AppColors.lightBackground.withOpacity(0.98),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.amber),
                onPressed: cerrarGaleria,
              ),
              const SizedBox(width: 6),
              const Text(
                "Tus Banners",
                style: TextStyle(
                    fontSize: 22,
                    color: Colors.amber,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: bannersComprados.isEmpty
                ? const Center(
                    child: Text(
                      "Aún no tienes banners comprados.",
                      style: TextStyle(color: Colors.amber, fontSize: 17),
                    ),
                  )
                : ListView.builder(
                    itemCount: bannersComprados.length,
                    itemBuilder: (context, i) {
                      final banner = bannersComprados[i];
                      final bannerEnUso =
                          banner['id'].toString() == bannerFondoId;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.black54
                                    : Colors.white.withOpacity(0.92),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 8,
                                      offset: Offset(0, 4))
                                ],
                              ),
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(18),
                                    child: Image.network(
                                      banner['url'],
                                      height: 180,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: Text(
                                      banner['nombre'] ?? '',
                                      style: const TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.amber),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: Text(
                                      banner['descripcion'] ?? '',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: isDark
                                              ? Colors.white70
                                              : Colors.black87),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  // Botón principal
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          icon: Icon(
                                            Icons.wallpaper_rounded,
                                            color: bannerEnUso
                                                ? Colors.grey[300]
                                                : Colors.white,
                                          ),
                                          label: Text(
                                            bannerEnUso
                                                ? "En uso"
                                                : "Poner de fondo",
                                            style: TextStyle(
                                              color: bannerEnUso
                                                  ? Colors.grey[300]
                                                  : Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: bannerEnUso
                                                ? Colors.grey
                                                : Colors.amber,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12)),
                                          ),
                                          onPressed: bannerEnUso
                                              ? null
                                              : () async {
                                                  final prefs =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  await prefs.setString(
                                                      'banner_fondo',
                                                      banner['id'].toString());
                                                  setState(() {
                                                    bannerFondoId =
                                                        banner['id'].toString();
                                                  });
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                        content: Text(
                                                            '¡Banner puesto de fondo!')),
                                                  );
                                                },
                                        ),
                                      ),
                                      // Botón "Quitar banner"
                                      if (bannerEnUso)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8),
                                          child: TextButton.icon(
                                            icon: const Icon(Icons.cancel,
                                                color: Colors.redAccent),
                                            label: const Text(
                                              "Quitar banner",
                                              style: TextStyle(
                                                  color: Colors.redAccent,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            onPressed: () async {
                                              final prefs =
                                                  await SharedPreferences
                                                      .getInstance();
                                              await prefs
                                                  .remove('banner_fondo');
                                              setState(() {
                                                bannerFondoId = null;
                                              });
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        'Banner removido')),
                                              );
                                            },
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                            // Label "EN USO"
                            if (bannerEnUso)
                              Positioned(
                                top: 18,
                                right: 24,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.amber[800]?.withOpacity(0.95),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black38,
                                        blurRadius: 6,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: const Text(
                                    "EN USO",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
          )
        ],
      ),
    );
  }
}
