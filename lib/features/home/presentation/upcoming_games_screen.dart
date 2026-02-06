import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/repositories/hall_repository.dart';
import '../../../models/special_model.dart';
import 'widgets/special_card.dart';
import '../../../models/special_model.dart';

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
    'New Player'
  ];

  final List<Color> _categoryColors = [
    Colors.purple[700]!,
    Colors.blue[700]!,
    Colors.deepOrange[700]!,
    Colors.teal[700]!,
    Colors.redAccent[700]!,
    Colors.green[700]!,
    Colors.pink[700]!,
  ];
  
  @override
  Widget build(BuildContext context) {
    // We fetch all (global) specials for the directory. No distance limit? 
    // User implied directory is broader. For MVP, we stick to the feed logic (global or 75mi?).
    // Let's pass null to getSpecialsFeed to get EVERYTHING.
    final specialsStream = ref.watch(hallRepositoryProvider).getSpecialsFeed(null);

    return PopScope(
      canPop: _selectedCategory == null,
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
          leading: _selectedCategory != null 
            ? IconButton(
                icon: const Icon(Icons.arrow_back), 
                onPressed: () => setState(() {
                  _selectedCategory = null;
                  _searchQuery = ''; // Clear search on back?
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
        body: StreamBuilder<List<SpecialModel>>(
          stream: specialsStream,
          builder: (context, snapshot) {
             if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
             if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
             
             final allSpecials = snapshot.data ?? [];
  
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
                           // Add a decorative icon or shape if time permits
                         ],
                       ),
                     ),
                   );
                 },
               );
             }
  
             // --- MODE 2: FILTERED LIST ---
             // Filter by Category AND Search Query
             final results = allSpecials.where((s) {
               final matchesSearch = s.title.toLowerCase().contains(_searchQuery) || s.hallName.toLowerCase().contains(_searchQuery);
               final matchesCategory = _selectedCategory == null || s.tags.contains(_selectedCategory!);
               
               return matchesSearch && matchesCategory;
             }).toList();
  
             if (results.isEmpty) {
               return Center(
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     const Icon(Icons.event_busy, size: 64, color: Colors.grey),
                     const SizedBox(height: 16),
                     Text("No ${_selectedCategory ?? ''} games found."),
                   ],
                 ),
               );
             }
  
             return ListView.builder(
               itemCount: results.length,
               itemBuilder: (context, index) {
                 final special = results[index];
                 return SpecialCard(special: special);
               },
             );
          },
        ),
      ),
    );
  }
}
