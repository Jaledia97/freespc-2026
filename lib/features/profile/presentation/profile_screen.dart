import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/auth_service.dart';
import '../../home/repositories/hall_repository.dart';
import '../../wallet/repositories/wallet_repository.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_menu.dart';
import '../../my_halls/presentation/my_halls_screen.dart';
import '../../manager/presentation/pin_entry_screen.dart';
import '../../settings/presentation/display_settings_screen.dart';
import 'my_photos_screen.dart';
import '../../../core/utils/role_utils.dart'; // Import RoleUtils
import '../../wallet/presentation/my_raffles_screen.dart'; // Import MyRafflesScreen
import '../../home/presentation/tournaments_screen.dart'; // Import TournamentsScreen

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
              // Extract values BEFORE the list
              final user = userAsync.value; // Safe
              final role = user?.role;
              final overrideRole = ref.watch(roleOverrideProvider);

              showModalBottomSheet(
                context: context,
                backgroundColor: const Color(0xFF1E1E1E),
                builder: (context) => SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                         // Manager Mode Switch (Conditional)
                         if (user != null && RoleUtils.canAccessDashboard(user))
                           ListTile(
                             leading: const Icon(Icons.admin_panel_settings, color: Colors.blueAccent),
                             title: const Text('Switch to Manager Mode', style: TextStyle(color: Colors.blueAccent)),
                             onTap: () {
                               Navigator.pop(context); // Close sheet
                               Navigator.push(context, MaterialPageRoute(builder: (_) => const PinEntryScreen()));
                             },
                           ),
                         

                         // Super Admin: View As
                         if (role == 'super-admin' || overrideRole != null) 
                           ExpansionTile(
                             leading: const Icon(Icons.visibility, color: Colors.purpleAccent),
                             title: Text(overrideRole != null ? 'Viewing as: $overrideRole' : 'View As...', style: const TextStyle(color: Colors.purpleAccent)),
                             children: [
                               _roleOption(context, ref, 'super-admin', 'Super Admin (Reset)'),
                               _roleOption(context, ref, 'owner', 'Owner'),
                               _roleOption(context, ref, 'admin', 'Admin'),
                               _roleOption(context, ref, 'manager', 'Manager'),
                               _roleOption(context, ref, 'worker', 'Worker'),
                               _roleOption(context, ref, 'player', 'Player'),
                             ],
                           ),
                         
                         ListTile(
                           leading: const Icon(Icons.settings_display, color: Colors.blueGrey),
                           title: const Text('Display Settings', style: TextStyle(color: Colors.white)),
                           onTap: () {
                             Navigator.pop(context); // Close sheet
                             Navigator.push(context, MaterialPageRoute(builder: (_) => const DisplaySettingsScreen()));
                           },
                         ),
                         ListTile(
                          leading: const Icon(Icons.logout, color: Colors.redAccent),
                          title: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
                          onTap: () {
                            Navigator.pop(context); // Close sheet
                            ref.read(authServiceProvider).signOut();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
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
                        "Gallery", 
                        Icons.photo_camera, 
                        Colors.pinkAccent,
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyPhotosScreen())),
                      ),
                      const SizedBox(width: 8),
                      _buildActionCard(
                        context, 
                        "Tournaments", 
                        Icons.emoji_events, 
                        Colors.purple,
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TournamentsScreen())),
                      ),
                      const SizedBox(width: 8),
                      _buildActionCard(
                        context, 
                        "Raffles", 
                        Icons.local_activity, 
                        Colors.orange,
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyRafflesScreen())),
                      ),
                    ],
                  ),
                
                const SizedBox(height: 24),

                // 3. Bio & Home Hall Card
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
                      // About Me Section
                      if (user.bio != null && user.bio!.isNotEmpty) ...[
                        const Text(
                          "About Me",
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const Divider(color: Colors.white24, height: 24),
                        Text(
                          user.bio!,
                          style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Home Hall Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Home Hall",
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          if (user.homeBaseId != null)
                            GestureDetector(
                              onTap: () {
                                ref.read(hallRepositoryProvider).toggleHomeBase(user.uid, user.homeBaseId!, user.homeBaseId);
                              },
                              child: const Text("UNSET", style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                      const Divider(color: Colors.white24, height: 24),
                      _HomeBaseDisplay(homeBaseId: user.homeBaseId),
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
                        subtitle: const Text('Sets You as Owner + Resets Data'),
                        trailing: const Icon(Icons.build, color: Colors.white54),
                        onTap: () async {
                           try {
                             final repo = ref.read(hallRepositoryProvider);
                             // 1. Reset Hall & User
                             await repo.seedMaryEstherEnv(user.uid);
                             // 2. Reset Raffles (Sync with Wallet)
                             await repo.seedRaffles('mary-esther-bingo');
                             // 3. Reset Wallet Data
                             await ref.read(walletRepositoryProvider).seedWalletData(user.uid);

                             if (context.mounted) {
                               ScaffoldMessenger.of(context).showSnackBar(
                                 const SnackBar(content: Text('Master Reset Complete! (User, Hall, Raffles, Wallet)')),
                               );
                             }
                           } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                              }
                           }
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
                      ListTile(
                        title: const Text('ADMIN: Seed Wallet Data', style: TextStyle(color: Colors.amber)),
                        trailing: const Icon(Icons.account_balance_wallet, color: Colors.white54),
                        onTap: () async {
                           try {
                             await ref.read(walletRepositoryProvider).seedWalletData(user.uid);
                             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wallet Data Seeded!')));
                           } catch (e) {
                             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                           }
                        },
                      ),
                      ListTile(
                        title: const Text('ADMIN: Promote to Super Admin', style: TextStyle(color: Colors.purpleAccent)),
                        subtitle: const Text('Grants full access without resetting data'),
                        trailing: const Icon(Icons.security, color: Colors.white54),
                        onTap: () async {
                           await ref.read(hallRepositoryProvider).promoteToSuperAdmin(user.uid);
                           if (context.mounted) {
                             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You are now a Super Admin!')));
                           }
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                
                // 5. Logout
                const SizedBox(height: 48),
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

  Widget _roleOption(BuildContext context, WidgetRef ref, String role, String label) {
    return ListTile(
      title: Text(label, style: const TextStyle(color: Colors.white70)),
      onTap: () {
        if (role == 'super-admin') {
          // Reset
          ref.read(roleOverrideProvider.notifier).state = null;
        } else {
          ref.read(roleOverrideProvider.notifier).state = role;
        }
        Navigator.pop(context); // Close sheet
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Now viewing as $label")));
      },
    );
  }
}

class _HomeBaseDisplay extends ConsumerWidget {
  final String? homeBaseId;

  const _HomeBaseDisplay({required this.homeBaseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (homeBaseId == null) {
      return const Text(
        "No Home Base Set",
        style: TextStyle(
          color: Colors.white38,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
      );
    }

    final hallAsync = ref.watch(hallStreamProvider(homeBaseId!));

    return hallAsync.when(
      data: (hall) {
        if (hall == null) {
          return const Text(
            "Unknown Hall",
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          );
        }
        return Text(
          hall.name,
          style: const TextStyle(
            color: Colors.blueAccent,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        );
      },
      loading: () => const SizedBox(
        width: 14,
        height: 14,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blueGrey),
      ),
      error: (_, __) => const Text(
        "Error loading hall",
        style: TextStyle(color: Colors.red, fontSize: 12),
      ),
    );
  }
}
