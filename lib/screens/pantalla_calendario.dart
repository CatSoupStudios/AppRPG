import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../utils/colors.dart';
import '../utils/xp_diaria.dart';

class PantallaCalendario extends StatelessWidget {
  const PantallaCalendario({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
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
            const SizedBox(height: 16),
            Expanded(
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: today,
                availableGestures: AvailableGestures.all,
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: AppColors.lightAccent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.lightAccent.withOpacity(0.6),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  todayTextStyle: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
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
                if (!snapshot.hasData) {
                  return const SizedBox.shrink();
                }
                final xp = snapshot.data!;
                return Text(
                  '🔸 XP ganada hoy: $xp',
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
