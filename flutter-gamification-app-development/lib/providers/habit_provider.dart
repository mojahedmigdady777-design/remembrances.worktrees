import 'package:flutter/material.dart';

import '../models/habit.dart';
import '../services/hive_service.dart';

class HabitProvider extends ChangeNotifier {
  static const String _habitsBox = 'habits';
  static const String _habitsKey = 'habit_list';
  static const String _statusBox = 'daily_status';
  static const String _notesBox = 'daily_notes';

  final List<Habit> _habits = [];
  final Map<String, Map<String, HabitStatus>> _dailyStatus = {};
  final Map<String, String> _dailyNotes = {};

  List<Habit> get habits => List.unmodifiable(_habits);

  List<Habit> habitsByCategory(HabitCategory category) {
    return _habits.where((h) => h.category == category).toList();
  }

  String statusLabel(HabitStatus status) => status.title;

  Future<void> init() async {
    await _loadHabits();
    await _loadRecords();
  }

  Future<void> _loadHabits() async {
    final box = await HiveService.openBox(_habitsBox);
    final raw = box.get(_habitsKey);
    if (raw is List) {
      final list = raw.map((item) {
        return Habit.fromMap(Map<String, dynamic>.from(item as Map));
      }).toList();
      if (list.isNotEmpty) {
        _habits.clear();
        _habits.addAll(list);
        return;
      }
    }

    _habits.clear();
    _habits.addAll(_defaultHabits);
  }

  Future<void> _loadRecords() async {
    final statusBox = await HiveService.openBox(_statusBox);
    final notesBox = await HiveService.openBox(_notesBox);

    for (final key in statusBox.keys) {
      final raw = statusBox.get(key);
      if (raw is Map) {
        final statusMap = <String, HabitStatus>{};
        for (final entry in raw.entries) {
          final habitId = entry.key.toString();
          final statusValue = entry.value.toString();
          final status = HabitStatus.values.firstWhere(
            (value) => value.name == statusValue,
            orElse: () => HabitStatus.none,
          );
          statusMap[habitId] = status;
        }
        _dailyStatus[key.toString()] = statusMap;
      }
    }

    for (final key in notesBox.keys) {
      final raw = notesBox.get(key);
      if (raw is String) {
        _dailyNotes[key.toString()] = raw;
      }
    }
  }

  Future<void> _saveHabits() async {
    final box = await HiveService.openBox(_habitsBox);
    await box.put(_habitsKey, _habits.map((habit) => habit.toMap()).toList());
  }

  Future<void> _saveStatus(String dateKey) async {
    final box = await HiveService.openBox(_statusBox);
    final record = _dailyStatus[dateKey]?.map((key, value) => MapEntry(key, value.name));
    if (record == null || record.isEmpty) {
      await box.delete(dateKey);
      return;
    }

    await box.put(dateKey, record);
  }

  Future<void> _saveNote(String dateKey) async {
    final box = await HiveService.openBox(_notesBox);
    final note = _dailyNotes[dateKey] ?? '';
    if (note.isEmpty) {
      await box.delete(dateKey);
      return;
    }
    await box.put(dateKey, note);
  }

  String formatDateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  HabitStatus statusForDate(DateTime date, String habitId) {
    final key = formatDateKey(date);
    return _dailyStatus[key]?[habitId] ?? HabitStatus.none;
  }

  void updateStatus(DateTime date, String habitId, HabitStatus status) {
    final key = formatDateKey(date);
    final record = _dailyStatus.putIfAbsent(key, () => {});
    if (status == HabitStatus.none) {
      record.remove(habitId);
    } else {
      record[habitId] = status;
    }
    if (record.isEmpty) {
      _dailyStatus.remove(key);
    }
    _saveStatus(key);
    notifyListeners();
  }

  String noteForDate(DateTime date) {
    return _dailyNotes[formatDateKey(date)] ?? '';
  }

  void updateNote(DateTime date, String note) {
    final key = formatDateKey(date);
    _dailyNotes[key] = note.trim();
    if (_dailyNotes[key]!.isEmpty) {
      _dailyNotes.remove(key);
    }
    _saveNote(key);
    notifyListeners();
  }

  int dailyPoints(DateTime date) {
    final key = formatDateKey(date);
    return _dailyStatus[key]?.values.fold<int>(0, (int sum, HabitStatus status) => sum + status.points) ?? 0;
  }

  double dailyProgress(DateTime date) {
    if (_habits.isEmpty) return 0;
    final total = _habits.length * 2;
    return total == 0 ? 0 : dailyPoints(date) / total;
  }

  int monthlyPoints([DateTime? date]) {
    final now = date ?? DateTime.now();
    final monthPrefix = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}';
    return _dailyStatus.entries
        .where((entry) => entry.key.startsWith(monthPrefix))
        .fold(0, (sum, entry) => sum + entry.value.values.fold(0, (inner, status) => inner + status.points));
  }

  /// يحسب النقاط المكتسبة لعبادة معينة خلال الشهر
  int habitEarnedMonthlyPoints(String habitId, [DateTime? date]) {
    final now = date ?? DateTime.now();
    final monthPrefix = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}';
    return _dailyStatus.entries
        .where((entry) => entry.key.startsWith(monthPrefix))
        .fold<int>(0, (sum, entry) {
          final status = entry.value[habitId];
          return sum + (status?.points ?? 0);
        });
  }

  int habitMonthlyPoints(String habitId, [DateTime? date]) {
    return habitEarnedMonthlyPoints(habitId, date);
  }

  /// يحسب عدد مرات الإنجاز الفعلية (التي حصل فيها على نقاط) للعبادة خلال الشهر
  int habitCompletionDays(String habitId, [DateTime? date]) {
    final now = date ?? DateTime.now();
    final monthPrefix = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}';
    return _dailyStatus.entries
        .where((entry) => entry.key.startsWith(monthPrefix))
        .where((entry) {
          final status = entry.value[habitId];
          return status != null && status.points > 0;
        })
        .length;
  }

  int completedDaysThisMonth([DateTime? date]) {
    final now = date ?? DateTime.now();
    final monthPrefix = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}';
    final maxPoints = _habits.length * 2;
    return _dailyStatus.entries
        .where((entry) => entry.key.startsWith(monthPrefix))
        .where((entry) => entry.value.values.fold(0, (sum, status) => sum + status.points) == maxPoints)
        .length;
  }

  int currentStreak() {
    if (_habits.isEmpty) return 0;
    var streak = 0;
    var day = DateTime.now();
    final maxPoints = _habits.length * 2;
    while (true) {
      final points = dailyPoints(day);
      if (points == maxPoints) {
        streak++;
        day = day.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  String lastCompletedHabitTitle() {
    final sortedKeys = _dailyStatus.keys.toList()
      ..sort((a, b) => b.compareTo(a));
    for (final dateKey in sortedKeys) {
      final statusMap = _dailyStatus[dateKey]!;
      final doneHabitId = statusMap.entries
          .where((entry) => entry.value == HabitStatus.done)
          .map((entry) => entry.key)
          .toList();
      if (doneHabitId.isNotEmpty) {
        final habit = _habits.firstWhere(
          (h) => h.id == doneHabitId.first,
          orElse: () => Habit(id: 'unknown', title: '...', category: HabitCategory.custom),
        );
        return habit.title;
      }
    }
    return 'لا يوجد';
  }

  void addHabit(String title) {
    final habit = Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      category: HabitCategory.custom,
      isCustom: true,
    );
    _habits.add(habit);
    _saveHabits();
    notifyListeners();
  }

  void removeHabit(String id) {
    _habits.removeWhere((habit) => habit.id == id);
    _saveHabits();
    notifyListeners();
  }

  void reorderHabits(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final habit = _habits.removeAt(oldIndex);
    _habits.insert(newIndex, habit);
    _saveHabits();
    notifyListeners();
  }

  void updateHabit(Habit updated) {
    final idx = _habits.indexWhere((h) => h.id == updated.id);
    if (idx == -1) return;
    _habits[idx] = updated;
    _saveHabits();
    notifyListeners();
  }

  static List<Habit> get _defaultHabits {
    return [
      Habit(id: 'ward_qurani', title: 'ورد قرآني', category: HabitCategory.quran),
      Habit(id: 'dhikr', title: 'ذكر', category: HabitCategory.quran),
      Habit(id: 'adhkar_sabah_masa', title: 'أذكار الصباح والمساء', category: HabitCategory.quran),
      Habit(id: 'qiyam_layl', title: 'قيام ليل', category: HabitCategory.prayer),
      Habit(id: 'siyam_nawafil', title: 'صيام نوافل', category: HabitCategory.prayer),
      Habit(id: 'salat_janaiz', title: 'صلاة جنازة', category: HabitCategory.prayer),
      Habit(id: 'salat_masjid_jamaah', title: 'الصلاة في المسجد جماعة', category: HabitCategory.mosque),
      Habit(id: 'itikaf', title: 'اعتكاف في المسجد', category: HabitCategory.mosque),
      Habit(id: 'sadaqah', title: 'صدقة', category: HabitCategory.charity),
      Habit(id: 'listening_sermon', title: 'سماع موعظة', category: HabitCategory.knowledge),
    ];
  }
}