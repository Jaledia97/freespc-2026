import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/repositories/hall_repository.dart';
import '../../../services/location_service.dart';
import 'hall_profile_screen.dart';
import '../../../models/bingo_hall_model.dart'; // Add model import

class HallSearchScreen extends ConsumerStatefulWidget {
  const HallSearchScreen({super.key});

  @override
  ConsumerState<HallSearchScreen> createState() => _HallSearchScreenState();
}

class _HallSearchScreenState extends ConsumerState<HallSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  List<BingoHallModel> _results = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialSuggestions();
  }

  Future<void> _loadInitialSuggestions() async {
    setState(() => _isLoading = true);
    
    // We want all nearby halls, so pass empty list for subscribed exclusions
    final userLocation = ref.read(userLocationStreamProvider).valueOrNull;
    try {
      final suggestions = await ref.read(hallRepositoryProvider).getNearbyHalls(
        [], 
        location: userLocation,
        limit: 10
      );
      
      if (mounted) {
        setState(() {
          _results = suggestions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    // If query is empty, reload suggestions instantly
    if (query.isEmpty) {
       _loadInitialSuggestions();
       return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.length < 2) {
        // Wait for more chars? Or just show suggestions?
        // Let's stick to showing suggestions if < 2 chars.
        _loadInitialSuggestions();
        return;
      }

      setState(() => _isLoading = true);
      
      final userLocation = ref.read(userLocationStreamProvider).valueOrNull;
      final results = await ref.read(hallRepositoryProvider).searchHalls(query, userLocation: userLocation);

      if (mounted) {
        setState(() {
          _results = results;
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search by Name, City, or Zip',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: _onSearchChanged,
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : (_results.isEmpty)
            ? const Center(child: Text('No halls found matching your search.'))
            : ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final hall = _results[index];
                  // If we have user location, show distance
                  final userLocation = ref.read(userLocationStreamProvider).valueOrNull;
                  String subtitle = "${hall.city ?? ''}, ${hall.state ?? ''} ${hall.zipCode ?? ''}".trim();
                  
                  if (subtitle.isEmpty) subtitle = hall.beaconUuid; // Fallback

                  if (userLocation != null) {
                     // We could calc distance again or rely on repo to pass it if we modified model, 
                     // but calc here is cheap for 10 items.
                     // Actually, let's keep it simple.
                  }

                  return ListTile(
                    leading: const Icon(Icons.store),
                    title: Text(hall.name),
                    subtitle: Text(subtitle),
                    onTap: () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (_) => HallProfileScreen(hall: hall))
                      );
                    },
                  );
                },
              ),
    );
  }
}
