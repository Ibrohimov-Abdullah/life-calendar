// lib/data/repositories/settings_repository.dart
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_settings.dart';
import '../../core/constants/app_constants.dart';

class SettingsRepository {
  Box? _box;

  Future<void> init() async {
    _box = await Hive.openBox(AppConstants.hiveBoxSettings);
  }

  UserSettings loadSettings() {
    final box = _box;
    if (box == null) return const UserSettings();
    final data = box.get(AppConstants.settingsKey);
    if (data == null) return const UserSettings();
    return UserSettings.fromMap(data as Map);
  }

  Future<void> saveSettings(UserSettings settings) async {
    await _box?.put(AppConstants.settingsKey, settings.toMap());
  }
}
