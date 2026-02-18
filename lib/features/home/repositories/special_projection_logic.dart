import 'package:flutter/foundation.dart';
import '../../../models/special_model.dart';


// Top-level function for compute()
List<SpecialModel> projectSpecialsComputed(List<SpecialModel> input) {
  // Pass 'false' for includeAll as default for feed
  return _projectSpecialsLogic(input, includeAll: false);
}

// Separate entry point if needed for CMS (includeAll: true)
List<SpecialModel> projectSpecialsComputedAll(List<SpecialModel> input) {
  return _projectSpecialsLogic(input, includeAll: true);
}

// The core logic, moved from HallRepository
List<SpecialModel> _projectSpecialsLogic(List<SpecialModel> input, {bool includeAll = false}) {
  final now = DateTime.now();
  final output = <SpecialModel>[];

  for (var s in input) {
    if (includeAll) {
      output.add(s);
      continue;
    }
    
    // 1. If not recurring, check expiry
    if (s.recurrence == 'none') {
      final end = s.endTime ?? s.startTime?.add(const Duration(hours: 2));
      // Show if not expired more than 12 hours ago
      if (end != null && end.isAfter(now.subtract(const Duration(hours: 12)))) {
          output.add(s);
      }
      continue;
    }

    // 2. Recurring Logic
    if (s.startTime == null) continue;

    final originalStart = s.startTime!;
    final localStart = originalStart.toLocal(); // Wall Clock Time
    final originalEnd = s.endTime ?? originalStart.add(const Duration(hours: 4));
    final duration = originalEnd.difference(originalStart);
    
    // Determine Rule
    RecurrenceRule rule;
    if (s.recurrenceRule != null) {
      rule = s.recurrenceRule!;
    } else {
      // Legacy Conversion
      String freq = 'daily';
      if (s.recurrence == 'weekly') freq = 'weekly';
      if (s.recurrence == 'monthly') freq = 'monthly';
      rule = RecurrenceRule(frequency: freq, interval: 1);
    }

    // Projection Logic
    // Limit projection to next 30 days to save memory/time
    final projectionLimit = now.add(const Duration(days: 30));

    DateTime candidateStart = DateTime(
      localStart.year, 
      localStart.month, 
      localStart.day, 
      localStart.hour, 
      localStart.minute
    );

    int safety = 0;
    bool found = false;
    
    // Check End Conditions
    bool isEnded(DateTime checkDate, int count) {
      if (rule.endCondition == 'date' && rule.endDate != null) {
        return checkDate.isAfter(rule.endDate!);
      }
      if (rule.endCondition == 'count' && rule.occurrenceCount != null) {
        return count >= rule.occurrenceCount!;
      }
      return false;
    }

    // If original is valid (future or active), use it
    final candidateEnd = candidateStart.add(duration);
    if (candidateEnd.isAfter(now)) {
      if (rule.frequency == 'weekly' && rule.daysOfWeek.isNotEmpty) {
          if (rule.daysOfWeek.contains(candidateStart.weekday)) {
            output.add(s);
            found = true;
          }
      } else {
          output.add(s);
          found = true;
      }
    }

    // Find next occurrence
    if (!found) {
      DateTime current = candidateStart;
      int occurrences = 1; 

      while (safety < 100) { // Reduced safety limit for performance
        safety++;
        
        if (current.isAfter(projectionLimit)) break;

        // Advance
        if (rule.frequency == 'daily') {
          current = current.add(Duration(days: rule.interval));
        } else if (rule.frequency == 'weekly') {
           if (rule.daysOfWeek.isNotEmpty) {
             // Simple daily advance to match pattern
             current = current.add(const Duration(days: 1));
             if (!rule.daysOfWeek.contains(current.weekday)) continue;
             
             // Check interval week
             final daysDiff = current.difference(candidateStart).inDays;
             final weeksDiff = (daysDiff / 7).floor();
             if (weeksDiff % rule.interval != 0) continue;
           } else {
             current = current.add(Duration(days: 7 * rule.interval));
           }
        } else if (rule.frequency == 'monthly') {
          current = DateTime(current.year, current.month + rule.interval, current.day, current.hour, current.minute);
        } else if (rule.frequency == 'yearly') {
           current = DateTime(current.year + rule.interval, current.month, current.day, current.hour, current.minute);
        }

        if (isEnded(current, occurrences)) break;
        occurrences++;

        final end = current.add(duration);
        if (end.isAfter(now)) {
           output.add(s.copyWith(startTime: current, endTime: end));
           found = true;
           break; // Found next
        }
      }
    }
  }

  // Sort
  output.sort((a, b) => (a.startTime ?? DateTime.now()).compareTo(b.startTime ?? DateTime.now()));
  
  return output;
}
