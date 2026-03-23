import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../services/auth_service.dart';
import '../../friends/presentation/friends_screen.dart';
import '../repositories/messaging_repository.dart';
import 'chat_screen.dart';
import 'new_chat_screen.dart';
import '../../notifications/presentation/notifications_screen.dart';

final userChatsProvider = StreamProvider((ref) {
  final user = ref.watch(userProfileProvider).value;
  if (user == null) return const Stream.empty();
  return ref.watch(messagingRepositoryProvider).streamUserChats(user.uid);
});

final userNotificationsProvider = StreamProvider((ref) {
  final user = ref.watch(userProfileProvider).value;
  if (user == null) return const Stream.empty();
  return ref.watch(messagingRepositoryProvider).streamNotifications(user.uid);
});

class MessagingHubScreen extends ConsumerWidget {
  const MessagingHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text("Messages"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const _MessagesTab(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const NewChatScreen()));
        },
      ),
    );
  }
}

class _MessagesTab extends ConsumerWidget {
  const _MessagesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatsAsync = ref.watch(userChatsProvider);
    final friendsAsync = ref.watch(friendsProfilesProvider);

    return Column(
      children: [
        // 1. Active Friends Row
        Container(
          height: 100, // Fixed height for the row
          alignment: Alignment.centerLeft,
          child: friendsAsync.when(
            data: (friends) {
              if (friends.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Center(child: Text("Add friends to easily message them here", style: TextStyle(color: Colors.white54, fontSize: 13))),
                );
              }
              
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                itemCount: friends.length,
                itemBuilder: (context, index) {
                  final friend = friends[index];
                  // Check online status
                  Color statusColor = Colors.grey;
                  if (friend.onlineStatus == 'Online') statusColor = Colors.green;
                  if (friend.onlineStatus == 'Away') statusColor = Colors.amber;
                  
                  return GestureDetector(
                    onTap: () async {
                      try {
                        final currentUser = ref.read(userProfileProvider).value;
                        if (currentUser == null) return;
                        
                        // Intelligent resolution: create or route
                        final chat = await ref.read(messagingRepositoryProvider).createChat(
                          [currentUser.uid, friend.uid],
                          {
                            currentUser.uid: currentUser.username,
                            friend.uid: friend.username,
                          }
                        );
                        
                        if (context.mounted) {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (_) => ChatScreen(chatId: chat.id, chatName: friend.username)
                          ));
                        }
                      } catch (e) {
                         if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            children: [
                               CircleAvatar(
                                radius: 26,
                                backgroundColor: const Color(0xFF333333),
                                backgroundImage: friend.photoUrl != null ? CachedNetworkImageProvider(friend.photoUrl!) : null,
                                child: friend.photoUrl == null ? const Icon(Icons.person, color: Colors.white54) : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 14, height: 14,
                                  decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle, border: Border.all(color: const Color(0xFF1E1E1E), width: 2)),
                                )
                              )
                            ]
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 60,
                            child: Text(
                              friend.username,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontSize: 11),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text("Error: $e", style: const TextStyle(color: Colors.red))),
          ),
        ),

        // Divider
        const Divider(color: Colors.white12, height: 1),

        // 2. Chat List
        Expanded(
          child: chatsAsync.when(
            data: (chats) {
              if (chats.isEmpty) {
                return const Center(
                  child: Text("No messages yet.", style: TextStyle(color: Colors.white54)),
                );
              }

              return ListView.builder(
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  final currentUserId = ref.read(userProfileProvider).value?.uid;
                  
                  // Derive display name (if 1-on-1, show other person's name)
                  String displayName = chat.name ?? "Group Chat";
                  if (!chat.isGroup && chat.name == null) {
                    final otherUserId = chat.participantIds.firstWhere((id) => id != currentUserId, orElse: () => "");
                    displayName = chat.participantNames[otherUserId] ?? "Unknown User";
                  }

                  final unreadCount = chat.unreadCounts[currentUserId] ?? 0;
                  final hasUnread = unreadCount > 0;

                  return Dismissible(
                    key: ValueKey(chat.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20.0),
                      color: Colors.redAccent,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      ref.read(messagingRepositoryProvider).hideChat(chat.id, currentUserId!);
                    },
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.blueGrey,
                        child: Text(displayName.isNotEmpty ? displayName[0].toUpperCase() : "?", style: const TextStyle(color: Colors.white, fontSize: 20)),
                      ),
                      title: Text(displayName, style: TextStyle(color: Colors.white, fontWeight: hasUnread ? FontWeight.w900 : FontWeight.bold, fontSize: 16)),
                      subtitle: Text(
                        chat.lastMessage, 
                        maxLines: 1, 
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: hasUnread ? Colors.white : Colors.white54, fontSize: 14, fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal)
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatDate(chat.lastMessageAt),
                            style: TextStyle(color: hasUnread ? Colors.blueAccent : Colors.white38, fontSize: 12, fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal),
                          ),
                          if (hasUnread) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
                              child: Text(unreadCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            )
                          ]
                        ],
                      ),
                      onTap: () {
                         ref.read(messagingRepositoryProvider).markChatAsRead(chat.id, currentUserId!);
                         Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(chatId: chat.id, chatName: displayName)));
                      },
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text("Error: $e", style: const TextStyle(color: Colors.red))),
          ),
        ),
      ],
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    }
    return "${date.month}/${date.day}";
  }
}
