import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../services/auth_service.dart';
import '../../../models/chat_model.dart';
import '../repositories/messaging_repository.dart';
import '../../friends/presentation/friends_screen.dart'; // To get friends list

class GroupSettingsScreen extends ConsumerStatefulWidget {
  final ChatModel chat;

  const GroupSettingsScreen({super.key, required this.chat});

  @override
  ConsumerState<GroupSettingsScreen> createState() => _GroupSettingsScreenState();
}

class _GroupSettingsScreenState extends ConsumerState<GroupSettingsScreen> {
  Future<void> _showInviteDialog() async {
    final friendsAsync = ref.read(friendsProfilesProvider);

    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return friendsAsync.when(
          data: (friends) {
            // Filter out friends who are already in the chat or already pending
            final availableFriends = friends.where((f) => 
              !widget.chat.participantIds.contains(f.uid) && 
              !widget.chat.pendingParticipantIds.contains(f.uid)
            ).toList();

            if (availableFriends.isEmpty) {
              return const SizedBox(
                height: 200,
                child: Center(child: Text("No more friends available to invite.", style: TextStyle(color: Colors.white54))),
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Invite Friends", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const Divider(color: Colors.white24),
                  Expanded(
                    child: ListView.builder(
                      itemCount: availableFriends.length,
                      itemBuilder: (context, index) {
                        final friend = availableFriends[index];
                        return ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.person)),
                          title: Text(friend.username, style: const TextStyle(color: Colors.white)),
                          trailing: const Icon(Icons.add_circle, color: Colors.blueAccent),
                          onTap: () async {
                            Navigator.pop(ctx);
                            try {
                              final currentUser = ref.read(userProfileProvider).value;
                              if (currentUser != null) {
                                await ref.read(messagingRepositoryProvider).inviteToGroupChat(
                                  widget.chat.id, 
                                  currentUser.uid, 
                                  friend.uid, 
                                  friend.username
                                );
                                if (context.mounted) {
                                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invite sent!"), backgroundColor: Colors.green));
                                }
                              }
                            } catch (e) {
                              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
          error: (e, st) => SizedBox(height: 200, child: Center(child: Text("Error: $e", style: const TextStyle(color: Colors.red)))),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.watch(userProfileProvider).value?.uid;
    final isOwner = widget.chat.ownerId == currentUserId;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text("Group Settings"),
        backgroundColor: const Color(0xFF252525),
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('chats').doc(widget.chat.id).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }

          final liveChat = ChatModel.fromJson(snapshot.data!.data() as Map<String, dynamic>);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header
              Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.blueGrey,
                      child: Icon(Icons.group, size: 40, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(liveChat.name ?? "Group Chat", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    Text("${liveChat.participantIds.length} Members", style: const TextStyle(color: Colors.white54, fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Actions
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent.withValues(alpha: 0.1),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.person_add, color: Colors.blueAccent),
                  label: const Text("Invite Friends", style: TextStyle(color: Colors.blueAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                  onPressed: _showInviteDialog,
                ),
              ),

              const SizedBox(height: 32),

              // Pending Approvals (Only visible to Owner)
              if (isOwner && liveChat.pendingParticipantIds.isNotEmpty) ...[
                const Text("Pending Approvals", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(color: const Color(0xFF2C2C2C), borderRadius: BorderRadius.circular(12)),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: liveChat.pendingParticipantIds.length,
                    separatorBuilder: (_, __) => const Divider(color: Colors.white12, height: 1),
                    itemBuilder: (context, index) {
                      final uid = liveChat.pendingParticipantIds[index];
                      final name = liveChat.participantNames[uid] ?? "Unknown User";
                      
                      return ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.hourglass_empty, color: Colors.amber)),
                        title: Text(name, style: const TextStyle(color: Colors.white)),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          onPressed: () async {
                             await ref.read(messagingRepositoryProvider).approveGroupInvite(liveChat.id, uid, name);
                          },
                          child: const Text("Approve", style: TextStyle(color: Colors.white)),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Members List
              const Text("Members", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(color: const Color(0xFF2C2C2C), borderRadius: BorderRadius.circular(12)),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: liveChat.participantIds.length,
                  separatorBuilder: (_, __) => const Divider(color: Colors.white12, height: 1),
                  itemBuilder: (context, index) {
                    final uid = liveChat.participantIds[index];
                    final name = liveChat.participantNames[uid] ?? "Unknown User";
                    final isMemberOwner = liveChat.ownerId == uid;

                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(name, style: const TextStyle(color: Colors.white)),
                      trailing: isMemberOwner 
                        ? const Chip(label: Text("Owner", style: TextStyle(color: Colors.white, fontSize: 10)), backgroundColor: Colors.blueAccent)
                        : null,
                    );
                  },
                ),
              ),
            ],
          );
        }
      )
    );
  }
}
