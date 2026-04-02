// lib/data/repositories/goals_repository.dart
import 'package:hive_flutter/hive_flutter.dart';
import '../models/goal.dart';
import '../../core/constants/app_constants.dart';

class GoalsRepository {
  Box? _box;

  Future<void> init() async {
    _box = await Hive.openBox(AppConstants.hiveBoxGoals);
  }

  List<Goal> loadGoals() {
    final box = _box;
    if (box == null) return [];
    return box.values
        .map((v) => Goal.fromMap(v as Map))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> saveGoal(Goal goal) async {
    await _box?.put(goal.id, goal.toMap());
  }

  Future<void> deleteGoal(String id) async {
    await _box?.delete(id);
  }
}
