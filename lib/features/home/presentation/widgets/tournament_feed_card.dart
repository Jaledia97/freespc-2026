import 'package:flutter/material.dart';
import '../../../../models/tournament_model.dart';
import 'package:intl/intl.dart';

class TournamentFeedCard extends StatelessWidget {
  final TournamentModel tournament;

  const TournamentFeedCard({super.key, required this.tournament});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d');
    final dateStr = tournament.startTime != null 
        ? '${dateFormat.format(tournament.startTime!)}${tournament.endTime != null ? ' - ${dateFormat.format(tournament.endTime!)}' : ''}'
        : 'TBA';

    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orangeAccent.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.emoji_events, color: Colors.orangeAccent, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'TOURNAMENT',
                      style: theme.textTheme.labelSmall?.copyWith(color: Colors.orangeAccent, fontWeight: FontWeight.w900, letterSpacing: 1),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  tournament.title,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (tournament.description.isNotEmpty) ...[
                  Text(
                    tournament.description,
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: Colors.white54),
                    const SizedBox(width: 4),
                    Text(
                      dateStr,
                      style: theme.textTheme.labelMedium?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
