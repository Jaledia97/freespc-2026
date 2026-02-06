import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/repositories/hall_repository.dart';
import '../../../../models/bingo_hall_model.dart';
import '../../../../services/auth_service.dart';

class HallSelectionScreen extends ConsumerStatefulWidget {
  const HallSelectionScreen({super.key});

  @override
  ConsumerState<HallSelectionScreen> createState() => _HallSelectionScreenState();
}

class _HallSelectionScreenState extends ConsumerState<HallSelectionScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // We reuse the getAllHalls future/logic. 
    // Since getAllHalls isn't a stream provider yet, we'll use a FutureBuilder wrapper or ref.watch if available.
    // Actually, HallRepository has searchHalls, we can use that for filtered, or getAllHalls.
    // Let's create a future provider ad-hoc or just use FutureBuilder.
    
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Select Hall to Manage'),
        backgroundColor: Colors.transparent, 
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search halls...',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<BingoHallModel>>(
              future: ref.read(hallRepositoryProvider).getAllHalls(), // We assume this gets ALL.
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
                }

                final allHalls = snapshot.data ?? [];
                
                final filtered = allHalls.where((h) {
                   return h.name.toLowerCase().contains(_searchQuery) || 
                          (h.city?.toLowerCase().contains(_searchQuery) ?? false);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text("No halls found", style: TextStyle(color: Colors.white54)));
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final hall = filtered[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.white10,
                        child: Text(hall.name.substring(0,1), style: const TextStyle(color: Colors.white)),
                      ),
                      title: Text(hall.name, style: const TextStyle(color: Colors.white)),
                      subtitle: Text("${hall.city}, ${hall.state}", style: const TextStyle(color: Colors.white54)),
                      trailing: const Icon(Icons.chevron_right, color: Colors.white24),
                      onTap: () async {
                        // Switch Logic
                        final user = ref.read(userProfileProvider).value;
                        if (user != null) {
                          await ref.read(hallRepositoryProvider).toggleHomeBase(user.uid, hall.id, null); // Force set
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Managing: ${hall.name}")));
                            Navigator.pop(context); // Close selection
                          }
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
