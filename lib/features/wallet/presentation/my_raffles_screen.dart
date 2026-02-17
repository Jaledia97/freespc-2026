import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../wallet/repositories/wallet_repository.dart';
import '../../../core/widgets/glass_container.dart';
import 'widgets/raffle_ticket_item.dart';
import '../../../services/auth_service.dart';

class MyRafflesScreen extends ConsumerWidget {
  const MyRafflesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Get Current User
    final userAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('My Raffles'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text("Please Log In", style: TextStyle(color: Colors.white)));
          }
          final userId = user.uid;

          // 2. Watch User's Raffles
          final rafflesAsync = ref.watch(myRafflesStreamProvider(userId));

          return rafflesAsync.when(
            data: (raffles) {
              if (raffles.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.confirmation_number_outlined, size: 64, color: Colors.white38),
                      const SizedBox(height: 16),
                      const Text("No tickets collected yet", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text("Join a Hall to start playing!", style: TextStyle(color: Colors.white54)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: raffles.length,
                itemBuilder: (context, index) {
                  // Reuse the widget, but ensure it takes full width appropriately
                  return Center(
                    child: SizedBox(
                      width: double.infinity, // Let it stretch if needed, or stick to 280
                      child: RaffleTicketItem(ticket: raffles[index]),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text("Error: $e", style: const TextStyle(color: Colors.red))),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => const Center(child: Text("User Error", style: TextStyle(color: Colors.red))),
      ),
    );
  }
}
