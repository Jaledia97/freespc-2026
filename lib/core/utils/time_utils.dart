import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../features/settings/data/display_settings_repository.dart';

class TimeUtils {
  static String formatTime(DateTime date, WidgetRef ref) {
    final format = ref.watch(timeFormatProvider);
    if (format == TimeFormat.h24) {
      return DateFormat('HH:mm').format(date);
    } else {
      return DateFormat('h:mm a').format(date);
    }
  }

  static String formatDateTime(DateTime date, WidgetRef ref) {
    final format = ref.watch(timeFormatProvider);
    final datePart = DateFormat.yMMMd().format(date);
    String timePart;
    
    if (format == TimeFormat.h24) {
      timePart = DateFormat('HH:mm').format(date);
    } else {
      timePart = DateFormat('h:mm a').format(date);
    }
    
    return "$datePart $timePart";
  }
}
