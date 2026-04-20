import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../models/venue_model.dart';
import '../../../services/session_context_controller.dart';
import '../../settings/data/display_settings_repository.dart'; // Gives sharedPreferencesProvider access
import 'dart:convert';

class SpoofWorkspaceScreen extends ConsumerStatefulWidget {
  const SpoofWorkspaceScreen({super.key});

  @override
  ConsumerState<SpoofWorkspaceScreen> createState() => _SpoofWorkspaceScreenState();
}

class _SpoofWorkspaceScreenState extends ConsumerState<SpoofWorkspaceScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<VenueModel> _history = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadHistory());
  }

  void _loadHistory() {
    final prefs = ref.read(sharedPreferencesProvider);
    final historyJson = prefs.getStringList('spoof_history') ?? [];
    setState(() {
      _history = historyJson.map((str) {
        try {
          return VenueModel.fromJson(jsonDecode(str) as Map<String, dynamic>);
        } catch (e) {
          return null; // Handle malformed or outdated history gracefully
        }
      }).whereType<VenueModel>().toList();
    });
  }

  void _saveToHistory(VenueModel venue) {
    // Avoid duplicates, keep max 10
    _history.removeWhere((h) => h.id == venue.id);
    _history.insert(0, venue);
    if (_history.length > 10) {
      _history = _history.sublist(0, 10);
    }
    
    final prefs = ref.read(sharedPreferencesProvider);
    final historyStrs = _history.map((h) {
      final json = h.toJson();
      json['id'] = h.id; // ensure ID is cached
      return jsonEncode(json);
    }).toList();
    prefs.setStringList('spoof_history', historyStrs);
  }
  
  bool _isIdQuery(String query) {
    // Firestore IDs are usually 20 alphanumeric characters without spaces
    return query.length >= 20 && !query.contains(' ');
  }

  void _applySpoof(VenueModel venue) {
    ref.read(sessionContextProvider.notifier).switchToBusiness(
      venue.id,
      venue.name,
      'owner',
      isSuperAdmin: true,
    );
    _saveToHistory(venue);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("God Mode Engaged")));
    Navigator.of(context).popUntil((route) => route.isFirst); // Force jump back to root Dashboard
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text('Spoof Workspace'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GlassContainer(
                blur: 15,
                opacity: 0.1,
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    icon: Icon(Icons.search, color: Colors.purpleAccent),
                    hintText: "Search Venue Name or Exact ID...",
                    hintStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim();
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _searchQuery.isEmpty
                  ? _buildHistory()
                  : _isIdQuery(_searchQuery)
                      ? _buildIdSearch()
                      : _buildNameSearch(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistory() {
    if (_history.isEmpty) {
      return const Center(
        child: Text(
          "Enter a search query. Recent spoofs will appear here.",
          style: TextStyle(color: Colors.white54),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
          child: Text("Recent Workplaces", style: TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _history.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildHallCard(_history[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildIdSearch() {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('venues').doc(_searchQuery).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.purpleAccent));
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(
            child: Text("No Venue found with this exact ID.", style: TextStyle(color: Colors.white54)),
          );
        }

        try {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          data['id'] = snapshot.data!.id;
          final venue = VenueModel.fromJson(data);
          return _buildHallCard(venue);
        } catch(e) {
          return Center(child: Text("Error Parsing Venue: \$e", style: const TextStyle(color: Colors.red)));
        }
      },
    );
  }

  Widget _buildNameSearch() {
    final queryLower = _searchQuery.toLowerCase();

    return StreamBuilder<QuerySnapshot>(
      // Listen to all venues natively for Superadmins to allow full case-insensitive filtering
      stream: FirebaseFirestore.instance
          .collection('venues')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.purpleAccent));
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("No Venues registered.", style: TextStyle(color: Colors.white54)),
          );
        }

        final venues = snapshot.data!.docs.map((doc) {
          try {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return VenueModel.fromJson(data);
          } catch (e) {
            print("Failed to parse venue \${doc.id}: \$e");
            return null;
          }
        }).whereType<VenueModel>().where((venue) {
          return venue.name.toLowerCase().contains(queryLower) || 
                 venue.id.toLowerCase().contains(queryLower);
        }).toList();

        // Sort alphabetically to maintain order
        venues.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

        if (venues.isEmpty) {
            return const Center(
              child: Text("No Workplaces match this query.", style: TextStyle(color: Colors.white54)),
            );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: venues.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _buildHallCard(venues[index]);
          },
        );
      },
    );
  }

  Widget _buildHallCard(VenueModel venue) {
    return GlassContainer(
      blur: 10,
      opacity: 0.05,
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.purpleAccent.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            image: venue.logoUrl != null
                ? DecorationImage(image: NetworkImage(venue.logoUrl!), fit: BoxFit.cover)
                : null,
          ),
          child: venue.logoUrl == null ? const Icon(Icons.store, color: Colors.purpleAccent) : null,
        ),
        title: Text(venue.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(venue.id, style: const TextStyle(color: Colors.white54, fontSize: 11, fontFamily: 'monospace')),
            Text("${venue.city}, ${venue.state}", style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
        trailing: OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.purpleAccent),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => _applySpoof(venue),
          child: const Text("Spoof"),
        ),
      ),
    );
  }
}
