import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'my_raffles_screen.dart'; // Import MyRafflesScreen
import 'widgets/raffle_ticket_item.dart'; // Import RaffleTicketItem
import 'widgets/transaction_history_list.dart'; // Import TransactionHistoryList
import 'all_memberships_screen.dart'; // Import AllMembershipsScreen
import '../../../services/auth_service.dart';
import '../../wallet/repositories/wallet_repository.dart';
import '../../../models/venue_membership_model.dart';
import '../../../models/tournament_participation_model.dart';
import '../../../models/drink_ticket_model.dart';
import '../../../models/special_model.dart';
import '../../../core/widgets/glass_container.dart';
import '../../home/repositories/venue_repository.dart';
import '../../messaging/presentation/messaging_hub_screen.dart';
import '../../../core/widgets/notification_badge.dart';
import '../../../services/location_service.dart'; // Import LocationService

final focusedMembershipProvider = StateProvider.autoDispose<VenueMembershipModel?>((ref) => null);

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('My Wallet'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const NotificationBadge(
              showForGeneral: false,
              showForManager: false,
              child: Icon(Icons.chat_bubble_outline),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MessagingHubScreen()),
              );
            },
          ),
        ],
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text("Please Log In"));
          final userId = user.uid;

          return SingleChildScrollView(
            padding: const EdgeInsets.only(
              bottom: 150,
            ), // Increased padding for Nav Bar
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Venue Memberships Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Memberships",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AllMembershipsScreen(userId: userId),
                            ),
                          );
                        },
                        child: const Text("See All", style: TextStyle(color: Colors.amber)),
                      ),
                    ],
                  ),
                ),
                
                // 2. Venue Memberships (Cards)
                SizedBox(
                  height: 160,
                  child: _HallCardsParams(
                    userId: userId,
                    followingIds: user.following,
                  ),
                ),

                const SizedBox(height: 32),

                // 2. Dynamic Venue Content
                _DynamicVenueContent(userId: userId),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Error: $e")),
      ),
    );
  }
}

// --- Venue Cards PageView ---
class _HallCardsParams extends ConsumerStatefulWidget {
  final String userId;
  final List<String> followingIds;
  const _HallCardsParams({required this.userId, required this.followingIds});

  @override
  ConsumerState<_HallCardsParams> createState() => _HallCardsParamsState();
}

class _HallCardsParamsState extends ConsumerState<_HallCardsParams> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final membershipsAsync = ref.watch(myMembershipsStreamProvider(widget.userId));
    
    // Batch fetch venues and user location for spatial sorting
    final venueIds = membershipsAsync.valueOrNull?.map((m) => m.venueId).toList() ?? [];
    final allVenuesAsync = ref.watch(venuesStreamProvider(venueIds.join(',')));
    final locationAsync = ref.watch(userLocationStreamProvider);

    List<VenueMembershipModel> _getSortedMemberships(List<VenueMembershipModel> baseMemberships) {
      var memberships = baseMemberships
          .where((m) => widget.followingIds.contains(m.venueId))
          .toList();
      
      final loc = locationAsync.valueOrNull;
      if (loc != null && allVenuesAsync.hasValue) {
        final venues = allVenuesAsync.value!;
        final locationService = ref.read(locationServiceProvider);
        
        memberships.sort((a, b) {
          final venueA = venues.where((v) => v.id == a.venueId).firstOrNull;
          final venueB = venues.where((v) => v.id == b.venueId).firstOrNull;
          
          if (venueA == null || venueB == null) return 0;
          
          final distA = locationService.getDistanceBetween(
            loc.latitude, loc.longitude, venueA.latitude, venueA.longitude
          );
          final distB = locationService.getDistanceBetween(
            loc.latitude, loc.longitude, venueB.latitude, venueB.longitude
          );
          return distA.compareTo(distB);
        });
      }
      return memberships;
    }

    ref.listen(focusedMembershipProvider, (previous, next) {
      if (next != null && membershipsAsync.hasValue) {
        final memberships = _getSortedMemberships(membershipsAsync.value!);
        final index = memberships.indexWhere((m) => m.venueId == next.venueId);
        if (index != -1 && _pageController.hasClients && _pageController.page?.round() != index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
    });

    return membershipsAsync.when(
      data: (allMemberships) {
        final memberships = _getSortedMemberships(allMemberships);

        if (memberships.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (ref.read(focusedMembershipProvider) != null) {
              ref.read(focusedMembershipProvider.notifier).state = null;
            }
          });
          return Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              height: 200,
              child: GlassContainer(
                padding: const EdgeInsets.all(24),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.credit_card_off,
                      size: 48,
                      color: Colors.white38,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "No Active Memberships",
                      style: TextStyle(color: Colors.white70),
                    ),
                    Text(
                      "Join a Place to earn points!",
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Initialize focused membership if null
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final current = ref.read(focusedMembershipProvider);
          if (current == null || !memberships.any((m) => m.venueId == current.venueId)) {
            ref.read(focusedMembershipProvider.notifier).state = memberships[0];
          }
        });

        return PageView.builder(
          controller: _pageController,
          itemCount: memberships.length,
          onPageChanged: (index) {
            final next = memberships[index];
            if (ref.read(focusedMembershipProvider)?.venueId != next.venueId) {
              ref.read(focusedMembershipProvider.notifier).state = next;
            }
          },
          itemBuilder: (context, index) {
            return HallMembershipCard(membership: memberships[index]);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text("Error loading cards: $e")),
    );
  }
}

class HallMembershipCard extends ConsumerWidget {
  final VenueMembershipModel membership;
  const HallMembershipCard({super.key, required this.membership});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Listen to LIVE Venue Data
    final hallAsync = ref.watch(venueStreamProvider(membership.venueId));

    return hallAsync.when(
      data: (venue) {
        // Use Live Data if available, else fallback to Membership snapshot
        final venueName = venue?.name ?? membership.venueName;
        final bannerUrl = venue?.bannerUrl ?? membership.bannerUrl;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            image: bannerUrl != null
                ? DecorationImage(
                    image: NetworkImage(bannerUrl),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.6),
                      BlendMode.darken,
                    ),
                  )
                : null,
            gradient: bannerUrl == null
                ? const LinearGradient(
                    colors: [Color(0xFF2C3E50), Color(0xFF000000)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Venue Name (Live)
                  Expanded(
                    child: Text(
                      venueName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Tier Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.withOpacity(0.5)),
                    ),
                    child: Text(
                      membership.tier,
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              // Balance
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    NumberFormat.decimalPattern().format(membership.balance),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    (venue?.loyaltySettings.currencyName ??
                            membership.currencyName)
                        .toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),

              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "ID: **** 9382",
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                  Icon(
                    Icons.nfc,
                    color: Colors.white.withOpacity(0.4),
                    size: 24,
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox(), // Minimal fallback
    );
  }
}

// --- Dynamic Venue Content ---
class _DynamicVenueContent extends ConsumerWidget {
  final String userId;
  const _DynamicVenueContent({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusedMembership = ref.watch(focusedMembershipProvider);
    
    if (focusedMembership == null) {
      return const SizedBox();
    }

    final hallAsync = ref.watch(venueStreamProvider(focusedMembership.venueId));

    return hallAsync.when(
      data: (venue) {
        final venueType = venue?.venueType ?? 'bingo';

        if (venueType == 'bingo') {
          return _buildBingoLayout(context, userId);
        } else {
          return _buildBarLayout(context, userId, focusedMembership.venueId);
        }
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text("Error: $e")),
    );
  }

  Widget _buildBingoLayout(BuildContext context, String userId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // My Raffles
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "My Raffles",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MyRafflesScreen(),
                  ),
                ),
                child: const Text(
                  "See All",
                  style: TextStyle(color: Colors.amber),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 140,
          child: _RafflesList(userId: userId),
        ),

        const SizedBox(height: 32),

        // My Tournaments
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const Text(
            "Active Tournaments",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _TournamentsList(userId: userId),

        const SizedBox(height: 32),

        // Transaction History
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const Text(
            "History",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        TransactionHistoryList(userId: userId),
      ],
    );
  }

  Widget _buildBarLayout(BuildContext context, String userId, String venueId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // My Drink Tickets (NEW)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const Text(
            "My Drink Tickets",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: _MyDrinkTicketsList(userId: userId, venueId: venueId),
        ),

        const SizedBox(height: 32),

        // Active Specials (NEW)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const Text(
            "Flash Specials",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.amber, 
            ),
          ),
        ),
        const SizedBox(height: 16),
        _ActiveSpecialsList(venueId: venueId),

        const SizedBox(height: 32),

        // Localized History
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const Text(
            "Place History",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        TransactionHistoryList(userId: userId, venueId: venueId),
      ],
    );
  }
}

// --- My Raffles Scroller ---
class _RafflesList extends ConsumerWidget {
  final String userId;
  const _RafflesList({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rafflesAsync = ref.watch(myRafflesStreamProvider(userId));

    return rafflesAsync.when(
      data: (raffles) {
        if (raffles.isEmpty) {
          return const Center(
            child: Text(
              "No tickets collected yet.",
              style: TextStyle(color: Colors.white38),
            ),
          );
        }

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: raffles.length,
          itemBuilder: (context, index) {
            return RaffleTicketItem(ticket: raffles[index]);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => const SizedBox(),
    );
  }
}

// --- My Tournaments List ---
// --- My Tournaments List ---
class _TournamentsList extends ConsumerWidget {
  final String userId;
  const _TournamentsList({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tournamentsAsync = ref.watch(myTournamentsStreamProvider(userId));

    return tournamentsAsync.when(
      data: (tournaments) {
        if (tournaments.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              "Not participating in any tournaments.",
              style: TextStyle(color: Colors.white38),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: tournaments.length,
          separatorBuilder: (c, i) => const Divider(color: Colors.white10),
          itemBuilder: (context, index) {
            return TournamentItem(tournament: tournaments[index]);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => const SizedBox(),
    );
  }
}

class TournamentItem extends ConsumerWidget {
  final TournamentParticipationModel tournament;
  const TournamentItem({super.key, required this.tournament});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to LIVE Venue Data
    final hallAsync = ref.watch(venueStreamProvider(tournament.venueId));

    return hallAsync.when(
      data: (venue) {
        final venueName = venue?.name ?? tournament.venueName;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          tileColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.emoji_events, color: Colors.purple),
          ),
          title: Text(
            tournament.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            venueName,
            style: const TextStyle(color: Colors.white54),
          ), // Use Live Name
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: tournament.status == 'Active'
                      ? Colors.green.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tournament.currentPlacement,
                  style: TextStyle(
                    color: tournament.status == 'Active'
                        ? Colors.green
                        : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const ListTile(
        title: Text("Loading...", style: TextStyle(color: Colors.white38)),
      ),
      error: (_, __) => const SizedBox(),
    );
  }
}

// --- Bar Wallet Modules ---
class _MyDrinkTicketsList extends ConsumerWidget {
  final String userId;
  final String venueId;
  const _MyDrinkTicketsList({required this.userId, required this.venueId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(myDrinkTicketsStreamProvider((userId: userId, venueId: venueId)));

    return ticketsAsync.when(
      data: (tickets) {
        if (tickets.isEmpty) {
          return const Center(
            child: Text(
              "No drink tickets available.",
              style: TextStyle(color: Colors.white38),
            ),
          );
        }

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: tickets.length,
          itemBuilder: (context, index) {
            final ticket = tickets[index];
            return Container(
              width: 160,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blueAccent.withOpacity(0.4)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Icon(Icons.local_bar, color: Colors.blueAccent, size: 32),
                  Text(
                    ticket.title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    ticket.description,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => const SizedBox(),
    );
  }
}

class _ActiveSpecialsList extends ConsumerWidget {
  final String venueId;
  const _ActiveSpecialsList({required this.venueId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final specialsAsync = ref.watch(hallSpecialsProvider(venueId));

    return specialsAsync.when(
      data: (specials) {
        if (specials.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "No active specials right now.",
              style: TextStyle(color: Colors.white38),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: specials.length,
          separatorBuilder: (c, i) => const Divider(color: Colors.white10),
          itemBuilder: (context, index) {
            final special = specials[index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              tileColor: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.flash_on, color: Colors.amber),
              ),
              title: Text(
                special.title,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                special.description,
                style: const TextStyle(color: Colors.white70),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.white24),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => const SizedBox(),
    );
  }
}
