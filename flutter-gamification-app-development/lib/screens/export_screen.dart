import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

import '../services/pdf_service.dart';
import '../providers/habit_provider.dart';
import '../services/hive_service.dart';
import '../providers/settings_provider.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('تصدير واستراد البيانات'),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'التقارير والنسخ الاحتياطية',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'يمكنك طباعة تقريرك الشهري، حفظه كملف PDF، أو حفظ نسخة احتياطية من بياناتك.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildActionTile(
                    icon: Icons.picture_as_pdf,
                    title: 'إنشاء تقرير PDF',
                    subtitle: 'تصدير سجل الشهر الحالي بصيغة قابلة للطباعة.',
                    enabled: !_isProcessing,
                    onTap: () async => _generatePdf(habitProvider),
                  ),
                  const SizedBox(height: 12),
                  _buildActionTile(
                    icon: Icons.backup,
                    title: 'تصدير نسخة احتياطية',
                    subtitle: 'حفظ بيانات التطبيق في ملف احتياطي.',
                    enabled: !_isProcessing,
                    onTap: () async => _exportBackup(),
                  ),
                  const SizedBox(height: 12),
                  _buildActionTile(
                    icon: Icons.upload_file,
                    title: 'استيراد نسخة احتياطية',
                    subtitle: 'استعادة البيانات من ملف سابق.',
                    enabled: !_isProcessing,
                    onTap: () async => _importBackup(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              if (_isProcessing)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                const Icon(Icons.arrow_forward_ios_rounded, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _generatePdf(HabitProvider habitProvider) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      final pdf = await PdfService.createDocument(habitProvider, settingsProvider);
      if (!mounted) return;
      await Printing.layoutPdf(onLayout: (format) => pdf.save());
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل إنشاء ملف PDF: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _exportBackup() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final boxes = [
        'habits',
        'daily_status',
        'daily_notes',
        'settings',
      ];
      final path = await HiveService.exportBoxesToFile(boxes);
      if (!mounted) return;
      await Share.shareXFiles(
        [XFile(path)],
        text: 'نسخة احتياطية لتطبيق خيركم',
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل تصدير النسخة الاحتياطية: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _importBackup() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final result = await FilePicker.pickFiles(
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final picked = result.files.single;
      final filePath = picked.path;
      final fileBytes = picked.bytes;

      if (filePath == null && fileBytes == null) {
        return;
      }

      if (!context.mounted) return;

      final confirm = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('تأكيد الاستيراد'),
          content: const Text(
            'سيتم استبدال بيانات التطبيق بالنسخة المستوردة. هل تريد المتابعة؟',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('استيراد'),
            ),
          ],
        ),
      );

      if (confirm != true) {
        return;
      }

      if (filePath != null) {
        await HiveService.importFromFile(filePath);
      } else if (fileBytes != null) {
        await HiveService.importFromBytes(fileBytes);
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم استيراد النسخة الاحتياطية بنجاح')),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل الاستيراد: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}