import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../services/auth_service.dart';
import '../../../models/public_profile.dart';
import '../repositories/friends_repository.dart';
import 'find_friends_screen.dart';
import '../../messaging/presentation/messaging_hub_screen.dart';
import '../../messaging/repositories/messaging_repository.dart';
import '../../messaging/presentation/chat_screen.dart';

// Provides a list of PublicProfiles for the user's accepted friends
final friendsProfilesProvider = StreamProvider<List<PublicProfile>>((ref) {
  final authState = ref.watch(authStateChangesProvider).value;
  if (authState == null) return const Stream.empty();
  
  return ref.watch(friendsRepositoryProvider).streamFriends(authState.uid).asyncMap((friendships) async {
    final accepted = friendships.where((f) => f.status == 'accepted').toList();
    if (accepted.isEmpty) return [];

    final authService = ref.read(authServiceProvider);
    
    // In a production app with thousands of friends, we'd batch this or use Cloud Functions to sync.
    // For now, fetch public profiles individually.
    final profiles = <PublicProfile>[];
    for (var f in accepted) {
       // It's better to fetch exact. We'll use a direct fetch here:
       final doc = await FirebaseFirestore.instance.collection('public_profiles').doc(f.user2Id).get();
       if (doc.exists && doc.data() != null) {
          profiles.add(PublicProfile.fromJson(doc.data()!));
       }
    }
    
    // Sort logic
    profiles.sort((a, b) {
      // 1. Online Status (Online > Away > Offline)
      int weight(String status) {
        if (status == 'Online') return 3;
        if (status == 'Away') return 2;
        return 1; // Offline
      }
      
      int cmp = weight(b.onlineStatus).compareTo(weight(a.onlineStatus));
      if (cmp != 0) return cmp;
      
      // 2. Proximity (If they have a check-in, we sort them higher, or calculate distance if we have lat/lng)
      // For now, basically checked-in > not checked-in
      if (a.currentCheckInHallId != null && b.currentCheckInHallId == null) return -1;
      if (b.currentCheckInHallId != null && a.currentCheckInHallId == null) return 1;
      
      // 3. Alphabetical fallback
      return a.username.compareTo(b.username);
    });
    
    return profiles;
  });
});

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProfileProvider);
    final friendsAsync = ref.watch(friendsProfilesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Search friends...",
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
              )
            : const Text("Friends"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MessagingHubScreen()));
              },
            ),
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                  _searchQuery = "";
                }
                _isSearching = !_isSearching;
              });
            },
          )
        ],
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text("User not found"));
          return Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.white12)),
                  color: Color(0xFF252525),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: user.photoUrl != null ? CachedNetworkImageProvider(user.photoUrl!) : null,
                      child: user.photoUrl == null ? const Icon(Icons.person) : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.username, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          if (user.realNameVisibility != 'Private')
                            Text("${user.firstName} ${user.lastName}", style: const TextStyle(color: Colors.white70, fontSize: 14)),
                        ],
                      ),
                    ),
                    DropdownButton<String>(
                      value: user.onlineStatus,
                      dropdownColor: const Color(0xFF2C2C2C),
                      style: const TextStyle(color: Colors.white),
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 'Online', child: Row(children: [Icon(Icons.circle, color: Colors.green, size: 12), SizedBox(width: 8), Text('Online')])),
                        DropdownMenuItem(value: 'Away', child: Row(children: [Icon(Icons.circle, color: Colors.amber, size: 12), SizedBox(width: 8), Text('Away')])),
                        DropdownMenuItem(value: 'Offline', child: Row(children: [Icon(Icons.circle, color: Colors.grey, size: 12), SizedBox(width: 8), Text('Offline')])),
                      ],
                      onChanged: (val) {
                        if (val != null) ref.read(authServiceProvider).updateUserProfile(user.uid, onlineStatus: val);
                      }
                    )
                  ],
                ),
              ),

              const SizedBox(height: 16),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                    icon: const Icon(Icons.person_search, color: Colors.white),
                    label: const Text("Find Friend", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const FindFriendsScreen()));
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Friends List
              Expanded(
                child: friendsAsync.when(
                  data: (friends) {
                    var filteredFriends = friends;
                    if (_searchQuery.isNotEmpty) {
                      final q = _searchQuery.toLowerCase();
                      filteredFriends = friends.where((f) {
                        final fullName = "${f.firstName} ${f.lastName}".toLowerCase();
                        return f.username.toLowerCase().contains(q) || fullName.contains(q);
                      }).toList();
                    }

                    if (filteredFriends.isEmpty) {
                      return Center(
                        child: Text(
                          _searchQuery.isNotEmpty ? "No friends found matching '$_searchQuery'." : "No friends yet. Add some!", 
                          style: const TextStyle(color: Colors.white70)
                        )
                      );
                    }
                    
                    return ListView.builder(
                      itemCount: filteredFriends.length,
                      itemBuilder: (context, index) {
                        final friend = filteredFriends[index];
                        Color statusColor = Colors.grey;
                        if (friend.onlineStatus == 'Online') statusColor = Colors.green;
                        if (friend.onlineStatus == 'Away') statusColor = Colors.amber;

                        return ListTile(
                          leading: Stack(
                            children: [
                              CircleAvatar(
                                backgroundImage: friend.photoUrl != null ? CachedNetworkImageProvider(friend.photoUrl!) : null,
                                child: friend.photoUrl == null ? const Icon(Icons.person) : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 12, height: 12,
                                  decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle, border: Border.all(color: const Color(0xFF1E1E1E), width: 2)),
                                )
                              )
                            ],
                          ),
                          title: Text(friend.username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: friend.realNameVisibility == 'Everyone' || friend.realNameVisibility == 'Friends Only'
                              ? Text("${friend.firstName} ${friend.lastName}", style: const TextStyle(color: Colors.white54)) 
                              : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (friend.currentCheckInHallId != null)
                                const Padding(
                                  padding: EdgeInsets.only(right: 8.0),
                                  child: Icon(Icons.location_on, color: Colors.blueAccent, size: 20),
                                ),
                              IconButton(
                                icon: const Icon(Icons.chat, color: Colors.white70, size: 20),
                                onPressed: () async {
                                  try {
                                    final currentUser = ref.read(userProfileProvider).value;
                                    if (currentUser == null) return;
                                    
                                    final chat = await ref.read(messagingRepositoryProvider).createChat(
                                      [currentUser.uid, friend.uid],
                                      {
                                        currentUser.uid: currentUser.username,
                                        friend.uid: friend.username,
                                      }
                                    );
                                    
                                    if (context.mounted) {
                                      Navigator.push(context, MaterialPageRoute(
                                        builder: (_) => ChatScreen(chatId: chat.id, chatName: friend.username)
                                      ));
                                    }
                                  } catch (e) {
                                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                                  }
                                },
                              )
                            ],
                          ),
                        );
                      }
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Center(child: Text("Error loading friends: $e", style: const TextStyle(color: Colors.red))),
                ),
              )

            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text("Error: $e", style: const TextStyle(color: Colors.red))),
      )
    );
  }
}
