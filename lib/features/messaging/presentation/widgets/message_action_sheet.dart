import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/message_model.dart';
import '../../repositories/messaging_repository.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../services/auth_service.dart';

class MessageActionSheet extends ConsumerWidget {
  final MessageModel message;
  final bool isMe;

  const MessageActionSheet({
    super.key,
    required this.message,
    required this.isMe,
  });

  static Future<void> show({
    required BuildContext context,
    required MessageModel message,
    required bool isMe,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => MessageActionSheet(message: message, isMe: isMe),
    );
  }

  void _react(BuildContext context, WidgetRef ref, String emoji) {
    final currentUserId = ref.read(userProfileProvider).value?.uid;
    if (currentUserId == null) return;
    
    ref.read(messagingRepositoryProvider).reactToMessage(
          message.chatId,
          message.id,
          emoji,
          currentUserId,
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.watch(userProfileProvider).value?.uid;
    final emojis = ['👍', '❤️', '😂', '😮', '😢', '🙏'];

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Reaction Row
          GlassContainer(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            borderRadius: BorderRadius.circular(24),
            blur: 10,
            opacity: 0.1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: emojis.map((emoji) {
                return GestureDetector(
                  onTap: () => _react(context, ref, emoji),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Actions
          ListTile(
            leading: const Icon(Icons.visibility_off, color: Colors.white70),
            title: const Text("Delete for Me", style: TextStyle(color: Colors.white)),
            onTap: () {
              if (currentUserId != null) {
                ref.read(messagingRepositoryProvider).deleteMessageLocally(
                      message.chatId,
                      message.id,
                      currentUserId,
                    );
              }
              Navigator.pop(context);
            },
          ),
          
          if (isMe)
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
              title: const Text("Unsend (Delete for Everyone)", style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                ref.read(messagingRepositoryProvider).unsendMessage(
                      message.chatId,
                      message.id,
                    );
                Navigator.pop(context);
              },
            ),
        ],
      ),
    );
  }
}
