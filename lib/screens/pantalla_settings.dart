import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/colors.dart';

class PantallaSettings extends StatefulWidget {
  const PantallaSettings({super.key});

  @override
  State<PantallaSettings> createState() => _PantallaSettingsState();
}

class _PantallaSettingsState extends State<PantallaSettings> {
  void mostrarSelectorDeIdioma() {
    final isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

    showModalBottomSheet(
      context: context,
      backgroundColor:
          isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.white24 : Colors.black26,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text('Español 🇲🇽',
                  style: TextStyle(
                      color:
                          isDarkMode ? AppColors.darkText : AppColors.lightText,
                      fontSize: 16)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: Text('English 🇺🇸',
                  style: TextStyle(
                      color:
                          isDarkMode ? AppColors.darkText : AppColors.lightText,
                      fontSize: 16)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: Text('Русский 🇷🇺',
                  style: TextStyle(
                      color:
                          isDarkMode ? AppColors.darkText : AppColors.lightText,
                      fontSize: 16)),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor:
            isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
        title: Text(
          'Configuración',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isDarkMode ? AppColors.darkText : AppColors.lightText,
          ),
        ),
        foregroundColor: isDarkMode ? AppColors.darkText : AppColors.lightText,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDarkMode ? AppColors.darkText : AppColors.lightText,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.white10 : Colors.black12,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  title: Text('Idioma',
                      style: TextStyle(
                          color: isDarkMode
                              ? AppColors.darkText
                              : AppColors.lightText,
                          fontSize: 16)),
                  subtitle: Text('Español',
                      style: TextStyle(
                          color: isDarkMode
                              ? AppColors.darkSecondaryText
                              : AppColors.lightSecondaryText)),
                  trailing: Icon(Icons.chevron_right,
                      color: isDarkMode
                          ? AppColors.darkSecondaryText
                          : AppColors.lightSecondaryText),
                  onTap: mostrarSelectorDeIdioma,
                ),
                Divider(
                    height: 1,
                    color: isDarkMode
                        ? AppColors.darkSecondaryText
                        : AppColors.lightSecondaryText),
                ListTile(
                  title: Text('Tema',
                      style: TextStyle(
                          color: isDarkMode
                              ? AppColors.darkText
                              : AppColors.lightText,
                          fontSize: 16)),
                  subtitle: Text(
                    isDarkMode ? 'Oscuro 🌙' : 'Claro ☀️',
                    style: TextStyle(
                        color: isDarkMode
                            ? AppColors.darkSecondaryText
                            : AppColors.lightSecondaryText),
                  ),
                  trailing: Switch(
                    value: isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleTheme(value);
                    },
                    activeColor: Colors.amber,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
