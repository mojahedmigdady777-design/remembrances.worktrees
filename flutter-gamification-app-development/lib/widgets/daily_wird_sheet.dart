import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../utils/app_colors.dart';
import 'sunnati_status_selector.dart';

/// نافذة "تسجيل الورد اليومي" بأسلوب تطبيق "سنّتي".
/// تعرض العبادات في تبويبات، وتتيح تحديد حالة الإنجاز لكل عبادة،
/// ثم حفظ جميع التغييرات دفعة واحدة قبل العودة للشاشة الرئيسية.
class DailyWirdSheet extends StatefulWidget {
  final HabitProvider habitProvider;
  final DateTime date;

  const DailyWirdSheet({
    super.key,
    required this.habitProvider,
    required this.date,
  });

  @override
  State<DailyWirdSheet> createState() => _DailyWirdSheetState();
}

enum _SunnatiTab { prayers, adhkar, sunan, wird }

extension on _SunnatiTab {
  String get title {
    switch (this) {
      case _SunnatiTab.prayers:
        return 'الصلوات';
      case _SunnatiTab.adhkar:
        return 'أذكار اليوم';
      case _SunnatiTab.sunan:
        return 'السنن والفرائض';
      case _SunnatiTab.wird:
        return 'الورد القرآني';
    }
  }

  IconData get icon {
    switch (this) {
      case _SunnatiTab.prayers:
        return Icons.mosque;
      case _SunnatiTab.adhkar:
        return Icons.auto_stories;
      case _SunnatiTab.sunan:
        return Icons.volunteer_activism;
      case _SunnatiTab.wird:
        return Icons.menu_book;
    }
  }
}

class _DailyWirdSheetState extends State<DailyWirdSheet> {
  late Map<String, HabitStatus> _pending;
  _SunnatiTab _currentTab = _SunnatiTab.prayers;

  @override
  void initState() {
    super.initState();
    _pending = {};
    for (final habit in widget.habitProvider.habits) {
      _pending[habit.id] =
          widget.habitProvider.statusForDate(widget.date, habit.id);
    }
  }

  _SunnatiTab _tabForHabit(Habit habit) {
    switch (habit.category) {
      case HabitCategory.prayer:
      case HabitCategory.mosque:
        return _SunnatiTab.prayers;
      case HabitCategory.quran:
        if (habit.id == 'ward_qurani' || habit.title.contains('ورد')) {
          return _SunnatiTab.wird;
        }
        return _SunnatiTab.adhkar;
      case HabitCategory.charity:
      case HabitCategory.knowledge:
      case HabitCategory.custom:
        return _SunnatiTab.sunan;
    }
  }

  String get _dateLabel {
    final date = widget.date;
    return '${date.day}/${date.month}/${date.year}';
  }

  int get _doneCount {
    final todayDone = (widget.habitProvider.habits).where((habit) {
          final status = _pending[habit.id] ?? HabitStatus.none;
          return status == HabitStatus.done;
        }).length;
    return todayDone;
  }

  void _saveAndClose() {
    for (final habit in widget.habitProvider.habits) {
      final newStatus = _pending[habit.id] ?? HabitStatus.none;
      widget.habitProvider.updateStatus(widget.date, habit.id, newStatus);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final habits = widget.habitProvider.habits
        .where((h) => _tabForHabit(h) == _currentTab)
        .toList();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.sunnatiBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildTabs(context),
            Expanded(
              child: habits.isEmpty
                  ? _emptyTab()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: habits.length,
                      itemBuilder: (context, index) {
                        return _buildHabitCard(context, habits[index]);
                      },
                    ),
            ),
            _buildSaveButton(context),
          ],
        ),
      ),
    );
  }

  // ---------- الهيدر الزيتي ----------
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
      decoration: const BoxDecoration(
        color: AppColors.sunnatiOlive,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تسجيل الورد اليومي',
                  style: GoogleFonts.tajawal(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'يوم $_dateLabel  •  $_doneCount عبادات مكتملة',
                  style: GoogleFonts.tajawal(
                    fontSize: 13,
                    color: const Color(0xFFCFE3DA),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            tooltip: 'إغلاق',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  // ---------- التبويبات ----------
  Widget _buildTabs(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: AppColors.sunnatiBackground,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: _SunnatiTab.values.map((tab) {
            final selected = tab == _currentTab;
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _TabChip(
                tab: tab,
                selected: selected,
                onTap: () => setState(() => _currentTab = tab),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ---------- بطاقة عبادة ----------
  Widget _buildHabitCard(BuildContext context, Habit habit) {
    final status = _pending[habit.id] ?? HabitStatus.none;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.sunnatiCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.sunnatiGoldLight.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(habit.icon, color: AppColors.sunnatiOlive, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
              _doneBadge(status == HabitStatus.done),
            ],
          ),
          const SizedBox(height: 12),
          SunnatiStatusSelector(
            value: status,
            onChanged: (newStatus) {
              setState(() => _pending[habit.id] = newStatus);
            },
          ),
        ],
      ),
    );
  }

  // ---------- شارة "تم" الذهبية ----------
  Widget _doneBadge(bool isDone) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDone ? AppColors.sunnatiGold : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDone ? AppColors.sunnatiGold : AppColors.divider,
        ),
      ),
      child: Text(
        isDone ? 'تم ✓' : 'لم يتم',
        style: GoogleFonts.tajawal(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isDone ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }

  // ---------- زر الحفظ العريض ----------
  Widget _buildSaveButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.sunnatiCard,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _saveAndClose,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.sunnatiGold,
          foregroundColor: AppColors.sunnatiOlive,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          minimumSize: const Size(double.infinity, 54),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 22),
            const SizedBox(width: 8),
            Text(
              'حفظ إنجاز اليوم',
              style: GoogleFonts.tajawal(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.sunnatiOlive,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- تبويب فارغ ----------
  Widget _emptyTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.inbox_outlined,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              'لا توجد عبادات في هذا القسم حالياً',
              style: GoogleFonts.tajawal(
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- شريحة التبويب ----------
class _TabChip extends StatelessWidget {
  final _SunnatiTab tab;
  final bool selected;
  final VoidCallback onTap;

  const _TabChip({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.sunnatiOlive : AppColors.sunnatiCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.sunnatiOlive : AppColors.divider,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              tab.icon,
              size: 18,
              color: selected ? AppColors.sunnatiGold : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              tab.title,
              style: GoogleFonts.tajawal(
                fontSize: 14,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
