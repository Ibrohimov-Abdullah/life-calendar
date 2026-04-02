// lib/data/models/user_settings.dart
import 'package:flutter/material.dart';

enum WeekStart { monday, sunday }

class UserSettings {
  final DateTime? birthDate;
  final int lifeExpectancyYears;
  final WeekStart weekStart;
  final bool dailyReminderEnabled;
  final int reminderHour;
  final int reminderMinute;
  final String languageCode;
  final bool onboardingCompleted;
  // Streak tracking
  final int streak;
  final DateTime? lastOpenDate;

  const UserSettings({
    this.birthDate,
    this.lifeExpectancyYears = 80,
    this.weekStart = WeekStart.monday,
    this.dailyReminderEnabled = false,
    this.reminderHour = 9,
    this.reminderMinute = 0,
    this.languageCode = 'en',
    this.onboardingCompleted = false,
    this.streak = 0,
    this.lastOpenDate,
  });

  UserSettings copyWith({
    DateTime? birthDate,
    bool clearBirthDate = false,
    int? lifeExpectancyYears,
    WeekStart? weekStart,
    bool? dailyReminderEnabled,
    int? reminderHour,
    int? reminderMinute,
    String? languageCode,
    bool? onboardingCompleted,
    int? streak,
    DateTime? lastOpenDate,
    bool clearLastOpenDate = false,
  }) {
    return UserSettings(
      birthDate: clearBirthDate ? null : (birthDate ?? this.birthDate),
      lifeExpectancyYears: lifeExpectancyYears ?? this.lifeExpectancyYears,
      weekStart: weekStart ?? this.weekStart,
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      languageCode: languageCode ?? this.languageCode,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      streak: streak ?? this.streak,
      lastOpenDate: clearLastOpenDate ? null : (lastOpenDate ?? this.lastOpenDate),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'birthDate': birthDate?.millisecondsSinceEpoch,
      'lifeExpectancyYears': lifeExpectancyYears,
      'weekStart': weekStart.index,
      'dailyReminderEnabled': dailyReminderEnabled,
      'reminderHour': reminderHour,
      'reminderMinute': reminderMinute,
      'languageCode': languageCode,
      'onboardingCompleted': onboardingCompleted,
      'streak': streak,
      'lastOpenDate': lastOpenDate?.millisecondsSinceEpoch,
    };
  }

  factory UserSettings.fromMap(Map<dynamic, dynamic> map) {
    return UserSettings(
      birthDate: map['birthDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['birthDate'] as int)
          : null,
      lifeExpectancyYears: (map['lifeExpectancyYears'] as int?) ?? 80,
      weekStart: WeekStart.values[(map['weekStart'] as int?) ?? 0],
      dailyReminderEnabled: (map['dailyReminderEnabled'] as bool?) ?? false,
      reminderHour: (map['reminderHour'] as int?) ?? 9,
      reminderMinute: (map['reminderMinute'] as int?) ?? 0,
      languageCode: (map['languageCode'] as String?) ?? 'en',
      onboardingCompleted: (map['onboardingCompleted'] as bool?) ?? false,
      streak: (map['streak'] as int?) ?? 0,
      lastOpenDate: map['lastOpenDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastOpenDate'] as int)
          : null,
    );
  }

  TimeOfDay get reminderTime => TimeOfDay(hour: reminderHour, minute: reminderMinute);
}
