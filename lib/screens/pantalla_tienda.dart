import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../utils/colors.dart';

class PantallaTienda extends StatefulWidget {
  @override
  _PantallaTiendaState createState() => _PantallaTiendaState();
}

class _PantallaTiendaState extends State<PantallaTienda>
    with SingleTickerProviderStateMixin {
  List<dynamic> banners = [];
  bool cargando = true;
  int oroActual = 0;

  // Animación para la moneda girando
  late AnimationController _monedaController;
  late Animation<double> _rotationY;

  List<String> bannersCompradosRaw = [];
  List<String> bannersCompradosIds = [];

  @override
  void initState() {
    super.initState();
    _monedaController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _rotationY = Tween<double>(begin: 0, end: 1).animate(_monedaController);

    cargarDatos();
  }

  @override
  void dispose() {
    _monedaController.dispose();
    super.dispose();
  }

  Future<void> cargarDatos() async {
    await cargarBanners();
    await cargarOro();
    await cargarComprasLocales();
  }

  Future<void> cargarBanners() async {
    try {
      final response = await http
          .get(Uri.parse('https://apprpg-api.onrender.com/tienda'))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          banners = data['banners'];
          cargando = false;
        });
      } else {
        setState(() {
          cargando = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Error al cargar la tienda: ${response.statusCode}')),
        );
      }
    } on TimeoutException catch (_) {
      setState(() {
        cargando = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Tiempo de espera agotado al cargar la tienda')),
      );
    } catch (e) {
      setState(() {
        cargando = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar la tienda: $e')),
      );
    }
  }

  Future<void> cargarOro() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      oroActual = prefs.getInt('monedas') ?? 0;
    });
  }

  Future<void> cargarComprasLocales() async {
    final prefs = await SharedPreferences.getInstance();
    final bannersStrings = prefs.getStringList('banners_comprados') ?? [];
    setState(() {
      bannersCompradosRaw = bannersStrings;
      bannersCompradosIds = bannersStrings
          .map((e) => json.decode(e) as Map<String, dynamic>)
          .map((map) => map['id'].toString())
          .toList();
    });
  }

  Future<void> animarOro() async {
    // Puedes hacer animación de oro aquí si gustas
    await cargarOro();
  }

  Future<void> comprarBanner(Map<String, dynamic> banner) async {
    final prefs = await SharedPreferences.getInstance();
    final oro = prefs.getInt('monedas') ?? 0;
    final bannersStrings = prefs.getStringList('banners_comprados') ?? [];

    final idsLocales = bannersStrings
        .map((e) => json.decode(e) as Map<String, dynamic>)
        .map((map) => map['id'].toString())
        .toList();

    final yaComprado = idsLocales.contains(banner['id'].toString());

    if (yaComprado) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ya compraste este banner')),
      );
      return;
    }

    if (oro >= banner['precio']) {
      final nuevoOro = (oro - banner['precio']).toInt();

      final bannerGuardado = {
        'id': banner['id'],
        'nombre': banner['nombre'],
        'descripcion': banner['descripcion'],
        'url': banner['url_imagen'],
        'precio': banner['precio'],
      };

      bannersStrings.add(json.encode(bannerGuardado));
      await prefs.setInt('monedas', nuevoOro);
      await prefs.setStringList('banners_comprados', bannersStrings);

      setState(() {
        oroActual = nuevoOro;
        bannersCompradosRaw = bannersStrings;
        bannersCompradosIds = bannersStrings
            .map((e) => json.decode(e) as Map<String, dynamic>)
            .map((map) => map['id'].toString())
            .toList();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('¡Has comprado ${banner['nombre']}!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No tienes suficiente oro 💸')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Tienda',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _rotationY,
                  builder: (context, child) {
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(_rotationY.value * 6.28319),
                      child: Image.asset(
                        'assets/moneda.png',
                        width: 32,
                        height: 32,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 7),
                Text(
                  '$oroActual',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        iconTheme: IconThemeData(
          color: isDark ? AppColors.darkText : AppColors.lightText,
        ),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : banners.isEmpty
              ? Center(
                  child: Text(
                    'No hay banners por ahora.',
                    style: TextStyle(
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        2, // Cambia a 3 si lo quieres más compacto aún
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio:
                        0.82, // Ajusta la altura de las cards (más grande, más alto)
                  ),
                  itemCount: banners.length,
                  itemBuilder: (context, index) {
                    final banner = banners[index];
                    final yaComprado =
                        bannersCompradosIds.contains(banner['id'].toString());

                    return GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext ctx) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              backgroundColor: isDark
                                  ? AppColors.darkBackground
                                  : AppColors.lightBackground,
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(18),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.network(
                                        banner['url_imagen'],
                                        width: 260,
                                        height: 180,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      banner['nombre'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                        color: isDark
                                            ? AppColors.darkText
                                            : AppColors.lightText,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      banner['descripcion'],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: isDark
                                            ? AppColors.darkSecondaryText
                                            : AppColors.lightSecondaryText,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      '${banner['precio']} 🪙',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 19,
                                        color: Colors.amber[800],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 400),
                                      child: yaComprado
                                          ? Container(
                                              key: ValueKey(
                                                  'comprado_${banner['id']}'),
                                              width: double.infinity,
                                              child: ElevatedButton.icon(
                                                icon: const Icon(
                                                    Icons.check_circle,
                                                    color: Colors.white),
                                                label: const Text(
                                                  'Comprado',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                onPressed: null,
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.grey,
                                                  foregroundColor: Colors.white,
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 12),
                                                ),
                                              ),
                                            )
                                          : Container(
                                              key: ValueKey(
                                                  'comprar_${banner['id']}'),
                                              width: double.infinity,
                                              child: ElevatedButton.icon(
                                                icon: const Icon(
                                                    Icons.shopping_bag_rounded,
                                                    color: Colors.black),
                                                label: Text(
                                                  'Comprar por ${banner['precio']}',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.amber[400],
                                                  foregroundColor: Colors.black,
                                                  elevation: 2,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 12),
                                                ),
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext ctx2) {
                                                      return AlertDialog(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(18),
                                                        ),
                                                        backgroundColor: isDark
                                                            ? AppColors
                                                                .darkBackground
                                                            : AppColors
                                                                .lightBackground,
                                                        title: Text(
                                                            '¿Seguro que quieres comprar "${banner['nombre']}"?'),
                                                        content: Text(
                                                          'Este banner cuesta ${banner['precio']} 🪙. ¿Confirmas tu compra?',
                                                          style: TextStyle(
                                                            color: isDark
                                                                ? AppColors
                                                                    .darkSecondaryText
                                                                : AppColors
                                                                    .lightSecondaryText,
                                                          ),
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            child: const Text(
                                                                'Cancelar'),
                                                            onPressed: () =>
                                                                Navigator.of(
                                                                        ctx2)
                                                                    .pop(),
                                                          ),
                                                          TextButton(
                                                            child: const Text(
                                                                'Aceptar'),
                                                            onPressed:
                                                                () async {
                                                              Navigator.of(ctx2)
                                                                  .pop();
                                                              Navigator.of(ctx)
                                                                  .pop();
                                                              await comprarBanner(
                                                                  banner);
                                                            },
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Card(
                        elevation: 4,
                        color:
                            isDark ? AppColors.darkCard : AppColors.lightCard,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 6),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.network(
                                    banner['url_imagen'],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 5),
                              child: Text(
                                banner['nombre'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: isDark
                                      ? AppColors.darkText
                                      : AppColors.lightText,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            if (yaComprado)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 7),
                                child: Icon(Icons.check_circle,
                                    color: Colors.green[400], size: 20),
                              ),
                            const SizedBox(height: 3),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
