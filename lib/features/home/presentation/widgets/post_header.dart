import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/username_router.dart';
import '../../controllers/feed_pagination_controller.dart';
import '../../../../features/moderation/repositories/moderation_repository.dart';
import '../../../../services/auth_service.dart';

class PostHeader extends ConsumerWidget {
  final String title;
  final String? subtitle;
  final String? avatarUrl;
  final VoidCallback? onTap;
  final String postId;
  final String authorId;
  final String targetType; // 'special', 'raffle', 'tournament'

  const PostHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.avatarUrl,
    this.onTap,
    required this.postId,
    required this.authorId,
    required this.targetType,
  });

  void _showReportOptions(BuildContext context, WidgetRef ref) {
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
                width: 40,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Text(
                  "Report Content",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildReportOption(
                context,
                ref,
                "Spam",
                "This content is repetitive or irrelevant.",
              ),
              _buildReportOption(
                context,
                ref,
                "Harassment",
                "Abusive language or bullying.",
              ),
              _buildReportOption(
                context,
                ref,
                "Inappropriate",
                "Nudity, violence, or offensive content.",
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReportOption(
    BuildContext context,
    WidgetRef ref,
    String reason,
    String description,
  ) {
    return ListTile(
      title: Text(
        reason,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        description,
        style: const TextStyle(color: Colors.white54),
      ),
      onTap: () async {
        Navigator.pop(context); // Close sub-sheet
        Navigator.pop(context); // Close main sheet
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report submitted. We will review this shortly.'),
          ),
        );
        final currentUser = ref.read(authStateChangesProvider).value;
        if (currentUser != null) {
          await ref
              .read(moderationRepositoryProvider)
              .submitReport(
                reporterId: currentUser.uid,
                targetId: postId,
                targetType: targetType,
                reason: reason,
              );
        }
      },
    );
  }

  void _showOptionsSheet(BuildContext context, WidgetRef ref) {
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
                width: 40,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.flag_outlined,
                  color: Colors.redAccent,
                ),
                title: const Text(
                  'Report Post',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  _showReportOptions(context, ref);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.visibility_off_outlined,
                  color: Colors.white,
                ),
                title: const Text(
                  'Hide Post',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  'See fewer posts like this.',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ref
                      .read(feedPaginationControllerProvider.notifier)
                      .hidePost(postId, title);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Post hidden.')));
                },
              ),
              ListTile(
                leading: const Icon(Icons.block_outlined, color: Colors.white),
                title: const Text(
                  'Block User',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  'You will no longer see content from this user.',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    await ref
                        .read(feedPaginationControllerProvider.notifier)
                        .blockUser(authorId, title);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('User blocked.')),
                      );
                    }
                  } catch (e) {
                    // Fail silently per user UX requirements
                    // The user was already warned via Dialog prior to unblocking.
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.white12,
        backgroundImage: avatarUrl != null
            ? CachedNetworkImageProvider(avatarUrl!)
            : null,
        child: avatarUrl == null
            ? const Icon(Icons.person, color: Colors.white54)
            : null,
      ),
      title: UsernameRouter(
        text: title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.white,
        ),
      ),
      subtitle: subtitle != null && subtitle!.isNotEmpty
          ? Text(
              subtitle!,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: IconButton(
        icon: const Icon(Icons.more_horiz, color: Colors.white54),
        onPressed: () => _showOptionsSheet(context, ref),
      ),
    );
  }
}
