import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
//import 'pantalla_creacion.dart'; // <-- Este es el correcto si el archivo está en lib/
import 'utils/colors.dart';
import 'screens/intro_screen.dart'; // Esta sí va en /screens

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return FadeTransition(
      opacity: _animation,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Solo Leving',
        theme: ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: AppColors.lightBackground, // Fondo claro
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.lightBackground,
            foregroundColor: AppColors.lightText,
          ),
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: AppColors.lightText), // Texto claro
          ),
          iconTheme: const IconThemeData(
              color: AppColors.lightText), // Iconos en claro
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppColors.darkBackground, // Fondo oscuro
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.darkBackground,
            foregroundColor: AppColors.darkText,
          ),
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: AppColors.darkText), // Texto oscuro
          ),
          iconTheme: const IconThemeData(
              color: AppColors.darkText), // Iconos en oscuro
        ),
        themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: const IntroScreen(),
      ),
    );
  }
}
