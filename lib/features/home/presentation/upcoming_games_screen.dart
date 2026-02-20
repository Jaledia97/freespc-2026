import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freespc/features/home/repositories/hall_repository.dart';
import 'package:freespc/features/manager/repositories/tournament_repository.dart';
import 'package:freespc/features/wallet/repositories/wallet_repository.dart';
import 'package:freespc/services/auth_service.dart';
import 'package:freespc/models/special_model.dart';
import 'package:freespc/models/tournament_model.dart';
import 'widgets/special_card.dart';
import 'widgets/tournament_list_card.dart';

class UpcomingGamesScreen extends ConsumerStatefulWidget {
  final String? initialCategory;
  const UpcomingGamesScreen({super.key, this.initialCategory});

  @override
  ConsumerState<UpcomingGamesScreen> createState() => _UpcomingGamesScreenState();
}

class _UpcomingGamesScreenState extends ConsumerState<UpcomingGamesScreen> {
  String _searchQuery = '';
  String? _selectedCategory; 

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  final List<String> _categories = [
    'Session',
    'Regular Program',
    'Specials', 
    'Pulltabs', 
    'Progressives', 
    'Raffles',
    'Tournaments', // Added
    'New Player'
  ];

  final List<Color> _categoryColors = [
    Colors.purple[700]!,
    Colors.blue[700]!,
    Colors.deepOrange[700]!,
    Colors.teal[700]!,
    Colors.redAccent[700]!,
    Colors.green[700]!,
    Colors.indigo[700]!, // Color for Tournaments
    Colors.pink[700]!,
  ];
  
  @override
  Widget build(BuildContext context) {
    // Determine streams based on category
    final isTournamentMode = _selectedCategory == 'Tournaments';
    
    // Unified Data Logic using AsyncValue
    // This prevents stream re-creation on every build
    final AsyncValue<List<dynamic>> feedAsync;
    
    if (isTournamentMode) {
      feedAsync = ref.watch(tournamentsFeedProvider).whenData((list) => List<dynamic>.from(list));
    } else {
      feedAsync = ref.watch(specialsFeedProvider).whenData((list) => List<dynamic>.from(list));
    }

    return PopScope(
      canPop: _selectedCategory == null || widget.initialCategory != null,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        setState(() {
          _selectedCategory = null;
          _searchQuery = '';
        });
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_selectedCategory ?? 'Upcoming Games'),
          leading: (_selectedCategory != null && widget.initialCategory == null)
            ? IconButton(
                icon: const Icon(Icons.arrow_back), 
                onPressed: () => setState(() {
                  _selectedCategory = null;
                  _searchQuery = ''; 
                })
              ) 
            : null,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: _selectedCategory != null 
                     ? 'Search inside $_selectedCategory...' 
                     : 'Search all games...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: (_searchQuery.isNotEmpty) 
                     ? IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _searchQuery = '')) 
                     : null,
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                ),
                onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
              ),
            ),
          ),
        ),
        body: feedAsync.when(
          data: (allItems) {
             // --- MODE 1: GRID VIEW (Categories) ---
             if (_selectedCategory == null && _searchQuery.isEmpty) {
               return GridView.builder(
                 padding: const EdgeInsets.all(16),
                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                   crossAxisCount: 2,
                   childAspectRatio: 1.6,
                   crossAxisSpacing: 16,
                   mainAxisSpacing: 16,
                 ),
                 itemCount: _categories.length,
                 itemBuilder: (context, index) {
                   return InkWell(
                     onTap: () {
                       setState(() => _selectedCategory = _categories[index]);
                     },
                     borderRadius: BorderRadius.circular(12),
                     child: Container(
                       decoration: BoxDecoration(
                         gradient: LinearGradient(
                           colors: [_categoryColors[index % _categoryColors.length], _categoryColors[index % _categoryColors.length].withOpacity(0.7)],
                           begin: Alignment.topLeft, end: Alignment.bottomRight,
                         ),
                         borderRadius: BorderRadius.circular(12),
                         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(2, 2))],
                       ),
                       padding: const EdgeInsets.all(16),
                       child: Stack(
                         children: [
                           Text(
                             _categories[index],
                             style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                           ),
                         ],
                       ),
                     ),
                   );
                 },
               );
             }
  
             // --- MODE 2: FILTERED LIST ---
             final results = allItems.where((item) {
               String title = '';
               String hallName = '';
               List<String> tags = [];

               if (item is SpecialModel) {
                 title = item.title;
                 hallName = item.hallName;
                 tags = item.tags;
               } else if (item is TournamentModel) {
                 title = item.title;
                 // As noted, TournamentModel lacks hallName currently, so search might be limited
                 tags = ['Tournaments']; 
               }

               final matchesSearch = title.toLowerCase().contains(_searchQuery) || hallName.toLowerCase().contains(_searchQuery);
               final matchesCategory = _selectedCategory == null || tags.contains(_selectedCategory!) || (_selectedCategory == 'Tournaments' && item is TournamentModel);
               
               return matchesSearch && matchesCategory;
             }).toList();
  
             return CustomScrollView(
               slivers: [
                 // 1. My Active Items Section (Only if Category Selected & User Logged In)
                 if (_selectedCategory != null)
                   _buildMyItemsSection(context, ref, _selectedCategory!),

                 // 2. Main List
                 if (results.isEmpty)
                   SliverFillRemaining(
                     child: Center(
                       child: Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           const Icon(Icons.event_busy, size: 64, color: Colors.grey),
                           const SizedBox(height: 16),
                           Text("No ${_selectedCategory ?? ''} games found."),
                         ],
                       ),
                     ),
                   )
                 else
                   SliverList(
                     delegate: SliverChildBuilderDelegate(
                       (context, index) {
                         final item = results[index];
                         if (item is TournamentModel) {
                           return TournamentListCard(tournament: item, showHallName: true);
                         } else if (item is SpecialModel) {
                           return SpecialCard(special: item);
                         }
                         return const SizedBox.shrink();
                       },
                       childCount: results.length,
                     ),
                   ),
               ],
             );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text("Error: $e")),
        ),
      ),
    );
  }

  Widget _buildMyItemsSection(BuildContext context, WidgetRef ref, String category) {
    final user = ref.watch(userProfileProvider).value;
    if (user == null) return const SliverToBoxAdapter(child: SizedBox.shrink());

    if (category == 'Raffles') {
      final myRafflesAsync = ref.watch(myRafflesStreamProvider(user.uid));
      return myRafflesAsync.when(
        data: (raffles) {
          if (raffles.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
          return SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text("MY ACTIVE TICKETS", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                ),
                // Horizontal Scroll for Tickets? Or just stack them? 
                // Requests said "Top of the page separated".
                // Let's do a highlighted container.
                Container(
                  color: Colors.green.withOpacity(0.05),
                  child: Column(
                    children: raffles.take(3).map((ticket) => ListTile(
                      leading: const Icon(Icons.confirmation_number, color: Colors.green),
                      title: Text(ticket.title),
                      subtitle: Text(ticket.hallName),
                      trailing: Text("x${ticket.quantity}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    )).toList(),
                  ),
                ),
                if (raffles.length > 3)
                   Padding(
                     padding: const EdgeInsets.all(8.0),
                     child: Center(child: Text("+ ${raffles.length - 3} more in Wallet", style: const TextStyle(fontSize: 12, color: Colors.grey))),
                   ),
                const Divider(),
              ],
            ),
          );
        },
        loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
        error: (_,__) => const SliverToBoxAdapter(child: SizedBox.shrink()),
      );
    } 
    
    if (category == 'Tournaments') {
      final myTournamentsAsync = ref.watch(myTournamentsStreamProvider(user.uid));
      return myTournamentsAsync.when(
        data: (tournaments) {
          if (tournaments.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
          return SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text("MY TOURNAMENTS", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                ),
                Container(
                  color: Colors.indigo.withOpacity(0.05),
                  child: Column(
                    children: tournaments.take(3).map((t) => ListTile(
                      leading: const Icon(Icons.emoji_events, color: Colors.indigo),
                      title: Text(t.title),
                      subtitle: Text(t.hallName), // Need to ensure hallName is populated or fetched
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: Colors.indigo, borderRadius: BorderRadius.circular(4)),
                        child: Text(t.currentPlacement, style: const TextStyle(color: Colors.white, fontSize: 10)),
                      ),
                    )).toList(),
                  ),
                ),
                 if (tournaments.length > 3)
                   Padding(
                     padding: const EdgeInsets.all(8.0),
                     child: Center(child: Text("+ ${tournaments.length - 3} more in Wallet", style: const TextStyle(fontSize: 12, color: Colors.grey))),
                   ),
                const Divider(),
              ],
            ),
          );
        },
        loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
        error: (_,__) => const SliverToBoxAdapter(child: SizedBox.shrink()),
      );
    }

    return const SliverToBoxAdapter(child: SizedBox.shrink());
  }
}
