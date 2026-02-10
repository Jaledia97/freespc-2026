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
      // If override is expired, fall through to schedule check or return false?
      // User likely wants it to expire -> Inactive.
      // But maybe they want it to revert to schedule?
      // "Limit override to this time" implies after that time, the override is gone.
      // So we should probably fall back to normal schedule.
    }

    // 2. Check Schedule
    final now = DateTime.now();
    
    // Check Day
    if (program.specificDay != null) {
      // Simple Day Check
      // We need a helper to match "Monday" to DateTime.weekday
      if (!_isSameDay(program.specificDay!, now)) {
         return false;
      }
    }
    
    // Check Timeframe (if exists)
    if (program.startTime != null && program.endTime != null) {
       return _isWithinTimeframe(program.startTime!, program.endTime!, now);
    }
    
    // If no day/time restrictions, it's always active? Or always inactive?
    // "General" programs (no day/time) are usually always active.
    return true; 
  }

  bool _isSameDay(String dayName, DateTime date) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final index = days.indexOf(dayName);
    if (index == -1) return false;
    // DateTime.weekday: Mon=1, Sun=7. List index: Mon=0, Sun=6.
    return date.weekday == (index + 1);
  }

  bool _isWithinTimeframe(String startStr, String endStr, DateTime now) {
    try {
      final start = _parseTimeOfDay(startStr);
      final end = _parseTimeOfDay(endStr);
      if (start == null || end == null) return true; // Error parsing -> assume active?

      final nowTime = TimeOfDay.fromDateTime(now);
      
      // Convert to minutes for comparison
      final startMin = start.hour * 60 + start.minute;
      final endMin = end.hour * 60 + end.minute;
      final nowMin = nowTime.hour * 60 + nowTime.minute;
      
      if (endMin < startMin) {
        // Overnight, e.g. 10PM to 2AM
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
                if (program.specificDay != null || (program.startTime != null && program.endTime != null))
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.2), // Slightly more opaque
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
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white54), // White54
              ),
              const SizedBox(height: 4),
              Text(
                program.pricing,
                style: const TextStyle(fontSize: 15, height: 1.4, color: Colors.white70), // White70
              ),
              const SizedBox(height: 12),
            ],

            // Details
            if (program.details.isNotEmpty) ...[
              const Text(
                "Details",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white54), // White54
              ),
              const SizedBox(height: 4),
              Text(
                program.details,
                style: const TextStyle(fontSize: 15, height: 1.4, color: Colors.white70), // White70
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatSchedule(HallProgramModel program) {
    String text = "";
    if (program.specificDay != null) {
      text = program.specificDay!;
    }
    
    if (program.startTime != null && program.endTime != null) {
      if (text.isNotEmpty) text += " • ";
      text += "${program.startTime} - ${program.endTime}";
    }
    
    return text;
  }
}
