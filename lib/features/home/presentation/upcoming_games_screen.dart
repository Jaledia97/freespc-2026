import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/repositories/hall_repository.dart';
import '../../../models/special_model.dart';

class UpcomingGamesScreen extends ConsumerStatefulWidget {
  const UpcomingGamesScreen({super.key});

  @override
  ConsumerState<UpcomingGamesScreen> createState() => _UpcomingGamesScreenState();
}

class _UpcomingGamesScreenState extends ConsumerState<UpcomingGamesScreen> {
  // Simple filters for now
  String _searchQuery = '';
  
  @override
  Widget build(BuildContext context) {
    // Reuse the feed logic but maybe without the 75-mile limit? 
    // User said "in this tab, a new, filterable directory should pop up".
    // Let's assume global access or maybe wider radius? 
    // For now, let's reuse the repository but maybe we need a dedicated 'getAllUpcoming' method 
    // or just filter client side for MVP.
    // Let's use the same stream for now.
    
    // Actually, "directory" implies a structured list.
    final specialsStream = ref.watch(hallRepositoryProvider).getSpecialsFeed(null); // No location filter for directory mode? Or keep it?

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming Games'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Filter by Game or Hall...',
                prefixIcon: const Icon(Icons.search),
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
           
           // Client-side filter
           final results = allSpecials.where((s) {
             return s.title.toLowerCase().contains(_searchQuery) ||
                    s.hallName.toLowerCase().contains(_searchQuery);
           }).toList();

           if (results.isEmpty) return const Center(child: Text("No games found."));

           return ListView.builder(
             itemCount: results.length,
             itemBuilder: (context, index) {
               final special = results[index];
               return Card(
                 margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                 child: ListTile(
                   leading: Container(
                     width: 60, height: 60,
                     decoration: BoxDecoration(
                       borderRadius: BorderRadius.circular(8),
                       image: DecorationImage(image: NetworkImage(special.imageUrl), fit: BoxFit.cover),
                     ),
                   ),
                   title: Text(special.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                   subtitle: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text(special.hallName),
                       if (special.startTime != null)
                         Text(
                           "Starts: ${special.startTime!.toString().substring(0, 16)}", 
                           style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)
                         ),
                     ],
                   ),
                   trailing: const Icon(Icons.chevron_right),
                   onTap: () {
                     // Nav to Hall Profile?
                   },
                 ),
               );
             },
           );
        },
      ),
    );
  }
}
