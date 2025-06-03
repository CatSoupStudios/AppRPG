import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Gana una poción del valor que le pongas (10 o 20)
Future<void> ganarPocion(int valor) async {
  final prefs = await SharedPreferences.getInstance();
  final pocionesRaw = prefs.getString('pociones_json') ?? '{}';

  // Decodificar JSON a Map<String, dynamic>
  Map<String, dynamic> tempMap = jsonDecode(pocionesRaw);

  // Convertir a Map<int, int>
  Map<int, int> pociones = tempMap.map(
    (key, value) => MapEntry(int.parse(key), value as int),
  );

  // Sumar la pocion ganada
  pociones[valor] = (pociones[valor] ?? 0) + 1;

  // Guardar de nuevo en prefs con claves como String
  await prefs.setString('pociones_json',
      jsonEncode(pociones.map((k, v) => MapEntry(k.toString(), v))));
}

// Devuelve un Map<int, int> (clave=valor poción, valor=cantidad)
Future<Map<int, int>> obtenerPociones() async {
  final prefs = await SharedPreferences.getInstance();
  final pocionesRaw = prefs.getString('pociones_json') ?? '{}';

  final Map<String, dynamic> data = jsonDecode(pocionesRaw);
  return data.map((k, v) => MapEntry(int.parse(k), v as int));
}

// Usa una poción de cierto valor (si tienes)
Future<bool> usarPocion(int valor) async {
  final prefs = await SharedPreferences.getInstance();
  final pociones = await obtenerPociones();

  int cantidad = pociones[valor] ?? 0;
  if (cantidad > 0) {
    pociones[valor] = cantidad - 1;
    if (pociones[valor]! <= 0) {
      pociones.remove(valor);
    }

    await prefs.setString('pociones_json',
        jsonEncode(pociones.map((k, v) => MapEntry(k.toString(), v))));
    return true;
  }
  return false;
}

// Para debug: resetea todas las pociones
Future<void> resetPociones() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('pociones_json', '{}');
}
