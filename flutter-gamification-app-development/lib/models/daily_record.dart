import 'habit.dart';

class DailyRecord {
  final DateTime date;

  final String habitId;

  HabitStatus status;

  String note;

  DailyRecord({
    required this.date,
    required this.habitId,
    this.status = HabitStatus.none,
    this.note = "",
  });

  int get earnedPoints {
    return status.points;
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'habitId': habitId,
      'status': status.name,
      'note': note,
    };
  }

  factory DailyRecord.fromMap(Map<String, dynamic> map) {
    final status = HabitStatus.values.firstWhere(
      (value) => value.name == map['status'],
      orElse: () => HabitStatus.none,
    );

    return DailyRecord(
      date: DateTime.parse(map['date']),
      habitId: map['habitId'] ?? '',
      status: status,
      note: map['note'] ?? '',
    );
  }
}
