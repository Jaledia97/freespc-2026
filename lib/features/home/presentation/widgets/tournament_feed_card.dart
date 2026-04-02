import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../models/tournament_model.dart';
import 'package:intl/intl.dart';
import 'package:vibration/vibration.dart';
import '../../../../models/feed_item.dart';
import 'social_interaction_bar.dart';
import 'dynamic_hall_header.dart';
import 'expandable_post_text.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TournamentFeedCard extends StatelessWidget {
  final TournamentModel tournament;
  final bool fullWidth;

  const TournamentFeedCard({
    super.key,
    required this.tournament,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d');
    final dateStr = tournament.startTime != null
        ? '${dateFormat.format(tournament.startTime!)}${tournament.endTime != null ? ' - ${dateFormat.format(tournament.endTime!)}' : ''}'
        : 'TBA';

    return Container(
      width: fullWidth ? double.infinity : 240,
      margin: fullWidth
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
          : const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.orangeAccent.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (fullWidth)
            DynamicHallHeader(
              hallId: tournament.hallId,
              fallbackName: "Tournament Event",
              subtitle: "Tournament",
              postId: tournament.id,
              authorId: tournament.hallId,
              targetType: 'tournament',
              createdAt: tournament.postedAt,
            ),

          // Post Content
          GestureDetector(
            onDoubleTap: () => Vibration.vibrate(duration: 40),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        color: Colors.orangeAccent,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'TOURNAMENT',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.orangeAccent,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tournament.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (tournament.description.isNotEmpty) ...[
                    ExpandablePostText(text: tournament.description),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.white54,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateStr,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Edge-to-Edge Image if it exists
          if (tournament.imageUrl != null && tournament.imageUrl!.isNotEmpty)
            GestureDetector(
              onDoubleTap: () => Vibration.vibrate(duration: 40),
              child: CachedNetworkImage(
                imageUrl: tournament.imageUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
                memCacheHeight: 600,
                placeholder: (context, url) => Container(
                  height: 200,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 200,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: const Icon(
                    Icons.broken_image,
                    color: Colors.white54,
                    size: 40,
                  ),
                ),
              ),
            ),

          if (fullWidth) ...[
            SocialInteractionBar(feedItem: FeedItem.tournament(tournament)),
          ],
        ],
      ),
    );
  }
}
