import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../services/auth_service.dart';
import '../../scan/presentation/scan_screen.dart'; // Ensure this path is correct, might be lib/features/scan/presentation/scan_screen.dart
import '../repositories/friends_repository.dart';
import '../../../models/public_profile.dart';

class FindFriendsScreen extends ConsumerWidget {
  const FindFriendsScreen({super.key});

  void _shareLink(String uid) {
    Share.share("Add me as a friend on FreeSpc! freespc://add_friend?uid=$uid");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text("Find Friends"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text("User not found", style: TextStyle(color: Colors.white)));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const _ManualSearchSection(),
                const SizedBox(height: 32),
                
                const Text(
                  "Scan QR Code to Add",
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Have your friend scan this code to send a friend request.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 32),
                
                // QR Code Display
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: QrImageView(
                    data: "freespc://add_friend?uid=${user.uid}",
                    version: QrVersions.auto,
                    size: 200,
                  ),
                ),
                
                const SizedBox(height: 32),

                // Scan Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                    label: const Text("Scan a Friend's QR", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanScreen()));
                    },
                  ),
                ),

                const SizedBox(height: 16),
                const Row(
                  children: [
                    Expanded(child: Divider(color: Colors.white24)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text("OR", style: TextStyle(color: Colors.white54)),
                    ),
                    Expanded(child: Divider(color: Colors.white24)),
                  ],
                ),
                const SizedBox(height: 16),

                // Share Link Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.greenAccent),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.share, color: Colors.greenAccent),
                    label: const Text("Share Invite Link", style: TextStyle(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                    onPressed: () => _shareLink(user.uid),
                  ),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text("Error: $e", style: const TextStyle(color: Colors.red))),
      ),
    );
  }
}

class _ManualSearchSection extends ConsumerStatefulWidget {
  const _ManualSearchSection();

  @override
  ConsumerState<_ManualSearchSection> createState() => _ManualSearchSectionState();
}

class _ManualSearchSectionState extends ConsumerState<_ManualSearchSection> {
  final TextEditingController _searchController = TextEditingController();
  List<PublicProfile> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      if (mounted) setState(() {
        _searchResults = [];
        _hasSearched = false;
      });
      return;
    }
    
    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    final results = await ref.read(authServiceProvider).searchUsers(query.trim());
    
    if (mounted) {
      setState(() {
         // Filter out self if needed, but for simplicity let users see themselves
         _searchResults = results;
         _isSearching = false;
      });
    }
  }

  void _sendRequest(PublicProfile profile) async {
    final user = ref.read(userProfileProvider).value;
    if (user == null) return;
    
    try {
      await ref.read(friendsRepositoryProvider).sendFriendRequest(user.uid, profile.uid);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Request sent to @${profile.username}!"), backgroundColor: Colors.green));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Search by username or name...",
            hintStyle: const TextStyle(color: Colors.white54),
            prefixIcon: const Icon(Icons.search, color: Colors.white54),
            filled: true,
            fillColor: const Color(0xFF2C2C2C),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            suffixIcon: IconButton(
              icon: const Icon(Icons.send, color: Colors.blueAccent),
              onPressed: () => _performSearch(_searchController.text),
            )
          ),
          onSubmitted: _performSearch,
        ),
        
        if (_isSearching)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          ),
          
        if (!_isSearching && _hasSearched && _searchResults.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: Text("No users found.", style: TextStyle(color: Colors.white54))),
          ),
          
        if (!_isSearching && _searchResults.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2C),
              borderRadius: BorderRadius.circular(12)
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _searchResults.length > 5 ? 5 : _searchResults.length, // Limit visible results
              separatorBuilder: (context, index) => const Divider(color: Colors.white12, height: 1),
              itemBuilder: (context, index) {
                final result = _searchResults[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(result.username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: result.realNameVisibility == 'Everyone' || result.realNameVisibility == 'Friends Only'
                    ? Text("${result.firstName} ${result.lastName}", style: const TextStyle(color: Colors.white54))
                    : null,
                  trailing: IconButton(
                    icon: const Icon(Icons.person_add, color: Colors.blueAccent),
                    onPressed: () => _sendRequest(result),
                  ),
                );
              },
            ),
          )
      ],
    );
  }
}
