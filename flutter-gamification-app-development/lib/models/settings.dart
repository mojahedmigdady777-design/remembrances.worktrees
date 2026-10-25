class Settings {
  bool darkMode;

  bool notifications;

  bool vibration;

  bool sound;

  // بيانات الطالب للحفظ داخل إعدادات التقرير
  String studentName;
  String supervisor;
  String halaqa;

  Settings({
    this.darkMode = false,
    this.notifications = true,
    this.vibration = true,
    this.sound = true,
    this.studentName = '',
    this.supervisor = '',
    this.halaqa = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'darkMode': darkMode,
      'notifications': notifications,
      'vibration': vibration,
      'sound': sound,
      'studentName': studentName,
      'supervisor': supervisor,
      'halaqa': halaqa,
    };
  }

  factory Settings.fromMap(Map<String, dynamic> map) {
    return Settings(
      darkMode: map['darkMode'] ?? false,
      notifications: map['notifications'] ?? true,
      vibration: map['vibration'] ?? true,
      sound: map['sound'] ?? true,
      studentName: map['studentName'] ?? '',
      supervisor: map['supervisor'] ?? '',
      halaqa: map['halaqa'] ?? '',
    );
  }
}
