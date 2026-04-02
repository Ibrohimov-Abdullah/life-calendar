// lib/data/models/milestone.dart
import 'package:uuid/uuid.dart';

class Milestone {
  final String id;
  final String title;
  final DateTime date;
  final String emoji;
  final String? description;

  const Milestone({
    required this.id,
    required this.title,
    required this.date,
    required this.emoji,
    this.description,
  });

  factory Milestone.create({
    required String title,
    required DateTime date,
    required String emoji,
    String? description,
  }) {
    return Milestone(
      id: const Uuid().v4(),
      title: title,
      date: date,
      emoji: emoji,
      description: description,
    );
  }

  bool get isPast => date.isBefore(DateTime.now());

  int get daysFromNow => date.difference(DateTime.now()).inDays;

  Milestone copyWith({
    String? title,
    DateTime? date,
    String? emoji,
    String? description,
  }) {
    return Milestone(
      id: id,
      title: title ?? this.title,
      date: date ?? this.date,
      emoji: emoji ?? this.emoji,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date.millisecondsSinceEpoch,
      'emoji': emoji,
      'description': description,
    };
  }

  factory Milestone.fromMap(Map<dynamic, dynamic> map) {
    return Milestone(
      id: map['id'] as String,
      title: map['title'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      emoji: map['emoji'] as String,
      description: map['description'] as String?,
    );
  }
}

// Common emoji suggestions for milestones
const List<String> kMilestoneEmojis = [
  '🎓', '💼', '🏠', '✈️', '💍', '👶', '🚀', '🎯',
  '💡', '🏆', '❤️', '🌍', '📚', '🎨', '🎵', '🏋️',
  '🌱', '💰', '🤝', '🎉', '⭐', '🔑', '🛸', '🌙',
  '🦋', '🌊', '🏔️', '🌺', '🍀', '🦁', '🌅', '🎭',
];
