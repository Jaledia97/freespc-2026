import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/repositories/hall_repository.dart';
import '../../../services/location_service.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger permission request
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationServiceProvider).determinePosition();
    });
  }

  @override
  Widget build(BuildContext context) {
    final hallsAsync = ref.watch(hallsStreamProvider);
    final userLocationAsync = ref.watch(userLocationStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Directory')),
      body: hallsAsync.when(
        data: (halls) {
          // Get location if available, otherwise null
          final userLocation = userLocationAsync.valueOrNull;
          
          // Calculate distances
          final hallsWithDistance = halls.map((hall) {
            double? distanceInMeters;
            if (userLocation != null) {
              distanceInMeters = ref.read(locationServiceProvider).getDistanceBetween(
                userLocation.latitude,
                userLocation.longitude,
                hall.latitude,
                hall.longitude,
              );
            }
            return MapEntry(hall, distanceInMeters);
          }).toList();

          // Sort by distance (if available)
          if (userLocation != null) {
            hallsWithDistance.sort((a, b) {
              final dA = a.value ?? double.infinity;
              final dB = b.value ?? double.infinity;
              return dA.compareTo(dB);
            });
          }

          return ListView.builder(
            itemCount: hallsWithDistance.length,
            itemBuilder: (context, index) {
              final entry = hallsWithDistance[index];
              final hall = entry.key;
              final distance = entry.value;

              String subtitle = hall.beaconUuid;
              if (distance != null) {
                final miles = distance * 0.000621371;
                subtitle = "${miles.toStringAsFixed(1)} mi • ${hall.beaconUuid}";
              }

              return ListTile(
                leading: const Icon(Icons.store),
                title: Text(hall.name),
                subtitle: Text(subtitle),
                trailing: distance != null 
                    ? const Icon(Icons.near_me, size: 16, color: Colors.blue) 
                    : null,
                onTap: () {
                  print("Tapped ${hall.name}");
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading halls: $err')),
      ),
    );
  }
}
