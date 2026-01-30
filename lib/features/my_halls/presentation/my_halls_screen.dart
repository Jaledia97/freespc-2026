import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/repositories/hall_repository.dart';
import '../../../services/auth_service.dart';
import '../../../services/location_service.dart';
import '../../home/presentation/hall_profile_screen.dart';
import '../../home/presentation/hall_search_screen.dart';
import '../../../models/bingo_hall_model.dart';
import 'package:geolocator/geolocator.dart'; // Import explicitly for Position types if needed, or rely on service

final nearbyHallsFutureProvider = FutureProvider.family<List<BingoHallModel>, ({List<String> ids, Position? location})>((ref, args) {
  return ref.read(hallRepositoryProvider).getNearbyHalls(args.ids, location: args.location);
});

class MyHallsScreen extends ConsumerStatefulWidget {
  const MyHallsScreen({super.key});

  @override
  ConsumerState<MyHallsScreen> createState() => _MyHallsScreenState();
}

class _MyHallsScreenState extends ConsumerState<MyHallsScreen> {
  // Track expanded cards by ID
  final Set<String> _expandedHallIds = {};

  void _toggleExpanded(String hallId) {
    setState(() {
      if (_expandedHallIds.contains(hallId)) {
        _expandedHallIds.remove(hallId);
      } else {
        _expandedHallIds.add(hallId);
      }
    });
  }

  String _getHallImage(String hallId) {
    // Return static Unsplash images based on ID to avoid random "mock" look
    switch (hallId) {
      case 'mary-esther-bingo':
        return 'https://images.unsplash.com/photo-1518893063132-36e465be779d?auto=format&fit=crop&w=800&q=80';
      case 'grand-bingo-1':
        return 'https://images.unsplash.com/photo-1596838132731-3301c3fd4317?auto=format&fit=crop&w=800&q=80';
      case 'beach-bingo':
        return 'https://images.unsplash.com/photo-1563089145-599997674d42?auto=format&fit=crop&w=800&q=80';
      case 'westside-hall':
        return 'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?auto=format&fit=crop&w=800&q=80';
      case 'downtown-hall':
        return 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=800&q=80';
      default:
        // Use a high-reliability fallback (Abstract Gradient/Pattern) if others fail
        return 'https://images.unsplash.com/photo-1557683316-973673baf926?auto=format&fit=crop&w=800&q=80';
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(userProfileProvider);
    final userLocationAsync = ref.watch(userLocationStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Subscribed Halls'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HallSearchScreen())),
          ),
        ],
      ),
      body: userProfileAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text("Please log in."));

          final userLocation = userLocationAsync.valueOrNull;
          final nearbyHallsAsync = ref.watch(nearbyHallsFutureProvider((ids: user.following, location: userLocation)));

          return CustomScrollView(
            slivers: [
              // Section 1: Your Halls (Cards with Banners)
              if (user.following.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: Text("You aren't following any halls yet.")),
                  ),
                )
              else
                Consumer(
                  builder: (context, ref, child) {
                    final hallsAsync = ref.watch(hallsStreamProvider(user.following));
                    
                    return hallsAsync.when(
                      data: (myHalls) {
                        final userLocation = userLocationAsync.valueOrNull;
                        
                        // Sort: Home Base first
                        final sortedHalls = List<BingoHallModel>.from(myHalls);
                        sortedHalls.sort((a, b) {
                          if (a.id == user.homeBaseId) return -1;
                          if (b.id == user.homeBaseId) return 1;
                          return 0;
                        });

                        return SliverList(
                       delegate: SliverChildBuilderDelegate(
                         (context, index) {
                           final hall = sortedHalls[index];
                           final isHome = user.homeBaseId == hall.id;
                           final isExpanded = _expandedHallIds.contains(hall.id);
                           
                           double? distanceInMiles;
                           if (userLocation != null) {
                             final meters = ref.read(locationServiceProvider).getDistanceBetween(
                               userLocation.latitude, userLocation.longitude,
                               hall.latitude, hall.longitude
                             );
                             distanceInMiles = meters * 0.000621371;
                           }

                           return Card(
                             margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                             clipBehavior: Clip.antiAlias,
                             child: InkWell(
                               onTap: () => _toggleExpanded(hall.id),
                               child: Column(
                                 children: [
                                    // 1. Banner Image (Dynamic)
                                   Stack(
                                     children: [
                                       Container(
                                         height: 120,
                                         width: double.infinity,
                                         color: Colors.grey[300],
                                         child: Image.network(
                                           hall.bannerUrl ?? _getHallImage(hall.id), 
                                           fit: BoxFit.cover,
                                           errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image)),
                                         ),
                                       ),
                                       if (isHome)
                                          Positioned(
                                            top: 8, right: 8,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(color: const Color(0xFF673AB7), borderRadius: BorderRadius.circular(12)),
                                              child: const Row(
                                                children: [
                                                  Icon(Icons.home, color: Colors.white, size: 14),
                                                  SizedBox(width: 4),
                                                  Text("Home Base", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                                ],
                                              ),
                                            ),
                                          ),
                                     ],
                                   ),
                                   
                                   // 2. Info Row
                                   Padding(
                                     padding: const EdgeInsets.all(12.0),
                                     child: Column(
                                       crossAxisAlignment: CrossAxisAlignment.start,
                                       children: [
                                         Row(
                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                           children: [
                                             Expanded(
                                               child: Text(
                                                 hall.name, 
                                                 style: Theme.of(context).textTheme.titleLarge,
                                                 overflow: TextOverflow.ellipsis,
                                               ),
                                             ),
                                             if (distanceInMiles != null)
                                               Text(
                                                 "${distanceInMiles.toStringAsFixed(1)} mi",
                                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                                               ),
                                           ],
                                         ),
                                         if (isExpanded) ...[
                                            const SizedBox(height: 16),
                                            const Divider(),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                TextButton.icon(
                                                  onPressed: () {}, 
                                                  icon: const Icon(Icons.call),
                                                  label: const Text("Call"),
                                                ),
                                                TextButton.icon(
                                                  onPressed: () {}, 
                                                  icon: const Icon(Icons.directions),
                                                  label: const Text("Directions"),
                                                ),
                                                TextButton.icon(
                                                  onPressed: () {
                                                     Navigator.push(context, MaterialPageRoute(builder: (_) => HallProfileScreen(hall: hall)));
                                                  }, 
                                                  icon: const Icon(Icons.info_outline),
                                                  label: const Text("Details"),
                                                ),
                                              ],
                                            )
                                         ],
                                       ],
                                     ),
                                   ),
                                 ],
                               ),
                             ),
                           );
                         },
                         childCount: myHalls.length,
                       ),
                     );
                  },
                  loading: () => const SliverToBoxAdapter(child: LinearProgressIndicator()),
                  error: (e, _) => SliverToBoxAdapter(child: Text("Error: $e")),
                );
                  },
                ),

              const SliverToBoxAdapter(child: Divider(height: 32, thickness: 2)),

              // Section 2: GPS Suggestions
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Text("Nearest Halls to You", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              
              nearbyHallsAsync.when(
                data: (nearbyHalls) {
                  if (nearbyHalls.isEmpty) {
                    return const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(16), child: Text("No other halls found nearby.")));
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final hall = nearbyHalls[index];
                        final isExpanded = _expandedHallIds.contains(hall.id);

                        double? distanceInMiles;
                        if (userLocation != null) {
                           final meters = ref.read(locationServiceProvider).getDistanceBetween(
                             userLocation.latitude, userLocation.longitude,
                             hall.latitude, hall.longitude
                           );
                           distanceInMiles = meters * 0.000621371;
                        }

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => _toggleExpanded(hall.id),
                            child: Column(
                              children: [
                                // 1. Banner Image (Dynamic)
                                Stack(
                                  children: [
                                    Container(
                                      height: 120,
                                      width: double.infinity,
                                      color: Colors.grey[300],
                                      child: Image.network(
                                        hall.bannerUrl ?? _getHallImage(hall.id), 
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image)),
                                      ),
                                    ),
                                    Positioned( // "Nearby" Badge
                                      top: 8, right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(12)),
                                        child: const Row(
                                          children: [
                                            Icon(Icons.location_on, color: Colors.white, size: 14),
                                            SizedBox(width: 4),
                                            Text("Nearby", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                
                                // 2. Info Row
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              hall.name, 
                                              style: Theme.of(context).textTheme.titleLarge,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (distanceInMiles != null)
                                            Text(
                                              "${distanceInMiles.toStringAsFixed(1)} mi",
                                               style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                                            ),
                                        ],
                                      ),
                                      if (isExpanded) ...[
                                         const SizedBox(height: 16),
                                         const Divider(),
                                         Row(
                                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                           children: [
                                             TextButton.icon(
                                               onPressed: () {}, 
                                               icon: const Icon(Icons.call),
                                               label: const Text("Call"),
                                             ),
                                             TextButton.icon(
                                               onPressed: () {}, 
                                               icon: const Icon(Icons.directions),
                                               label: const Text("Directions"),
                                             ),
                                             TextButton.icon(
                                               onPressed: () {
                                                  Navigator.push(context, MaterialPageRoute(builder: (_) => HallProfileScreen(hall: hall)));
                                               }, 
                                               icon: const Icon(Icons.info_outline),
                                               label: const Text("Details"),
                                             ),
                                           ],
                                         )
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: nearbyHalls.length,
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
                error: (e, _) => SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(16), child: Text("Could not load nearby halls: $e"))),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 140)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading profile: $e')),
      ),
    );
  }
}
