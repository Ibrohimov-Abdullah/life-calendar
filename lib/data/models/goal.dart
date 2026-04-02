// lib/data/models/goal.dart
import 'package:uuid/uuid.dart';

enum GoalCategory {
  health,
  career,
  travel,
  learning,
  relationships,
  finance,
  personal,
}

enum GoalStatus { todo, inProgress, completed }

extension GoalCategoryExtension on GoalCategory {
  String get emoji {
    switch (this) {
      case GoalCategory.health: return '💪';
      case GoalCategory.career: return '💼';
      case GoalCategory.travel: return '✈️';
      case GoalCategory.learning: return '📚';
      case GoalCategory.relationships: return '❤️';
      case GoalCategory.finance: return '💰';
      case GoalCategory.personal: return '⭐';
    }
  }

  String get labelEn {
    switch (this) {
      case GoalCategory.health: return 'Health';
      case GoalCategory.career: return 'Career';
      case GoalCategory.travel: return 'Travel';
      case GoalCategory.learning: return 'Learning';
      case GoalCategory.relationships: return 'Relationships';
      case GoalCategory.finance: return 'Finance';
      case GoalCategory.personal: return 'Personal';
    }
  }

  String get labelRu {
    switch (this) {
      case GoalCategory.health: return 'Здоровье';
      case GoalCategory.career: return 'Карьера';
      case GoalCategory.travel: return 'Путешествия';
      case GoalCategory.learning: return 'Обучение';
      case GoalCategory.relationships: return 'Отношения';
      case GoalCategory.finance: return 'Финансы';
      case GoalCategory.personal: return 'Личное';
    }
  }
}

class Goal {
  final String id;
  final String title;
  final String emoji;
  final String? description;
  final GoalCategory category;
  final GoalStatus status;
  final DateTime? targetDate;
  final DateTime createdAt;
  final DateTime? completedAt;

  const Goal({
    required this.id,
    required this.title,
    required this.emoji,
    this.description,
    required this.category,
    this.status = GoalStatus.todo,
    this.targetDate,
    required this.createdAt,
    this.completedAt,
  });

  factory Goal.create({
    required String title,
    required String emoji,
    String? description,
    required GoalCategory category,
    GoalStatus status = GoalStatus.todo,
    DateTime? targetDate,
  }) {
    return Goal(
      id: const Uuid().v4(),
      title: title,
      emoji: emoji,
      description: description,
      category: category,
      status: status,
      targetDate: targetDate,
      createdAt: DateTime.now(),
    );
  }

  bool get isCompleted => status == GoalStatus.completed;

  int? get daysUntilTarget =>
      targetDate != null ? targetDate!.difference(DateTime.now()).inDays : null;

  Goal copyWith({
    String? title,
    String? emoji,
    String? description,
    bool clearDescription = false,
    GoalCategory? category,
    GoalStatus? status,
    DateTime? targetDate,
    bool clearTargetDate = false,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return Goal(
      id: id,
      title: title ?? this.title,
      emoji: emoji ?? this.emoji,
      description: clearDescription ? null : (description ?? this.description),
      category: category ?? this.category,
      status: status ?? this.status,
      targetDate: clearTargetDate ? null : (targetDate ?? this.targetDate),
      createdAt: createdAt,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'emoji': emoji,
      'description': description,
      'category': category.index,
      'status': status.index,
      'targetDate': targetDate?.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'completedAt': completedAt?.millisecondsSinceEpoch,
    };
  }

  factory Goal.fromMap(Map<dynamic, dynamic> map) {
    return Goal(
      id: map['id'] as String,
      title: map['title'] as String,
      emoji: map['emoji'] as String,
      description: map['description'] as String?,
      category: GoalCategory.values[(map['category'] as int?) ?? 6],
      status: GoalStatus.values[(map['status'] as int?) ?? 0],
      targetDate: map['targetDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['targetDate'] as int)
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
          (map['createdAt'] as int?) ?? DateTime.now().millisecondsSinceEpoch),
      completedAt: map['completedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completedAt'] as int)
          : null,
    );
  }
}

// Common emojis for goals
const List<String> kGoalEmojis = [
  '🎯', '💪', '🏆', '⭐', '🚀', '💡', '🌱', '🔥',
  '📚', '✈️', '💼', '💰', '❤️', '🎨', '🎵', '🏋️',
  '🌍', '🏠', '🤝', '🎉', '🌅', '🦋', '🏔️', '🌊',
  '🧘', '🎓', '💍', '👶', '🍀', '🌺', '🦁', '🎭',
];
