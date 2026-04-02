import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../models/feed_item.dart';
import '../../../../models/user_model.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/location_service.dart';
import '../../home/repositories/hall_repository.dart';
import '../../home/repositories/feed_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FeedPaginationState {
  final List<FeedItem> items;
  final bool isLoading;
  final bool hasMore;

  // Cursors
  final DateTime? lastSpecialDate;
  final DateTime? lastRaffleDate;
  final DateTime? lastTournamentDate;

  // Stream depletion flags
  final bool hasMoreSpecials;
  final bool hasMoreRaffles;
  final bool hasMoreTournaments;

  FeedPaginationState({
    required this.items,
    this.isLoading = false,
    this.hasMore = true,
    this.lastSpecialDate,
    this.lastRaffleDate,
    this.lastTournamentDate,
    this.hasMoreSpecials = true,
    this.hasMoreRaffles = true,
    this.hasMoreTournaments = true,
  });

  FeedPaginationState copyWith({
    List<FeedItem>? items,
    bool? isLoading,
    bool? hasMore,
    DateTime? lastSpecialDate,
    DateTime? lastRaffleDate,
    DateTime? lastTournamentDate,
    bool? hasMoreSpecials,
    bool? hasMoreRaffles,
    bool? hasMoreTournaments,
  }) {
    return FeedPaginationState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      lastSpecialDate: lastSpecialDate ?? this.lastSpecialDate,
      lastRaffleDate: lastRaffleDate ?? this.lastRaffleDate,
      lastTournamentDate: lastTournamentDate ?? this.lastTournamentDate,
      hasMoreSpecials: hasMoreSpecials ?? this.hasMoreSpecials,
      hasMoreRaffles: hasMoreRaffles ?? this.hasMoreRaffles,
      hasMoreTournaments: hasMoreTournaments ?? this.hasMoreTournaments,
    );
  }
}

final feedPaginationControllerProvider =
    StateNotifierProvider<FeedPaginationController, FeedPaginationState>((ref) {
      return FeedPaginationController(ref);
    });

class FeedPaginationController extends StateNotifier<FeedPaginationState> {
  final Ref ref;
  static const int _limit = 20;

  FeedPaginationController(this.ref) : super(FeedPaginationState(items: [])) {
    loadInitial();
  }

  Future<void> loadInitial() async {
    if (state.isLoading) return;
    state = FeedPaginationState(items: [], isLoading: true); // Reset completely

    await _fetchAndMerge();
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true);

    await _fetchAndMerge();
  }

  Future<void> _fetchAndMerge() async {
    try {
      final hallRepo = ref.read(hallRepositoryProvider);
      final feedRepo = ref.read(feedRepositoryProvider);
      final userLoc = ref.read(userLocationStreamProvider).valueOrNull;

      // 1. Fetch concurrently based on depletion flags
      final futures = <Future>[];

      Future<void> fetchSpecials() async {
        if (!state.hasMoreSpecials) return;
        final specials = await hallRepo.fetchSpecialsPage(
          startAfterTimestamp: state.lastSpecialDate,
          limit: _limit,
          userLoc: userLoc,
        );

        final FeedItems = specials.map((s) => FeedItem.special(s)).toList();
        final bool exhausted = specials.length < _limit;
        final DateTime? newCursor = specials.isNotEmpty
            ? specials.last.postedAt
            : state.lastSpecialDate;

        state = state.copyWith(
          lastSpecialDate: newCursor,
          hasMoreSpecials: !exhausted,
          items: [...state.items, ...FeedItems],
        );
      }

      Future<void> fetchRaffles() async {
        if (!state.hasMoreRaffles) return;
        final raffles = await hallRepo.fetchRafflesPage(
          startAfterTimestamp: state.lastRaffleDate,
          limit: _limit,
          userLoc: userLoc,
        );

        final FeedItems = raffles.map((r) => FeedItem.raffle(r)).toList();
        final bool exhausted = raffles.length < _limit;
        final DateTime? newCursor = raffles.isNotEmpty
            ? raffles.last.createdAt
            : state.lastRaffleDate;

        state = state.copyWith(
          lastRaffleDate: newCursor,
          hasMoreRaffles: !exhausted,
          items: [...state.items, ...FeedItems],
        );
      }

      Future<void> fetchTourneys() async {
        if (!state.hasMoreTournaments) return;
        final tourneys = await hallRepo.fetchTournamentsPage(
          startAfterTimestamp: state.lastTournamentDate,
          limit: _limit,
          userLoc: userLoc,
        );

        final FeedItems = tourneys.map((t) => FeedItem.tournament(t)).toList();
        final bool exhausted = tourneys.length < _limit;
        final DateTime? newCursor = tourneys.isNotEmpty
            ? tourneys.last.createdAt
            : state.lastTournamentDate;

        state = state.copyWith(
          lastTournamentDate: newCursor,
          hasMoreTournaments: !exhausted,
          items: [...state.items, ...FeedItems],
        );
      }

      futures.add(fetchSpecials());
      futures.add(fetchRaffles());
      futures.add(fetchTourneys());

      // Await all distinct collection pulls
      await Future.wait(futures);

      // --- UGC MODERATION FILTERS ---
      final prefs = await SharedPreferences.getInstance();
      final List<String> hiddenRaw = prefs.getStringList('hidden_posts') ?? [];
      final List<String> hiddenIds = hiddenRaw.map((e) {
        try {
          return jsonDecode(e)['id'] as String;
        } catch (_) {
          return e;
        }
      }).toList();

      final List<String> blockedRaw =
          prefs.getStringList('blocked_users') ?? [];
      final List<String> blockedIds = blockedRaw.map((e) {
        try {
          return jsonDecode(e)['id'] as String;
        } catch (_) {
          return e;
        }
      }).toList();

      final List<FeedItem> filteredItems = state.items.where((item) {
        final String authorId = item.map(
          tournament: (t) => t.data.hallId,
          raffle: (r) => r.data.hallId,
          special: (s) => s.data.hallId,
          checkIn: (c) => c.data.userId,
          winPost: (w) => w.data.userId,
          textPost: (tp) => tp.data.userId,
        );

        final String docId = item.map(
          tournament: (t) => t.data.id,
          raffle: (r) => r.data.id,
          special: (s) => s.data.id,
          checkIn: (c) => c.data.id,
          winPost: (w) => w.data.id,
          textPost: (tp) => tp.data.id,
        );

        if (blockedIds.contains(authorId)) return false;
        if (hiddenIds.contains(docId)) return false;

        // EXPIRATION CLAMP: Natively block any chronological event that has physically concluded
        final now = DateTime.now();
        final bool isExpired = item.map(
          tournament: (t) => t.data.endTime != null && t.data.endTime!.isBefore(now),
          raffle: (r) => r.data.endsAt.isBefore(now),
          special: (s) {
            // For instances with an exact endTime
            if (s.data.endTime != null) return s.data.endTime!.isBefore(now);
            // Standalone Specials without endTime expire physically after 7 days
            return s.data.postedAt.isBefore(now.subtract(const Duration(days: 7)));
          },
          checkIn: (c) => c.data.createdAt.isBefore(now.subtract(const Duration(hours: 24))),
          winPost: (w) => false, // Evergreen
          textPost: (tp) => false, // Evergreen
        );

        if (isExpired) return false;

        return true;
      }).toList();

      // 2. Sort the aggregate pool using standard algorithms
      final currentUser = ref.read(userProfileProvider).value;

      final sortedItems = feedRepo.sortFeedByHype(
        filteredItems,
        currentUser,
        [], // squads optimization placeholder
      );

      final overallHasMore =
          state.hasMoreSpecials ||
          state.hasMoreRaffles ||
          state.hasMoreTournaments;

      state = state.copyWith(
        items: sortedItems,
        isLoading: false,
        hasMore: overallHasMore,
      );
    } catch (e) {
      print("Feed pagination error: $e");
      state = state.copyWith(isLoading: false);
    }
  }

  /// Instantly strips a post from the feed and cascades the ID locally
  Future<void> hidePost(String postId, String title) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> hiddenRaw = prefs.getStringList('hidden_posts') ?? [];

    bool exists = hiddenRaw.any((e) {
      try {
        return jsonDecode(e)['id'] == postId;
      } catch (_) {
        return e == postId;
      }
    });

    if (!exists) {
      hiddenRaw.add(jsonEncode({"id": postId, "title": title}));
      await prefs.setStringList('hidden_posts', hiddenRaw);
    }

    // Instantly wipe from active UI array
    final newItems = state.items.where((item) {
      final String docId = item.map(
        tournament: (t) => t.data.id,
        raffle: (r) => r.data.id,
        special: (s) => s.data.id,
        checkIn: (c) => c.data.id,
        winPost: (w) => w.data.id,
        textPost: (tp) => tp.data.id,
      );
      return docId != postId;
    }).toList();

    state = state.copyWith(items: newItems);
  }

  /// Instantly shreds an entire user's history from the feed locally
  Future<void> blockUser(String authorId, String name) async {
    final prefs = await SharedPreferences.getInstance();

    // ENFORCE 24-HOUR COOLDOWN
    final cooldowns = prefs.getStringList('unblock_cooldowns') ?? [];
    for (String cd in cooldowns) {
      try {
        final decoded = jsonDecode(cd);
        if (decoded['id'] == authorId) {
          final int unblockedAt = decoded['timestamp'];
          final int now = DateTime.now().millisecondsSinceEpoch;
          final int delta = now - unblockedAt;
          if (delta < 24 * 60 * 60 * 1000) {
            throw Exception('You cannot re-block this user for 24 hours.');
          }
        }
      } catch (_) {}
    }

    List<String> blockedRaw = prefs.getStringList('blocked_users') ?? [];

    bool exists = blockedRaw.any((e) {
      try {
        return jsonDecode(e)['id'] == authorId;
      } catch (_) {
        return e == authorId;
      }
    });

    if (!exists) {
      blockedRaw.add(jsonEncode({"id": authorId, "name": name}));
      await prefs.setStringList('blocked_users', blockedRaw);
    }

    // Instantly wipe from active UI array
    final newItems = state.items.where((item) {
      final String aId = item.map(
        tournament: (t) => t.data.hallId,
        raffle: (r) => r.data.hallId,
        special: (s) => s.data.hallId,
        checkIn: (c) => c.data.userId,
        winPost: (w) => w.data.userId,
        textPost: (tp) => tp.data.userId,
      );
      return aId != authorId;
    }).toList();

    state = state.copyWith(items: newItems);
  }

  Future<void> unhidePost(String postId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> hiddenRaw = prefs.getStringList('hidden_posts') ?? [];
    hiddenRaw.removeWhere((e) {
      try {
        return jsonDecode(e)['id'] == postId;
      } catch (_) {
        return e == postId;
      }
    });
    await prefs.setStringList('hidden_posts', hiddenRaw);
  }

  Future<void> unblockUser(String authorId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> blockedRaw = prefs.getStringList('blocked_users') ?? [];
    blockedRaw.removeWhere((e) {
      try {
        return jsonDecode(e)['id'] == authorId;
      } catch (_) {
        return e == authorId;
      }
    });
    await prefs.setStringList('blocked_users', blockedRaw);

    // Apply 24H Cooldown record
    List<String> cooldowns = prefs.getStringList('unblock_cooldowns') ?? [];
    cooldowns.removeWhere((e) {
      try {
        return jsonDecode(e)['id'] == authorId;
      } catch (_) {
        return false;
      }
    });
    cooldowns.add(
      jsonEncode({
        "id": authorId,
        "timestamp": DateTime.now().millisecondsSinceEpoch,
      }),
    );
    await prefs.setStringList('unblock_cooldowns', cooldowns);
  }

  /// Mutates the local state machine optimistically so UI filter pills stay cleanly synced
  void toggleLocalRsvp(String postId, String userId, bool isAdding) {
    final updatedItems = state.items.map((item) {
      final docId = item.map(
        tournament: (t) => t.data.id,
        raffle: (r) => r.data.id,
        special: (s) => s.data.id,
        checkIn: (c) => c.data.id,
        winPost: (w) => w.data.id,
        textPost: (tp) => tp.data.id,
      );

      if (docId == postId) {
        return item.map(
          tournament: (t) {
            final List<String> list = List.from(t.data.interestedUserIds);
            isAdding ? list.add(userId) : list.remove(userId);
            return FeedItem.tournament(
              t.data.copyWith(interestedUserIds: list),
            );
          },
          raffle: (r) {
            final List<String> list = List.from(r.data.interestedUserIds);
            isAdding ? list.add(userId) : list.remove(userId);
            return FeedItem.raffle(r.data.copyWith(interestedUserIds: list));
          },
          special: (s) {
            final List<String> list = List.from(s.data.interestedUserIds);
            isAdding ? list.add(userId) : list.remove(userId);
            return FeedItem.special(s.data.copyWith(interestedUserIds: list));
          },
          checkIn: (c) => c,
          winPost: (w) => w,
          textPost: (tp) => tp,
        );
      }
      return item;
    }).toList();

    state = state.copyWith(items: updatedItems);
  }
} // End Controller
