import 'package:shared_preferences/shared_preferences.dart';

Future<void> sumarMisionCompletada() async {
  final prefs = await SharedPreferences.getInstance();
  int actuales = prefs.getInt('misiones_completadas') ?? 0;
  await prefs.setInt('misiones_completadas', actuales + 1);
}
