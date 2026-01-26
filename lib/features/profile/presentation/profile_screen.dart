import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/auth_service.dart';
import '../../home/repositories/hall_repository.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_menu.dart';
import '../../my_halls/presentation/my_halls_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch real user data
    final userAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Dark bg
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Settings
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Settings coming soon")));
            },
          ),
        ],
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text("User not found"));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              children: [
                // 1. Header (Avatar, Name, Edit)
                ProfileHeader(user: user),
                
                const SizedBox(height: 32),

                // 2. Action Grid (Tournaments & Raffles)
                Row(
                  children: [
                    _buildActionCard(
                      context, 
                      "My Tournaments", 
                      Icons.emoji_events, 
                      Colors.purple,
                      () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tournaments coming soon (Phase 21)"))),
                    ),
                    const SizedBox(width: 16),
                    _buildActionCard(
                      context, 
                      "My Raffles", 
                      Icons.local_activity, 
                      Colors.orange,
                      () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Raffles coming soon (Phase 20)"))),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),

                // 3. Bio / About Me
                if (user.bio != null && user.bio!.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "About Me",
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const Divider(color: Colors.white24, height: 24),
                        Text(
                          user.bio!,
                          style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),
                const Divider(color: Colors.white10),
                const SizedBox(height: 12),

                // 4. Developer Tools (Collapsible)
                Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    title: const Text("Developer Options", style: TextStyle(color: Colors.grey, fontSize: 14)),
                    iconColor: Colors.grey,
                    collapsedIconColor: Colors.grey,
                    children: [
                      ListTile(
                        title: const Text('ADMIN: Seed Mock Hall', style: TextStyle(color: Colors.red)),
                        trailing: const Icon(Icons.add_box, color: Colors.white54),
                        onTap: () {
                           ref.read(hallRepositoryProvider).createMockHall();
                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mock Hall Created')));
                        },
                      ),
                      ListTile(
                        title: const Text('ADMIN: Seed Mary Esther Env', style: TextStyle(color: Colors.blue)),
                        subtitle: const Text('Sets You as Owner of Mary Esther'),
                        trailing: const Icon(Icons.build, color: Colors.white54),
                        onTap: () async {
                           await ref.read(hallRepositoryProvider).seedMaryEstherEnv(user.uid);
                           ScaffoldMessenger.of(context).showSnackBar(
                             const SnackBar(content: Text('Environment Seeded! You are now Owner.')),
                           );
                        },
                      ),
                      ListTile(
                        title: const Text('ADMIN: Seed Specials (5 items)', style: TextStyle(color: Colors.green)),
                        trailing: const Icon(Icons.cloud_upload, color: Colors.white54),
                        onTap: () async {
                           await ref.read(hallRepositoryProvider).seedSpecials();
                           ScaffoldMessenger.of(context).showSnackBar(
                             const SnackBar(content: Text('Specials Seeded!')),
                           );
                          // Force refresh of map might be needed
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                
                // 5. Logout
                ProfileMenu(
                  title: "Logout",
                  icon: Icons.logout,
                  isDestructive: true,
                  onTap: () {
                    ref.read(authServiceProvider).signOut();
                  },
                ),
                const SizedBox(height: 48),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text("Error: $e")),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 12),
              Text(
                label, 
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
