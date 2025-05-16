import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _cargarPreferencia();
  }

  void toggleTheme(bool isDark) {
    _isDarkMode = isDark;
    notifyListeners();
    _guardarPreferencia();
  }

  Future<void> _cargarPreferencia() async {
    final prefs = await SharedPreferences.getInstance();
    final temaGuardado = prefs.getString('tema');
    if (temaGuardado == 'oscuro') {
      _isDarkMode = true;
    } else if (temaGuardado == 'claro') {
      _isDarkMode = false;
    }
    notifyListeners();
  }

  Future<void> _guardarPreferencia() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tema', _isDarkMode ? 'oscuro' : 'claro');
  }
}
