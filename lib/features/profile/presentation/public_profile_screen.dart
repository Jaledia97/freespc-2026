import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freespc/models/public_profile.dart';
import 'package:freespc/models/friendship_model.dart';
import 'package:freespc/features/friends/repositories/friends_repository.dart';
import 'package:freespc/services/auth_service.dart';

class PublicProfileScreen extends ConsumerWidget {
  final PublicProfile profile;

  const PublicProfileScreen({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: Text(profile.username),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: userAsync.when(
        data: (currentUser) {
          if (currentUser == null) {
            return const Center(child: Text("Not authenticated", style: TextStyle(color: Colors.white)));
          }
          
          final isSelf = currentUser.uid == profile.uid;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Avatar
                CircleAvatar(
                  radius: 60,
                  backgroundImage: profile.photoUrl != null ? NetworkImage(profile.photoUrl!) : null,
                  child: profile.photoUrl == null ? const Icon(Icons.person, size: 60) : null,
                ),
                const SizedBox(height: 16),
                
                // Name
                if (profile.realNameVisibility == 'Everyone')
                  Text(
                    "\${profile.firstName} \${profile.lastName}",
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  )
                else
                  Text(
                    "@${profile.username}",
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),

                // Username (if name was shown)
                if (profile.realNameVisibility == 'Everyone')
                  Text(
                    "@${profile.username}",
                    style: const TextStyle(color: Colors.white54, fontSize: 16),
                  ),

                const SizedBox(height: 24),

                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCol("Points", profile.points.toString()),
                    _buildStatCol("Status", profile.onlineStatus, color: profile.onlineStatus == 'Online' ? Colors.greenAccent : Colors.white54),
                  ],
                ),

                const SizedBox(height: 32),

                // Bio Section
                if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Bio", style: TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(profile.bio!, style: const TextStyle(color: Colors.white, fontSize: 16)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                // Action Button (Not self)
                if (!isSelf)
                  _FriendshipActionButton(currentUserId: currentUser.uid, targetUser: profile),

              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text("Error: \$e", style: const TextStyle(color: Colors.red))),
      ),
    );
  }

  Widget _buildStatCol(String label, String value, {Color color = Colors.white}) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 14)),
      ],
    );
  }
}

class _FriendshipActionButton extends ConsumerWidget {
  final String currentUserId;
  final PublicProfile targetUser;

  const _FriendshipActionButton({
    required this.currentUserId,
    required this.targetUser,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We stream the friends collection to see the current status
    final friendsStream = ref.watch(friendsStreamProvider(currentUserId));

    return friendsStream.when(
      data: (friendsList) {
        // Find if this user is in our friends list
        final friendRecord = friendsList.where((f) => f.user2Id == targetUser.uid || f.user1Id == targetUser.uid).firstOrNull;

        if (friendRecord == null) {
          // Not friends, no request sent
          return SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.person_add, color: Colors.white),
              label: const Text("Add Friend", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              onPressed: () async {
                try {
                  await ref.read(friendsRepositoryProvider).sendFriendRequest(currentUserId, targetUser.uid);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Request sent to @\${targetUser.username}!"), backgroundColor: Colors.green));
                  }
                } catch (e) {
                  if (context.mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: \$e"), backgroundColor: Colors.red));
                  }
                }
              },
            ),
          );
        } else if (friendRecord.status == 'sent') {
          // Request is pending (sent by us)
          return SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.hourglass_empty, color: Colors.white54),
              label: const Text("Cancel Pending Request", style: TextStyle(color: Colors.white54, fontSize: 16, fontWeight: FontWeight.bold)),
              onPressed: () async {
                 // Confirm dialog
                 final confirm = await showDialog<bool>(
                   context: context,
                   builder: (context) => AlertDialog(
                     backgroundColor: const Color(0xFF2C2C2C),
                     title: const Text("Cancel Friend Request?", style: TextStyle(color: Colors.white)),
                     content: Text("Are you sure you want to cancel the friend request to @\${targetUser.username}?", style: const TextStyle(color: Colors.white70)),
                     actions: [
                       TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("No")),
                       TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Yes, Cancel", style: TextStyle(color: Colors.redAccent))),
                     ],
                   )
                 );
                 
                 if (confirm == true) {
                   await ref.read(friendsRepositoryProvider).removeFriend(currentUserId, targetUser.uid);
                   if (context.mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Friend request canceled."), backgroundColor: Colors.white30));
                   }
                 }
              },
            ),
          );
        } else if (friendRecord.status == 'received') {
          // Request received from them
          return Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.check, color: Colors.black87),
                    label: const Text("Accept", style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
                    onPressed: () async {
                      try {
                        await ref.read(friendsRepositoryProvider).acceptFriendRequest(currentUserId, targetUser.uid);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("You are now friends with @\${targetUser.username}!"), backgroundColor: Colors.green));
                        }
                      } catch (e) {
                         if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: \$e"), backgroundColor: Colors.red));
                         }
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.close, color: Colors.redAccent),
                    label: const Text("Decline", style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                    onPressed: () async {
                       await ref.read(friendsRepositoryProvider).removeFriend(currentUserId, targetUser.uid);
                       if (context.mounted) {
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Friend request declined."), backgroundColor: Colors.white30));
                       }
                    },
                  ),
                ),
              ),
            ],
          );
        } else {
          // Already friends
          return SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.person_remove, color: Colors.redAccent),
              label: const Text("Remove Friend", style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
              onPressed: () async {
                 // Confirm dialog
                 final confirm = await showDialog<bool>(
                   context: context,
                   builder: (context) => AlertDialog(
                     backgroundColor: const Color(0xFF2C2C2C),
                     title: const Text("Remove Friend?", style: TextStyle(color: Colors.white)),
                     content: Text("Are you sure you want to remove @\${targetUser.username}?", style: const TextStyle(color: Colors.white70)),
                     actions: [
                       TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                       TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Remove", style: TextStyle(color: Colors.redAccent))),
                     ],
                   )
                 );
                 
                 if (confirm == true) {
                   await ref.read(friendsRepositoryProvider).removeFriend(currentUserId, targetUser.uid);
                 }
              },
            ),
          );
        }
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Text("Error checking friend status: \$e", style: const TextStyle(color: Colors.red)),
    );
  }
}
