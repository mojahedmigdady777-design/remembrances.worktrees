import 'package:intl/intl.dart';

class Helpers {
  Helpers._();

  static String formatDate(DateTime date) {
    return DateFormat('yyyy/MM/dd').format(date);
  }

  static String monthName(DateTime date) {
    return DateFormat('MMMM', 'ar').format(date);
  }

  static String weekDay(DateTime date) {
    return DateFormat('EEEE', 'ar').format(date);
  }

  static double calculateProgress(int done, int total) {
    if (total == 0) return 0;
    return done / total;
  }
}