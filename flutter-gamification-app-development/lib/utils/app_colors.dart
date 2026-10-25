import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // الألوان الأساسية
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF1B5E20);

  // اللون الثانوي
  static const Color secondary = Color(0xFFD4AF37);

  // الخلفيات
  static const Color background = Color(0xFFF7F9F5);
  static const Color card = Colors.white;

  // ألوان التقييم
  static const Color success = Color(0xFF4CAF50);
  static const Color half = Color(0xFFFFC107);
  static const Color failed = Color.fromARGB(255, 255, 1, 1);

  // النصوص
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);

  static const Color divider = Color(0xFFE0E0E0);

  // ---------- هوية "سنّتي" البصرية ----------
  static const Color sunnatiOlive = Color(0xFF1B4332); // زيتي داكن للروؤس والأزرار
  static const Color sunnatiOliveLight = Color(0xFF2D6A4F);
  static const Color sunnatiGold = Color(0xFFD4AF37); // ذهبي للتأكيدات والشارات
  static const Color sunnatiGoldLight = Color(0xFFF3D082);
  static const Color sunnatiBackground = Color(0xFFF4F7F1); // خلفية مريحة
  static const Color sunnatiCard = Color(0xFFFFFFFF); // بطاقات بيضاء
}
