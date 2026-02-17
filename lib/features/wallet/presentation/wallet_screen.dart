import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'my_raffles_screen.dart'; // Import MyRafflesScreen
import 'widgets/raffle_ticket_item.dart'; // Import RaffleTicketItem
import '../../../services/auth_service.dart';
import '../../wallet/repositories/wallet_repository.dart';
import '../../../models/hall_membership_model.dart';
import '../../../models/raffle_ticket_model.dart';
import '../../../models/tournament_participation_model.dart';
import '../../../core/widgets/glass_container.dart';
import '../../home/presentation/hall_profile_screen.dart';
import '../../home/repositories/hall_repository.dart';

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
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text("Please Log In"));
          final userId = user.uid;

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 150), // Increased padding for Nav Bar
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Hall Memberships (Cards)
                SizedBox(
                  height: 220,
                  child: _HallCardsParams(userId: userId, followingIds: user.following),
                ),

                const SizedBox(height: 32),

                // 2. My Raffles
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("My Raffles", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyRafflesScreen())),
                        child: const Text("See All", style: TextStyle(color: Colors.amber)),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 140, // Height for Ticket Stub
                  child: _RafflesList(userId: userId),
                ),

                const SizedBox(height: 32),

                // 3. My Tournaments
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Text("Active Tournaments", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                const SizedBox(height: 16),
                _TournamentsList(userId: userId),
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

// --- Hall Cards PageView ---
class _HallCardsParams extends ConsumerWidget {
  final String userId;
  final List<String> followingIds;
  const _HallCardsParams({required this.userId, required this.followingIds});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membershipsAsync = ref.watch(myMembershipsStreamProvider((userId: userId, followingIds: followingIds)));

    return membershipsAsync.when(
      data: (memberships) {
        if (memberships.isEmpty) {
          return Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              height: 200,
              child: GlassContainer(
                padding: const EdgeInsets.all(24),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     Icon(Icons.credit_card_off, size: 48, color: Colors.white38),
                     SizedBox(height: 16),
                     Text("No Active Memberships", style: TextStyle(color: Colors.white70)),
                     Text("Join a Hall to earn points!", style: TextStyle(color: Colors.white38, fontSize: 12)),
                  ],
                ),
              ),
            ),
          );
        }

        return PageView.builder(
          controller: PageController(viewportFraction: 0.9),
          itemCount: memberships.length,
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
  final HallMembershipModel membership;
  const HallMembershipCard({super.key, required this.membership});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Listen to LIVE Hall Data
    final hallAsync = ref.watch(hallStreamProvider(membership.hallId));

    return hallAsync.when(
      data: (hall) {
        // Use Live Data if available, else fallback to Membership snapshot
        final hallName = hall?.name ?? membership.hallName;
        final bannerUrl = hall?.bannerUrl ?? membership.bannerUrl;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
             borderRadius: BorderRadius.circular(24),
             image: bannerUrl != null 
                 ? DecorationImage(
                     image: NetworkImage(bannerUrl), 
                     fit: BoxFit.cover,
                     colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.darken),
                   )
                 : null,
             gradient: bannerUrl == null ? const LinearGradient(
               colors: [Color(0xFF2C3E50), Color(0xFF000000)],
               begin: Alignment.topLeft,
               end: Alignment.bottomRight,
             ) : null,
             boxShadow: [
               BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0,5)),
             ]
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Hall Name (Live)
                  Expanded(
                    child: Text(
                      hallName,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Tier Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amber.withOpacity(0.5)),
                    ),
                    child: Text(membership.tier, style: const TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),

              // Balance
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    NumberFormat.decimalPattern().format(membership.balance),
                    style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: -1),
                  ),
                  Text(
                    membership.currencyName.toUpperCase(),
                    style: const TextStyle(color: Colors.white54, fontSize: 14, letterSpacing: 1.5),
                  ),
                ],
              ),

              // Footer
              Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   const Text("Member ID: **** 9382", style: TextStyle(color: Colors.white38, fontSize: 12)),
                   Icon(Icons.nfc, color: Colors.white.withOpacity(0.3), size: 32),
                 ],
              ),
            ],
          ),
        );
      },
      loading: () => Container(
         margin: const EdgeInsets.symmetric(horizontal: 8),
         decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(24)),
         child: const Center(child: CircularProgressIndicator()),
      ),
      error: (_,__) => const SizedBox(), // Minimal fallback
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
           return const Center(child: Text("No tickets collected yet.", style: TextStyle(color: Colors.white38)));
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
            child: Text("Not participating in any tournaments.", style: TextStyle(color: Colors.white38)),
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
    // Listen to LIVE Hall Data
    final hallAsync = ref.watch(hallStreamProvider(tournament.hallId));

    return hallAsync.when(
      data: (hall) {
        final hallName = hall?.name ?? tournament.hallName;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          tileColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.emoji_events, color: Colors.purple),
          ),
          title: Text(tournament.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: Text(hallName, style: const TextStyle(color: Colors.white54)), // Use Live Name
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: tournament.status == 'Active' ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tournament.currentPlacement, 
                  style: TextStyle(
                    color: tournament.status == 'Active' ? Colors.green : Colors.grey, 
                    fontWeight: FontWeight.bold, fontSize: 12
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const ListTile(title: Text("Loading...", style: TextStyle(color: Colors.white38))),
      error: (_,__) => const SizedBox(),
    );
  }
}
