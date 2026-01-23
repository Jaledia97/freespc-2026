import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/auth_service.dart';
import '../../home/repositories/hall_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Profile'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ref.read(authServiceProvider).signOut();
              },
              child: const Text('Logout'),
            ),
            const Divider(),
            ListTile(
              title: const Text('ADMIN: Seed Mock Hall', style: TextStyle(color: Colors.red)),
              trailing: const Icon(Icons.add_box),
              onTap: () {
                ref.read(hallRepositoryProvider).createMockHall();
              },
            ),
          ],
        ),
      ),
    );
  }
}
