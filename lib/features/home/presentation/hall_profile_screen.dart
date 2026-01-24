import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/bingo_hall_model.dart';
import '../../home/repositories/hall_repository.dart';
import '../../../services/auth_service.dart';

class HallProfileScreen extends ConsumerWidget {
  final BingoHallModel hall;
  final double? distanceInMeters;

  const HallProfileScreen({
    super.key,
    required this.hall,
    this.distanceInMeters,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(hall.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Hero / Map Header Placeholder
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey[300],
              child: const Icon(Icons.map, size: 80, color: Colors.white),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Hall Info
                  Text(
                    hall.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  if (distanceInMeters != null)
                     Text(
                      "${(distanceInMeters! * 0.000621371).toStringAsFixed(1)} miles away",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text("Beacon ID: ${hall.beaconUuid}"),
                  
                  const Divider(height: 32),
                  
                  // 3. Actions
                  userProfileAsync.when(
                    data: (user) {
                      if (user == null) return const SizedBox.shrink();

                      final isFollowing = user.following.contains(hall.id);
                      final isHome = user.homeBaseId == hall.id;

                      return Column(
                        children: [
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                ref.read(hallRepositoryProvider).toggleFollow(
                                  user.uid,
                                  hall.id,
                                  isFollowing,
                                );
                              },
                              onLongPress: () {
                                  ref.read(hallRepositoryProvider).toggleHomeBase(
                                    user.uid,
                                    hall.id,
                                    user.homeBaseId,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(isHome ? "Home Base Removed" : "Home Base Set!")),
                                  );
                                },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isHome 
                                    ? const Color(0xFF673AB7).withOpacity(0.1) 
                                    : (isFollowing ? Colors.red.withOpacity(0.1) : Colors.grey.withOpacity(0.1)),
                                ),
                                child: Icon(
                                  isHome ? Icons.home : (isFollowing ? Icons.favorite : Icons.favorite_border),
                                  size: 48,
                                  color: isHome 
                                    ? const Color(0xFF673AB7) 
                                    : (isFollowing ? Colors.red : Colors.grey),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isHome 
                              ? "Home Base" 
                              : (isFollowing ? "Following" : "Follow"),
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          if (!isHome)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                "(Hold heart to set Home)",
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                              ),
                            ),
                        ],
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (e, _) => Text("Error loading profile: $e"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
