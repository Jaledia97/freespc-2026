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

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: programs.length,
      itemBuilder: (context, index) {
        final program = programs[index];
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
                // Title & Day Badge
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
                    if (program.specificDay != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.2), // Slightly more opaque
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blueAccent.withOpacity(0.5)),
                        ),
                        child: Text(
                          program.specificDay!,
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
      },
    );
  }
}
