import 'package:shared_preferences/shared_preferences.dart';

const int staminaMax = 100;

// --- Carga stamina actual ---
Future<int> getStamina() async {
  final prefs = await SharedPreferences.getInstance();
  await reiniciarStaminaDiaria(); // Siempre revisa si toca reiniciar
  return prefs.getInt('stamina') ?? staminaMax;
}

// --- Guarda nueva stamina ---
Future<void> setStamina(int value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('stamina', value.clamp(0, staminaMax));
}

// --- Reinicia stamina a las 12am ---
Future<void> reiniciarStaminaDiaria() async {
  final prefs = await SharedPreferences.getInstance();
  final lastReset = prefs.getString('stamina_last_reset');
  final now = DateTime.now();
  final todayString = "${now.year}-${now.month}-${now.day}";

  if (lastReset != todayString) {
    await prefs.setInt('stamina', staminaMax);
    await prefs.setString('stamina_last_reset', todayString);
  }
}

// --- Gasta stamina, regresa true si sí pudo, false si no hay suficiente ---
Future<bool> gastarStamina(int cantidad) async {
  await reiniciarStaminaDiaria();
  final prefs = await SharedPreferences.getInstance();
  int actual = prefs.getInt('stamina') ?? staminaMax;
  if (actual < cantidad) return false;
  await setStamina(actual - cantidad);
  return true;
}

// --- Suma stamina (por poción, etc), nunca más del máximo ---
Future<void> sumarStamina(int cantidad) async {
  await reiniciarStaminaDiaria();
  final prefs = await SharedPreferences.getInstance();
  int actual = prefs.getInt('stamina') ?? staminaMax;
  await setStamina(actual + cantidad);
}

// --- Resetea stamina manualmente (solo por si ocupas debug) ---
Future<void> resetStamina() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('stamina', staminaMax);
  final now = DateTime.now();
  final todayString = "${now.year}-${now.month}-${now.day}";
  await prefs.setString('stamina_last_reset', todayString);
}
