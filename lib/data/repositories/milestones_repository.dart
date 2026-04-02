// lib/data/repositories/milestones_repository.dart
import 'package:hive_flutter/hive_flutter.dart';
import '../models/milestone.dart';
import '../../core/constants/app_constants.dart';

class MilestonesRepository {
  Box? _box;

  Future<void> init() async {
    _box = await Hive.openBox(AppConstants.hiveBoxMilestones);
  }

  List<Milestone> loadMilestones() {
    final box = _box;
    if (box == null) return [];
    return box.values
        .map((v) => Milestone.fromMap(v as Map))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  Future<void> saveMilestone(Milestone milestone) async {
    await _box?.put(milestone.id, milestone.toMap());
  }

  Future<void> deleteMilestone(String id) async {
    await _box?.delete(id);
  }
}
