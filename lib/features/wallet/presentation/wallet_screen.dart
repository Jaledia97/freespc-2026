import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
                      TextButton(onPressed: (){}, child: const Text("See All", style: TextStyle(color: Colors.amber))),
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
            return _buildHallCard(memberships[index]);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text("Error loading cards: $e")),
    );
  }

  Widget _buildHallCard(HallMembershipModel membership) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
         borderRadius: BorderRadius.circular(24),
         image: membership.bannerUrl != null 
             ? DecorationImage(
                 image: NetworkImage(membership.bannerUrl!), 
                 fit: BoxFit.cover,
                 colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.darken),
               )
             : null,
         gradient: membership.bannerUrl == null ? const LinearGradient(
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
              // Hall Name
              Expanded(
                child: Text(
                  membership.hallName,
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
           return const Center(child: Text("No tickets purchased yet.", style: TextStyle(color: Colors.white38)));
        }

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: raffles.length,
          itemBuilder: (context, index) {
            final ticket = raffles[index];
            return GestureDetector(
              onTap: () async {
                 // Navigate to Hall Profile (Raffles Tab)
                 try {
                   final hall = await ref.read(hallRepositoryProvider).getHallStream(ticket.hallId).first;
                   if (hall != null && context.mounted) {
                     Navigator.push(
                       context, 
                       MaterialPageRoute(
                         builder: (_) => HallProfileScreen(hall: hall, initialTabIndex: 1) // 1 = Raffles Tab
                       )
                     );
                   } else if (context.mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Hall not found")));
                   }
                 } catch (e) {
                   if (context.mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error loading hall")));
                   }
                 }
              },
              child: Container(
                width: 280,
                margin: const EdgeInsets.only(right: 12),
                child: Stack(
                  children: [
                    // Ticket Shape (Visual approximation)
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF252525),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        children: [
                          // Left Stub (Image)
                          Container(
                            width: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                              image: ticket.imageUrl != null 
                                ? DecorationImage(image: NetworkImage(ticket.imageUrl!), fit: BoxFit.cover)
                                : null,
                            ),
                            child: ticket.imageUrl == null ? const Center(child: Icon(Icons.confirmation_number, color: Colors.white24)) : null,
                          ),
                          
                          // Dashed Line
                          Container(width: 1, color: Colors.white10, margin: const EdgeInsets.symmetric(horizontal: 2)),
                          
                          // Details
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(ticket.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 4),
                                  Text(ticket.hallName, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                                  const Spacer(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("x${ticket.quantity} Tickets", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                                      const Icon(Icons.qr_code, color: Colors.white24, size: 20),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
            final t = tournaments[index];
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
              title: Text(t.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text(t.hallName, style: const TextStyle(color: Colors.white54)),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: t.status == 'Active' ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      t.currentPlacement, 
                      style: TextStyle(
                        color: t.status == 'Active' ? Colors.green : Colors.grey, 
                        fontWeight: FontWeight.bold, fontSize: 12
                      ),
                    ),
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
