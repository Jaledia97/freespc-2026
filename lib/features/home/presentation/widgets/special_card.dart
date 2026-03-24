import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../models/special_model.dart';
import '../../repositories/hall_repository.dart';
import '../hall_profile_screen.dart';

import 'package:flutter/services.dart';
import '../../../../models/feed_item.dart';
import 'social_interaction_bar.dart';
import 'dynamic_hall_header.dart';
import 'expandable_post_text.dart';
import 'package:vibration/vibration.dart';

class SpecialCard extends ConsumerStatefulWidget {
  final SpecialModel special;
  final bool isFeatured;
  final bool fullWidth;

  const SpecialCard({
    super.key,
    required this.special,
    this.isFeatured = false,
    this.fullWidth = false,
  });

  @override
  ConsumerState<SpecialCard> createState() => _SpecialCardState();
}

class _SpecialCardState extends ConsumerState<SpecialCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Filter out internal system tags so UI is clean
    final displayTags = widget.special.tags
        .where((t) => t.toLowerCase() != 'featured')
        .toList();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.fullWidth || widget.isFeatured)
            DynamicHallHeader(
              hallId: widget.special.hallId,
              fallbackName: widget.special.hallName.isNotEmpty
                  ? widget.special.hallName
                  : "FreeSpc",
              subtitle: "Special Offer",
              postId: widget.special.id,
              authorId: widget.special.authorId ?? widget.special.hallId,
              targetType: 'special',
              createdAt:
                  (widget.special.recurrence == 'none' &&
                      widget.special.recurrenceRule == null)
                  ? widget.special.postedAt
                  : null,
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
                        Icons.local_fire_department,
                        size: 14,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formattedDate(widget.special),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.special.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (widget.special.description.isNotEmpty) ...[
                    ExpandablePostText(text: widget.special.description),
                    const SizedBox(height: 8),
                  ],
                  if (displayTags.isNotEmpty) ...[
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: displayTags
                          .map(
                            (tag) => Chip(
                              label: Text(
                                tag,
                                style: const TextStyle(fontSize: 10),
                              ),
                              backgroundColor:
                                  Colors.grey[850], // Dark mode chip background
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                                side: BorderSide(color: Colors.grey[800]!),
                              ),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
          ),

          // Edge-to-Edge Image
          if (widget.special.imageUrl.isNotEmpty)
            GestureDetector(
              onDoubleTap: () => Vibration.vibrate(duration: 40),
              child: CachedNetworkImage(
                imageUrl: widget.special.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                memCacheHeight:
                    600, // ~200 logical pixels * 3.0 devicePixelRatio
                placeholder: (context, url) => Container(
                  height: 200,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 200,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.broken_image),
                ),
              ),
            ),

          if (widget.fullWidth) ...[
            SocialInteractionBar(feedItem: FeedItem.special(widget.special)),
          ],
        ],
      ),
    );
  }

  String _formattedDate(SpecialModel special) {
    if (special.startTime == null) return "Check Hall for Time";

    final dt = special.startTime!;
    final timeStr =
        "${dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour)}:${dt.minute.toString().padLeft(2, '0')} ${dt.hour >= 12 ? 'PM' : 'AM'}";

    if (special.recurrence == 'daily') {
      return "Every Day at $timeStr";
    } else if (special.recurrence == 'weekly') {
      const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
      final weekday = days[dt.weekday - 1]; // dt.weekday is 1-7 (Mon-Sun)
      return "Every $weekday at $timeStr";
    } else if (special.recurrence == 'monthly') {
      return "Monthly on the ${dt.day}${_ordinal(dt.day)} at $timeStr";
    } else {
      // One time event
      final months = [
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec",
      ];
      final dateStr = "${months[dt.month - 1]} ${dt.day}";
      return "$dateStr at $timeStr";
    }
  }

  String _ordinal(int n) {
    if (n >= 11 && n <= 13) return 'th';
    switch (n % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }
}

class DynamicHallName extends ConsumerWidget {
  final String hallId;

  const DynamicHallName({super.key, required this.hallId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hallAsync = ref.watch(hallStreamProvider(hallId));

    return hallAsync.when(
      data: (hall) => Text(
        hall?.name ?? "Unknown Hall",
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      loading: () => const Text(
        "Loading...",
        style: TextStyle(fontSize: 12, color: Colors.grey),
      ),
      error: (error, stackTrace) => const Text(
        "Unknown Hall",
        style: TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Ensuring High Contrast for Accessibility
    final iconColor = Theme.of(context).colorScheme.primary;
    final textColor = Theme.of(context).colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
