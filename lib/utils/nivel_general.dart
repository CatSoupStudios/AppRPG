import 'package:shared_preferences/shared_preferences.dart';

Future<int> obtenerNivelGeneral() async {
  final prefs = await SharedPreferences.getInstance();

  final fuerza = prefs.getInt('fuerza_nivel') ?? 1;
  final inteligencia = prefs.getInt('inteligencia_nivel') ?? 1;
  final defensa = prefs.getInt('defensa_nivel') ?? 1;
  final agilidad = prefs.getInt('agilidad_nivel') ?? 1;
  final vitalidad = prefs.getInt('vitalidad_nivel') ?? 1;
  final suerte = prefs.getInt('suerte_nivel') ?? 1;
  final carisma = prefs.getInt('carisma_nivel') ?? 1;

  final total =
      fuerza + inteligencia + defensa + agilidad + vitalidad + suerte + carisma;
  return total;
}
