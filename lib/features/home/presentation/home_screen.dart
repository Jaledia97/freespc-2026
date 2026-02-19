import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/repositories/hall_repository.dart';
import 'hall_profile_screen.dart';
import 'hall_search_screen.dart';
import 'upcoming_games_screen.dart';
import 'upcoming_games_screen.dart';
import 'widgets/special_card.dart';
import '../../../services/location_service.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In a real implementation this would be a stream from the repository
    final userLocation = ref.watch(userLocationStreamProvider).valueOrNull;
    final specialsStream = ref.watch(hallRepositoryProvider).getSpecialsFeed(userLocation); 

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. Pinned App Bar
          const SliverAppBar(
            title: Text('FreeSpc'),
            centerTitle: true,
            floating: true,
            pinned: true,
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
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Coming Soon"))),
                    ),
                    _QuickAction(
                      icon: Icons.person_search,
                      label: 'Find Friend',
                      color: Colors.blue,
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Coming Soon"))),
                    ),

                    const SizedBox(width: 16),
                  ],
                ),
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
