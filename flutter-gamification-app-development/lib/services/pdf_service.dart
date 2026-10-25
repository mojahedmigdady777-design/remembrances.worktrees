import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../providers/habit_provider.dart';
import '../providers/settings_provider.dart';

class PdfService {
  PdfService._();

  static Future<pw.Document> createDocument(
      HabitProvider habitProvider, SettingsProvider settingsProvider) async {
    final pdf = pw.Document();

    final regularFontData =
        await rootBundle.load('assets/fonts/Amiri/Amiri-Regular.ttf');
    final boldFontData =
        await rootBundle.load('assets/fonts/Amiri/Amiri-Bold.ttf');

    final ttfRegular = pw.Font.ttf(regularFontData);
    final ttfBold = pw.Font.ttf(boldFontData);

    final now = DateTime.now();
    final month = '${now.year}/${now.month.toString().padLeft(2, '0')}';

    final settings = settingsProvider.settings;
    final studentName =
        settings.studentName.trim().isEmpty ? 'غير محدد' : settings.studentName;
    final halaqa =
        settings.halaqa.trim().isEmpty ? 'غير محدد' : settings.halaqa;
    final supervisor =
        settings.supervisor.trim().isEmpty ? 'غير محدد' : settings.supervisor;

    // ألوان الهوية البصرية
    final primaryColor = PdfColor.fromHex('#1E3A8A'); // أزرق داكن راقي
    final secondaryColor = PdfColor.fromHex('#D97706'); // ذهبي/برتقالي
    final lightBg = PdfColor.fromHex('#F3F4F6');

    // تجهيز الصفوف مع ضمان جلب الرقم الفعلي من الموديل
    final dataRows = habitProvider.habits.map((habit) {
      final completedTimes = habitProvider.habitCompletionDays(habit.id, now);
      return [
        habit.title,
        habit.categoryTitle,
        completedTimes.toString(),
      ];
    }).toList();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // هيدر ملون ورائع
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: primaryColor,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'مشروع خيركم',
                        style: pw.TextStyle(
                          font: ttfBold,
                          fontSize: 24,
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'سجل المتابعة الشهري - $month',
                        style: pw.TextStyle(
                          font: ttfRegular,
                          fontSize: 14,
                          color: PdfColors.white,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 16),

                // بطاقة بيانات الطالب والمشرف
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: lightBg,
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: PdfColors.grey300),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.RichText(
                            text: pw.TextSpan(
                              children: [
                                pw.TextSpan(
                                    text: 'الطالب: ',
                                    style: pw.TextStyle(
                                        font: ttfBold, fontSize: 12)),
                                pw.TextSpan(
                                    text: studentName,
                                    style: pw.TextStyle(
                                        font: ttfRegular, fontSize: 12)),
                              ],
                            ),
                          ),
                          pw.SizedBox(height: 6),
                          pw.RichText(
                            text: pw.TextSpan(
                              children: [
                                pw.TextSpan(
                                    text: 'الحلقة: ',
                                    style: pw.TextStyle(
                                        font: ttfBold, fontSize: 12)),
                                pw.TextSpan(
                                    text: halaqa,
                                    style: pw.TextStyle(
                                        font: ttfRegular, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.RichText(
                            text: pw.TextSpan(
                              children: [
                                pw.TextSpan(
                                    text: 'المشرف: ',
                                    style: pw.TextStyle(
                                        font: ttfBold, fontSize: 12)),
                                pw.TextSpan(
                                    text: supervisor,
                                    style: pw.TextStyle(
                                        font: ttfRegular, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 16),

                // جدول العبادات الأنيق
                pw.TableHelper.fromTextArray(
                  context: context,
                  headers: ['العبادة', 'الفئة', 'عدد المرات'],
                  data: dataRows,
                  border: pw.TableBorder.all(
                    color: PdfColors.grey300,
                    width: 0.5,
                  ),
                  headerStyle: pw.TextStyle(
                    font: ttfBold,
                    fontSize: 12,
                    color: PdfColors.white,
                  ),
                  headerDecoration: pw.BoxDecoration(
                    color: secondaryColor,
                  ),
                  cellStyle: pw.TextStyle(
                    font: ttfRegular,
                    fontSize: 11,
                  ),
                  cellAlignment: pw.Alignment.center,
                  cellAlignments: {
                    0: pw.Alignment.centerRight,
                    1: pw.Alignment.centerRight,
                    2: pw.Alignment.center,
                  },
                  rowDecoration: const pw.BoxDecoration(
                    color: PdfColors.white,
                  ),
                  oddRowDecoration: pw.BoxDecoration(
                    color: lightBg,
                  ),
                  columnWidths: {
                    0: const pw.FractionColumnWidth(0.50),
                    1: const pw.FractionColumnWidth(0.30),
                    2: const pw.FractionColumnWidth(0.20),
                  },
                ),
                pw.SizedBox(height: 20), // مسافة ثابتة لرفع التواقيع أسفل الجدول مباشرة

                // قسم التواقيع المرفوع والمقرب من الجدول
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 8),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('توقيع الطالب: ....................',
                              style: pw.TextStyle(font: ttfRegular, fontSize: 11)),
                          pw.SizedBox(height: 12),
                          pw.Text('توقيع ولي الأمر: ....................',
                              style: pw.TextStyle(font: ttfRegular, fontSize: 11)),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('توقيع المشرف: ....................',
                              style: pw.TextStyle(font: ttfRegular, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf;
  }
}
