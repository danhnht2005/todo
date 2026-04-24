import 'package:intl/intl.dart';

class DateFormatter {
  static String fullDate(DateTime date) {
    return DateFormat('EEEE, d MMMM', 'vi').format(date);
  }
  
  static String dayOfWeek(DateTime date) {
    return DateFormat('EEEE', 'vi').format(date);
  }
  
  static String compactDate(DateTime date) {
    return DateFormat('d/M/yyyy').format(date);
  }

  static String relative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final compareDate = DateTime(date.year, date.month, date.day);
    
    final difference = compareDate.difference(today).inDays;
    
    if (difference == 0) return 'Hôm nay';
    if (difference == 1) return 'Ngày mai';
    if (difference == -1) return 'Hôm qua';
    
    return fullDate(date);
  }

  static String createdAt(DateTime date) {
    return 'Đã tạo vào ${DateFormat('EEEE, d MMMM').format(date)}';
  }
}
