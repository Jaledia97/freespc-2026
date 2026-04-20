import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../models/raffle_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../models/feed_item.dart';
import '../../../../models/feed_item.dart';
import 'social_interaction_bar.dart';
import 'dynamic_venue_header.dart';
import 'expandable_post_text.dart';
import 'package:vibration/vibration.dart';

class RaffleFeedCard extends StatelessWidget {
  final RaffleModel raffle;
  final bool fullWidth;

  const RaffleFeedCard({
    super.key,
    required this.raffle,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daysLeft = raffle.endsAt.difference(DateTime.now()).inDays;
    final timeText = daysLeft > 0 ? '$daysLeft days left' : 'Ends soon';

    return Container(
      width: fullWidth ? double.infinity : 240,
      margin: fullWidth
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
          : const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.purpleAccent.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (fullWidth)
            DynamicVenueHeader(
              venueId: raffle.venueId,
              fallbackName: "Raffle Event",
              subtitle: "Raffle",
              postId: raffle.id,
              authorId: raffle.venueId,
              targetType: 'raffle',
              createdAt: (!raffle.isTemplate && raffle.templateId != null)
                  ? (raffle.createdAt ?? raffle.endsAt)
                  : raffle.createdAt,
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
                        Icons.local_activity,
                        color: Colors.purpleAccent,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        timeText,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.purpleAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    raffle.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (raffle.description.isNotEmpty) ...[
                    ExpandablePostText(text: raffle.description),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
          ),

          // Edge-to-Edge Image
          if (raffle.imageUrl.isNotEmpty)
            GestureDetector(
              onDoubleTap: () => Vibration.vibrate(duration: 40),
              child: CachedNetworkImage(
                imageUrl: raffle.imageUrl,
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
                    Icons.loyalty,
                    color: Colors.white54,
                    size: 40,
                  ),
                ),
              ),
            ),
          if (fullWidth) ...[
            SocialInteractionBar(feedItem: FeedItem.raffle(raffle)),
          ],
        ],
      ),
    );
  }
}
