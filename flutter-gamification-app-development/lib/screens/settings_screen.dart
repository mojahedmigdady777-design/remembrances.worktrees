import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("الإعدادات"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Consumer<SettingsProvider>(builder: (context, prov, _) {
          final s = prov.settings;
          return Form(
            key: GlobalKey<FormState>(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'بيانات الطالب (ستُضمّن في تقارير PDF)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: s.studentName,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(labelText: 'اسم الطالب'),
                  onChanged: (v) => prov.updateStudentInfo(name: v),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: s.halaqa,
                    textAlign: TextAlign.right,
                  decoration: const InputDecoration(labelText: 'الحلقة'),
                  onChanged: (v) => prov.updateStudentInfo(halaqa: v),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: s.supervisor,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(labelText: 'المشرف'),
                  onChanged: (v) => prov.updateStudentInfo(supervisor: v),
                ),
                const SizedBox(height: 20),
                SwitchListTile(
                  title: const Text('وضع الليل (Dark Mode)'),
                  value: s.darkMode,
                  onChanged: (_) => prov.toggleDarkMode(),
                ),
                SwitchListTile(
                  title: const Text('تفعيل الإشعارات'),
                  value: s.notifications,
                  onChanged: (_) => prov.toggleNotifications(),
                ),
                SwitchListTile(
                  title: const Text('تفعيل الصوت'),
                  value: s.sound,
                  onChanged: (_) => prov.toggleSound(),
                ),
                SwitchListTile(
                  title: const Text('تفعيل الاهتزاز'),
                  value: s.vibration,
                  onChanged: (_) => prov.toggleVibration(),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}