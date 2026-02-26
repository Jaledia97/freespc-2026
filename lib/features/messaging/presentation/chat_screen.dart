import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/auth_service.dart';
import '../repositories/messaging_repository.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/chat_model.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;
  final String chatName;

  const ChatScreen({super.key, required this.chatId, required this.chatName});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    final user = ref.read(userProfileProvider).value;
    if (user == null) return;

    setState(() => _isSending = true);

    try {
      await ref.read(messagingRepositoryProvider).sendMessage(widget.chatId, text, user.uid);
      _msgController.clear();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _renameGroupChat() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: const Text("Rename Group", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: "New Group Name",
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: const Color(0xFF1E1E1E),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                try {
                  await ref.read(messagingRepositoryProvider).renameGroupChat(widget.chatId, newName);
                  if (ctx.mounted) Navigator.pop(ctx);
                } catch (e) {
                  if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(String targetId, String targetType) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: Text("Report $targetType", style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          textCapitalization: TextCapitalization.sentences,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: "Reason for reporting...",
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: const Color(0xFF1E1E1E),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final reason = controller.text.trim();
              if (reason.isNotEmpty) {
                final user = ref.read(userProfileProvider).value;
                if (user != null) {
                  try {
                    await ref.read(messagingRepositoryProvider).submitReport(
                      reporterId: user.uid,
                      targetId: targetId,
                      targetType: targetType,
                      reason: reason,
                    );
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text("Report submitted successfully.")));
                    }
                  } catch (e) {
                    if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                }
              }
            },
            child: const Text("Submit", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmBlockUser(String otherUserId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: const Text("Block User", style: TextStyle(color: Colors.white)),
        content: const Text("Are you sure you want to block this user? You will no longer see their messages or be able to chat with them.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final user = ref.read(userProfileProvider).value;
              if (user != null) {
                try {
                  await ref.read(messagingRepositoryProvider).blockUser(user.uid, otherUserId);
                  if (ctx.mounted) {
                    Navigator.pop(ctx); // Close dialog
                    Navigator.pop(ctx); // Close chat screen natively if blocked
                  }
                } catch (e) {
                  if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
            },
            child: const Text("Block", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Only stream the last 50 messages to keep rendering fast
    final messagesStream = ref.watch(messagingRepositoryProvider).streamChatMessages(widget.chatId, limit: 50);
    final currentUser = ref.watch(userProfileProvider).value;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('chats').doc(widget.chatId).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Text(widget.chatName);
            }
            final chat = ChatModel.fromJson(snapshot.data!.data() as Map<String, dynamic>);
            return Text(chat.name ?? widget.chatName);
          }
        ),
        backgroundColor: const Color(0xFF252525),
        elevation: 0,
        actions: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('chats').doc(widget.chatId).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.exists) {
                 final chat = ChatModel.fromJson(snapshot.data!.data() as Map<String, dynamic>);
                 final isMuted = currentUser != null && chat.mutedBy.contains(currentUser.uid);
                 final isGroup = chat.isGroup;
                 
                 // If 1-on-1, find the other participant ID
                 String? otherUserId;
                 if (!isGroup && currentUser != null) {
                   otherUserId = chat.participantIds.firstWhere((id) => id != currentUser.uid, orElse: () => '');
                 }

                 return Row(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                     if (isGroup)
                       IconButton(
                         icon: const Icon(Icons.edit, color: Colors.blueAccent),
                         onPressed: _renameGroupChat,
                         tooltip: "Rename Group",
                       ),
                     PopupMenuButton<String>(
                       icon: const Icon(Icons.more_vert, color: Colors.white),
                       color: const Color(0xFF2C2C2C),
                       onSelected: (value) {
                         if (value == 'mute') {
                           if (currentUser != null) {
                             ref.read(messagingRepositoryProvider).toggleMuteChat(widget.chatId, currentUser.uid);
                           }
                         } else if (value == 'report_chat') {
                           _showReportDialog(widget.chatId, 'chat');
                         } else if (value == 'report_user' && otherUserId != null) {
                           _showReportDialog(otherUserId, 'user');
                         } else if (value == 'block_user' && otherUserId != null) {
                           _confirmBlockUser(otherUserId);
                         }
                       },
                       itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                         PopupMenuItem<String>(
                           value: 'mute',
                           child: Text(isMuted ? 'Unmute Chat' : 'Mute Chat', style: const TextStyle(color: Colors.white)),
                         ),
                         const PopupMenuItem<String>(
                           value: 'report_chat',
                           child: Text('Report Chat', style: TextStyle(color: Colors.redAccent)),
                         ),
                         if (!isGroup && otherUserId != null && otherUserId.isNotEmpty) ...[
                           const PopupMenuDivider(),
                           const PopupMenuItem<String>(
                             value: 'report_user',
                             child: Text('Report User', style: TextStyle(color: Colors.redAccent)),
                           ),
                           const PopupMenuItem<String>(
                             value: 'block_user',
                             child: Text('Block User', style: TextStyle(color: Colors.redAccent)),
                           ),
                         ],
                       ],
                     ),
                   ],
                 );
              }
              return const SizedBox.shrink();
            }
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: messagesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
                }

                final messages = snapshot.data ?? [];
                
                if (messages.isEmpty) {
                  return const Center(child: Text("Send a message to start the chat.", style: TextStyle(color: Colors.white54)));
                }

                return ListView.builder(
                  reverse: true, // Show newest at the bottom
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == currentUser?.uid;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blueAccent : const Color(0xFF333333),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                          )
                        ),
                        child: Text(msg.text, style: const TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          
          // Input Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 24), // Bottom padding for iOS SafeArea
            decoration: const BoxDecoration(
              color: Color(0xFF252525),
              border: Border(top: BorderSide(color: Colors.white12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    style: const TextStyle(color: Colors.white),
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: "Message...",
                      hintStyle: const TextStyle(color: Colors.white54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFF333333),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: _isSending 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blueAccent))
                    : const Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: _isSending ? null : _sendMessage,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
