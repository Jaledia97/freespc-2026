import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../manager/repositories/tournament_repository.dart';
import '../../../services/auth_service.dart';
import '../../home/presentation/widgets/tournament_list_card.dart';
import '../repositories/hall_repository.dart'; // For hall names if needed, though they aren't on model yet? 
// Wait, TournamentModel only has hallId. We might need to fetch hall details or just show ID for now?
// Ideally we join data, but for MVP let's just list them. 
// Actually, `TournamentListCard` doesn't show Hall Name. We should probably update it to optionally show Hall Name.

class TournamentsScreen extends ConsumerWidget {
  const TournamentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tournamentsAsync = ref.watch(tournamentsFeedProvider);
    final userAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tournaments"),
        centerTitle: true,
      ),
      body: tournamentsAsync.when(
        data: (tournaments) {
          return userAsync.when(
            data: (user) {
              if (tournaments.isEmpty) {
                return const Center(child: Text("No active tournaments found."));
              }

              // Filter Logic
              final myTournaments = <dynamic>[]; // Using dynamic to avoid type issues if models change
              final otherTournaments = <dynamic>[];

              if (user != null) {
                for (var t in tournaments) {
                   if (user.following.contains(t.hallId) || user.homeBaseId == t.hallId) {
                     myTournaments.add(t);
                   } else {
                     otherTournaments.add(t);
                   }
                }
              } else {
                otherTournaments.addAll(tournaments);
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                   // 1. Your Tournaments
                   if (myTournaments.isNotEmpty) ...[
                     const Text("YOUR TOURNAMENTS", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                     const SizedBox(height: 8),
                     ...myTournaments.map((t) => TournamentListCard(tournament: t, showHallName: true)).toList(),
                     const SizedBox(height: 24),
                   ],

                   // 2. All Tournaments
                   if (otherTournaments.isNotEmpty) ...[
                     const Text("ALL TOURNAMENTS", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                     const SizedBox(height: 8),
                     ...otherTournaments.map((t) => TournamentListCard(tournament: t, showHallName: true)).toList(),
                   ],
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text("User Error: $e")),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error loading tournaments: $e")),
      ),
    );
  }
}
