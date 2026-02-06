import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/bingo_hall_model.dart';
import '../../home/repositories/hall_repository.dart';
import '../../../services/auth_service.dart';
import 'widgets/special_card.dart';
import 'widgets/raffle_list_card.dart';
import 'widgets/hall_about_tab.dart';
import 'hall_full_gallery_screen.dart';

class HallProfileScreen extends ConsumerWidget {
  final BingoHallModel hall;
  final double? distanceInMeters;
  final int initialTabIndex;

  const HallProfileScreen({
    super.key,
    required this.hall,
    this.distanceInMeters,
    this.initialTabIndex = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      body: DefaultTabController(
        length: 4,
        initialIndex: initialTabIndex,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(hall.name, style: const TextStyle(shadows: [Shadow(blurRadius: 2, color: Colors.black)])),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                       // Banner Image
                       hall.bannerUrl != null 
                         ? Image.network(hall.bannerUrl!, fit: BoxFit.cover)
                         : Container(
                             color: Colors.grey[800],
                             child: const Center(child: Icon(Icons.casino, size: 80, color: Colors.white24)),
                           ),
                       
                       // Gradient Overlay (for text readability)
                       Container(
                         decoration: BoxDecoration(
                           gradient: LinearGradient(
                             begin: Alignment.topCenter,
                             end: Alignment.bottomCenter,
                             colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                             stops: const [0.4, 1.0],
                           ),
                         ),
                       ),

                       // Logo Overlay (Bottom Left)
                       if (hall.logoUrl != null)
                         Positioned(
                           bottom: 10, // Adjust based on collapse behavior if needed
                           left: 16,
                           child: Container(
                             width: 80, 
                             height: 80,
                             decoration: BoxDecoration(
                               shape: BoxShape.circle,
                               border: Border.all(color: Colors.white, width: 2),
                               boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8)],
                               image: DecorationImage(
                                 image: NetworkImage(hall.logoUrl!),
                                 fit: BoxFit.cover,
                               ),
                             ),
                           ),
                         ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                        // Distance & Beacon
                        Row(
                          children: [
                             if (distanceInMeters != null)
                             Container(
                               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                               decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                               child: Text(
                                "${(distanceInMeters! * 0.000621371).toStringAsFixed(1)} mi",
                                style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold),
                               ),
                             ),
                             const SizedBox(width: 8),
                             Expanded(
                               child: Row(
                                 children: [
                                   const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                   const SizedBox(width: 4),
                                   Text("${hall.city}, ${hall.state}", style: const TextStyle(color: Colors.grey), overflow: TextOverflow.ellipsis),
                                 ],
                               ),
                             ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Action Buttons (Follow/Home)
                        userProfileAsync.when(
                          data: (user) {
                            if (user == null) return const SizedBox.shrink();
                            final isFollowing = user.following.contains(hall.id);
                            final isHome = user.homeBaseId == hall.id;

                            return Row(
                              children: [
                                // Follow / Home Button
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      ref.read(hallRepositoryProvider).toggleFollow(
                                        user.uid,
                                        hall.id,
                                        isFollowing,
                                        hall.name, 
                                      );
                                    },
                                    onLongPress: () {
                                        ref.read(hallRepositoryProvider).toggleHomeBase(
                                          user.uid,
                                          hall.id,
                                          user.homeBaseId,
                                        );
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(isHome ? "Home Base Removed" : "Home Base Set!")),
                                        );
                                    },
                                    borderRadius: BorderRadius.circular(30),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: isHome 
                                            ? Colors.deepPurple.withOpacity(0.1) 
                                            : (isFollowing ? Colors.red.withOpacity(0.1) : Colors.grey[100]),
                                        borderRadius: BorderRadius.circular(30),
                                        border: isHome ? Border.all(color: Colors.deepPurple.withOpacity(0.3)) : null,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            isHome 
                                                ? Icons.home 
                                                : (isFollowing ? Icons.favorite : Icons.favorite_border),
                                            color: isHome 
                                                ? Colors.deepPurple
                                                : (isFollowing ? Colors.red : Colors.grey),
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            isHome ? "Home Hall" : (isFollowing ? "Following" : "Follow"), 
                                            style: TextStyle(
                                              fontSize: 14, 
                                              fontWeight: FontWeight.bold,
                                              color: isHome ? Colors.deepPurple : Colors.black87
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // Gallery Button
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                       Navigator.push(context, MaterialPageRoute(builder: (_) => HallFullGalleryScreen(hallId: hall.id, hallName: hall.name)));
                                    },
                                    borderRadius: BorderRadius.circular(30),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.pinkAccent.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.photo_library, color: Colors.pinkAccent, size: 20),
                                          SizedBox(width: 8),
                                          Text("Gallery", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                
                                // Store Button
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("Store coming soon!")),
                                        );
                                    },
                                    borderRadius: BorderRadius.circular(30),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.store_mall_directory, color: Colors.green, size: 20),
                                          SizedBox(width: 8),
                                          Text("Store", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                          loading: () => const SizedBox(height: 60, child: Center(child: CircularProgressIndicator())),
                          error: (e, _) => const SizedBox.shrink(),
                        ),
                    ],
                  ),
                ),
              ),
              // Pinned Tab Bar
               SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  const TabBar(
                    labelColor: Colors.black87,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.blue,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start, // Align to left edge
                    padding: EdgeInsets.zero,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 20),
                    tabs: [
                      Tab(text: "EVENTS"),
                      Tab(text: "RAFFLES"),
                      Tab(text: "TOURNAMENTS"),
                      Tab(text: "ABOUT"),
                    ],
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            children: [
              // 1. Events Tab
              Consumer(
                builder: (context, ref, _) {
                  final specialsAsync = ref.watch(hallSpecialsProvider(hall.id));
                  return specialsAsync.when(
                    data: (specials) {
                      if (specials.isEmpty) {
                         return const Center(child: Text("No upcoming events scheduled."));
                      }
                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: specials.length,
                        itemBuilder: (context, index) => SpecialCard(special: specials[index]),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text("Error: $e")),
                  );
                },
              ),
              
              // 2. Raffles Tab
              Consumer(
                 builder: (context, ref, _) {
                  final rafflesAsync = ref.watch(hallRafflesProvider(hall.id));
                  return rafflesAsync.when(
                    data: (raffles) {
                       if (raffles.isEmpty) {
                         return Center(
                           child: Column(
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                               const Text("No active raffles."),
                               // Dev Tool: Seed Hint
                               TextButton(
                                 onPressed: () async {
                                    try {
                                      await ref.read(hallRepositoryProvider).seedRaffles(hall.id);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Success! Raffles seeded.")));
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error seeding: $e")));
                                      }
                                    }
                                 }, 
                                 child: const Text("Dev: Seed Raffles")
                               ),
                             ],
                           ),
                         );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: raffles.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          return RaffleListCard(raffle: raffles[index]);
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text("Error: $e")),
                  );
                 },
              ),


              // 3. Tournaments Tab
              const Center(child: Text("Tournaments Coming Soon (Phase 21)")),

              // 4. About Tab
              HallAboutTab(hall: hall),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height + 1; // plus 1 for bottom border usually
  @override
  double get maxExtent => _tabBar.preferredSize.height + 1;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white, // Background of pinned tab bar
      child: Column(
        children: [
          _tabBar,
          const Divider(height: 1),
        ],
      )
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
