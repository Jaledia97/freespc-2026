import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freespc/models/public_profile.dart';
import 'package:freespc/features/friends/repositories/friends_repository.dart';
import 'package:freespc/services/auth_service.dart';
import '../../messaging/repositories/messaging_repository.dart';
import '../../messaging/presentation/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

final profileFriendsCountProvider = StreamProvider.family<int, String>((
  ref,
  uid,
) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('friends')
      .where('status', isEqualTo: 'accepted')
      .snapshots()
      .map((snap) => snap.docs.length);
});

final profilePostsCountProvider = FutureProvider.family<int, String>((
  ref,
  uid,
) async {
  final db = FirebaseFirestore.instance;
  try {
    final wins = await db
        .collection('win_posts')
        .where('userId', isEqualTo: uid)
        .count()
        .get();
    final checkins = await db
        .collection('check_ins')
        .where('userId', isEqualTo: uid)
        .count()
        .get();
    return (wins.count ?? 0) + (checkins.count ?? 0);
  } catch (e) {
    return 0;
  }
});

final profileGalleryProvider = FutureProvider.family<List<String>, String>((
  ref,
  uid,
) async {
  final db = FirebaseFirestore.instance;
  try {
    final QuerySnapshot winsSnapshot = await db
        .collection('win_posts')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .get();
    List<String> images = [];
    for (var doc in winsSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data.containsKey('imageUrl') && data['imageUrl'] != null) {
        images.add(data['imageUrl']);
      }
    }
    return images;
  } catch (e) {
    return [];
  }
});

class PublicProfileScreen extends ConsumerStatefulWidget {
  final PublicProfile profile;

  const PublicProfileScreen({super.key, required this.profile});

  @override
  ConsumerState<PublicProfileScreen> createState() =>
      _PublicProfileScreenState();
}

class _PublicProfileScreenState extends ConsumerState<PublicProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.profile.username,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black.withOpacity(0.95),
        elevation: 0,
        centerTitle: true,
      ),
      body: userAsync.when(
        data: (currentUser) {
          if (currentUser == null) {
            return const Center(
              child: Text(
                "Not authenticated",
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          final isSelf = currentUser.uid == widget.profile.uid;

          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Avatar & Stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Hero(
                            tag: 'avatar_${widget.profile.uid}',
                            child: CircleAvatar(
                              radius: 45,
                              backgroundColor: Colors.white10,
                              backgroundImage: widget.profile.photoUrl != null
                                  ? NetworkImage(widget.profile.photoUrl!)
                                  : null,
                              child: widget.profile.photoUrl == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 45,
                                      color: Colors.white54,
                                    )
                                  : null,
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Consumer(
                                  builder: (context, ref, _) {
                                    final postsCountAsync = ref.watch(
                                      profilePostsCountProvider(
                                        widget.profile.uid,
                                      ),
                                    );
                                    final count =
                                        postsCountAsync.valueOrNull ?? 0;
                                    return _buildStatCol(
                                      "Posts",
                                      count.toString(),
                                    );
                                  },
                                ),
                                Consumer(
                                  builder: (context, ref, _) {
                                    final friendsCountAsync = ref.watch(
                                      profileFriendsCountProvider(
                                        widget.profile.uid,
                                      ),
                                    );
                                    final count =
                                        friendsCountAsync.valueOrNull ?? 0;
                                    return _buildStatCol(
                                      "Friends",
                                      count.toString(),
                                    );
                                  },
                                ),
                                _buildStatCol(
                                  "Points",
                                  widget.profile.points.toString(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Name & Bio
                      if (widget.profile.realNameVisibility == 'Everyone')
                        Text(
                          "${widget.profile.firstName} ${widget.profile.lastName}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (widget.profile.bio != null &&
                          widget.profile.bio!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.profile.bio!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),

                      // Active Squads Readout
                      if (widget.profile.squadIds.isNotEmpty)
                        Row(
                          children: [
                            const Icon(
                              Icons.shield,
                              size: 14,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Captain of ${widget.profile.squadIds.length} Squads",
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 16),

                      // Actions
                      if (!isSelf)
                        _FriendshipActionButton(
                          currentUserId: currentUser.uid,
                          targetUser: widget.profile,
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {}, // Edit Profile
                            child: const Text(
                              "Edit Profile",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Badges section removed until real backend implementation exists
                      const Divider(color: Colors.white10, height: 1),
                    ],
                  ),
                ),
              ),

              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.amber,
                    labelColor: Colors.amber,
                    unselectedLabelColor: Colors.white54,
                    onTap: (index) {
                      setState(() {});
                    },
                    tabs: const [
                      Tab(text: "THE WALL", icon: Icon(Icons.list_alt)),
                      Tab(text: "PHOTOS", icon: Icon(Icons.grid_on)),
                    ],
                  ),
                ),
              ),

              if (_tabController.index == 0) ...[
                // Tab 1: Vertical Feed (TextPosts & Check-Ins)
                // Placeholder until feed_repository.dart supports user-specific feeds
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 300,
                    child: Center(
                      child: Text(
                        "The Wall Component Coming Soon",
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // Tab 2: The 3-Column Instagram Gallery Grid
                Consumer(
                  builder: (context, ref, _) {
                    final galleryAsync = ref.watch(
                      profileGalleryProvider(widget.profile.uid),
                    );

                    return galleryAsync.when(
                      data: (images) {
                        if (images.isEmpty) {
                          return const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Center(
                                child: Text(
                                  "No posts yet.",
                                  style: TextStyle(color: Colors.white54),
                                ),
                              ),
                            ),
                          );
                        }

                        return SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 1),
                          sliver: SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 2,
                                  mainAxisSpacing: 2,
                                  childAspectRatio: 1.0,
                                ),
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              return CachedNetworkImage(
                                imageUrl: images[index],
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    Container(color: Colors.white10),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.white10,
                                  child: const Icon(
                                    Icons.error,
                                    color: Colors.white24,
                                  ),
                                ),
                              );
                            }, childCount: images.length),
                          ),
                        );
                      },
                      loading: () => const SliverToBoxAdapter(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (e, st) => const SliverToBoxAdapter(
                        child: Center(child: Text("Failed to load gallery.")),
                      ),
                    );
                  },
                ),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Text("Error: $e", style: const TextStyle(color: Colors.red)),
        ),
      ),
    );
  }

  Widget _buildStatCol(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 13),
        ),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.black, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class _FriendshipActionButton extends ConsumerWidget {
  final String currentUserId;
  final PublicProfile targetUser;

  const _FriendshipActionButton({
    required this.currentUserId,
    required this.targetUser,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendsStream = ref.watch(friendsStreamProvider(currentUserId));

    return friendsStream.when(
      data: (friendsList) {
        final friendRecord = friendsList
            .where(
              (f) => f.user2Id == targetUser.uid || f.user1Id == targetUser.uid,
            )
            .firstOrNull;

        if (friendRecord == null) {
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                try {
                  await ref
                      .read(friendsRepositoryProvider)
                      .sendFriendRequest(currentUserId, targetUser.uid);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Request sent to @${targetUser.username}!",
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Error: $e"),
                        backgroundColor: Colors.red,
                      ),
                    );
                }
              },
              child: const Text(
                "Add Friend",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        } else if (friendRecord.status == 'sent') {
          return SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                await ref
                    .read(friendsRepositoryProvider)
                    .removeFriend(currentUserId, targetUser.uid);
              },
              child: const Text(
                "Requested",
                style: TextStyle(
                  color: Colors.white54,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        } else if (friendRecord.status == 'received') {
          return Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    await ref
                        .read(friendsRepositoryProvider)
                        .acceptFriendRequest(currentUserId, targetUser.uid);
                  },
                  child: const Text(
                    "Accept",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    await ref
                        .read(friendsRepositoryProvider)
                        .removeFriend(currentUserId, targetUser.uid);
                  },
                  child: const Text(
                    "Decline",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          );
        } else {
          // Already friends
          return Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {}, // Following logic if implemented
                  child: const Text(
                    "Friends",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white12,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    final userAsync = ref.read(userProfileProvider).value;
                    if (userAsync == null) return;

                    final chat = await ref
                        .read(messagingRepositoryProvider)
                        .createChat(
                          [userAsync.uid, targetUser.uid],
                          {
                            userAsync.uid: userAsync.username,
                            targetUser.uid: targetUser.username,
                          },
                        );
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            chatId: chat.id,
                            chatName: targetUser.username,
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    "Message",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          );
        }
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => const SizedBox.shrink(),
    );
  }
}
