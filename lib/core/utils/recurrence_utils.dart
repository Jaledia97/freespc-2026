import '../../models/special_model.dart'; // To access RecurrenceRule

class RecurrenceUtils {
  /// Generates a list of explicit Start Dates for a given recurrence rule.
  /// Used by the backend serializers to instantly physicalize occurrences into Firestore.
  static List<DateTime> generateOccurrenceDates({
    required DateTime originalStart,
    required DateTime originalEnd,
    required RecurrenceRule rule,
    int maxDaysLimit = 90, // Defaults to a 90 day buffer queue
  }) {
    final now = DateTime.now();
    final localStart = originalStart.toLocal();
    final duration = originalEnd.difference(originalStart);

    final projectionLimit = now.add(Duration(days: maxDaysLimit));
    final outputDates = <DateTime>[];

    DateTime candidateStart = DateTime(
      localStart.year,
      localStart.month,
      localStart.day,
      localStart.hour,
      localStart.minute,
    );

    int safety = 0;
    int occurrencesCount = 0;

    bool isEnded(DateTime checkDate, int count) {
      if (rule.endCondition == 'date' && rule.endDate != null) {
        return checkDate.isAfter(rule.endDate!);
      }
      if (rule.endCondition == 'count' && rule.occurrenceCount != null) {
        return count >= rule.occurrenceCount!;
      }
      return false;
    }

    // 1. Initial Assessment (Is the template itself valid?)
    final candidateEnd = candidateStart.add(duration);
    if (candidateEnd.isAfter(now)) {
      if (rule.frequency == 'weekly' && rule.daysOfWeek.isNotEmpty) {
        if (rule.daysOfWeek.contains(candidateStart.weekday)) {
          outputDates.add(candidateStart);
          occurrencesCount++;
        }
      } else {
        outputDates.add(candidateStart);
        occurrencesCount++;
      }
    }

    // 2. Project Future Dates
    DateTime current = candidateStart;

    while (safety < 200) {
      safety++;
      if (current.isAfter(projectionLimit)) break;

      // Advance clock
      if (rule.frequency == 'daily') {
        current = current.add(Duration(days: rule.interval));
      } else if (rule.frequency == 'weekly') {
        if (rule.daysOfWeek.isNotEmpty) {
          current = current.add(const Duration(days: 1));
          if (!rule.daysOfWeek.contains(current.weekday)) continue;

          final daysDiff = current.difference(candidateStart).inDays;
          final weeksDiff = (daysDiff / 7).floor();
          if (weeksDiff % rule.interval != 0) continue;
        } else {
          current = current.add(Duration(days: 7 * rule.interval));
        }
      } else if (rule.frequency == 'monthly') {
        current = DateTime(
          current.year,
          current.month + rule.interval,
          current.day,
          current.hour,
          current.minute,
        );
      } else if (rule.frequency == 'yearly') {
        current = DateTime(
          current.year + rule.interval,
          current.month,
          current.day,
          current.hour,
          current.minute,
        );
      }

      if (isEnded(current, occurrencesCount + 1)) break;
      
      final end = current.add(duration);
      if (end.isAfter(now)) {
        outputDates.add(current);
        occurrencesCount++;
      }
    }

    // Sort chronologically
    outputDates.sort((a, b) => a.compareTo(b));
    return outputDates;
  }
}
