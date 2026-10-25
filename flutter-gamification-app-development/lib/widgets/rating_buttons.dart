import 'package:flutter/material.dart';

import '../models/habit.dart';

class RatingButtons extends StatelessWidget {
  final HabitStatus value;

  final ValueChanged<HabitStatus> onChanged;

  const RatingButtons({
    super.key,
    required this.value,
    required this.onChanged,
  });

  Widget button(
      HabitStatus status,
      IconData icon,
      Color color,
  ) {
    return IconButton(
      onPressed: () => onChanged(status),
      icon: Icon(
        icon,
        color: value == status ? color : Colors.grey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [

        button(
          HabitStatus.done,
          Icons.check_circle,
          Colors.green,
        ),

        button(
          HabitStatus.half,
          Icons.remove_circle,
          Colors.orange,
        ),

        button(
          HabitStatus.none,
          Icons.cancel,
          Colors.red,
        ),
      ],
    );
  }
}