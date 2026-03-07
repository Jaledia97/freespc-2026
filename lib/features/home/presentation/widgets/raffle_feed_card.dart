import 'package:flutter/material.dart';
import '../../../../models/raffle_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RaffleFeedCard extends StatelessWidget {
  final RaffleModel raffle;

  const RaffleFeedCard({super.key, required this.raffle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daysLeft = raffle.endsAt.difference(DateTime.now()).inDays;
    final timeText = daysLeft > 0 ? '$daysLeft days left' : 'Ends soon';

    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.purpleAccent.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: SizedBox(
              height: 120,
              width: double.infinity,
              child: CachedNetworkImage(
                imageUrl: raffle.imageUrl,
                fit: BoxFit.cover,
                memCacheHeight: 360, // ~120 logical pixels * 3.0 devicePixelRatio
                placeholder: (context, url) => Container(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (context, url, error) => Container(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.loyalty, color: Colors.white54, size: 40),
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_activity, color: Colors.purpleAccent, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      timeText,
                      style: theme.textTheme.labelSmall?.copyWith(color: Colors.purpleAccent, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  raffle.name,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  raffle.description,
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
