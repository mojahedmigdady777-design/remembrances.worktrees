import 'package:flutter/material.dart';

import '../models/settings.dart';
import '../services/hive_service.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _settingsBox = 'settings';
  static const String _settingsKey = 'app_settings';

  final Settings _settings = Settings();

  Settings get settings => _settings;

  Future<void> loadSettings() async {
    final box = await HiveService.openBox(_settingsBox);
    final stored = box.get(_settingsKey);
    if (stored is Map) {
      final map = Map<String, dynamic>.from(stored);
      final loaded = Settings.fromMap(map);
      _settings.darkMode = loaded.darkMode;
      _settings.notifications = loaded.notifications;
      _settings.vibration = loaded.vibration;
      _settings.sound = loaded.sound;
      _settings.studentName = loaded.studentName;
      _settings.supervisor = loaded.supervisor;
      _settings.halaqa = loaded.halaqa;
      notifyListeners();
    }
  }

  Future<void> _saveSettings() async {
    final box = await HiveService.openBox(_settingsBox);
    await box.put(_settingsKey, _settings.toMap());
  }

  void toggleDarkMode() {
    _settings.darkMode = !_settings.darkMode;
    notifyListeners();
    _saveSettings();
  }

  void toggleNotifications() {
    _settings.notifications = !_settings.notifications;
    notifyListeners();
    _saveSettings();
  }

  void toggleSound() {
    _settings.sound = !_settings.sound;
    notifyListeners();
    _saveSettings();
  }

  void toggleVibration() {
    _settings.vibration = !_settings.vibration;
    notifyListeners();
    _saveSettings();
  }

  void updateStudentInfo({String? name, String? supervisor, String? halaqa}) {
    if (name != null) _settings.studentName = name;
    if (supervisor != null) _settings.supervisor = supervisor;
    if (halaqa != null) _settings.halaqa = halaqa;
    notifyListeners();
    _saveSettings();
  }
}
