import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/repositories/venue_repository.dart';
import '../../../services/auth_service.dart';
import '../../../services/location_service.dart';
import '../../home/presentation/venue_profile_screen.dart';
import '../../home/presentation/venue_search_screen.dart';
import '../../../models/venue_model.dart';
import 'package:geolocator/geolocator.dart'; // Import explicitly for Position types if needed, or rely on service

final nearbyHallsFutureProvider =
    FutureProvider.family<
      List<VenueModel>,
      ({List<String> ids, Position? location})
    >((ref, args) {
      return ref
          .read(venueRepositoryProvider)
          .getNearbyHalls(args.ids, location: args.location);
    });

class MyVenuesScreen extends ConsumerStatefulWidget {
  const MyVenuesScreen({super.key});

  @override
  ConsumerState<MyVenuesScreen> createState() => _MyVenuesScreenState();
}

class _MyVenuesScreenState extends ConsumerState<MyVenuesScreen> {

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(userProfileProvider);
    final userLocationAsync = ref.watch(userLocationStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Places'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: FilledButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HallSearchScreen()),
              ),
              icon: const Icon(Icons.map, size: 18),
              label: const Text('Map View', style: TextStyle(fontWeight: FontWeight.bold)),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white12,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
      body: userProfileAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text("Please log in."));

          final userLocation = userLocationAsync.valueOrNull;
          final nearbyHallsAsync = ref.watch(
            nearbyHallsFutureProvider((
              ids: user.following,
              location: userLocation,
            )),
          );

          return CustomScrollView(
            slivers: [
              // Section 1: Your Venues (Cards with Banners)
              if (user.following.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: Text("You aren't following any places yet."),
                    ),
                  ),
                )
              else
                Consumer(
                  builder: (context, ref, child) {
                    final hallsAsync = ref.watch(
                      venuesStreamProvider(user.following.join(',')),
                    );

                    return hallsAsync.when(
                      data: (myHalls) {
                        final userLocation = userLocationAsync.valueOrNull;

                        // Sort: Alphabetical
                        final sortedHalls = List<VenueModel>.from(myHalls);
                        sortedHalls.sort((a, b) => a.name.compareTo(b.name));

                        return SliverGrid(
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 220,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final venue = sortedHalls[index];

                            double? distanceInMiles;
                            if (userLocation != null) {
                              final meters = ref
                                  .read(locationServiceProvider)
                                  .getDistanceBetween(
                                    userLocation.latitude,
                                    userLocation.longitude,
                                    venue.latitude,
                                    venue.longitude,
                                  );
                              distanceInMiles = meters * 0.000621371;
                            }

                            return _VenueGridCard(
                              venue: venue,
                              distanceText: distanceInMiles != null 
                                ? "${distanceInMiles.toStringAsFixed(1)} mi" 
                                : null,
                            );
                          }, childCount: myHalls.length),
                        );
                      },
                      loading: () => const SliverToBoxAdapter(
                        child: LinearProgressIndicator(),
                      ),
                      error: (e, _) =>
                          SliverToBoxAdapter(child: Text("Error: $e")),
                    );
                  },
                ),

              const SliverToBoxAdapter(
                child: Divider(height: 32, thickness: 2),
              ),

              // Section 2: GPS Suggestions
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Text(
                    "Nearest Places to You",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              nearbyHallsAsync.when(
                data: (nearbyHalls) {
                  if (nearbyHalls.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text("No other places found nearby."),
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 220,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.75,
                      ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final venue = nearbyHalls[index];

                        double? distanceInMiles;
                        if (userLocation != null) {
                          final meters = ref
                              .read(locationServiceProvider)
                              .getDistanceBetween(
                                userLocation.latitude,
                                userLocation.longitude,
                                venue.latitude,
                                venue.longitude,
                              );
                          distanceInMiles = meters * 0.000621371;
                        }

                        return _VenueGridCard(
                          venue: venue,
                          distanceText: distanceInMiles != null 
                            ? "${distanceInMiles.toStringAsFixed(1)} mi" 
                            : null,
                          isNearbyRecommended: true,
                        );
                      }, childCount: nearbyHalls.length),
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text("Could not load nearby places: $e"),
                  ),
                ),
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

class _VenueGridCard extends StatelessWidget {
  final VenueModel venue;
  final String? distanceText;
  final bool isNearbyRecommended;

  const _VenueGridCard({
    required this.venue,
    this.distanceText,
    this.isNearbyRecommended = false,
  });

  @override
  Widget build(BuildContext context) {
    final logoUrl = venue.logoUrl ?? venue.bannerUrl;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HallProfileScreen(venue: venue),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Recommended Badge OR Avatar Row
            if (isNearbyRecommended)
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on, color: Colors.blue, size: 12),
                    SizedBox(width: 4),
                    Text(
                      "Nearby",
                      style: TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

             // Avatar
             CircleAvatar(
              radius: isNearbyRecommended ? 24 : 28, // Shrink slightly to fit badge
              backgroundColor: Colors.amber.withOpacity(0.2),
              backgroundImage: logoUrl != null ? NetworkImage(logoUrl) : null,
              child: logoUrl == null 
                ? Text(
                    venue.name.isNotEmpty ? venue.name[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.amber, fontSize: 24, fontWeight: FontWeight.bold),
                  )
                : null,
            ),
            const SizedBox(height: 12),
            
            // Name
            Text(
              venue.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            
            // Distance
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on, size: 12, color: Colors.white54),
                const SizedBox(width: 4),
                Text(
                  distanceText ?? "Unknown",
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
                ),
              ],
            ),
            const Spacer(),
            
            // Details Button Mimic (Replaces Points)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "View",
                style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

