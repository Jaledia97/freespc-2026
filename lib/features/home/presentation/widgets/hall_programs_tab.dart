import 'package:flutter/material.dart';
import '../../../../models/hall_program_model.dart';

class HallProgramsTab extends StatelessWidget {
  final List<HallProgramModel> programs;

  const HallProgramsTab({super.key, required this.programs});

  @override
  Widget build(BuildContext context) {
    if (programs.isEmpty) {
      return const Center(
        child: Text(
          "No programs listed for this hall.",
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }
    
    final activePrograms = programs.where((p) => _isProgramActive(p)).toList();
    final inactivePrograms = programs.where((p) => !_isProgramActive(p)).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...activePrograms.map((program) => _buildProgramCard(program)),
          
          if (inactivePrograms.isNotEmpty) ...[
             const SizedBox(height: 24),
             const Divider(color: Colors.white24),
             Theme(
               data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
               child: ExpansionTile(
                 title: const Text("Other Programs", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                 children: inactivePrograms.map((program) => _buildProgramCard(program)).toList(),
               ),
             ),
          ],
          
          // Bottom padding
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  bool _isProgramActive(HallProgramModel program) {
    // 1. Check Override
    if (program.overrideEndTime != null) {
      if (program.overrideEndTime!.isAfter(DateTime.now())) {
        return true; // Forced Active
      }
    }

    // 2. Check Schedule
    final now = DateTime.now();
    
    // Check Days
    if (program.selectedDays.isEmpty) {
      // If no days selected, it's manual only.
      // Since we already checked Override above, if we are here, there is no active override.
      return false; 
    }
    
    if (!program.selectedDays.contains(now.weekday)) {
       return false;
    }
    
    // Check Timeframe (if exists)
    if (program.startTime != null && program.endTime != null) {
       return _isWithinTimeframe(program.startTime!, program.endTime!, now);
    }
    
    return true; 
  }

  // Removed _isSameDay (no longer needed)

  bool _isWithinTimeframe(String startStr, String endStr, DateTime now) {
    try {
      final start = _parseTimeOfDay(startStr);
      final end = _parseTimeOfDay(endStr);
      if (start == null || end == null) return true; 

      final nowTime = TimeOfDay.fromDateTime(now);
      
      final startMin = start.hour * 60 + start.minute;
      final endMin = end.hour * 60 + end.minute;
      final nowMin = nowTime.hour * 60 + nowTime.minute;
      
      if (endMin < startMin) {
        return nowMin >= startMin || nowMin <= endMin;
      } else {
        return nowMin >= startMin && nowMin <= endMin;
      }
      
    } catch (_) {
      return true;
    }
  }

  TimeOfDay? _parseTimeOfDay(String timeStr) {
     if (!timeStr.contains(":")) return null;
      try {
        final parts = timeStr.split(" ");
        final timeParts = parts[0].split(":");
        int hour = int.parse(timeParts[0]);
        int minute = int.parse(timeParts[1]);
        if (parts.length > 1) {
           if (parts[1] == "PM" && hour != 12) hour += 12;
           if (parts[1] == "AM" && hour == 12) hour = 0;
        }
        return TimeOfDay(hour: hour, minute: minute);
      } catch (e) {
        return null;
      }
  }

  Widget _buildProgramCard(HallProgramModel program) {
    return Card(
      color: const Color(0xFF2C2C2C), // Dark Background
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Day/Time Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    program.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // White Text
                    ),
                  ),
                ),
                // Always show badge for schedule context unless it's strictly "Every Day" with no hours?
                // But generally users want to see "Every Day" too.
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.2), 
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blueAccent.withOpacity(0.5)),
                  ),
                  child: Text(
                    _formatSchedule(program),
                    style: const TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Pricing
            if (program.pricing.isNotEmpty) ...[
              const Text(
                "Pricing",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white54), 
              ),
              const SizedBox(height: 4),
              Text(
                program.pricing,
                style: const TextStyle(fontSize: 15, height: 1.4, color: Colors.white70), 
              ),
              const SizedBox(height: 12),
            ],

            // Details
            if (program.details.isNotEmpty) ...[
              const Text(
                "Details",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white54), 
              ),
              const SizedBox(height: 4),
              Text(
                program.details,
                style: const TextStyle(fontSize: 15, height: 1.4, color: Colors.white70), 
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatSchedule(HallProgramModel program) {
    if (program.selectedDays.isEmpty) return "Manual Only";
    
    String daysText = "Every Day";
    if (program.selectedDays.isNotEmpty) {
      if (program.selectedDays.length == 7) {
        daysText = "Every Day";
      } else if (program.selectedDays.length == 2 && program.selectedDays.contains(6) && program.selectedDays.contains(7)) {
        daysText = "Weekends";
      } else if (program.selectedDays.length == 5 && [1,2,3,4,5].every((d) => program.selectedDays.contains(d))) {
        daysText = "Weekdays";
      } else {
        // Sort days
        final sortedDays = List<int>.from(program.selectedDays)..sort();
        daysText = sortedDays.map((d) => ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d - 1]).join(", ");
      }
    }
    
    String timeText = "";
    if (program.startTime != null && program.endTime != null) {
      timeText = "${program.startTime} - ${program.endTime}";
    }
    
    if (timeText.isNotEmpty) {
      return "$daysText • $timeText";
    }
    return daysText;
  }
}
