import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/bingo_hall_model.dart';
import '../../repositories/hall_repository.dart';
import '../../../../models/special_model.dart';
import '../hall_profile_screen.dart';
import 'package:intl/intl.dart';

class HallMapDetailPanel extends ConsumerWidget {
  final BingoHallModel hall;
  final VoidCallback onClose;

  const HallMapDetailPanel({super.key, required this.hall, required this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch upcoming specials for this hall
    final specialsStream = ref.watch(hallSpecialsProvider(hall.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Drag Handle
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo placeholder or image
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.blue.shade50,
                child: Text(hall.name[0], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hall.name,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${hall.city}, ${hall.state}",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        const Text("4.8", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text("OPEN", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Actions
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => HallProfileScreen(hall: hall)));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("View Full Profile"),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Upcoming Events
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text("Upcoming Games", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        const SizedBox(height: 12),
        
        SizedBox(
          height: 140, // Height for compact cards
          child: specialsStream.when(
            data: (specials) {
              if (specials.isEmpty) {
                return const Center(child: Text("No upcoming games listed.", style: TextStyle(color: Colors.grey)));
              }
              // Sort by date/time ideally, if not already sorted
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                scrollDirection: Axis.horizontal,
                itemCount: specials.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return _CompactSpecialCard(special: specials[index]);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(child: Text("Could not load games")),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _CompactSpecialCard extends StatelessWidget {
  final SpecialModel special;
  const _CompactSpecialCard({required this.special});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image / Color Header
          Container(
             height: 60,
             decoration: BoxDecoration(
               color: Colors.blue[100],
               borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
               image: special.imageUrl != null 
                 ? DecorationImage(image: NetworkImage(special.imageUrl!), fit: BoxFit.cover)
                 : null
             ),
             child: special.imageUrl == null 
               ? const Center(child: Icon(Icons.event, color: Colors.blue))
               : null,
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  special.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 4),
                const SizedBox(height: 4),
                Text(
                  // Simple logic, assuming recurrence description exists or just title
                  special.recurrence == 'none' ? 'One Time Event' : "Repeats ${special.recurrence}",
                  style: TextStyle(color: Colors.grey[600], fontSize: 10),
                  maxLines: 1, 
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
