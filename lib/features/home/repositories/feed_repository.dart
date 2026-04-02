import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/feed_item.dart';
import '../../../models/user_model.dart';
import '../../../models/squad_model.dart';

final feedRepositoryProvider = Provider((ref) => FeedRepository(ref: ref));

class FeedRepository {
  final Ref ref;
  FeedRepository({required this.ref});

  /// Sorts a raw list of FeedItems by the calculated algorithmic hypeScore.
  List<FeedItem> sortFeedByHype(
    List<FeedItem> items,
    UserModel? currentUser,
    List<SquadModel> userSquads,
  ) {
    items.sort((a, b) {
      double scoreA = _calculateHypeScore(a, currentUser, userSquads);
      double scoreB = _calculateHypeScore(b, currentUser, userSquads);

      // Sort descending (highest hype first)
      if (scoreA == scoreB) {
        final aDate = a.map(
          tournament: (t) => t.data.startTime ?? DateTime.now(),
          raffle: (r) => r.data.endsAt,
          special: (s) => (!s.data.isTemplate && s.data.templateId != null && s.data.startTime != null) ? s.data.startTime! : s.data.postedAt,
          checkIn: (c) => c.data.createdAt,
          winPost: (w) => w.data.createdAt,
          textPost: (tp) => tp.data.createdAt,
        );
        final bDate = b.map(
          tournament: (t) => t.data.startTime ?? DateTime.now(),
          raffle: (r) => r.data.endsAt,
          special: (s) => (!s.data.isTemplate && s.data.templateId != null && s.data.startTime != null) ? s.data.startTime! : s.data.postedAt,
          checkIn: (c) => c.data.createdAt,
          winPost: (w) => w.data.createdAt,
          textPost: (tp) => tp.data.createdAt,
        );
        return bDate.compareTo(aDate); // Fallback to recency
      }
      return scoreB.compareTo(scoreA);
    });
    return items;
  }

  double _calculateHypeScore(
    FeedItem item,
    UserModel? currentUser,
    List<SquadModel> userSquads,
  ) {
    double baseScore = 1.0;

    // Extrapolate interactions
    List<String> reactions = item.map(
      tournament: (t) => t.data.reactionUserIds,
      raffle: (r) => r.data.reactionUserIds,
      special: (s) => s.data.reactionUserIds,
      checkIn: (c) => c.data.reactionUserIds,
      winPost: (w) => w.data.reactionUserIds,
      textPost: (tp) => tp.data.reactionUserIds,
    );

    // Weight 1: Social Intersection. Massive boost if squad members interacted.
    int squadIntersections = 0;
    for (var squad in userSquads) {
      for (var memberId in squad.memberIds) {
        if (reactions.contains(memberId)) squadIntersections++;
      }
    }
    if (squadIntersections > 0) {
      baseScore += (squadIntersections * 50.0); // Massive algorithmic boost
    }

    // Weight 2: High payout overriding distance
    double payoutValue = item.maybeMap(
      winPost: (w) => w.data.winAmount,
      orElse: () => 0.0,
    );
    if (payoutValue > 500) {
      baseScore += 30.0;
    }

    // Weight 3: Local SpecialModel forced visual priority inside 7 days
    bool isSpecial = item.maybeMap(special: (_) => true, orElse: () => false);
    if (isSpecial) {
      baseScore += 20.0;
    }

    // Recency Decay: Older posts lose hypeScore slowly
    final itemDate = item.map(
      tournament: (t) => t.data.startTime ?? DateTime.now(),
      raffle: (r) => r.data.endsAt,
      special: (s) => (!s.data.isTemplate && s.data.templateId != null && s.data.startTime != null) ? s.data.startTime! : s.data.postedAt,
      checkIn: (c) => c.data.createdAt,
      winPost: (w) => w.data.createdAt,
      textPost: (tp) => tp.data.createdAt,
    );
    final hoursOld = DateTime.now().difference(itemDate).inHours;
    baseScore -= (hoursOld * 0.1);

    return baseScore;
  }
}
