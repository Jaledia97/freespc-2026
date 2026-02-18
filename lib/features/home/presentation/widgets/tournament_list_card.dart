import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../models/tournament_model.dart';
import 'package:intl/intl.dart';
import '../../repositories/hall_repository.dart';

class TournamentListCard extends ConsumerWidget {
  final TournamentModel tournament;
  final bool showHallName;

  const TournamentListCard({super.key, required this.tournament, this.showHallName = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('MMM d, h:mm a');
    final hallAsync = showHallName ? ref.watch(hallStreamProvider(tournament.hallId)) : null;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              if (tournament.imageUrl != null && tournament.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: CachedNetworkImage(
                  imageUrl: tournament.imageUrl!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => 
                      const SizedBox(height: 150, child: Center(child: CircularProgressIndicator())),
                  errorWidget: (context, url, error) =>
                      const SizedBox(height: 150, child: Center(child: Icon(Icons.broken_image, color: Colors.grey))),
                ),
              ),
            
            // Content Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showHallName) ...[
                    hallAsync?.when(
                      data: (hall) => Text(
                        hall?.name ?? "Unknown Hall",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_,__) => const SizedBox.shrink(),
                    ) ?? const SizedBox.shrink(),
                    const SizedBox(height: 4),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          tournament.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (tournament.startTime != null &&
                          tournament.startTime!.isAfter(DateTime.now()))
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "UPCOMING",
                            style: const TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                  if (tournament.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      tournament.description,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      if (tournament.startTime != null)
                        Text(
                          dateFormat.format(tournament.startTime!),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      if (tournament.recurrenceRule != null &&
                          tournament.recurrenceRule!.frequency != 'none') ...[
                        const SizedBox(width: 16),
                        const Icon(Icons.repeat, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          tournament.recurrenceRule!.frequency.toUpperCase(),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ],
                  ),
                  const Divider(height: 24),
                  Text(
                    "Games: ${tournament.games.length}",
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tournament.games.take(3).map((game) {
                      return Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "${game.title} (${game.value}pts)",
                          style: TextStyle(color: Colors.grey[800], fontSize: 12),
                        ),
                      );
                    }).toList(),
                  ),
                  if (tournament.games.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        "+ ${tournament.games.length - 3} more",
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ),
                ], // Close Inner Children
              ), // Close Inner Column
            ), // Close Inner Padding
          ], // Close Outer Children
        ), // Close Outer Column
      ), // Close Outer Padding
    ); // Close Card
  }
}
