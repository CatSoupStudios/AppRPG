import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

const int xpPorNivel = 20;

/// Agrega XP al día actual (solo visual, aún no se convierte en nivel).
Future<void> agregarXpDelDia(int cantidad) async {
  final prefs = await SharedPreferences.getInstance();
  final hoy = DateFormat('yyyy-MM-dd').format(DateTime.now());

  final raw = prefs.getString('xp_por_dia');
  final Map<String, dynamic> mapa = raw != null ? jsonDecode(raw) : {};

  final xpActual = (mapa[hoy] ?? 0) as int;
  mapa[hoy] = xpActual + cantidad;

  await prefs.setString('xp_por_dia', jsonEncode(mapa));
}

/// Devuelve la XP ganada en el día actual.
Future<int> obtenerXpDelDiaActual() async {
  final prefs = await SharedPreferences.getInstance();
  final hoy = DateFormat('yyyy-MM-dd').format(DateTime.now());

  final raw = prefs.getString('xp_por_dia');
  final Map<String, dynamic> mapa = raw != null ? jsonDecode(raw) : {};

  return (mapa[hoy] ?? 0) as int;
}

/// NUEVO: Devuelve la XP ganada para cualquier día específico.
Future<int> obtenerXpDelDia(String yyyyMMdd) async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString('xp_por_dia');
  final Map<String, dynamic> mapa = raw != null ? jsonDecode(raw) : {};
  return (mapa[yyyyMMdd] ?? 0) as int;
}

/// Procesa la XP del día anterior, la suma a xp_general,
/// y convierte a niveles extra si se alcanza el umbral.
Future<void> procesarXpDelDiaAnteriorYAplicar() async {
  final prefs = await SharedPreferences.getInstance();
  final ayer = DateFormat('yyyy-MM-dd').format(
    DateTime.now().subtract(const Duration(days: 1)),
  );

  final raw = prefs.getString('xp_por_dia');
  if (raw == null) return;

  final Map<String, dynamic> mapa = jsonDecode(raw);
  final int xpAyer = (mapa[ayer] ?? 0) as int;
  if (xpAyer == 0) return;

  // Sumar al total
  int xpTotal = prefs.getInt('xp_general') ?? 0;
  xpTotal += xpAyer;

  // Calcular cuántos niveles nuevos se ganan
  int nivelExtra = prefs.getInt('nivel_general_extra') ?? 0;
  while (xpTotal >= xpPorNivel) {
    xpTotal -= xpPorNivel;
    nivelExtra++;
  }

  await prefs.setInt('xp_general', xpTotal);
  await prefs.setInt('nivel_general_extra', nivelExtra);

  // Resetear XP de ayer
  mapa[ayer] = 0;
  await prefs.setString('xp_por_dia', jsonEncode(mapa));
}

/// Devuelve el nivel extra obtenido por XP diaria acumulada.
Future<int> obtenerNivelExtra() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('nivel_general_extra') ?? 0;
}
