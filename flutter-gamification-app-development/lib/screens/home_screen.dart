import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../providers/habit_provider.dart';
import '../screens/student_screen.dart';
import '../screens/statistics_screen.dart';
import '../screens/export_screen.dart';
import '../screens/settings_screen.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/custom_habit_dialog.dart';
import '../widgets/daily_wird_sheet.dart';
import '../widgets/habit_card.dart';
import '../widgets/progress_bar.dart';
import '../utils/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('مشروع خيركم'),
            actions: [
              IconButton(
                icon: const Icon(Icons.person),
                tooltip: 'بيانات الطالب',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StudentScreen(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'إضافة عبادة',
                onPressed: () => _addHabit(context),
              ),
            ],
          ),
          body: IndexedStack(
            index: appProvider.currentIndex,
            children: [
              _buildDashboard(context),
              const StatisticsScreen(),
              const ExportScreen(),
              const SettingsScreen(),
            ],
          ),
          floatingActionButton: appProvider.currentIndex == 0
              ? FloatingActionButton.extended(
                  onPressed: () => _openDailyWirdSheet(context),
                  backgroundColor: AppColors.sunnatiOlive,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.checklist_rounded),
                  label: const Text('تسجيل الورد اليومي'),
                )
              : null,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: appProvider.currentIndex,
            onTap: (value) => appProvider.changePage(value),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                backgroundColor: Color(0xFF1B5E20),
                label: 'الرئيسية',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart),
                backgroundColor: Color(0xFF1B5E20),
                label: 'الإحصائيات',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.picture_as_pdf),
                backgroundColor: Color(0xFF1B5E20),
                label: 'تصدير',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                backgroundColor: Color(0xFF1B5E20),
                label: 'الإعدادات',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDashboard(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, _) {
        final progress = habitProvider.dailyProgress(selectedDate);
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSummaryCards(habitProvider),
              const SizedBox(height: 16),
              CalendarWidget(
                focusedDay: selectedDate,
                selectedDay: selectedDate,
                onChanged: (date) {
                  setState(() {
                    selectedDate = date;
                  });
                },
              ),
              const SizedBox(height: 16),
              ProgressBar(progress: progress),
              const SizedBox(height: 16),
              Text(
                'العبادات اليومية',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              _buildHabitsList(habitProvider),
              const SizedBox(height: 16),
              Text(
                'ملاحظة اليوم',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                key: ValueKey(selectedDate),
                initialValue: habitProvider.noteForDate(selectedDate),
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'أضف ملاحظة قصيرة لهذا اليوم',
                ),
                onChanged: (value) {
                  habitProvider.updateNote(selectedDate, value);
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCards(HabitProvider habitProvider) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildSummaryCard(
          title: 'نقاط الشهر',
          value: habitProvider.monthlyPoints().toString(),
          icon: Icons.stars,
        ),
        _buildSummaryCard(
          title: 'أيام مكتملة',
          value: habitProvider.completedDaysThisMonth().toString(),
          icon: Icons.event_available,
        ),
        _buildSummaryCard(
          title: 'السلسلة الحالية',
          value: habitProvider.currentStreak().toString(),
          icon: Icons.local_fire_department,
        ),
        _buildSummaryCard(
          title: 'آخر عبادة',
          value: habitProvider.lastCompletedHabitTitle(),
          icon: Icons.history,
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return SizedBox(
      width: 160,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 20, color: Colors.green[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHabitsList(HabitProvider habitProvider) {
    if (habitProvider.habits.isEmpty) {
      return const Center(
        child: Text('لا يوجد عادات حتى الآن'),
      );
    }

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: habitProvider.habits.length,
      onReorder: habitProvider.reorderHabits,
      itemBuilder: (context, index) {
        final habit = habitProvider.habits[index];
        final status = habitProvider.statusForDate(selectedDate, habit.id);
        return HabitCard(
          key: ValueKey(habit.id),
          habit: habit,
          status: status,
          onChanged: (newStatus) {
            habitProvider.updateStatus(selectedDate, habit.id, newStatus);
          },
        );
      },
    );
  }

  Future<void> _addHabit(BuildContext context) async {
    final habitTitle = await showDialog<String>(
      context: context,
      builder: (context) => const CustomHabitDialog(),
    );
    if (!mounted) return;
    if (habitTitle != null && habitTitle.trim().isNotEmpty) {
      context.read<HabitProvider>().addHabit(habitTitle.trim());
    }
  }

  Future<void> _openDailyWirdSheet(BuildContext context) async {
    final habitProvider = context.read<HabitProvider>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (sheetContext) => DailyWirdSheet(
        habitProvider: habitProvider,
        date: selectedDate,
      ),
    );
    if (!mounted) return;
    setState(() {});
  }
}
