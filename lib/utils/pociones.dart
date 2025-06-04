import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Siempre guarda SOLO como 'pocion_10', 'pocion_20'
Future<void> ganarPocion(int valor) async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString('pociones_json') ?? '{}';

  Map<String, dynamic> tempMap = {};
  try {
    tempMap = jsonDecode(raw);
  } catch (_) {}

  String clave = 'pocion_$valor';
  tempMap[clave] = (tempMap[clave] ?? 0) + 1;

  await prefs.setString('pociones_json', jsonEncode(tempMap));
  await prefs.setString('pociones_inventario', jsonEncode(tempMap));
}

// Lee ambos formatos, pero **solo suma una vez cada clave**
Future<Map<int, int>> obtenerPociones() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString('pociones_json') ?? '{}';

  final Map<String, dynamic> data = jsonDecode(raw);

  Map<int, int> resultado = {};
  data.forEach((k, v) {
    int? claveInt;
    if (k.startsWith('pocion_')) {
      claveInt = int.tryParse(k.replaceFirst('pocion_', ''));
    } else if (int.tryParse(k) != null) {
      // Si queda algún int viejo por migración
      claveInt = int.parse(k);
    }
    if (claveInt != null && v is int) {
      resultado[claveInt] = v;
    }
  });
  return resultado;
}

Future<bool> usarPocion(int valor) async {
  final prefs = await SharedPreferences.getInstance();
  final pociones = await obtenerPociones();

  int cantidad = pociones[valor] ?? 0;
  if (cantidad > 0) {
    pociones[valor] = cantidad - 1;
    if (pociones[valor]! <= 0) {
      pociones.remove(valor);
    }

    // Al guardar, solo usa el formato nuevo
    Map<String, dynamic> tempMap = {};
    pociones.forEach((k, v) {
      tempMap['pocion_$k'] = v;
    });

    await prefs.setString('pociones_json', jsonEncode(tempMap));
    await prefs.setString('pociones_inventario', jsonEncode(tempMap));
    return true;
  }
  return false;
}

Future<void> resetPociones() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('pociones_json', '{}');
  await prefs.setString('pociones_inventario', '{}');
}
