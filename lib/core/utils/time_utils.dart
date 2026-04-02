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

  static String getTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    
    // Future Dates (Generated Iterations)
    if (diff.inSeconds < 0) {
      if (diff.inDays.abs() >= 1) {
        return "in ${diff.inDays.abs()}d";
      } else if (diff.inHours.abs() >= 1) {
        return "in ${diff.inHours.abs()}h";
      } else if (diff.inMinutes.abs() >= 1) {
        return "in ${diff.inMinutes.abs()}m";
      } else {
        return "Upcoming";
      }
    }
    if (diff.inDays >= 365) {
      final years = (diff.inDays / 365).floor();
      return "${years}y";
    } else if (diff.inDays >= 7) {
      final weeks = (diff.inDays / 7).floor();
      return "${weeks}w";
    } else if (diff.inDays >= 1) {
      return "${diff.inDays}d";
    } else if (diff.inHours >= 1) {
      return "${diff.inHours}h";
    } else if (diff.inMinutes >= 1) {
      return "${diff.inMinutes}m";
    } else {
      return "Now";
    }
  }
}
