import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/auth_service.dart';
import '../repositories/messaging_repository.dart';

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

  @override
  Widget build(BuildContext context) {
    // Only stream the last 50 messages to keep rendering fast
    final messagesStream = ref.watch(messagingRepositoryProvider).streamChatMessages(widget.chatId, limit: 50);
    final currentUser = ref.watch(userProfileProvider).value;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: Text(widget.chatName),
        backgroundColor: const Color(0xFF252525),
        elevation: 0,
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
