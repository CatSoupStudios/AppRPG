import 'package:shared_preferences/shared_preferences.dart';

const int staminaMax = 100;
const double staminaRegenPerHour = 0.2; // 20% por hora

// --- Carga stamina actual con regeneración automática ---
Future<int> getStamina() async {
  final prefs = await SharedPreferences.getInstance();
  await reiniciarStaminaDiaria(); // Siempre revisa si toca reiniciar

  int stamina = prefs.getInt('stamina') ?? staminaMax;

  // Obtener el último update o poner ahora si nunca ha habido
  int lastUpdateMillis = prefs.getInt('stamina_last_update') ??
      DateTime.now().millisecondsSinceEpoch;
  DateTime lastUpdate = DateTime.fromMillisecondsSinceEpoch(lastUpdateMillis);
  DateTime now = DateTime.now();

  // Calcula horas completas transcurridas desde el último update
  int horasPasadas = now.difference(lastUpdate).inHours;

  if (horasPasadas > 0 && stamina < staminaMax) {
    int posibleRecuperar =
        (staminaMax * staminaRegenPerHour * horasPasadas).round();

    int staminaNueva = stamina + posibleRecuperar;
    if (staminaNueva > staminaMax) staminaNueva = staminaMax;

    stamina = staminaNueva;

    // Guarda stamina y nuevo timestamp
    await prefs.setInt('stamina', stamina);
    await prefs.setInt('stamina_last_update', now.millisecondsSinceEpoch);
  } else {
    // Si no hubo recuperación, actualiza el timestamp solo si nunca lo habías guardado antes
    if (prefs.getInt('stamina_last_update') == null) {
      await prefs.setInt('stamina_last_update', now.millisecondsSinceEpoch);
    }
  }

  return stamina;
}

// --- Guarda nueva stamina y actualiza timestamp ---
Future<void> setStamina(int value) async {
  final prefs = await SharedPreferences.getInstance();
  int val = value.clamp(0, staminaMax);
  await prefs.setInt('stamina', val);
  await prefs.setInt(
      'stamina_last_update', DateTime.now().millisecondsSinceEpoch);
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
    await prefs.setInt('stamina_last_update', now.millisecondsSinceEpoch);
  }
}

// --- Gasta stamina, regresa true si sí pudo, false si no hay suficiente ---
Future<bool> gastarStamina(int cantidad) async {
  await reiniciarStaminaDiaria();
  int actual = await getStamina(); // para que aplique la regeneración antes
  if (actual < cantidad) return false;
  await setStamina(actual - cantidad);
  return true;
}

// --- Suma stamina (por poción, etc), nunca más del máximo ---
Future<void> sumarStamina(int cantidad) async {
  await reiniciarStaminaDiaria();
  int actual = await getStamina(); // para que aplique la regeneración antes
  await setStamina(actual + cantidad);
}

// --- Resetea stamina manualmente (solo por si ocupas debug) ---
Future<void> resetStamina() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('stamina', staminaMax);
  final now = DateTime.now();
  final todayString = "${now.year}-${now.month}-${now.day}";
  await prefs.setString('stamina_last_reset', todayString);
  await prefs.setInt('stamina_last_update', now.millisecondsSinceEpoch);
}
