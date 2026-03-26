import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';
import 'dart:convert';
import '../../../../models/feed_item.dart';
import '../../../../services/auth_service.dart';
import '../../repositories/hall_repository.dart';
import '../../controllers/feed_pagination_controller.dart';
import 'comments_bottom_sheet.dart';
import '../../../../core/widgets/glass_container.dart';

class SocialInteractionBar extends ConsumerStatefulWidget {
  final FeedItem feedItem;

  const SocialInteractionBar({super.key, required this.feedItem});

  @override
  ConsumerState<SocialInteractionBar> createState() =>
      _SocialInteractionBarState();
}

class _SocialInteractionBarState extends ConsumerState<SocialInteractionBar> {
  bool? _localHypeState; // Local optimistic state

  void _handleHype(bool currentlyHyped) {
    Vibration.vibrate(duration: 50, amplitude: 50);
    setState(() => _localHypeState = !currentlyHyped);
    _handleInteractionSync('reactionUserIds', !currentlyHyped, currentlyHyped);
  }

  void _showReactionsOverlay(BuildContext context, Offset position) {
    Vibration.vibrate(duration: 50, amplitude: 50);
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black12,
        pageBuilder: (BuildContext context, _, __) {
          return GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Stack(
                children: [
                  Positioned(
                    left: (position.dx - 40).clamp(
                      16.0,
                      MediaQuery.of(context).size.width - 200.0,
                    ),
                    top: position.dy - 70, // Above the finger
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C2C2E),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black54,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _reactionIcon('🔥', 'Hype', context),
                            const SizedBox(width: 8),
                            _reactionIcon('😂', 'Haha', context),
                            const SizedBox(width: 8),
                            _reactionIcon('❤️', 'Love', context),
                            const SizedBox(width: 8),
                            _reactionIcon('😢', 'Sad', context),
                            const SizedBox(width: 8),
                            _reactionIcon('😡', 'Angry', context),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _reactionIcon(String emoji, String label, BuildContext parentContext) {
    return GestureDetector(
      onTap: () {
        Vibration.vibrate(duration: 50, amplitude: 50);
        final currentlyHyped = _localHypeState ?? false;
        setState(() => _localHypeState = true); // Represent reaction
        Navigator.pop(parentContext);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Reacted with $emoji $label")));
        _handleInteractionSync('reactionUserIds', true, currentlyHyped);
      },
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Text(emoji, style: const TextStyle(fontSize: 28)),
      ),
    );
  }

  bool? _localRsvpState; // Optimistic update flag

  Future<void> _handleInteractionSync(String field, bool isAdding, bool originalState) async {
    final currentUser = ref.read(authStateChangesProvider).value;
    if (currentUser == null) return;

    final String collectionName = widget.feedItem.map(
      tournament: (_) => 'tournaments',
      raffle: (_) => 'raffles',
      special: (_) => 'specials',
      checkIn: (_) => 'check_ins',
      winPost: (_) => 'win_posts',
      textPost: (_) => 'text_posts',
    );

    final String docId = widget.feedItem.map(
      tournament: (t) => t.data.id,
      raffle: (r) => r.data.id,
      special: (s) => s.data.id,
      checkIn: (c) => c.data.id,
      winPost: (w) => w.data.id,
      textPost: (t) => t.data.id,
    );

    try {
      await ref
          .read(hallRepositoryProvider)
          .toggleInteraction(
            collectionName,
            docId,
            field,
            currentUser.uid,
            isAdding,
          );

      // Synchronize the local Pagination machine instantly
      if (field == 'interestedUserIds') {
        ref
            .read(feedPaginationControllerProvider.notifier)
            .toggleLocalRsvp(docId, currentUser.uid, isAdding);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (field == 'reactionUserIds') _localHypeState = originalState;
          if (field == 'interestedUserIds') _localRsvpState = originalState;
        });
      }
    }
  }

  void _handleRsvp(bool currentlyRsvpd) {
    Vibration.vibrate(duration: 50, amplitude: 50);
    setState(() => _localRsvpState = !currentlyRsvpd);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          currentlyRsvpd ? "RSVP Removed" : "RSVP Confirmed!",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 150, // Float near Top
          left: 48,
          right: 48,
        ),
        duration: const Duration(milliseconds: 1500),
      ),
    );
    _handleInteractionSync('interestedUserIds', !currentlyRsvpd, currentlyRsvpd);
  }

  void _handleComment() {
    Vibration.vibrate(duration: 50, amplitude: 50);

    final currentUser = ref.read(authStateChangesProvider).value;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Must be logged in to comment.")),
      );
      return;
    }

    final String collectionName = widget.feedItem.map(
      tournament: (_) => 'tournaments',
      raffle: (_) => 'raffles',
      special: (_) => 'specials',
      checkIn: (_) => 'check_ins',
      winPost: (_) => 'win_posts',
      textPost: (_) => 'text_posts',
    );

    final String docId = widget.feedItem.map(
      tournament: (t) => t.data.id,
      raffle: (r) => r.data.id,
      special: (s) => s.data.id,
      checkIn: (c) => c.data.id,
      winPost: (w) => w.data.id,
      textPost: (t) => t.data.id,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsBottomSheet(
        collectionName: collectionName,
        docId: docId,
        currentUser: currentUser,
      ),
    );
  }

  void _handleShare() {
    Vibration.vibrate(duration: 50, amplitude: 50);
    final String titleText = widget.feedItem.map(
      tournament: (t) => t.data.title,
      raffle: (r) => r.data.name,
      special: (s) => s.data.title,
      checkIn: (c) => "Live Check-in",
      winPost: (w) => "Huge win at ${w.data.hallId}",
      textPost: (t) => t.data.title,
    );
    final String docId = widget.feedItem.map(
      tournament: (t) => t.data.id,
      raffle: (r) => r.data.id,
      special: (s) => s.data.id,
      checkIn: (c) => c.data.id,
      winPost: (w) => w.data.id,
      textPost: (t) => t.data.id,
    );
    final String collectionName = widget.feedItem.map(
      tournament: (_) => 'tournaments',
      raffle: (_) => 'raffles',
      special: (_) => 'specials',
      checkIn: (_) => 'check_ins',
      winPost: (_) => 'win_posts',
      textPost: (_) => 'text_posts',
    );
    
    final String deepLink = "freespc://feed?type=$collectionName&id=$docId";

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _HybridShareSheet(
         title: titleText,
         deepLink: deepLink,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> reactions = widget.feedItem.map(
      tournament: (t) => t.data.reactionUserIds,
      raffle: (r) => r.data.reactionUserIds,
      special: (s) => s.data.reactionUserIds,
      checkIn: (c) => c.data.reactionUserIds,
      winPost: (w) => w.data.reactionUserIds,
      textPost: (t) => t.data.reactionUserIds,
    );

    final currentUser = ref.watch(authStateChangesProvider).value;
    final bool dbIsHyped =
        currentUser != null && reactions.contains(currentUser.uid);
    final bool isHyped = _localHypeState ?? dbIsHyped;

    int displayHypeCount = reactions.length;
    if (isHyped && !dbIsHyped) displayHypeCount += 1;
    if (!isHyped && dbIsHyped) displayHypeCount -= 1;

    final int commentCount = widget.feedItem.map(
      tournament: (t) => t.data.commentCount,
      raffle: (r) => r.data.commentCount,
      special: (s) => s.data.commentCount,
      checkIn: (c) => c.data.commentCount,
      winPost: (w) => w.data.commentCount,
      textPost: (t) => t.data.commentCount,
    );

    final String? latestComment = widget.feedItem.map(
      tournament: (t) => t.data.latestComment,
      raffle: (r) => r.data.latestComment,
      special: (s) => s.data.latestComment,
      checkIn: (c) => c.data.latestComment,
      winPost: (w) => w.data.latestComment,
      textPost: (t) => t.data.latestComment,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Hype Button with Facebook-style long press
              GestureDetector(
                onTap: () => _handleHype(isHyped),
                onLongPressStart: (details) =>
                    _showReactionsOverlay(context, details.globalPosition),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isHyped
                        ? Icons.local_fire_department
                        : Icons.local_fire_department_outlined,
                    color: isHyped ? Colors.amber : Colors.white,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Comment Button
              GestureDetector(
                onTap: _handleComment,
                child: const Icon(
                  Icons.mode_comment_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              // Share Button
              GestureDetector(
                onTap: _handleShare,
                child: const Icon(
                  Icons.send_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),

              const Spacer(),

              // RSVP Button
              Consumer(
                builder: (context, ref, _) {
                  final currentUser = ref.watch(authStateChangesProvider).value;
                  final interestedUserIds = widget.feedItem.map(
                    tournament: (t) => t.data.interestedUserIds,
                    raffle: (r) => r.data.interestedUserIds,
                    special: (s) => s.data.interestedUserIds,
                    checkIn: (c) => c.data.interestedUserIds,
                    winPost: (w) => w.data.interestedUserIds,
                    textPost: (t) => t.data.interestedUserIds,
                  );

                  final dbIsRsvpd =
                      currentUser != null &&
                      interestedUserIds.contains(currentUser.uid);
                  final isRsvpd = _localRsvpState ?? dbIsRsvpd;

                  return GestureDetector(
                    onTap: () => _handleRsvp(isRsvpd),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isRsvpd
                            ? Colors.blueAccent.withOpacity(0.2)
                            : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isRsvpd ? Colors.blueAccent : Colors.white24,
                        ),
                      ),
                      child: Text(
                        isRsvpd ? 'Reserved' : 'RSVP',
                        style: TextStyle(
                          color: isRsvpd ? Colors.blueAccent : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          if (displayHypeCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                '$displayHypeCount Hypes',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),

          if (commentCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
              child: Text(
                'View all $commentCount comments',
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ),

          if (latestComment != null && latestComment.isNotEmpty)
            GestureDetector(
              onTap: _handleComment,
              child: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Builder(
                  builder: (context) {
                    try {
                      final data =
                          jsonDecode(latestComment) as Map<String, dynamic>;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.white12,
                              backgroundImage:
                                  data['authorAvatarUrl'] != null &&
                                      data['authorAvatarUrl']
                                          .toString()
                                          .isNotEmpty
                                  ? NetworkImage(data['authorAvatarUrl'])
                                  : null,
                              child:
                                  (data['authorAvatarUrl'] == null ||
                                      data['authorAvatarUrl']
                                          .toString()
                                          .isEmpty)
                                  ? const Icon(
                                      Icons.person,
                                      size: 10,
                                      color: Colors.white54,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              data['authorName'] ?? 'User',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                data['text'] ?? '',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    } catch (e) {
                      return Text(
                        latestComment,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      );
                    }
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HybridShareSheet extends StatelessWidget {
  final String title;
  final String deepLink;

  const _HybridShareSheet({required this.title, required this.deepLink});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Share to External", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.close, color: Colors.white54), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 16),
          GlassContainer(
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(child: Text(deepLink, style: const TextStyle(color: Colors.white54, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  IconButton(
                    icon: const Icon(Icons.copy, color: Colors.blueAccent, size: 20),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: "Check out $title on FreeSpc!\n\n$deepLink"));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Link copied to clipboard!")));
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
               Navigator.pop(context);
               Share.share("Check out $title on FreeSpc!\n\n$deepLink");
            },
            icon: const Icon(Icons.share),
            label: const Text("Share via OS", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}

