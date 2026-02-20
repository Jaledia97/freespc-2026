import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/auth_service.dart';
import '../repositories/messaging_repository.dart';
import 'chat_screen.dart';
import 'new_chat_screen.dart';

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

class MessagingHubScreen extends ConsumerStatefulWidget {
  const MessagingHubScreen({super.key});

  @override
  ConsumerState<MessagingHubScreen> createState() => _MessagingHubScreenState();
}

class _MessagingHubScreenState extends ConsumerState<MessagingHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text("Inbox"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blueAccent,
          tabs: const [
            Tab(text: "Messages"),
            Tab(text: "Notifications"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _MessagesTab(),
          _NotificationsTab(),
        ],
      ),
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

    return chatsAsync.when(
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

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blueGrey,
                child: Text(displayName.isNotEmpty ? displayName[0].toUpperCase() : "?", style: const TextStyle(color: Colors.white)),
              ),
              title: Text(displayName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text(
                chat.lastMessage, 
                maxLines: 1, 
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70)
              ),
              trailing: Text(
                _formatDate(chat.lastMessageAt),
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              onTap: () {
                 Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(chatId: chat.id, chatName: displayName)));
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text("Error: $e", style: const TextStyle(color: Colors.red))),
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

class _NotificationsTab extends ConsumerWidget {
  const _NotificationsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(userNotificationsProvider);

    return notesAsync.when(
      data: (notes) {
        if (notes.isEmpty) {
          return const Center(
            child: Text("No notifications.", style: TextStyle(color: Colors.white54)),
          );
        }

        return ListView.builder(
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index];
            return ListTile(
              leading: const Icon(Icons.notifications, color: Colors.blueAccent),
              title: Text(note.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text(note.body, style: const TextStyle(color: Colors.white70)),
              trailing: note.isRead ? null : const Icon(Icons.circle, color: Colors.redAccent, size: 10),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text("Error: $e", style: const TextStyle(color: Colors.red))),
    );
  }
}
