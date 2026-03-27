import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../repositories/hall_repository.dart';
import '../../../../models/comment_model.dart';
import 'package:intl/intl.dart';

final commentsProvider = StreamProvider.family<List<CommentModel>, String>((
  ref,
  comboId,
) {
  final parts = comboId.split('|');
  return ref.watch(hallRepositoryProvider).getComments(parts[0], parts[1]);
});

class CommentsBottomSheet extends ConsumerStatefulWidget {
  final String collectionName;
  final String docId;
  final User currentUser;

  const CommentsBottomSheet({
    super.key,
    required this.collectionName,
    required this.docId,
    required this.currentUser,
  });

  @override
  ConsumerState<CommentsBottomSheet> createState() =>
      _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends ConsumerState<CommentsBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSubmitting = false;
  String? _replyingToCommentId;
  String? _replyingToAuthorName;

  // Moderation state
  final Set<String> _hiddenCommentIds = {};
  String? _editingCommentId;

  void _editComment(CommentModel comment) {
    _cancelReply();
    setState(() {
      _editingCommentId = comment.id;
      _controller.text = comment.text;
    });
    _focusNode.requestFocus();
  }

  void _cancelEdit() {
    setState(() {
      _editingCommentId = null;
      _controller.clear();
    });
    _focusNode.unfocus();
  }

  void _showCommentOptions(CommentModel comment) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: ["❤️", "🔥", "😂", "😢", "😡", "👍"].map((emoji) {
                    return GestureDetector(
                      onTap: () async {
                        Navigator.pop(context);
                        await ref.read(hallRepositoryProvider).reactToComment(
                          widget.collectionName,
                          widget.docId,
                          comment.id,
                          widget.currentUser.uid,
                          emoji,
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(color: Colors.white10, shape: BoxShape.circle),
                        child: Text(emoji, style: const TextStyle(fontSize: 24)),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const Divider(color: Colors.white24),
              if (comment.authorId == widget.currentUser.uid) ...[
                ListTile(
                  leading: const Icon(Icons.edit, color: Colors.white),
                  title: const Text(
                    'Edit Comment',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _editComment(comment);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.redAccent),
                  title: const Text(
                    'Delete Comment',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await ref
                        .read(hallRepositoryProvider)
                        .deleteComment(
                          widget.collectionName,
                          widget.docId,
                          comment.id,
                        );
                  },
                ),
              ] else ...[
                ListTile(
                  leading: const Icon(
                    Icons.visibility_off,
                    color: Colors.white,
                  ),
                  title: const Text(
                    'Hide Comment',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _hiddenCommentIds.add(comment.id));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.flag, color: Colors.orangeAccent),
                  title: const Text(
                    'Report Comment',
                    style: TextStyle(color: Colors.orangeAccent),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Comment reported to moderators."),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.block, color: Colors.red),
                  title: Text(
                    'Block @${comment.authorName}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _hiddenCommentIds.add(comment.id));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "@${comment.authorName} has been blocked locally.",
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _initiateReply(String commentId, String authorName) {
    _cancelEdit();
    setState(() {
      _replyingToCommentId = commentId;
      _replyingToAuthorName = authorName;
    });
    _focusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyingToCommentId = null;
      _replyingToAuthorName = null;
    });
  }

  Future<void> _submitComment() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      if (_editingCommentId != null) {
        await ref
            .read(hallRepositoryProvider)
            .updateComment(
              widget.collectionName,
              widget.docId,
              _editingCommentId!,
              text,
            );
        _controller.clear();
        _cancelEdit();
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUser.uid)
          .get();
      final userData = userDoc.data() ?? {};
      final String name =
          userData['username'] ?? userData['firstName'] ?? 'User';
      final String? avatar = userData['photoUrl'];

      final comment = CommentModel(
        id: '',
        text: text,
        authorId: widget.currentUser.uid,
        authorName: name,
        authorAvatarUrl: avatar,
        createdAt: DateTime.now(),
        parentId: _replyingToCommentId,
      );

      await ref
          .read(hallRepositoryProvider)
          .addComment(widget.collectionName, widget.docId, comment);

      _controller.clear();
      _cancelReply();
      _focusNode.unfocus();
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to post comment: $e")));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return DateFormat('MMM d').format(date);
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'Just now';
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(
      commentsProvider('${widget.collectionName}|${widget.docId}'),
    );

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 16),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text(
            "Comments",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(color: Colors.white24, height: 16),

          Expanded(
            child: commentsAsync.when(
              data: (allComments) {
                if (allComments.isEmpty) {
                  return const Center(
                    child: Text(
                      "No comments yet. Be the first!",
                      style: TextStyle(color: Colors.white54),
                    ),
                  );
                }

                // Group Comments
                final filteredComments = allComments
                    .where((c) => !_hiddenCommentIds.contains(c.id))
                    .toList();
                final topLevel = filteredComments
                    .where((c) => c.parentId == null)
                    .toList();
                final childrenMap = <String, List<CommentModel>>{};
                for (var c in filteredComments.where(
                  (c) => c.parentId != null,
                )) {
                  childrenMap.putIfAbsent(c.parentId!, () => []).add(c);
                }

                for (var key in childrenMap.keys) {
                  childrenMap[key]!.sort(
                    (a, b) => a.createdAt.compareTo(b.createdAt),
                  ); // Oldest nested first
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: topLevel.length,
                  itemBuilder: (context, index) {
                    final parent = topLevel[index];
                    final children = childrenMap[parent.id] ?? [];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCommentRow(parent),
                          if (children.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 42,
                              ), // Indent for nested
                              child: Column(
                                children: children
                                    .map(
                                      (child) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 12.0,
                                        ),
                                        child: _buildCommentRow(
                                          child,
                                          isChild: true,
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: Colors.blueAccent),
              ),
              error: (e, st) => Center(
                child: Text(
                  "Error loading comments: $e",
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Container(
              color: const Color(0xFF1E1E1E),
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 8,
                top: 8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_editingCommentId != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.edit,
                            size: 16,
                            color: Colors.blueAccent,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Editing Comment",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: _cancelEdit,
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_replyingToCommentId != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.reply,
                            size: 16,
                            color: Colors.blueAccent,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Replying to @$_replyingToAuthorName",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: _cancelReply,
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: "Add a comment...",
                            hintStyle: TextStyle(color: Colors.white54),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(30),
                              ),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.black26,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                          ),
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _submitComment(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _isSubmitting ? null : _submitComment,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.blueAccent,
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                  size: 20,
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildReactionChips(CommentModel comment) {
    final Map<String, int> counts = {};
    final Map<String, bool> userReacted = {};

    for (var entry in comment.reactions.entries) {
      final uid = entry.key;
      final emoji = entry.value;
      counts[emoji] = (counts[emoji] ?? 0) + 1;
      if (uid == widget.currentUser.uid) userReacted[emoji] = true;
    }

    return counts.entries.map((entry) {
      final emoji = entry.key;
      final count = entry.value;
      final isMine = userReacted[emoji] == true;

      return GestureDetector(
        onTap: () async {
          await ref.read(hallRepositoryProvider).reactToComment(
            widget.collectionName, widget.docId, comment.id, widget.currentUser.uid, emoji);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isMine ? Colors.blueAccent.withValues(alpha: 0.2) : Colors.white10,
            borderRadius: BorderRadius.circular(12),
            border: isMine ? Border.all(color: Colors.blueAccent.withValues(alpha: 0.5)) : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text(count.toString(), style: TextStyle(
                color: isMine ? Colors.blueAccent : Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              )),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildCommentRow(CommentModel comment, {bool isChild = false}) {
    return GestureDetector(
      onLongPress: () => _showCommentOptions(comment),
      child: Container(
        color:
            Colors.transparent, // Ensures the entire row area captures gestures
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: isChild ? 12 : 16,
              backgroundColor: Colors.white12,
              backgroundImage:
                  comment.authorAvatarUrl != null &&
                      comment.authorAvatarUrl!.isNotEmpty
                  ? NetworkImage(comment.authorAvatarUrl!)
                  : null,
              child:
                  comment.authorAvatarUrl == null ||
                      comment.authorAvatarUrl!.isEmpty
                  ? Icon(
                      Icons.person,
                      size: isChild ? 12 : 16,
                      color: Colors.white54,
                    )
                  : null,
            ),
            SizedBox(width: isChild ? 8 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        comment.authorName,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: isChild ? 12 : 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(comment.createdAt),
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: isChild ? 11 : 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    comment.text,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: isChild ? 13 : 14,
                    ),
                  ),
                  if (comment.reactions.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _buildReactionChips(comment),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await ref.read(hallRepositoryProvider).reactToComment(
                            widget.collectionName,
                            widget.docId,
                            comment.id,
                            widget.currentUser.uid,
                            "❤️",
                          );
                        },
                        onLongPress: () => _showCommentOptions(comment),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                comment.reactions[widget.currentUser.uid] == "❤️"
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: comment.reactions[widget.currentUser.uid] == "❤️"
                                    ? Colors.redAccent
                                    : Colors.white54,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Like",
                                style: TextStyle(
                                  color: comment.reactions[widget.currentUser.uid] == "❤️"
                                      ? Colors.redAccent
                                      : Colors.white54,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (!isChild) ...[
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () => _initiateReply(comment.id, comment.authorName),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              "Reply",
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
