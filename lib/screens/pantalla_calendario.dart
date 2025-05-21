import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../utils/colors.dart';
import '../utils/xp_diaria.dart';

class PantallaCalendario extends StatefulWidget {
  const PantallaCalendario({super.key});

  @override
  State<PantallaCalendario> createState() => _PantallaCalendarioState();
}

class _PantallaCalendarioState extends State<PantallaCalendario>
    with SingleTickerProviderStateMixin {
  DateTime today = DateTime.now();
  Set<String> diasActivos = {};
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    cargarDiasActivos();

    // Animación sutil de flameo
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -0.03),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> cargarDiasActivos() async {
    final prefs = await SharedPreferences.getInstance();
    final activos = prefs.getStringList('dias_activos') ?? [];
    setState(() {
      diasActivos = activos.toSet();
    });
  }

  Future<int> cargarRachaActual() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('racha_actual') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return FractionallySizedBox(
      heightFactor: 0.7,
      child: Container(
        decoration: BoxDecoration(
          color:
              isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Text(
              "Calendario",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            const SizedBox(height: 12),
            FutureBuilder<int>(
              future: cargarRachaActual(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '🔥 Racha actual: ${snapshot.data} días seguidos',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.amberAccent,
                    ),
                  ),
                );
              },
            ),
            Expanded(
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: today,
                availableGestures: AvailableGestures.all,
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    final hoy = DateTime.now();
                    final diaStr = DateFormat('yyyy-MM-dd').format(day);
                    final esPasado =
                        day.isBefore(DateTime(hoy.year, hoy.month, hoy.day));

                    if (diasActivos.contains(diaStr)) {
                      return SlideTransition(
                        position: _offsetAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: const Center(
                            child: Text(
                              "🔥",
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      );
                    } else if (esPasado) {
                      return Center(
                        child: Text(
                          '${day.day}',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white24 : Colors.black26,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      );
                    } else {
                      return Center(
                        child: Text(
                          '${day.day}',
                          style: TextStyle(
                            color: isDarkMode
                                ? AppColors.darkText
                                : AppColors.lightText,
                          ),
                        ),
                      );
                    }
                  },
                  todayBuilder: (context, day, focusedDay) {
                    final diaStr = DateFormat('yyyy-MM-dd').format(day);
                    if (diasActivos.contains(diaStr)) {
                      return SlideTransition(
                        position: _offsetAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.lightAccent,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.lightAccent.withOpacity(0.6),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                "🔥",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.lightAccent,
                            width: 1.2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${day.day}',
                            style: TextStyle(
                              color: isDarkMode
                                  ? AppColors.darkText
                                  : AppColors.lightText,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
                calendarStyle: CalendarStyle(
                  defaultTextStyle: TextStyle(
                    color:
                        isDarkMode ? AppColors.darkText : AppColors.lightText,
                  ),
                  weekendTextStyle: TextStyle(
                    color: isDarkMode
                        ? AppColors.darkSecondaryText
                        : AppColors.lightSecondaryText,
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color:
                        isDarkMode ? AppColors.darkText : AppColors.lightText,
                  ),
                  leftChevronIcon: Icon(Icons.chevron_left,
                      color: isDarkMode
                          ? AppColors.darkText
                          : AppColors.lightText),
                  rightChevronIcon: Icon(Icons.chevron_right,
                      color: isDarkMode
                          ? AppColors.darkText
                          : AppColors.lightText),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color:
                        isDarkMode ? AppColors.darkText : AppColors.lightText,
                  ),
                  weekendStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode
                        ? AppColors.darkSecondaryText
                        : AppColors.lightSecondaryText,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            FutureBuilder<int>(
              future: obtenerXpDelDiaActual(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();
                return Text(
                  '🔸 XP ganada hoy: ${snapshot.data}',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode
                        ? AppColors.darkSecondaryText
                        : AppColors.lightSecondaryText,
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            const Text(
              "💫 Tu progreso diario se reflejará aquí.",
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.amber,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
