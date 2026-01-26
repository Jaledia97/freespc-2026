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
            ListTile(
              title: const Text('ADMIN: Seed Mary Esther Env', style: TextStyle(color: Colors.blue)),
              subtitle: const Text('Sets You as Owner of Mary Esther'),
              trailing: const Icon(Icons.build),
              onTap: () async {
                final user = ref.read(authStateChangesProvider).value;
                if (user != null) {
                   await ref.read(hallRepositoryProvider).seedMaryEstherEnv(user.uid);
                   await ref.read(hallRepositoryProvider).checkHallData('mary-esther-bingo'); // Verify write
                   ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(content: Text('Environment Seeded! You are now Owner.')),
                   );
                }
              },
            ),
            ListTile(
              title: const Text('ADMIN: Seed Specials (5 items)', style: TextStyle(color: Colors.green)),
              trailing: const Icon(Icons.cloud_upload),
              onTap: () async {
                 await ref.read(hallRepositoryProvider).seedSpecials();
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text('Specials Seeded!')),
                 );
              },
            ),
          ],
        ),
      ),
    );
  }
}
