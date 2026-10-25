import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../services/notification_service.dart';
import '../utils/app_colors.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final HabitStatus status;
  final ValueChanged<HabitStatus> onChanged;

  const HabitCard({
    super.key,
    required this.habit,
    required this.status,
    required this.onChanged,
  });

  /// يزيد حالة الإنجاز خطوة واحدة: لم يتم → تم جزئياً → تم → لم يتم.
  HabitStatus _increment(HabitStatus s) {
    switch (s) {
      case HabitStatus.none:
        return HabitStatus.half;
      case HabitStatus.half:
        return HabitStatus.done;
      case HabitStatus.done:
        return HabitStatus.none;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDone = status == HabitStatus.done;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // أيقونة العبادة داخل حاوية ملونة
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.sunnatiGoldLight.withOpacity(0.35),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(habit.icon, color: AppColors.sunnatiOlive, size: 26),
            ),
            const SizedBox(width: 12),
            // العنوان والفئة
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    habit.title,
                    style: GoogleFonts.tajawal(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    habit.categoryTitle,
                    style: GoogleFonts.tajawal(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // زر سريع: زيادة العداد
            _QuickActionButton(
              icon: Icons.add_rounded,
              tooltip: 'زيادة العداد',
              onPressed: () => onChanged(_increment(status)),
            ),
            const SizedBox(width: 6),
            // زر سريع: إتمام / إلغاء
            _QuickActionButton(
              icon: Icons.check_rounded,
              tooltip: isDone ? 'إلغاء الإتمام' : 'إتمام العبادة',
              active: isDone,
              activeColor: AppColors.sunnatiGold,
              onPressed: () => onChanged(
                isDone ? HabitStatus.none : HabitStatus.done,
              ),
            ),
            const SizedBox(width: 2),
            // قائمة "المزيد": التذكير + الحالة التفصيلية
            PopupMenuButton<String>(
              icon: Icon(
                habit.notificationsEnabled ? Icons.alarm : Icons.alarm_off,
                color: habit.notificationsEnabled ? Colors.orange : Colors.grey,
                size: 22,
              ),
              tooltip: 'المزيد',
              onSelected: (value) {
                switch (value) {
                  case 'done':
                    onChanged(HabitStatus.done);
                    break;
                  case 'half':
                    onChanged(HabitStatus.half);
                    break;
                  case 'none':
                    onChanged(HabitStatus.none);
                    break;
                  case 'alarm':
                    _showNotificationDialog(context);
                    break;
                }
              },
              itemBuilder: (context) => [
                _menuItem(Icons.check_circle, AppColors.sunnatiGold, 'تم', 'done'),
                _menuItem(Icons.remove_circle, Colors.orange, 'تم جزئياً', 'half'),
                _menuItem(Icons.cancel, Colors.red, 'لم يتم', 'none'),
                const PopupMenuDivider(),
                _menuItem(
                  Icons.alarm,
                  Colors.orange,
                  'إعداد التذكير',
                  'alarm',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _menuItem(
    IconData icon,
    Color color,
    String label,
    String value,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.tajawal(fontSize: 14)),
        ],
      ),
    );
  }

  // نافذة إعدادات التذكير
  Future<void> _showNotificationDialog(BuildContext context) async {
    final habitProvider = context.read<HabitProvider>();
    bool enabled = habit.notificationsEnabled;
    TimeOfDay? time = habit.reminderTime;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          final localTime = time;
          String timeText = localTime == null
              ? 'لم يتم تحديد وقت'
              : 'الوقت: ${localTime.format(context)}';

          return AlertDialog(
            title: const Text('إعدادات التذكير'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: const Text('تفعيل التذكير'),
                  value: enabled,
                  onChanged: (v) => setState(() => enabled = v),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(timeText),
                    ),
                    TextButton(
                      child: const Text('اختر الوقت'),
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime:
                              time ?? const TimeOfDay(hour: 18, minute: 0),
                        );
                        if (picked != null) setState(() => time = picked);
                      },
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('حفظ'),
              ),
            ],
          );
        });
      },
    );

    if (result != true) return;

    final updated = Habit(
      id: habit.id,
      title: habit.title,
      category: habit.category,
      icon: habit.icon,
      isCustom: habit.isCustom,
      notificationsEnabled: enabled,
      reminderTime: time,
      points: habit.points,
    );

    habitProvider.updateHabit(updated);

    final notifId = habit.id.hashCode & 0x7fffffff;
    if (enabled && time != null) {
      final scheduled = NotificationService.scheduledDateFromTimeOfDay(
        tz.local,
        time!.hour,
        time!.minute,
      );
      await NotificationService.scheduleReminder(
        id: notifId,
        title: habit.title,
        body: 'حان وقت أداء ${habit.title}',
        scheduledDate: scheduled,
      );
    } else {
      await NotificationService.cancel(notifId);
    }
  }
}

/// زر الإجراء السريع الدائري المصغر.
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool active;
  final Color? activeColor;
  final VoidCallback onPressed;

  const _QuickActionButton({
    required this.icon,
    required this.tooltip,
    this.active = false,
    this.activeColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final base = activeColor ?? AppColors.sunnatiGold;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: active ? base : AppColors.sunnatiBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active ? base : AppColors.divider,
            ),
          ),
          child: Icon(
            icon,
            color: active ? Colors.white : AppColors.sunnatiOlive,
            size: 22,
          ),
        ),
      ),
    );
  }
}
