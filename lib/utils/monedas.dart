import 'package:shared_preferences/shared_preferences.dart';

Future<void> ganarMonedas(int cantidad) async {
  final prefs = await SharedPreferences.getInstance();
  int monedas = prefs.getInt('monedas') ?? 0;
  monedas += cantidad;
  await prefs.setInt('monedas', monedas);
  print("🪙 TOTAL DE MONEDAS: $monedas");
}

Future<int> obtenerMonedas() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('monedas') ?? 0;
}

Future<bool> usarMonedas(int cantidad) async {
  final prefs = await SharedPreferences.getInstance();
  int monedas = prefs.getInt('monedas') ?? 0;
  if (monedas >= cantidad) {
    monedas -= cantidad;
    await prefs.setInt('monedas', monedas);
    print("🪙 Has gastado $cantidad monedas. Te quedan: $monedas");
    return true;
  } else {
    print("❌ No tienes suficientes monedas. Tienes: $monedas");
    return false;
  }
}
