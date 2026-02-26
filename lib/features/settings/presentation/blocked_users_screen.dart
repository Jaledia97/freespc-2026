import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/auth_service.dart';
import '../../../models/public_profile.dart';

class BlockedUsersScreen extends ConsumerWidget {
  const BlockedUsersScreen({super.key});

  Future<void> _unblockUser(BuildContext context, WidgetRef ref, String currentUserId, String blockedUserId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(currentUserId).update({
        'blockedUsers': FieldValue.arrayRemove([blockedUserId])
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User unblocked')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to unblock user: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text('Blocked Accounts'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text("User not found", style: TextStyle(color: Colors.white)));
          }

          final blockedIds = user.blockedUsers;

          if (blockedIds.isEmpty) {
            return const Center(
              child: Text("You haven't blocked anyone.", style: TextStyle(color: Colors.white54, fontSize: 16)),
            );
          }

          return ListView.builder(
            itemCount: blockedIds.length,
            itemBuilder: (context, index) {
              final blockedUserId = blockedIds[index];
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('public_profiles').doc(blockedUserId).get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(
                      leading: CircularProgressIndicator(),
                      title: Text("Loading...", style: TextStyle(color: Colors.white54)),
                    );
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return ListTile(
                      leading: const CircleAvatar(backgroundColor: Colors.grey, child: Icon(Icons.person, color: Colors.white)),
                      title: const Text("Unknown User", style: TextStyle(color: Colors.white)),
                      trailing: TextButton(
                        onPressed: () => _unblockUser(context, ref, user.uid, blockedUserId),
                        child: const Text("Unblock", style: TextStyle(color: Colors.blueAccent)),
                      ),
                    );
                  }

                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  final profile = PublicProfile.fromJson({...data, 'uid': snapshot.data!.id});

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: profile.photoUrl != null ? NetworkImage(profile.photoUrl!) : null,
                      backgroundColor: Colors.grey,
                      child: profile.photoUrl == null ? const Icon(Icons.person, color: Colors.white) : null,
                    ),
                    title: Text(profile.username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: profile.realNameVisibility != 'Private' 
                        ? Text('${profile.firstName} ${profile.lastName}', style: const TextStyle(color: Colors.white70))
                        : null,
                    trailing: TextButton(
                      onPressed: () => _unblockUser(context, ref, user.uid, blockedUserId),
                      child: const Text("Unblock", style: TextStyle(color: Colors.blueAccent)),
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text("Error: $e", style: const TextStyle(color: Colors.red))),
      ),
    );
  }
}
