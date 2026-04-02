import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';
import 'blocked_users_screen.dart';
import 'hidden_posts_screen.dart';
import '../../../services/auth_service.dart';

class PrivacySettingsScreen extends ConsumerWidget {
  const PrivacySettingsScreen({super.key});

  @override
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Privacy & Safety',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Vibration.vibrate(duration: 40);
            Navigator.pop(context);
          },
        ),
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text("User not found", style: TextStyle(color: Colors.white)));
          }
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            children: [
              _buildDropdownTile(
                icon: Icons.badge,
                title: 'Real Name Visibility',
                subtitle: 'Who can see your real name.',
                value: user.realNameVisibility,
                items: const [
                  DropdownMenuItem(value: 'Private', child: Text('Private', style: TextStyle(color: Colors.grey))),
                  DropdownMenuItem(value: 'Friends Only', child: Text('Friends Only', style: TextStyle(color: Colors.amber))),
                  DropdownMenuItem(value: 'Everyone', child: Text('Everyone', style: TextStyle(color: Colors.green))),
                ],
                onChanged: (val) {
                  if (val != null) {
                    ref.read(authServiceProvider).updateUserProfile(user.uid, realNameVisibility: val);
                  }
                },
              ),
              const SizedBox(height: 12),
              _buildDropdownTile(
                icon: Icons.online_prediction,
                title: 'Online Status',
                subtitle: 'How others see your current status.',
                value: user.onlineStatus,
                items: const [
                  DropdownMenuItem(value: 'Online', child: Text('Online', style: TextStyle(color: Colors.green))),
                  DropdownMenuItem(value: 'Away', child: Text('Away', style: TextStyle(color: Colors.amber))),
                  DropdownMenuItem(value: 'Offline', child: Text('Offline', style: TextStyle(color: Colors.grey))),
                ],
                onChanged: (val) {
                  if (val != null) {
                    ref.read(authServiceProvider).updateUserProfile(user.uid, onlineStatus: val);
                  }
                },
              ),
              const SizedBox(height: 12),
              _buildPrivacyTile(
                context,
                icon: Icons.block,
                title: 'Blocked Users & Halls',
                subtitle: 'Manage the accounts you have blocked.',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BlockedUsersScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildPrivacyTile(
                context,
                icon: Icons.visibility_off,
                title: 'Hidden Posts',
                subtitle: 'Manage the specific posts you have hidden.',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HiddenPostsScreen()),
                  );
                },
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text("Error: $e", style: const TextStyle(color: Colors.red))),
      ),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Icon(icon, color: Colors.white70, size: 28),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.white54, fontSize: 13),
        ),
        trailing: DropdownButton<String>(
          value: value,
          dropdownColor: const Color(0xFF2C2C2C),
          style: const TextStyle(color: Colors.white),
          underline: const SizedBox(),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildPrivacyTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: ListTile(
        onTap: () {
          Vibration.vibrate(duration: 40);
          onTap();
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Icon(icon, color: Colors.white70, size: 28),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.white54, fontSize: 13),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
      ),
    );
  }
}
