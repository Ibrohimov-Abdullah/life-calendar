// lib/core/utils/date_utils.dart
import 'package:flutter/material.dart';

class AppDateUtils {
  AppDateUtils._();

  /// Returns the day of year (1-365/366)
  static int dayOfYear(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    return date.difference(startOfYear).inDays + 1;
  }

  /// Returns total days in a year (handles leap year)
  static int daysInYear(int year) {
    return isLeapYear(year) ? 366 : 365;
  }

  static bool isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  /// Days left in the year
  static int daysLeftInYear(DateTime date) {
    return daysInYear(date.year) - dayOfYear(date);
  }

  /// Year progress (0.0 to 1.0)
  static double yearProgress(DateTime date) {
    return dayOfYear(date) / daysInYear(date.year);
  }

  /// Total days in a month
  static int daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  /// Day of month (1-based)
  static int dayOfMonth(DateTime date) => date.day;

  /// Month progress (0.0 to 1.0)
  static double monthProgress(DateTime date) {
    return date.day / daysInMonth(date.year, date.month);
  }

  /// Days left in the month
  static int daysLeftInMonth(DateTime date) {
    return daysInMonth(date.year, date.month) - date.day;
  }

  /// Week number of year (ISO 8601)
  static int weekOfYear(DateTime date, {bool startOnMonday = true}) {
    final startOfYear = DateTime(date.year, 1, 1);
    final firstDayOfWeek = startOnMonday ? 1 : 0; // 1=Monday, 0=Sunday
    
    int startOffset = startOfYear.weekday - (startOnMonday ? 1 : 0);
    if (!startOnMonday && startOfYear.weekday == 7) startOffset = 0;
    
    final daysSinceStart = date.difference(startOfYear).inDays;
    return ((daysSinceStart + startOffset) / 7).floor() + 1;
  }

  /// Total weeks in year
  static int weeksInYear(int year, {bool startOnMonday = true}) {
    final lastDay = DateTime(year, 12, 31);
    return weekOfYear(lastDay, startOnMonday: startOnMonday);
  }

  /// Week progress (0.0 to 1.0) based on day of week
  static double weekProgress(DateTime date, {bool startOnMonday = true}) {
    int dayOfWeek = date.weekday; // 1=Mon, 7=Sun
    if (!startOnMonday) {
      // Sunday = 1, Saturday = 7
      dayOfWeek = date.weekday == 7 ? 1 : date.weekday + 1;
    }
    return dayOfWeek / 7;
  }

  /// Days left in the week
  static int daysLeftInWeek(DateTime date, {bool startOnMonday = true}) {
    int dayOfWeek = date.weekday;
    if (!startOnMonday) {
      dayOfWeek = date.weekday == 7 ? 1 : date.weekday + 1;
    }
    return 7 - dayOfWeek;
  }

  // ---- Life Calendar calculations ----

  /// Calculate weeks lived since birthdate
  static int weeksLived(DateTime birthDate) {
    final today = DateTime.now();
    if (birthDate.isAfter(today)) return 0;
    return today.difference(birthDate).inDays ~/ 7;
  }

  /// Total expected weeks
  static int totalLifeWeeks(int lifeExpectancyYears) {
    return lifeExpectancyYears * 52;
  }

  /// Life progress (0.0 to 1.0)
  static double lifeProgress(DateTime birthDate, int lifeExpectancyYears) {
    final lived = weeksLived(birthDate);
    final total = totalLifeWeeks(lifeExpectancyYears);
    return (lived / total).clamp(0.0, 1.0);
  }

  /// Age in years
  static int ageInYears(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age.clamp(0, 200);
  }

  /// Format date to readable string
  static String formatDate(DateTime date, Locale locale) {
    final months = locale.languageCode == 'ru'
        ? _monthsRu
        : _monthsEn;
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  static const List<String> _monthsEn = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  static const List<String> _monthsRu = [
    'янв', 'фев', 'мар', 'апр', 'май', 'июн',
    'июл', 'авг', 'сен', 'окт', 'ноя', 'дек',
  ];

  static String monthName(int month, Locale locale) {
    final fullMonthsEn = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final fullMonthsRu = [
      'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
      'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь',
    ];
    return locale.languageCode == 'ru'
        ? fullMonthsRu[month - 1]
        : fullMonthsEn[month - 1];
  }
}
