import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/repositories/hall_repository.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hallsAsync = ref.watch(hallsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Directory')),
      body: hallsAsync.when(
        data: (halls) => ListView.builder(
          itemCount: halls.length,
          itemBuilder: (context, index) {
            final hall = halls[index];
            return ListTile(
              leading: const Icon(Icons.store),
              title: Text(hall.name),
              subtitle: Text(hall.beaconUuid),
              onTap: () {
                print("Tapped ${hall.name}");
              },
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading halls: $err')),
      ),
    );
  }
}
