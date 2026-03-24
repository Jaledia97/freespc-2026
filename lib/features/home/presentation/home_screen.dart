import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/repositories/hall_repository.dart';
import '../../home/repositories/feed_repository.dart';
import 'hall_search_screen.dart';
import 'widgets/special_card.dart';
import 'widgets/raffle_feed_card.dart';
import 'widgets/tournament_feed_card.dart';
import '../../../models/raffle_model.dart';
import '../../../models/tournament_model.dart';
import '../../../models/special_model.dart';
import '../../../models/feed_item.dart';
import '../../../services/location_service.dart';
import '../../friends/presentation/friends_screen.dart';
import '../../friends/presentation/find_friends_screen.dart';
import '../../messaging/presentation/messaging_hub_screen.dart';
import '../../notifications/presentation/notifications_screen.dart';
import '../../../services/auth_service.dart';
import 'hall_search_screen.dart';
import '../../../models/public_profile.dart'; // Add this for PublicProfile
import '../../../models/bingo_hall_model.dart'; // Add this for BingoHallModel
import '../../profile/presentation/public_profile_screen.dart'; // For user routing
import 'hall_profile_screen.dart'; // For hall routing
import 'package:vibration/vibration.dart';

final homeSearchUsersProvider =
    FutureProvider.family<List<PublicProfile>, String>((ref, query) async {
      if (query.isEmpty) return [];
      return ref.read(authServiceProvider).searchUsers(query);
    });

final homeSearchHallsProvider =
    FutureProvider.family<List<BingoHallModel>, String>((ref, query) async {
      if (query.isEmpty) return [];
      final userLoc = ref.read(userLocationStreamProvider).valueOrNull;
      final halls = await ref
          .read(hallRepositoryProvider)
          .getHallsInRadius(
            latitude: userLoc?.latitude ?? 39.8283,
            longitude: userLoc?.longitude ?? -98.5795,
            radiusInMiles: 1000, // broad search
          )
          .first;

      return halls
          .where(
            (h) =>
                h.name.toLowerCase().contains(query) ||
                (h.city?.toLowerCase().contains(query) ?? false),
          )
          .toList();
    });

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'RSVPs',
    'Squad Activity',
    'Tournaments',
    'Raffles',
    'Specials',
  ];

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    Vibration.vibrate(duration: 40);
    final userLocation = ref.read(userLocationStreamProvider).valueOrNull;
    // Just re-fetching data logic (simulated by a short delay in real scenarios, or riverpod invalidation)
    await Future.delayed(const Duration(milliseconds: 800));
    ref.invalidate(hallRepositoryProvider);
  }

  void _onFilterTap(String filter) {
    Vibration.vibrate(duration: 40);
    setState(() => _selectedFilter = filter);
  }

  @override
  Widget build(BuildContext context) {
    final userLocation = ref.watch(userLocationStreamProvider).valueOrNull;
    final specialsStream = ref
        .watch(hallRepositoryProvider)
        .getSpecialsFeed(userLocation);
    final rafflesStream = ref
        .watch(hallRepositoryProvider)
        .getActiveRafflesFeed(userLocation);
    final tournamentsStream = ref
        .watch(hallRepositoryProvider)
        .getActiveTournamentsFeed(userLocation);
    final currentUser = ref
        .watch(authStateChangesProvider)
        .value; // Placeholder for user

    return Scaffold(
      backgroundColor: Colors.black,
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: Colors.amber,
        backgroundColor: const Color(0xFF1E1E1E),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // 1. Sleek Modern Pinned App Bar with top actions
            SliverAppBar(
              title: const Text(
                'FreeSpc',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                  letterSpacing: -1.0,
                ),
              ),
              centerTitle: false,
              floating: true,
              pinned: true,
              backgroundColor: Colors.black.withOpacity(0.95),
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.people_alt),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FriendsScreen()),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MessagingHubScreen(),
                    ),
                  ),
                ),
              ],
            ),

            // 2. The Filter Pill System
            SliverToBoxAdapter(
              child: Container(
                height: 50,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filters.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return GestureDetector(
                        onTap: () {
                          if (!_isSearching) {
                            setState(() => _isSearching = true);
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: _isSearching
                              ? MediaQuery.of(context).size.width * 0.7
                              : 50,
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Row(
                            mainAxisAlignment: _isSearching
                                ? MainAxisAlignment.start
                                : MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.search,
                                color: Colors.white,
                                size: 18,
                              ),
                              if (_isSearching) ...[
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    autofocus: true,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Search FreeSpc...',
                                      hintStyle: TextStyle(
                                        color: Colors.white.withOpacity(0.5),
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isSearching = false;
                                      _searchController.clear();
                                    });
                                  },
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white54,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }

                    final filterIndex = index - 1;
                    final filter = _filters[filterIndex];
                    final isSelected = _selectedFilter == filter;
                    return GestureDetector(
                      onTap: () => _onFilterTap(filter),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 0,
                        ),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white
                              : Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : Colors.white24,
                          ),
                        ),
                        child: Text(
                          filter,
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // 3. Unified S-Tier Feed
            // For now, we manually combine the streams. In a full architecture, this is done in the Repository layer.
            StreamBuilder(
              stream:
                  specialsStream, // Combining everything properly is complex in raw StreamBuilders, simulating raw assembly here:
              builder: (context, specialsSnap) {
                return StreamBuilder(
                  stream: rafflesStream,
                  builder: (context, rafflesSnap) {
                    return StreamBuilder(
                      stream: tournamentsStream,
                      builder: (context, tourneysSnap) {
                        if (specialsSnap.connectionState ==
                            ConnectionState.waiting) {
                          return const SliverFillRemaining(
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        List<FeedItem> allItems = [];

                        // Parse into FeedItems
                        if (specialsSnap.hasData) {
                          for (var s
                              in specialsSnap.data as List<SpecialModel>) {
                            if (_selectedFilter == 'All' ||
                                _selectedFilter == 'Specials') {
                              allItems.add(FeedItem.special(s));
                            } else if (_selectedFilter == 'RSVPs' &&
                                currentUser != null &&
                                s.interestedUserIds.contains(currentUser.uid)) {
                              allItems.add(FeedItem.special(s));
                            }
                          }
                        }
                        if (rafflesSnap.hasData) {
                          for (var r in rafflesSnap.data as List<RaffleModel>) {
                            if (_selectedFilter == 'All' ||
                                _selectedFilter == 'Raffles') {
                              allItems.add(FeedItem.raffle(r));
                            } else if (_selectedFilter == 'RSVPs' &&
                                currentUser != null &&
                                r.interestedUserIds.contains(currentUser.uid)) {
                              allItems.add(FeedItem.raffle(r));
                            }
                          }
                        }
                        if (tourneysSnap.hasData) {
                          for (var t
                              in tourneysSnap.data as List<TournamentModel>) {
                            if (_selectedFilter == 'All' ||
                                _selectedFilter == 'Tournaments') {
                              allItems.add(FeedItem.tournament(t));
                            } else if (_selectedFilter == 'RSVPs' &&
                                currentUser != null &&
                                t.interestedUserIds.contains(currentUser.uid)) {
                              allItems.add(FeedItem.tournament(t));
                            }
                          }
                        }

                        // Use FeedRepository to sort algorithmically
                        allItems = ref
                            .read(feedRepositoryProvider)
                            .sortFeedByHype(allItems, null, []);

                        if (_isSearching && _searchQuery.isNotEmpty) {
                          return _buildSearchResultsOverlay(allItems);
                        }

                        if (allItems.isEmpty) {
                          return const SliverFillRemaining(
                            child: Center(
                              child: Text(
                                "No feed activity. Tell your squad to post!",
                                style: TextStyle(color: Colors.white54),
                              ),
                            ),
                          );
                        }

                        return SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final item = allItems[index];

                            return item.map(
                              tournament: (t) => TournamentFeedCard(
                                tournament: t.data,
                                fullWidth: true,
                              ),
                              raffle: (r) => RaffleFeedCard(
                                raffle: r.data,
                                fullWidth: true,
                              ),
                              special: (s) => SpecialCard(
                                special: s.data,
                                fullWidth: true,
                                isFeatured: false,
                              ),
                              checkIn: (c) => const SizedBox.shrink(),
                              winPost: (w) => const SizedBox.shrink(),
                              textPost: (tp) => const SizedBox.shrink(),
                            );
                          }, childCount: allItems.length),
                        );
                      },
                    );
                  },
                );
              },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 140)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultsOverlay(List<FeedItem> allItems) {
    final usersAsync = ref.watch(homeSearchUsersProvider(_searchQuery));
    final hallsAsync = ref.watch(homeSearchHallsProvider(_searchQuery));

    // Filter local posts
    final matchingPosts = allItems
        .where((item) {
          return item.map(
            tournament: (t) =>
                t.data.title.toLowerCase().contains(_searchQuery) ||
                t.data.description.toLowerCase().contains(_searchQuery),
            raffle: (r) =>
                r.data.name.toLowerCase().contains(_searchQuery) ||
                r.data.description.toLowerCase().contains(_searchQuery),
            special: (s) =>
                s.data.title.toLowerCase().contains(_searchQuery) ||
                s.data.description.toLowerCase().contains(_searchQuery),
            checkIn: (c) => false,
            winPost: (w) => false,
            textPost: (tp) =>
                tp.data.title.toLowerCase().contains(_searchQuery) ||
                tp.data.description.toLowerCase().contains(_searchQuery),
          );
        })
        .take(5)
        .toList();

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Halls Section
            hallsAsync.when(
              data: (halls) {
                if (halls.isEmpty) return const SizedBox.shrink();
                return _buildSectionGroup(
                  "Halls",
                  halls
                      .take(3)
                      .map(
                        (h) => ListTile(
                          leading: const Icon(Icons.store, color: Colors.amber),
                          title: Text(
                            h.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            h.city ?? '',
                            style: const TextStyle(color: Colors.white54),
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HallProfileScreen(hall: h),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => const SizedBox.shrink(),
            ),

            // Posts Section
            if (matchingPosts.isNotEmpty)
              _buildSectionGroup(
                "Posts",
                matchingPosts.map((post) {
                  return post.map(
                    tournament: (t) => ListTile(
                      leading: const Icon(
                        Icons.emoji_events,
                        color: Colors.blueAccent,
                      ),
                      title: Text(
                        t.data.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: const Text(
                        "Tournament",
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                    raffle: (r) => ListTile(
                      leading: const Icon(
                        Icons.local_activity,
                        color: Colors.greenAccent,
                      ),
                      title: Text(
                        r.data.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        "Raffle",
                        style: const TextStyle(color: Colors.white54),
                      ),
                    ),
                    special: (s) => ListTile(
                      leading: const Icon(
                        Icons.local_fire_department,
                        color: Colors.redAccent,
                      ),
                      title: Text(
                        s.data.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        s.data.hallName,
                        style: const TextStyle(color: Colors.white54),
                      ),
                    ),
                    checkIn: (c) => const SizedBox.shrink(),
                    winPost: (w) => const SizedBox.shrink(),
                    textPost: (tp) => const SizedBox.shrink(),
                  );
                }).toList(),
              ),

            // Users Section
            usersAsync.when(
              data: (users) {
                if (users.isEmpty) return const SizedBox.shrink();
                return _buildSectionGroup(
                  "Users",
                  users
                      .take(5)
                      .map(
                        (u) => ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.white12,
                            backgroundImage: u.photoUrl != null
                                ? NetworkImage(u.photoUrl!)
                                : null,
                            child: u.photoUrl == null
                                ? const Icon(Icons.person, color: Colors.white)
                                : null,
                          ),
                          title: Text(
                            "${u.firstName} ${u.lastName}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            "@${u.username}",
                            style: const TextStyle(color: Colors.white54),
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PublicProfileScreen(profile: u),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionGroup(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
