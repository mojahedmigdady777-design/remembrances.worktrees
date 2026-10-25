import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidget extends StatelessWidget {

  final DateTime focusedDay;

  final DateTime selectedDay;

  final Function(DateTime) onChanged;

  const CalendarWidget({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {

    return TableCalendar(

      firstDay: DateTime.utc(2025),

      lastDay: DateTime.utc(2035),

      focusedDay: focusedDay,

      selectedDayPredicate: (day){

        return isSameDay(day, selectedDay);

      },

      onDaySelected: (selected, focused){

        onChanged(selected);

      },

    );

  }
}