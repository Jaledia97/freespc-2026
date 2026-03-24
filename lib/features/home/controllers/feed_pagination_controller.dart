import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../models/feed_item.dart';
import '../../../../models/user_model.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/location_service.dart';
import '../../home/repositories/hall_repository.dart';
import '../../home/repositories/feed_repository.dart';

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

      // 2. Sort the aggregate pool using standard algorithms
      final currentUser = ref.read(authStateChangesProvider).value;
      // We don't have Squad access natively here easily without a provider, but feedRepo handles nulls safely
      final sortedItems = feedRepo.sortFeedByHype(
        List.from(state.items),
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
      print("Feed pagination error: \$e");
      state = state.copyWith(isLoading: false);
    }
  }
}
