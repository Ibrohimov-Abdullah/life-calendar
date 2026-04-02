// lib/core/services/firestore_sync_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/milestone.dart';
import '../../data/models/goal.dart';
import '../../data/models/user_settings.dart';
import 'firebase_service.dart';

class FirestoreSyncService {
  static final FirestoreSyncService _instance = FirestoreSyncService._internal();
  factory FirestoreSyncService() => _instance;
  FirestoreSyncService._internal();

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  bool get canSync => FirebaseService.isAvailable && _uid != null;

  DocumentReference get _userDoc => _db.collection('users').doc(_uid);

  /// Upload all local data to Firestore
  Future<SyncResult> uploadAll({
    required List<Milestone> milestones,
    required List<Goal> goals,
    required UserSettings settings,
  }) async {
    if (!canSync) return SyncResult.notAvailable();
    try {
      final batch = _db.batch();

      // Settings subset
      batch.set(_userDoc.collection('data').doc('settings'), {
        'birthDate': settings.birthDate?.millisecondsSinceEpoch,
        'lifeExpectancyYears': settings.lifeExpectancyYears,
        'weekStart': settings.weekStart.index,
        'languageCode': settings.languageCode,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      for (final milestone in milestones) {
        final data = Map<String, dynamic>.from(milestone.toMap());
        data['syncedAt'] = FieldValue.serverTimestamp();
        batch.set(_userDoc.collection('milestones').doc(milestone.id), data);
      }

      for (final goal in goals) {
        final data = Map<String, dynamic>.from(goal.toMap());
        data['syncedAt'] = FieldValue.serverTimestamp();
        batch.set(_userDoc.collection('goals').doc(goal.id), data);
      }

      await batch.commit();
      debugPrint('[Sync] Uploaded ${milestones.length} milestones, ${goals.length} goals');
      return SyncResult.success(milestones.length + goals.length);
    } catch (e) {
      debugPrint('[Sync] Upload failed: $e');
      return SyncResult.error(e.toString());
    }
  }

  /// Download cloud data
  Future<DownloadResult> downloadAll() async {
    if (!canSync) return DownloadResult.notAvailable();
    try {
      final results = await Future.wait([
        _userDoc.collection('milestones').get(),
        _userDoc.collection('goals').get(),
      ]);

      final milestones = results[0].docs
          .map((d) => Milestone.fromMap(d.data()))
          .toList();
      final goals = results[1].docs
          .map((d) => Goal.fromMap(d.data()))
          .toList();

      debugPrint('[Sync] Downloaded ${milestones.length} milestones, ${goals.length} goals');
      return DownloadResult.success(milestones: milestones, goals: goals);
    } catch (e) {
      debugPrint('[Sync] Download failed: $e');
      return DownloadResult.error(e.toString());
    }
  }
}

class SyncResult {
  final bool success;
  final bool available;
  final String? error;
  final int itemCount;

  SyncResult._({required this.success, required this.available, this.error, this.itemCount = 0});

  factory SyncResult.success(int count) =>
      SyncResult._(success: true, available: true, itemCount: count);
  factory SyncResult.error(String msg) =>
      SyncResult._(success: false, available: true, error: msg);
  factory SyncResult.notAvailable() =>
      SyncResult._(success: false, available: false);
}

class DownloadResult {
  final bool success;
  final bool available;
  final String? error;
  final List<Milestone> milestones;
  final List<Goal> goals;

  DownloadResult._({
    required this.success,
    required this.available,
    this.error,
    this.milestones = const [],
    this.goals = const [],
  });

  factory DownloadResult.success({
    required List<Milestone> milestones,
    required List<Goal> goals,
  }) => DownloadResult._(success: true, available: true, milestones: milestones, goals: goals);

  factory DownloadResult.error(String msg) =>
      DownloadResult._(success: false, available: true, error: msg);

  factory DownloadResult.notAvailable() =>
      DownloadResult._(success: false, available: false);
}
