
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/auth_service.dart';

class AccountSettingsScreen extends ConsumerWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text('Account Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Spacer(),
             const Text(
               "Danger Zone",
               style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
             ),
             const Divider(color: Colors.redAccent),
             ListTile(
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
      ),
    );
  }
}
