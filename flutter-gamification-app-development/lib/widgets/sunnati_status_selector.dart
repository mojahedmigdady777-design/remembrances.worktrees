import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/habit.dart';
import '../utils/app_colors.dart';

/// أداة اختيار حالة الإنجاز للعبادة بأسلوب "سنّتي":
/// لم يتم / تم جزئياً / تم.
class SunnatiStatusSelector extends StatelessWidget {
  final HabitStatus value;
  final ValueChanged<HabitStatus> onChanged;

  const SunnatiStatusSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.sunnatiBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _buildOption(context, HabitStatus.none, 'لم يتم'),
          _buildOption(context, HabitStatus.half, 'تم جزئياً'),
          _buildOption(context, HabitStatus.done, 'تم'),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, HabitStatus status, String label) {
    final selected = value == status;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(status),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? _selectedBackground(status) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(
              fontSize: 13,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              color: selected ? _selectedTextColor(status) : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Color _selectedBackground(HabitStatus status) {
    switch (status) {
      case HabitStatus.none:
        return const Color(0xFFE0E0E0);
      case HabitStatus.half:
        return AppColors.sunnatiGoldLight;
      case HabitStatus.done:
        return AppColors.sunnatiGold;
    }
  }

  Color _selectedTextColor(HabitStatus status) {
    switch (status) {
      case HabitStatus.none:
        return AppColors.textPrimary;
      case HabitStatus.half:
        return AppColors.sunnatiOlive;
      case HabitStatus.done:
        return Colors.white;
    }
  }
}
