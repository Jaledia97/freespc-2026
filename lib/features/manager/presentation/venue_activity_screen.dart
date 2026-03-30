import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/session_context_controller.dart';
import '../../home/repositories/hall_repository.dart';
import '../../manager/repositories/tournament_repository.dart';
import '../../home/presentation/widgets/special_card.dart';
import '../../home/presentation/widgets/raffle_feed_card.dart';
import '../../home/presentation/widgets/tournament_feed_card.dart';

class VenueActivityScreen extends ConsumerWidget {
  const VenueActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionContextProvider);
    final venueId = session.activeVenueId;

    if (venueId == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Text("No Active Venue.", style: TextStyle(color: Colors.white54))),
      );
    }

    final specialsAsync = ref.watch(hallSpecialsProvider(venueId));
    final rafflesAsync = ref.watch(hallRafflesProvider(venueId));
    final tournamentsAsync = ref.watch(hallTournamentsProvider(venueId));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Venue Activity', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Specials Section
          _buildSectionHeader("Active Specials", Icons.local_fire_department, Colors.redAccent),
          specialsAsync.when(
            data: (specials) {
              if (specials.isEmpty) {
                return _buildEmptyState("No active specials.");
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => SpecialCard(special: specials[index], fullWidth: true, isFeatured: false),
                  childCount: specials.length,
                ),
              );
            },
            loading: () => _buildLoadingState(),
            error: (e, _) => _buildErrorState(e),
          ),

          // Tournaments Section
          _buildSectionHeader("Live Tournaments", Icons.emoji_events, Colors.blueAccent),
          tournamentsAsync.when(
            data: (tournaments) {
              if (tournaments.isEmpty) {
                return _buildEmptyState("No active tournaments.");
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => TournamentFeedCard(tournament: tournaments[index], fullWidth: true),
                  childCount: tournaments.length,
                ),
              );
            },
            loading: () => _buildLoadingState(),
            error: (e, _) => _buildErrorState(e),
          ),

          // Raffles Section
          _buildSectionHeader("Current Raffles", Icons.local_activity, Colors.greenAccent),
          rafflesAsync.when(
            data: (raffles) {
              if (raffles.isEmpty) {
                return _buildEmptyState("No ongoing raffles.");
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => RaffleFeedCard(raffle: raffles[index], fullWidth: true),
                  childCount: raffles.length,
                ),
              );
            },
            loading: () => _buildLoadingState(),
            error: (e, _) => _buildErrorState(e),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildSectionHeader(String title, IconData icon, Color color) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 8),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildEmptyState(String message) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          message,
          style: const TextStyle(color: Colors.white38),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildLoadingState() {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(child: CircularProgressIndicator(color: Colors.white24)),
      ),
    );
  }

  SliverToBoxAdapter _buildErrorState(Object error) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text("Error: $error", style: const TextStyle(color: Colors.redAccent)),
      ),
    );
  }
}
