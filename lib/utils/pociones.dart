import 'package:shared_preferences/shared_preferences.dart';

Future<void> ganarPocion() async {
  final prefs = await SharedPreferences.getInstance();
  int pociones = prefs.getInt('pociones') ?? 0;
  pociones += 1;
  await prefs.setInt('pociones', pociones);
  print("🧪 TOTAL DE POCIONES: $pociones");
}

Future<int> obtenerPociones() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('pociones') ?? 0;
}

Future<void> usarPocion() async {
  final prefs = await SharedPreferences.getInstance();
  int pociones = prefs.getInt('pociones') ?? 0;
  if (pociones > 0) {
    pociones -= 1;
    await prefs.setInt('pociones', pociones);
    print("🧪 Pocion usada. Quedan: $pociones");
  }
}
