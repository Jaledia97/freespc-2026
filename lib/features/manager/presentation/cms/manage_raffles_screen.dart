import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/raffle_model.dart';
import '../../../../core/utils/time_utils.dart';
import '../../../home/repositories/hall_repository.dart';
import '../../../profile/presentation/widgets/profile_header.dart';
import 'edit_raffle_screen.dart';
import '../raffle_tool/raffle_tool_screen.dart';

class ManageRafflesScreen extends ConsumerWidget {
  final String hallId;
  const ManageRafflesScreen({super.key, required this.hallId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rafflesAsync = ref.watch(hallRafflesProvider(hallId));

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        title: const Text('Manage Raffles'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EditRaffleScreen(hallId: hallId)),
          );
        },
        backgroundColor: Colors.amber,
        label: const Text("Create Raffle", style: TextStyle(color: Colors.black)),
        icon: const Icon(Icons.add, color: Colors.black),
      ),
      body: rafflesAsync.when(
        data: (raffles) {
          if (raffles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.confirmation_number_outlined, size: 64, color: Colors.white24),
                  const SizedBox(height: 16),
                  const Text("No Raffles Found", style: TextStyle(color: Colors.white54)),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () async {
                      await ref.read(hallRepositoryProvider).seedRaffles(hallId);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Raffles Seeded!")));
                    }, 
                    child: const Text("Seed Demo Raffles")
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: raffles.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final raffle = raffles[index];
              final now = DateTime.now();
              // Check if "Today" (Simple check: Same Day, Month, Year)
              final isToday = raffle.endsAt.year == now.year && raffle.endsAt.month == now.month && raffle.endsAt.day == now.day;
              final isFuture = raffle.endsAt.isAfter(now) && !isToday;
              final isPast = raffle.endsAt.isBefore(now) && !isToday;

              return Card(
                color: const Color(0xFF1E1E1E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(raffle.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  title: Text(raffle.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(raffle.description, style: const TextStyle(color: Colors.white54, fontSize: 12), maxLines: 1),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                           Icon(Icons.calendar_today, size: 12, color: isPast ? Colors.red : (isToday ? Colors.green : Colors.blue)),
                           const SizedBox(width: 4),
                           Text(
                             TimeUtils.formatDateTime(raffle.endsAt, ref),
                             style: TextStyle(color: isPast ? Colors.red : (isToday ? Colors.green : Colors.blue), fontSize: 12, fontWeight: FontWeight.bold)
                           ),
                           if (isToday)
                             Container(
                               margin: const EdgeInsets.only(left: 8),
                               padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                               decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4)),
                               child: const Text("TODAY", style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                             ),
                        ],
                      ),
                    ],
                  ),
                  onTap: () {
                    if (isFuture || isPast) {
                      // Show Edit/Delete Options
                      _showEditDialog(context, ref, raffle);
                    } else if (isToday) {
                      // Navigate to Session Tool
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => RaffleToolScreen(hallId: hallId, raffle: raffle)), // Pass Raffle!
                      );
                    }
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Error: $e")),
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, RaffleModel raffle) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(raffle.name, style: const TextStyle(color: Colors.white)),
        content: Text(
          "This raffle is scheduled for ${TimeUtils.formatDateTime(raffle.endsAt, ref)}.\n\nYou can edit details or delete it.",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text("Delete Raffle?"),
                  content: const Text("This cannot be undone."),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("Cancel")),
                    TextButton(onPressed: () => Navigator.pop(c, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
                  ],
                ),
              );

              if (confirm == true) {
                await ref.read(hallRepositoryProvider).deleteRaffle(raffle.id);
                if (context.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text("DELETE", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(context, MaterialPageRoute(builder: (_) => EditRaffleScreen(hallId: hallId, raffle: raffle)));
            },
            child: const Text("EDIT"),
          ),
        ],
      ),
    );
  }
}
