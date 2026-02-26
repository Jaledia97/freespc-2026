
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/auth_service.dart';
import 'blocked_users_screen.dart';

class AccountSettingsScreen extends ConsumerWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text('Account Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text("User not found", style: TextStyle(color: Colors.white)));
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Privacy", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                const Divider(color: Colors.blueAccent),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Real Name Visibility', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('Who can see your real name.', style: TextStyle(color: Colors.white38, fontSize: 12)),
                  trailing: DropdownButton<String>(
                    value: user.realNameVisibility,
                    dropdownColor: const Color(0xFF2C2C2C),
                    style: const TextStyle(color: Colors.white),
                    underline: const SizedBox(),
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
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Blocked Accounts', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('Manage users you have blocked.', style: TextStyle(color: Colors.white38, fontSize: 12)),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const BlockedUsersScreen()));
                  },
                ),
                const SizedBox(height: 24),
                
                const Text("Presence", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                const Divider(color: Colors.greenAccent),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Online Status', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('How others see your current status.', style: TextStyle(color: Colors.white38, fontSize: 12)),
                  trailing: DropdownButton<String>(
                    value: user.onlineStatus,
                    dropdownColor: const Color(0xFF2C2C2C),
                    style: const TextStyle(color: Colors.white),
                    underline: const SizedBox(),
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
                ),
                const SizedBox(height: 48),

                 const Text(
               "Danger Zone",
               style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
             ),
             const Divider(color: Colors.redAccent),
             ListTile(
               contentPadding: EdgeInsets.zero,
               title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
               subtitle: const Text('Permanently remove your data. This cannot be undone.', style: TextStyle(color: Colors.white38, fontSize: 12)),
               leading: const Icon(Icons.delete_forever, color: Colors.red),
               onTap: () async {
                 final confirm = await showDialog<bool>(
                   context: context,
                   builder: (context) => AlertDialog(
                     backgroundColor: const Color(0xFF2C2C2C),
                     title: const Text("Delete Account?", style: TextStyle(color: Colors.white)),
                     content: const Text(
                       "Are you sure? This will permanently delete your profile, wallet balance, and membership data. This action cannot be undone.",
                       style: TextStyle(color: Colors.white70),
                     ),
                     actions: [
                       TextButton(
                         onPressed: () => Navigator.pop(context, false),
                         child: const Text("Cancel"),
                       ),
                       ElevatedButton(
                         style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                         onPressed: () => Navigator.pop(context, true),
                         child: const Text("DELETE PERMANENTLY"),
                       ),
                     ],
                   ),
                 );

                 if (confirm == true) {
                   try {
                     await ref.read(authServiceProvider).deleteAccount();
                     if (context.mounted) {
                       Navigator.pop(context); // Close Settings
                       // AuthWrapper will handle redirect to Login
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Account Deleted.")));
                     }
                   } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                      }
                   }
                 }
               },
             ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text("Error: $e", style: const TextStyle(color: Colors.red))),
      ),
    );
  }
}
