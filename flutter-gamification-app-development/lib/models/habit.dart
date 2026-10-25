import 'package:flutter/material.dart';

enum HabitCategory {
  quran,
  prayer,
  mosque,
  charity,
  knowledge,
  custom,
}

enum HabitStatus {
  none,
  half,
  done,
}

extension HabitStatusExtension on HabitStatus {
  String get title {
    switch (this) {
      case HabitStatus.done:
        return 'أتم';
      case HabitStatus.half:
        return 'جزئي';
      case HabitStatus.none:
        return 'لم يتم';
    }
  }

  int get points {
    switch (this) {
      case HabitStatus.done:
        return 2;
      case HabitStatus.half:
        return 1;
      case HabitStatus.none:
        return 0;
    }
  }
}

class Habit {
  final String id;

  final String title;

  final HabitCategory category;

  final IconData icon;

  bool isCustom;

  bool notificationsEnabled;

  TimeOfDay? reminderTime;

  int points;

  Habit({
    required this.id,
    required this.title,
    required this.category,
    IconData? icon,
    this.isCustom = false,
    this.notificationsEnabled = false,
    this.reminderTime,
    this.points = 2,
  }) : icon = icon ?? _iconForCategory(category);

  String get categoryTitle {
    switch (category) {
      case HabitCategory.quran:
        return 'القرآن والأذكار';
      case HabitCategory.prayer:
        return 'الصلوات والنوافل';
      case HabitCategory.mosque:
        return 'المسجد والاعتكاف';
      case HabitCategory.charity:
        return 'الخير';
      case HabitCategory.knowledge:
        return 'العلم';
      case HabitCategory.custom:
        return 'عبادة مخصصة';
    }
  }

  static IconData _iconForCategory(HabitCategory category) {
    switch (category) {
      case HabitCategory.quran:
        return Icons.menu_book;
      case HabitCategory.prayer:
        return Icons.bedtime;
      case HabitCategory.mosque:
        return Icons.mosque;
      case HabitCategory.charity:
        return Icons.volunteer_activism;
      case HabitCategory.knowledge:
        return Icons.headphones;
      case HabitCategory.custom:
        return Icons.star;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category.name,
      'isCustom': isCustom,
      'notificationsEnabled': notificationsEnabled,
      'reminderTime': reminderTime != null
          ? {'hour': reminderTime!.hour, 'minute': reminderTime!.minute}
          : null,
      'points': points,
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    final category = HabitCategory.values.firstWhere(
      (value) => value.name == map['category'],
      orElse: () => HabitCategory.custom,
    );

    TimeOfDay? reminderTime;
    if (map['reminderTime'] is Map) {
      final reminderMap = Map<String, dynamic>.from(map['reminderTime']);
      reminderTime = TimeOfDay(
        hour: reminderMap['hour'] ?? 0,
        minute: reminderMap['minute'] ?? 0,
      );
    }

    return Habit(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      category: category,
      icon: _iconForCategory(category),
      isCustom: map['isCustom'] ?? false,
      notificationsEnabled: map['notificationsEnabled'] ?? false,
      reminderTime: reminderTime,
      points: map['points'] ?? 2,
    );
  }
}
