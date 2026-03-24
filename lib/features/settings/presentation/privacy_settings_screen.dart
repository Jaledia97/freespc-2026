import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'blocked_users_screen.dart';
import 'hidden_posts_screen.dart';

class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
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
