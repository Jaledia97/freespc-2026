import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../models/bingo_hall_model.dart';
import '../../../services/session_context_controller.dart';

class SpoofWorkspaceScreen extends ConsumerStatefulWidget {
  const SpoofWorkspaceScreen({super.key});

  @override
  ConsumerState<SpoofWorkspaceScreen> createState() => _SpoofWorkspaceScreenState();
}

class _SpoofWorkspaceScreenState extends ConsumerState<SpoofWorkspaceScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  bool _isIdQuery(String query) {
    // Firestore IDs are usually 20 alphanumeric characters without spaces
    return query.length >= 20 && !query.contains(' ');
  }

  void _applySpoof(BingoHallModel hall) {
    ref.read(sessionContextProvider.notifier).switchToBusiness(
      hall.id,
      hall.name,
      'owner',
      isSuperAdmin: true,
    );
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
                    hintText: "Search Hall Name or Exact ID...",
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
                  ? const Center(
                      child: Text(
                        "Enter a search query.",
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : _isIdQuery(_searchQuery)
                      ? _buildIdSearch()
                      : _buildNameSearch(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdSearch() {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('bingo_halls').doc(_searchQuery).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.purpleAccent));
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(
            child: Text("No Hall found with this exact ID.", style: TextStyle(color: Colors.white54)),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        data['id'] = snapshot.data!.id;
        final hall = BingoHallModel.fromJson(data);

        return _buildHallCard(hall);
      },
    );
  }

  Widget _buildNameSearch() {
    // Note: Firestore string ranges are case sensitive.
    // If name is saved exactly case sensitive, this will match prefix.
    String startAt = _searchQuery;
    String endAt = '$_searchQuery\\uf8ff';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bingo_halls')
          .orderBy('name')
          .startAt([startAt])
          .endAt([endAt])
          .limit(20)
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
            child: Text("No Halls match this name.", style: TextStyle(color: Colors.white54)),
          );
        }

        final halls = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return BingoHallModel.fromJson(data);
        }).toList();

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: halls.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _buildHallCard(halls[index]);
          },
        );
      },
    );
  }

  Widget _buildHallCard(BingoHallModel hall) {
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
            image: hall.logoUrl != null
                ? DecorationImage(image: NetworkImage(hall.logoUrl!), fit: BoxFit.cover)
                : null,
          ),
          child: hall.logoUrl == null ? const Icon(Icons.store, color: Colors.purpleAccent) : null,
        ),
        title: Text(hall.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(hall.id, style: const TextStyle(color: Colors.white54, fontSize: 11, fontFamily: 'monospace')),
            Text("${hall.city}, ${hall.state}", style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
        trailing: OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.purpleAccent),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => _applySpoof(hall),
          child: const Text("Spoof"),
        ),
      ),
    );
  }
}
