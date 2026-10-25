import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

class HiveService {
  HiveService._();

  static Future<void> init() async {
    await Hive.initFlutter();
  }

  static Future<Box> openBox(String name) async {
    return await Hive.openBox(name);
  }

  static Future<void> close() async {
    await Hive.close();
  }

  /// Export specified boxes to a JSON file and return the file path.
  static Future<String> exportBoxesToFile(List<String> boxes) async {
    final Map<String, dynamic> data = {};
    for (final name in boxes) {
      final box = await openBox(name);
      final Map<String, dynamic> boxContent = {};
      for (final key in box.keys) {
        final value = box.get(key);
        boxContent[key.toString()] = value;
      }
      data[name] = boxContent;
    }

    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final file = File('${dir.path}/hive_backup_$timestamp.json');
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
    return file.path;
  }

  /// Import boxes from a JSON file path.
  static Future<void> importFromFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) return;
    final content = await file.readAsString();
    await _importFromRawJson(content);
  }

  /// 🌟 الدالة الجديدة: الاستيراد من البايتات مباشرة (Uint8List)
  static Future<void> importFromBytes(Uint8List bytes) async {
    final content = utf8.decode(bytes);
    await _importFromRawJson(content);
  }

  /// دالة خاصة لمباشرة الاستيراد من نص الـ JSON
  static Future<void> _importFromRawJson(String jsonString) async {
    final Map<String, dynamic> data = jsonDecode(jsonString) as Map<String, dynamic>;
    for (final entry in data.entries) {
      final boxName = entry.key;
      final boxData = Map<String, dynamic>.from(entry.value as Map);
      final box = await openBox(boxName);
      
      // مسح البيانات القديمة بالكامل واستبدالها بالنسخة المستوردة
      await box.clear();
      for (final k in boxData.keys) {
        await box.put(k, boxData[k]);
      }
    }
  }
}