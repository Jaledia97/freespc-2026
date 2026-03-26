import 'dart:async'; // ensure dart:async is imported
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

import '../../../services/auth_service.dart';
import '../repositories/messaging_repository.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/chat_model.dart';
import '../../../models/message_model.dart'; // Ensure message model is imported
import 'group_settings_screen.dart';
import 'package:vibration/vibration.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;
  final String chatName;

  const ChatScreen({super.key, required this.chatId, required this.chatName});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final FocusNode _msgFocusNode = FocusNode();
  bool _isSending = false;
  String?
  _lastSeenMessageId; // Hook to rigidly track stream yields against array limitations

  // Tracking the message we are actively replying to
  MessageModel? _replyToMessage;
  String? _replyToSenderName;

  // Typing state management
  Timer? _typingTimer;
  bool _isTypingLocally = false;

  // Reading state management
  StreamSubscription<DocumentSnapshot>? _chatSub;

  @override
  void initState() {
    super.initState();
    // Subscribes to the chat to instantly mark new messages as read while we're in the screen
    _chatSub = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .snapshots()
        .listen((snap) {
          if (snap.exists && mounted) {
            final chat = ChatModel.fromJson(
              snap.data() as Map<String, dynamic>,
            );
            final user = ref.read(userProfileProvider).value;
            if (user != null && (chat.unreadCounts[user.uid] ?? 0) > 0) {
              ref
                  .read(messagingRepositoryProvider)
                  .markChatAsRead(widget.chatId, user.uid);
            }
          }
        });
  }

  @override
  void dispose() {
    _chatSub?.cancel();
    _typingTimer?.cancel();
    _msgController.dispose();
    _msgFocusNode.dispose();
    super.dispose();
  }

  void _onReplySwipe(MessageModel message, String senderName) {
    setState(() {
      _replyToMessage = message;
      _replyToSenderName = senderName;
    });
    // Request focus on the text field after swiping to let the user type immediately
    _msgFocusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyToMessage = null;
      _replyToSenderName = null;
    });
  }

  void _onTextChanged(String text) {
    if (text.isEmpty) {
      _stopTyping();
      return;
    }

    if (!_isTypingLocally) {
      _startTyping();
    }

    // Reset the debounce timer
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), _stopTyping);
  }

  Future<void> _startTyping() async {
    _isTypingLocally = true;
    final user = ref.read(userProfileProvider).value;
    if (user != null) {
      await ref
          .read(messagingRepositoryProvider)
          .setTypingStatus(widget.chatId, user.uid, true);
    }
  }

  Future<void> _stopTyping() async {
    if (!_isTypingLocally) return;
    _isTypingLocally = false;
    final user = ref.read(userProfileProvider).value;
    if (user != null) {
      await ref
          .read(messagingRepositoryProvider)
          .setTypingStatus(widget.chatId, user.uid, false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    _typingTimer?.cancel();
    _stopTyping();

    final user = ref.read(userProfileProvider).value;
    if (user == null) return;

    setState(() => _isSending = true);

    try {
      await ref
          .read(messagingRepositoryProvider)
          .sendMessage(
            widget.chatId,
            text,
            user.uid,
            replyToMessageId: _replyToMessage?.id,
            replyToText: _replyToMessage?.text,
            replyToSenderName: _replyToSenderName,
          );
      _msgController.clear();
      _cancelReply();
      Vibration.vibrate(duration: 40);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
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
        title: const Text(
          "Rename Group",
          style: TextStyle(color: Colors.white),
        ),
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
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                try {
                  await ref
                      .read(messagingRepositoryProvider)
                      .renameGroupChat(widget.chatId, newName);
                  if (ctx.mounted) Navigator.pop(ctx);
                } catch (e) {
                  if (ctx.mounted)
                    ScaffoldMessenger.of(
                      ctx,
                    ).showSnackBar(SnackBar(content: Text(e.toString())));
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
        title: Text(
          "Report $targetType",
          style: const TextStyle(color: Colors.white),
        ),
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
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final reason = controller.text.trim();
              if (reason.isNotEmpty) {
                final user = ref.read(userProfileProvider).value;
                if (user != null) {
                  try {
                    await ref
                        .read(messagingRepositoryProvider)
                        .submitReport(
                          reporterId: user.uid,
                          targetId: targetId,
                          targetType: targetType,
                          reason: reason,
                        );
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(
                          content: Text("Report submitted successfully."),
                        ),
                      );
                    }
                  } catch (e) {
                    if (ctx.mounted)
                      ScaffoldMessenger.of(
                        ctx,
                      ).showSnackBar(SnackBar(content: Text(e.toString())));
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
        content: const Text(
          "Are you sure you want to block this user? You will no longer see their messages or be able to chat with them.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final user = ref.read(userProfileProvider).value;
              if (user != null) {
                try {
                  await ref
                      .read(messagingRepositoryProvider)
                      .blockUser(user.uid, otherUserId);
                  if (ctx.mounted) {
                    Navigator.pop(ctx); // Close dialog
                    Navigator.pop(ctx); // Close chat screen natively if blocked
                  }
                } catch (e) {
                  if (ctx.mounted)
                    ScaffoldMessenger.of(
                      ctx,
                    ).showSnackBar(SnackBar(content: Text(e.toString())));
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
    final messagesStream = ref
        .watch(messagingRepositoryProvider)
        .streamChatMessages(widget.chatId, limit: 50);
    final currentUser = ref.watch(userProfileProvider).value;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('chats')
              .doc(widget.chatId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Text(widget.chatName);
            }
            final chat = ChatModel.fromJson(
              snapshot.data!.data() as Map<String, dynamic>,
            );
            return Text(chat.name ?? widget.chatName);
          },
        ),
        backgroundColor: const Color(0xFF252525),
        elevation: 0,
        actions: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('chats')
                .doc(widget.chatId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.exists) {
                final chat = ChatModel.fromJson(
                  snapshot.data!.data() as Map<String, dynamic>,
                );
                final isMuted =
                    currentUser != null &&
                    chat.mutedBy.contains(currentUser.uid);
                final isGroup = chat.isGroup;

                // If 1-on-1, find the other participant ID
                String? otherUserId;
                if (!isGroup && currentUser != null) {
                  otherUserId = chat.participantIds.firstWhere(
                    (id) => id != currentUser.uid,
                    orElse: () => '',
                  );
                }

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isGroup)
                      IconButton(
                        icon: const Icon(Icons.group, color: Colors.blueAccent),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GroupSettingsScreen(chat: chat),
                            ),
                          );
                        },
                        tooltip: "Group Settings",
                      ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      color: const Color(0xFF2C2C2C),
                      onSelected: (value) {
                        if (value == 'mute') {
                          if (currentUser != null) {
                            ref
                                .read(messagingRepositoryProvider)
                                .toggleMuteChat(widget.chatId, currentUser.uid);
                          }
                        } else if (value == 'report_chat') {
                          _showReportDialog(widget.chatId, 'chat');
                        } else if (value == 'report_user' &&
                            otherUserId != null) {
                          _showReportDialog(otherUserId, 'user');
                        } else if (value == 'block_user' &&
                            otherUserId != null) {
                          _confirmBlockUser(otherUserId);
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                            PopupMenuItem<String>(
                              value: 'mute',
                              child: Text(
                                isMuted ? 'Unmute Chat' : 'Mute Chat',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'report_chat',
                              child: Text(
                                'Report Chat',
                                style: TextStyle(color: Colors.redAccent),
                              ),
                            ),
                            if (!isGroup &&
                                otherUserId != null &&
                                otherUserId.isNotEmpty) ...[
                              const PopupMenuDivider(),
                              const PopupMenuItem<String>(
                                value: 'report_user',
                                child: Text(
                                  'Report User',
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                              ),
                              const PopupMenuItem<String>(
                                value: 'block_user',
                                child: Text(
                                  'Block User',
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                              ),
                            ],
                          ],
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .doc(widget.chatId)
            .snapshots(),
        builder: (context, chatSnapshot) {
          final chat = chatSnapshot.hasData && chatSnapshot.data!.exists
              ? ChatModel.fromJson(
                  chatSnapshot.data!.data() as Map<String, dynamic>,
                )
              : null;

          return Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: messagesStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Error: ${snapshot.error}",
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    List<MessageModel> messages = snapshot.data ?? [];

                    if (chat != null &&
                        currentUser != null &&
                        chat.clearedAt.containsKey(currentUser.uid)) {
                      final clearedAtLimit = DateTime.parse(
                        chat.clearedAt[currentUser.uid]!,
                      );
                      messages = messages
                          .where((m) => m.createdAt.isAfter(clearedAtLimit))
                          .toList();
                    }

                    // Background Haptic hook triggers when foreign messages push the array
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (messages.isNotEmpty) {
                        final latestMessage = messages.first;

                        // If we haven't tracked anything yet, initialize the anchor
                        if (_lastSeenMessageId == null) {
                          if (mounted) _lastSeenMessageId = latestMessage.id;
                          return;
                        }

                        // If a new payload arrives beyond our active anchor
                        if (_lastSeenMessageId != latestMessage.id) {
                          if (latestMessage.senderId != currentUser?.uid) {
                            Vibration.vibrate(duration: 40);
                          }
                          if (mounted) _lastSeenMessageId = latestMessage.id;
                        }
                      }
                    });

                    if (messages.isEmpty) {
                      return const Center(
                        child: Text(
                          "Send a message to start the chat.",
                          style: TextStyle(color: Colors.white54),
                        ),
                      );
                    }

                    return ListView.builder(
                      reverse: true, // Show newest at the bottom
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isMe = msg.senderId == currentUser?.uid;

                        final bool isSameAsNext =
                            index < messages.length - 1 &&
                            messages[index + 1].senderId == msg.senderId;
                        final bool isSameAsPrev =
                            index > 0 &&
                            messages[index - 1].senderId == msg.senderId;

                        final senderName =
                            (isMe
                                ? currentUser?.firstName
                                : chat?.participantNames[msg.senderId]) ??
                            'Unknown';

                        // We need to compare this message with the chronologically older message.
                        // Since `reverse: true`, the chronologically older message is at `index + 1`.
                        bool showTimestampHeader = false;
                        if (index == messages.length - 1) {
                          // Very first message ever sent in the chat
                          showTimestampHeader = true;
                        } else {
                          final olderMsg = messages[index + 1];
                          final difference = msg.createdAt
                              .difference(olderMsg.createdAt)
                              .inMinutes;
                          // Show header if more than 60 minutes passed between the last message and this one
                          if (difference > 60 ||
                              msg.createdAt.day != olderMsg.createdAt.day) {
                            showTimestampHeader = true;
                          }
                        }

                        // Determine if we should show the avatar.
                        // We show it if it's the last message in a block (no same sender AFTER it chronologically).
                        // Since the list is reversed, chronologically "after" is `index - 1`.
                        // We also force showing the avatar if the NEXT message (chronologically) is delayed enough to cause a timestamp header.
                        bool showAvatar = !isMe && !isSameAsPrev;

                        // If the message immediately below this one (chronologically newer) has a timestamp header,
                        // it breaks the block, so we MUST show the avatar on this message.
                        if (!isMe && index > 0) {
                          final newerMsg = messages[index - 1];
                          final diffNewer = newerMsg.createdAt
                              .difference(msg.createdAt)
                              .inMinutes;
                          if (diffNewer > 60 ||
                              newerMsg.createdAt.day != msg.createdAt.day) {
                            showAvatar = true;
                          }
                        }

                        return Column(
                          children: [
                            if (showTimestampHeader)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 24.0,
                                ),
                                child: Text(
                                  DateFormat(
                                    'MMM d, h:mm a',
                                  ).format(msg.createdAt),
                                  style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            Container(
                              margin: EdgeInsets.only(
                                left: 12,
                                right: 12,
                                bottom: isSameAsPrev ? 2 : 12,
                                top: 0,
                              ),
                              child: Dismissible(
                                key: ValueKey(msg.id),
                                direction: DismissDirection.startToEnd,
                                confirmDismiss: (direction) async {
                                  _onReplySwipe(msg, senderName);
                                  return false; // Never actually dismiss the widget
                                },
                                background: Container(
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.only(left: 16),
                                  child: const Icon(
                                    Icons.reply,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: isMe
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (!isMe)
                                      if (showAvatar)
                                        CircleAvatar(
                                          radius: 14,
                                          backgroundColor: Colors.blueAccent
                                              .withValues(alpha: 0.5),
                                          child: Text(
                                            senderName.isNotEmpty
                                                ? senderName[0].toUpperCase()
                                                : '?',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        )
                                      else
                                        const SizedBox(
                                          width: 28,
                                        ), // Placeholder for alignment

                                    if (!isMe) const SizedBox(width: 8),

                                    Flexible(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                          horizontal: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isMe
                                              ? Colors.blueAccent
                                              : const Color(0xFF333333),
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(
                                              isMe || !isSameAsNext ? 18 : 6,
                                            ),
                                            topRight: Radius.circular(
                                              !isMe || !isSameAsNext ? 18 : 6,
                                            ),
                                            bottomLeft: Radius.circular(
                                              isMe || !isSameAsPrev ? 18 : 6,
                                            ),
                                            bottomRight: Radius.circular(
                                              !isMe || !isSameAsPrev ? 18 : 6,
                                            ),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Replied-To Block
                                            if (msg.replyToText != null)
                                              Container(
                                                margin: const EdgeInsets.only(
                                                  bottom: 6,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: const Border(
                                                    left: BorderSide(
                                                      color: Colors.white38,
                                                      width: 3,
                                                    ),
                                                  ),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      msg.replyToSenderName ??
                                                          'Someone',
                                                      style: TextStyle(
                                                        color: isMe
                                                            ? Colors.white
                                                            : Colors.blueAccent,
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      msg.replyToText!,
                                                      style: const TextStyle(
                                                        color: Colors.white70,
                                                        fontSize: 12,
                                                      ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),

                                            // Actual Message Text
                                            Text(
                                              msg.text,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                              ),
                                            ),
                                            
                                            // Rich Embedded Widget Visualizer
                                            if (msg.payloadType != null && msg.payloadId != null)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 8.0),
                                                child: _EmbeddedWidgetCard(
                                                  payloadType: msg.payloadType!,
                                                  payloadId: msg.payloadId!,
                                                  isMe: isMe,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),

              // Typing Indicator Display
              if (chat != null) ...[
                Builder(
                  builder: (context) {
                    final typers = chat.isTyping
                        .where((id) => id != currentUser?.uid)
                        .toList();
                    if (typers.isNotEmpty) {
                      final text = typers.length == 1
                          ? "${chat.participantNames[typers.first] ?? 'Someone'} is typing..."
                          : "${typers.length} people are typing...";

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white54,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              text,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],

              // Reply Preview Bar
              if (_replyToMessage != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2A2A2A),
                    border: Border(top: BorderSide(color: Colors.white12)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.reply,
                        color: Colors.blueAccent,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Replying to ${_replyToSenderName ?? 'Someone'}",
                              style: const TextStyle(
                                color: Colors.blueAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _replyToMessage!.text,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white54,
                          size: 20,
                        ),
                        onPressed: _cancelReply,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

              // Input Bar
              SafeArea(
                bottom: true,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF252525),
                    border: Border(
                      top: BorderSide(
                        color: _replyToMessage != null
                            ? Colors.transparent
                            : Colors.white12,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _msgController,
                          focusNode: _msgFocusNode,
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
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                          onChanged: _onTextChanged,
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: _isSending
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.blueAccent,
                                ),
                              )
                            : const Icon(Icons.send, color: Colors.blueAccent),
                        onPressed: _isSending ? null : _sendMessage,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EmbeddedWidgetCard extends StatelessWidget {
  final String payloadType;
  final String payloadId;
  final bool isMe;

  const _EmbeddedWidgetCard({
    required this.payloadType,
    required this.payloadId,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    String label;
    Color color;

    switch (payloadType) {
      case 'tournament':
        icon = Icons.emoji_events;
        label = 'Tournament Highlight';
        color = Colors.amber;
        break;
      case 'raffle':
        icon = Icons.local_activity;
        label = 'Raffle Drop';
        color = Colors.purpleAccent;
        break;
      case 'special':
        icon = Icons.local_offer;
        label = 'Exclusive Special';
        color = Colors.greenAccent;
        break;
      case 'checkIn':
        icon = Icons.location_on;
        label = 'Live Check-In';
        color = Colors.redAccent;
        break;
      default:
        icon = Icons.bolt;
        label = 'Feed Event';
        color = Colors.blueAccent;
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 240),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMe ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Event ID: \$payloadId",
            style: const TextStyle(color: Colors.white70, fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 32,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: color.withOpacity(0.2),
                foregroundColor: color,
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                // Interactive trigger - spawn bottom sheet keeping user in DM context
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Color(0xFF1E1E1E),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  builder: (ctx) => Container(
                    padding: const EdgeInsets.all(24),
                    height: 250,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "\$label Validation",
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Accessing Payload: \$payloadId",
                          style: const TextStyle(color: Colors.white54, fontSize: 13),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Interacted with \$payloadType natively from DM!')),
                            );
                          },
                          child: const Text("Confirm Action", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: const Text('View Payload', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}

