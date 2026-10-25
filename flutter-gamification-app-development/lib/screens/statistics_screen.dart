import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/habit_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('الإحصائيات'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStatCard(
                  'نقاط الشهر',
                  habitProvider.monthlyPoints().toString(),
                ),
                _buildStatCard(
                  'أيام مكتملة',
                  habitProvider.completedDaysThisMonth().toString(),
                ),
                _buildStatCard(
                  'السلسلة الحالية',
                  habitProvider.currentStreak().toString(),
                ),
                _buildStatCard(
                  'آخر عبادة مكتملة',
                  habitProvider.lastCompletedHabitTitle(),
                ),
                const SizedBox(height: 20),
                const Text(
                  'أهم العادات',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount:
                        habitProvider.habits.length.clamp(0, 5),
                    itemBuilder: (context, index) {
                      final habit = habitProvider.habits[index];
                      return Card(
                        child: ListTile(
                          title: Text(habit.title),
                          subtitle: Text(habit.categoryTitle),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
