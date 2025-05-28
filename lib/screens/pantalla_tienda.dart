import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/colors.dart';

class PantallaTienda extends StatefulWidget {
  @override
  _PantallaTiendaState createState() => _PantallaTiendaState();
}

class _PantallaTiendaState extends State<PantallaTienda> {
  List<dynamic> banners = [];
  bool cargando = true;
  int oroActual = 0;

  List<String> bannersCompradosRaw = []; // Lista completa en JSON
  List<String> bannersCompradosIds = []; // Solo los IDs

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    await cargarBanners();
    await cargarOro();
    await cargarComprasLocales();
  }

  Future<void> cargarBanners() async {
    final response = await http
        .get(Uri.parse('http://192.168.1.28:5000/tienda')); // <-- tu API
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        banners = data['banners'];
        cargando = false;
      });
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

  void comprarBanner(Map<String, dynamic> banner) async {
    final prefs = await SharedPreferences.getInstance();
    final oro = prefs.getInt('monedas') ?? 0;
    final bannersStrings = prefs.getStringList('banners_comprados') ?? [];

    // Actualiza IDs locales para evitar duplicados
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

      // Map con las claves que espera la mochila
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
        title: const Text('Tienda 🛒'),
        iconTheme: IconThemeData(
          color: isDark ? AppColors.darkText : AppColors.lightText,
        ),
        titleTextStyle: TextStyle(
          color: isDark ? AppColors.darkText : AppColors.lightText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 18, left: 24, right: 24),
                  child: Row(
                    children: [
                      const Icon(Icons.monetization_on,
                          color: Colors.amber, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        "$oroActual",
                        style: const TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: banners.length,
                    itemBuilder: (context, index) {
                      final banner = banners[index];
                      final yaComprado =
                          bannersCompradosIds.contains(banner['id'].toString());

                      return GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: isDark
                                ? AppColors.darkBackground
                                : AppColors.lightBackground,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20)),
                            ),
                            builder: (context) {
                              return Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        banner['url_imagen'],
                                        height: 180,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      banner['nombre'],
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? AppColors.darkText
                                            : AppColors.lightText,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      banner['descripcion'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isDark
                                            ? AppColors.darkSecondaryText
                                            : AppColors.lightSecondaryText,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 14),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: yaComprado
                                            ? Colors.grey
                                            : Colors.amber,
                                      ),
                                      onPressed: yaComprado
                                          ? null
                                          : () => comprarBanner(banner),
                                      child: Text(
                                        yaComprado
                                            ? 'Ya Comprado ✅'
                                            : 'Comprar por ${banner['precio']} 🪙',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: Card(
                          color:
                              isDark ? AppColors.darkCard : AppColors.lightCard,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                banner['url_imagen'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(
                              banner['nombre'],
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.darkText
                                    : AppColors.lightText,
                              ),
                            ),
                            subtitle: Text(
                              '${banner['precio']} 🪙',
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.darkSecondaryText
                                    : AppColors.lightSecondaryText,
                              ),
                            ),
                            trailing: yaComprado
                                ? const Icon(Icons.check_circle,
                                    color: Colors.green)
                                : const Icon(Icons.shopping_cart_outlined),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
