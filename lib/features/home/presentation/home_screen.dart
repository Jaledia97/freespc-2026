import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/repositories/hall_repository.dart';
import 'hall_search_screen.dart';
import 'upcoming_games_screen.dart';
import 'widgets/special_card.dart';
import 'widgets/raffle_feed_card.dart';
import 'widgets/tournament_feed_card.dart';
import '../../../models/raffle_model.dart';
import '../../../models/tournament_model.dart';
import '../../../services/location_service.dart';
import '../../friends/presentation/friends_screen.dart';
import '../../friends/presentation/find_friends_screen.dart';
import '../../messaging/presentation/messaging_hub_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In a real implementation this would be a stream from the repository
    final userLocation = ref.watch(userLocationStreamProvider).valueOrNull;
    final specialsStream = ref.watch(hallRepositoryProvider).getSpecialsFeed(userLocation); 
    final rafflesStream = ref.watch(hallRepositoryProvider).getActiveRafflesFeed(userLocation);
    final tournamentsStream = ref.watch(hallRepositoryProvider).getActiveTournamentsFeed(userLocation);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. Pinned App Bar
          SliverAppBar(
            title: const Text('FreeSpc'),
            centerTitle: true,
            floating: true,
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MessagingHubScreen()));
                },
              )
            ],
          ),

          // 2. Quick Action Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    _QuickAction(
                      icon: Icons.search,
                      label: 'Find Hall',
                      color: Colors.orange,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HallSearchScreen())),
                    ),
                    _QuickAction(
                      icon: Icons.calendar_today,
                      label: 'Upcoming Games',
                      color: Colors.purpleAccent,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UpcomingGamesScreen())),
                    ),
                    _QuickAction(
                      icon: Icons.local_activity,
                      label: 'Raffles',
                      color: Colors.purple,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UpcomingGamesScreen(initialCategory: 'Raffles'))),
                    ),
                    _QuickAction(
                      icon: Icons.emoji_events,
                      label: 'Tournaments',
                      color: Colors.red,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UpcomingGamesScreen(initialCategory: 'Tournaments'))),
                    ),
                    _QuickAction(
                      icon: Icons.people,
                      label: 'Friends',
                      color: Colors.teal,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FriendsScreen())),
                    ),
                    _QuickAction(
                      icon: Icons.person_search,
                      label: 'Find Friend',
                      color: Colors.blue,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FindFriendsScreen())),
                    ),

                    const SizedBox(width: 16),
                  ],
                ),
              ),
            ),
          ),

          // Active Raffles Carousel
          StreamBuilder<List<RaffleModel>>(
            stream: rafflesStream,
            builder: (context, snapshot) {
              final raffles = snapshot.data ?? [];
              if (raffles.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

              return SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 8, bottom: 12),
                      child: Text(
                        'Active Raffles',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 250,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 16),
                        itemCount: raffles.length,
                        itemBuilder: (context, index) {
                          return RaffleFeedCard(raffle: raffles[index]);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          ),

          // Upcoming Tournaments Carousel
          StreamBuilder<List<TournamentModel>>(
            stream: tournamentsStream,
            builder: (context, snapshot) {
              final tourneys = snapshot.data ?? [];
              if (tourneys.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

              return SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 8, bottom: 12),
                      child: Text(
                        'Upcoming Tournaments',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 160,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 16),
                        itemCount: tourneys.length,
                        itemBuilder: (context, index) {
                          return TournamentFeedCard(tournament: tourneys[index]);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          ),

          // Daily Specials Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, top: 8, bottom: 12),
              child: Text(
                'Daily Events & Specials',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // 3. The Specials Feed
          StreamBuilder(
            stream: specialsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
              }
              if (snapshot.hasError) {
                return SliverFillRemaining(child: Center(child: Text("Error: ${snapshot.error}")));
              }
              
              final specials = snapshot.data ?? [];

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final special = specials[index];
                    return SpecialCard(special: special, isFeatured: true);
                  },
                  childCount: specials.length,
                ),
              );
            },
          ),
          
          // Bottom Padding to clear BottomAppBar (80) + FAB space
          const SliverToBoxAdapter(child: SizedBox(height: 140)),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon, 
    required this.label, 
    required this.color, 
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
