// lib/data/providers/app_providers.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_settings.dart';
import '../models/milestone.dart';
import '../models/goal.dart';
import '../repositories/settings_repository.dart';
import '../repositories/milestones_repository.dart';
import '../repositories/goals_repository.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/firebase_service.dart';

// Repositories
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

final milestonesRepositoryProvider = Provider<MilestonesRepository>((ref) {
  return MilestonesRepository();
});

final goalsRepositoryProvider = Provider<GoalsRepository>((ref) {
  return GoalsRepository();
});

// Auth state (Firebase user, null when not signed in or Firebase unavailable)
final authUserProvider = StreamProvider<User?>((ref) {
  if (!FirebaseService.isAvailable) return const Stream.empty();
  return FirebaseAuth.instance.authStateChanges();
});

// Settings notifier
class SettingsNotifier extends StateNotifier<UserSettings> {
  final SettingsRepository _repository;

  SettingsNotifier(this._repository) : super(_repository.loadSettings());

  Future<void> updateSettings(UserSettings settings) async {
    state = settings;
    await _repository.saveSettings(settings);
  }

  Future<void> setBirthDate(DateTime? date) async {
    if (date == null) {
      state = state.copyWith(clearBirthDate: true);
    } else {
      state = state.copyWith(birthDate: date);
    }
    await _repository.saveSettings(state);
  }

  Future<void> setLifeExpectancy(int years) async {
    state = state.copyWith(lifeExpectancyYears: years);
    await _repository.saveSettings(state);
  }

  Future<void> setWeekStart(WeekStart weekStart) async {
    state = state.copyWith(weekStart: weekStart);
    await _repository.saveSettings(state);
  }

  Future<void> setDailyReminder(bool enabled) async {
    state = state.copyWith(dailyReminderEnabled: enabled);
    await _repository.saveSettings(state);
  }

  Future<void> setReminderTime(int hour, int minute) async {
    state = state.copyWith(reminderHour: hour, reminderMinute: minute);
    await _repository.saveSettings(state);
  }

  Future<void> setLanguage(String code) async {
    state = state.copyWith(languageCode: code);
    await _repository.saveSettings(state);
  }

  Future<void> completeOnboarding() async {
    state = state.copyWith(onboardingCompleted: true);
    await _repository.saveSettings(state);
  }

  /// Called on every app open to track daily streak
  Future<void> recordAppOpen() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastOpen = state.lastOpenDate;

    int newStreak = state.streak;

    if (lastOpen == null) {
      newStreak = 1;
    } else {
      final lastOpenDay = DateTime(lastOpen.year, lastOpen.month, lastOpen.day);
      final diff = today.difference(lastOpenDay).inDays;
      if (diff == 0) {
        // Already opened today — no change
        return;
      } else if (diff == 1) {
        // Consecutive day
        newStreak = state.streak + 1;
      } else {
        // Streak broken
        newStreak = 1;
      }
    }

    state = state.copyWith(streak: newStreak, lastOpenDate: now);
    await _repository.saveSettings(state);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, UserSettings>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return SettingsNotifier(repo);
});

// Milestones notifier
class MilestonesNotifier extends StateNotifier<List<Milestone>> {
  final MilestonesRepository _repository;

  MilestonesNotifier(this._repository) : super(_repository.loadMilestones());

  Future<void> addMilestone(Milestone milestone) async {
    await _repository.saveMilestone(milestone);
    state = [...state, milestone]..sort((a, b) => a.date.compareTo(b.date));
  }

  Future<void> updateMilestone(Milestone milestone) async {
    await _repository.saveMilestone(milestone);
    state = state
        .map((m) => m.id == milestone.id ? milestone : m)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  Future<void> deleteMilestone(String id) async {
    await _repository.deleteMilestone(id);
    state = state.where((m) => m.id != id).toList();
  }

  void replaceAll(List<Milestone> milestones) {
    state = milestones..sort((a, b) => a.date.compareTo(b.date));
  }
}

final milestonesProvider =
    StateNotifierProvider<MilestonesNotifier, List<Milestone>>((ref) {
  final repo = ref.watch(milestonesRepositoryProvider);
  return MilestonesNotifier(repo);
});

// Goals notifier
class GoalsNotifier extends StateNotifier<List<Goal>> {
  final GoalsRepository _repository;

  GoalsNotifier(this._repository) : super(_repository.loadGoals());

  Future<void> addGoal(Goal goal) async {
    await _repository.saveGoal(goal);
    state = [goal, ...state];
  }

  Future<void> updateGoal(Goal goal) async {
    await _repository.saveGoal(goal);
    state = state.map((g) => g.id == goal.id ? goal : g).toList();
  }

  Future<void> toggleComplete(Goal goal) async {
    final updated = goal.isCompleted
        ? goal.copyWith(status: GoalStatus.todo, clearCompletedAt: true)
        : goal.copyWith(
            status: GoalStatus.completed,
            completedAt: DateTime.now(),
          );
    await updateGoal(updated);
  }

  Future<void> deleteGoal(String id) async {
    await _repository.deleteGoal(id);
    state = state.where((g) => g.id != id).toList();
  }

  void replaceAll(List<Goal> goals) {
    state = goals;
  }
}

final goalsProvider =
    StateNotifierProvider<GoalsNotifier, List<Goal>>((ref) {
  final repo = ref.watch(goalsRepositoryProvider);
  return GoalsNotifier(repo);
});

// Locale provider
final localeProvider = StateProvider<Locale>((ref) {
  final settings = ref.watch(settingsProvider);
  return Locale(settings.languageCode);
});

// Current date provider
final currentDateProvider = Provider<DateTime>((ref) => DateTime.now());
