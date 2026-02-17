import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/raffle_ticket_model.dart';
import '../../../home/presentation/hall_profile_screen.dart';
import '../../../home/repositories/hall_repository.dart';

class RaffleTicketItem extends ConsumerWidget {
  final RaffleTicketModel ticket;
  const RaffleTicketItem({super.key, required this.ticket});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to LIVE Hall Data
    final hallAsync = ref.watch(hallStreamProvider(ticket.hallId));

    return hallAsync.when(
      data: (hall) {
        final hallName = hall?.name ?? ticket.hallName;

        return GestureDetector(
          onTap: () {
             if (hall != null) {
               Navigator.push(
                 context, 
                 MaterialPageRoute(
                   builder: (_) => HallProfileScreen(hall: hall, initialTabIndex: 1) // 1 = Raffles Tab
                 )
               );
             } else {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Hall not found")));
             }
          },
          child: Container(
            width: 280,
            margin: const EdgeInsets.only(right: 12, bottom: 12), // Added bottom margin for vertical lists
            child: Stack(
              children: [
                // Ticket Shape (Visual approximation)
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF252525),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    children: [
                      // Left Stub (Image)
                      Container(
                        width: 80,
                        height: 100, // Fixed height for consistency
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                          image: ticket.imageUrl != null 
                            ? DecorationImage(image: NetworkImage(ticket.imageUrl!), fit: BoxFit.cover)
                            : null,
                        ),
                        child: ticket.imageUrl == null ? const Center(child: Icon(Icons.confirmation_number, color: Colors.white24)) : null,
                      ),
                      
                      // Dashed Line
                      Container(width: 1, height: 100, color: Colors.white10, margin: const EdgeInsets.symmetric(horizontal: 2)),
                      
                      // Details
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(ticket.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text(hallName, style: const TextStyle(color: Colors.white54, fontSize: 12)), // Use Live Name
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("x${ticket.quantity} Tickets", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                                  const Icon(Icons.qr_code, color: Colors.white24, size: 20),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Container(width: 280, height: 100, margin: const EdgeInsets.only(right: 12, bottom: 12), color: Colors.white10),
      error: (_,__) => const SizedBox(),
    );
  }
}
