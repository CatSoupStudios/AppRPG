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
  List<dynamic> pociones = [];
  bool cargando = true;
  int oroActual = 0;

  late AnimationController _monedaController;
  late Animation<double> _rotationY;

  List<String> bannersCompradosRaw = [];
  List<String> bannersCompradosIds = [];
  Map<String, int> inventarioPociones = {}; // id -> cantidad

  int _tabIndex = 0; // 0: banners, 1: pociones

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
    await cargarTienda();
    await cargarOro();
    await cargarComprasLocales();
    await cargarInventarioPociones();
  }

  Future<void> cargarTienda() async {
    try {
      final response = await http
          .get(Uri.parse('https://apprpg-api.onrender.com/tienda'))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          banners = data['banners'];
          pociones = data['pociones'];
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

  Future<void> cargarInventarioPociones() async {
    final prefs = await SharedPreferences.getInstance();
    final inventario = prefs.getString('pociones_inventario');
    if (inventario != null) {
      inventarioPociones =
          Map<String, int>.from(json.decode(inventario) as Map);
    } else {
      inventarioPociones = {};
    }
    setState(() {});
  }

  Future<void> guardarInventarioPociones() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'pociones_inventario', json.encode(inventarioPociones));
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

  // ======== NUEVO: CONFIRMAR COMPRA POCION =========
  Future<void> confirmarCompraPocion(Map<String, dynamic> pocion) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          backgroundColor:
              isDark ? AppColors.darkBackground : AppColors.lightBackground,
          title: Text('¿Seguro que quieres comprar "${pocion['nombre']}"?'),
          content: Text(
            pocion['moneda'] == "usd"
                ? 'Esta poción premium requiere pago real (próximamente).'
                : 'Esta poción cuesta ${pocion['precio']} 🪙. ¿Confirmas tu compra?',
            style: TextStyle(
              color: isDark
                  ? AppColors.darkSecondaryText
                  : AppColors.lightSecondaryText,
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(ctx).pop(false),
            ),
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () => Navigator.of(ctx).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      await comprarPocion(pocion);
    }
  }
  // ========================================

  Future<void> comprarPocion(Map<String, dynamic> pocion) async {
    final prefs = await SharedPreferences.getInstance();
    final oro = prefs.getInt('monedas') ?? 0;
    if (pocion['moneda'] == "usd") {
      // Futuro: lógica de pago real
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Disponible próximamente 🚧')),
      );
      return;
    }
    if (oro >= pocion['precio']) {
      final nuevoOro = (oro - pocion['precio']).toInt();
      // Suma la poción al inventario
      final id = pocion['id'];
      inventarioPociones[id] = (inventarioPociones[id] ?? 0) + 1;
      await guardarInventarioPociones();
      await prefs.setInt('monedas', nuevoOro);

      setState(() {
        oroActual = nuevoOro;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('¡Has comprado una ${pocion['nombre']}!')),
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
          : Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _tabIndex = 0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: _tabIndex == 0
                                    ? (isDark
                                        ? Colors.amber[800]
                                        : Colors.amber[400])
                                    : Colors.transparent,
                              ),
                              child: Center(
                                child: Text(
                                  "Banners",
                                  style: TextStyle(
                                    color: _tabIndex == 0
                                        ? Colors.white
                                        : (isDark
                                            ? AppColors.darkText
                                            : AppColors.lightText),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _tabIndex = 1),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: _tabIndex == 1
                                    ? (isDark
                                        ? Colors.amber[800]
                                        : Colors.amber[400])
                                    : Colors.transparent,
                              ),
                              child: Center(
                                child: Text(
                                  "Pociones",
                                  style: TextStyle(
                                    color: _tabIndex == 1
                                        ? Colors.white
                                        : (isDark
                                            ? AppColors.darkText
                                            : AppColors.lightText),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: _tabIndex == 0
                      ? _buildBannersGrid(isDark)
                      : _buildPocionesList(isDark),
                ),
              ],
            ),
    );
  }

  Widget _buildBannersGrid(bool isDark) {
    if (banners.isEmpty) {
      return Center(
        child: Text(
          'No hay banners por ahora.',
          style: TextStyle(
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.82,
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
                          duration: const Duration(milliseconds: 400),
                          child: yaComprado
                              ? Container(
                                  key: ValueKey('comprado_${banner['id']}'),
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.check_circle,
                                        color: Colors.white),
                                    label: const Text(
                                      'Comprado',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                    ),
                                  ),
                                )
                              : Container(
                                  key: ValueKey('comprar_${banner['id']}'),
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.shopping_bag_rounded,
                                        color: Colors.black),
                                    label: Text(
                                      'Comprar por ${banner['precio']}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.amber[400],
                                      foregroundColor: Colors.black,
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext ctx2) {
                                          return AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                            ),
                                            backgroundColor: isDark
                                                ? AppColors.darkBackground
                                                : AppColors.lightBackground,
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
                                                child: const Text('Cancelar'),
                                                onPressed: () =>
                                                    Navigator.of(ctx2).pop(),
                                              ),
                                              TextButton(
                                                child: const Text('Aceptar'),
                                                onPressed: () async {
                                                  Navigator.of(ctx2).pop();
                                                  Navigator.of(ctx).pop();
                                                  await comprarBanner(banner);
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
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                  child: Text(
                    banner['nombre'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
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
    );
  }

  Widget _buildPocionesList(bool isDark) {
    if (pociones.isEmpty) {
      return Center(
        child: Text(
          'No hay pociones disponibles.',
          style: TextStyle(
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pociones.length,
      itemBuilder: (context, index) {
        final pocion = pociones[index];
        final id = pocion['id'];
        final esPremium = pocion['moneda'] == "usd";
        final cantidad = inventarioPociones[id] ?? 0;
        return Card(
          elevation: 4,
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                pocion['url_imagen'],
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(
              pocion['nombre'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pocion['descripcion'],
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkSecondaryText
                        : AppColors.lightSecondaryText,
                  ),
                ),
                if (!esPremium && cantidad > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      "Tienes: $cantidad en inventario",
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkText.withOpacity(0.85)
                            : AppColors.lightText.withOpacity(0.8),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
              ],
            ),
            trailing: esPremium
                ? ElevatedButton.icon(
                    onPressed: null, // Pronto disponible
                    icon: const Icon(Icons.lock, color: Colors.white),
                    label: const Text('Premium'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[600],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                  )
                : ElevatedButton.icon(
                    // CONFIRMACIÓN DE COMPRA AQUÍ:
                    onPressed: () => confirmarCompraPocion(pocion),
                    icon: const Icon(Icons.shopping_bag_rounded,
                        color: Colors.black),
                    label: Text('${pocion['precio']} 🪙'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[400],
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                  ),
            onTap: null,
          ),
        );
      },
    );
  }
}
