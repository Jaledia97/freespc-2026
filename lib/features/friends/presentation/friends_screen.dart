import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../services/auth_service.dart';
import '../../../models/public_profile.dart';
import '../repositories/friends_repository.dart';
import 'find_friends_screen.dart';
import 'widgets/create_squad_sheet.dart';
import '../../messaging/presentation/messaging_hub_screen.dart';
import '../../messaging/repositories/messaging_repository.dart';
import '../../messaging/presentation/chat_screen.dart';
import '../../profile/presentation/public_profile_screen.dart';
import '../../../core/widgets/notification_badge.dart';
import '../../../core/utils/presence_utils.dart';

// Provides a list of PublicProfiles for the user's accepted friends
final friendsProfilesProvider = StreamProvider<List<PublicProfile>>((ref) {
  final authState = ref.watch(authStateChangesProvider).value;
  if (authState == null) return const Stream.empty();

  return ref
      .watch(friendsRepositoryProvider)
      .streamFriends(authState.uid)
      .asyncMap((friendships) async {
        final accepted = friendships
            .where((f) => f.status == 'accepted')
            .toList();
        if (accepted.isEmpty) return [];

        // Fetch public profiles individually.
        final profiles = <PublicProfile>[];
        for (var f in accepted) {
          final doc = await FirebaseFirestore.instance
              .collection('public_profiles')
              .doc(f.user2Id)
              .get();
          if (doc.exists && doc.data() != null) {
            profiles.add(PublicProfile.fromJson(doc.data()!));
          }
        }

        // Sort logic
        profiles.sort((a, b) {
          int weight(String status) {
            if (status == 'Online') return 3;
            if (status == 'Away') return 2;
            return 1; // Offline
          }

          final aDerived = PresenceUtils.getDerivedStatus(a.onlineStatus, a.lastSeen);
          final bDerived = PresenceUtils.getDerivedStatus(b.onlineStatus, b.lastSeen);

          int cmp = weight(bDerived).compareTo(weight(aDerived));
          if (cmp != 0) return cmp;

          // 2. Proximity (If they have a check-in, we sort them higher)
          if (a.currentCheckInHallId != null && b.currentCheckInHallId == null)
            return -1;
          if (b.currentCheckInHallId != null && a.currentCheckInHallId == null)
            return 1;

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
      body: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text("User not found"));
          return CustomScrollView(
            slivers: [
              // 1. Sleek SliverAppBar
              SliverAppBar(
                backgroundColor: const Color(0xFF1E1E1E),
                pinned: true,
                elevation: 0,
                title: const Text(
                  "Friends",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.person_add_alt),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const FindFriendsScreen(),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.group_add),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const CreateSquadSheet(),
                      );
                    },
                  ),
                  IconButton(
                    icon: const NotificationBadge(
                      showForGeneral: false,
                      showForManager: false,
                      child: Icon(Icons.chat_bubble_outline),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MessagingHubScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),

              // 2. Persistent Search Capsule
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: "Search friends...",
                        hintStyle: TextStyle(color: Colors.white54),
                        prefixIcon: Icon(Icons.search, color: Colors.white54),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 3. Compact My Status Toggle Row
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: user.photoUrl != null
                            ? CachedNetworkImageProvider(user.photoUrl!)
                            : null,
                        child: user.photoUrl == null
                            ? const Icon(Icons.person, size: 16)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "My Status:",
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: DropdownButton<String>(
                          value: user.onlineStatus,
                          dropdownColor: const Color(0xFF2C2C2C),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                          icon: const SizedBox.shrink(),
                          underline: const SizedBox.shrink(),
                          isDense: true,
                          items: const [
                            DropdownMenuItem(
                              value: 'Online',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    color: Colors.greenAccent,
                                    size: 10,
                                  ),
                                  SizedBox(width: 6),
                                  Text('Online'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'Away',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    color: Colors.amber,
                                    size: 10,
                                  ),
                                  SizedBox(width: 6),
                                  Text('Away'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'Offline',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    color: Colors.grey,
                                    size: 10,
                                  ),
                                  SizedBox(width: 6),
                                  Text('Offline'),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null)
                              ref
                                  .read(authServiceProvider)
                                  .updateUserProfile(
                                    user.uid,
                                    onlineStatus: val,
                                  );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverPadding(padding: EdgeInsets.only(bottom: 16)),

              // 4. The Live Friends Feed
              friendsAsync.when(
                data: (friends) {
                  var filteredFriends = friends;
                  if (_searchQuery.isNotEmpty) {
                    final q = _searchQuery.toLowerCase();
                    filteredFriends = friends.where((f) {
                      final fullName = "${f.firstName} ${f.lastName}"
                          .toLowerCase();
                      return f.username.toLowerCase().contains(q) ||
                          fullName.contains(q);
                    }).toList();
                  }

                  if (filteredFriends.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          _searchQuery.isNotEmpty
                              ? "No friends found matching '$_searchQuery'."
                              : "No friends yet. Tap + to add some!",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final friend = filteredFriends[index];
                      final derivedStatus = PresenceUtils.getDerivedStatus(friend.onlineStatus, friend.lastSeen);
                      Color statusColor = PresenceUtils.getStatusColor(derivedStatus);

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: Stack(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundImage: friend.photoUrl != null
                                  ? CachedNetworkImageProvider(friend.photoUrl!)
                                  : null,
                              child: friend.photoUrl == null
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF1E1E1E),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        title: Text(
                          friend.username,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (friend.currentCheckInHallId != null)
                              const Text(
                                "📍 At a Bingo Hall",
                                style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontSize: 13,
                                ),
                              )
                            else
                              Text(
                                "${friend.firstName} ${friend.lastName}",
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 13,
                                ),
                              ),
                            const SizedBox(height: 2),
                            Text(
                              PresenceUtils.getLastSeenText(friend.lastSeen),
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.blueAccent.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.chat_bubble_rounded,
                                  color: Colors.blueAccent,
                                  size: 20,
                                ),
                                onPressed: () async {
                                  try {
                                    final chat = await ref
                                        .read(messagingRepositoryProvider)
                                        .createChat(
                                          [user.uid, friend.uid],
                                          {
                                            user.uid: user.username,
                                            friend.uid: friend.username,
                                          },
                                        );
                                    if (context.mounted) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ChatScreen(
                                            chatId: chat.id,
                                            chatName: friend.username,
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted)
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text("Error: $e")),
                                      );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  PublicProfileScreen(profile: friend),
                            ),
                          );
                        },
                      );
                    }, childCount: filteredFriends.length),
                  );
                },
                loading: () => const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.blueAccent),
                  ),
                ),
                error: (e, st) => SliverFillRemaining(
                  child: Center(
                    child: Text(
                      "Error loading friends: $e",
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.blueAccent),
        ),
        error: (e, st) => const Center(
          child: Text(
            "Error loading auth",
            style: TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
