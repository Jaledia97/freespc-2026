import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../services/auth_service.dart';
import '../../scan/presentation/scan_screen.dart';
import '../repositories/friends_repository.dart';
import '../../messaging/repositories/messaging_repository.dart';
import '../../messaging/presentation/chat_screen.dart';
import '../../../models/public_profile.dart';
import '../../profile/presentation/public_profile_screen.dart';
import '../../../core/widgets/glass_container.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FindFriendsScreen extends ConsumerWidget {
  const FindFriendsScreen({super.key});

  void _shareLink(String uid) {
    Share.share("Add me as a friend on FreeSpc! freespc://add_friend?uid=$uid");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Color(0xFF121212),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 20),
            height: 5,
            width: 48,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Text(
              "Find Friends",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: userAsync.when(
              data: (user) {
                if (user == null) {
                  return const Center(
                    child: Text(
                      "User not found",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 12.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _ManualSearchSection(),
                      const SizedBox(height: 40),

                      const Text(
                        "Scan QR to Add",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Have a friend scan this code to connect.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white60, fontSize: 14),
                      ),
                      const SizedBox(height: 24),

                      // QR Code Display Premium Card
                      Center(
                        child: GlassContainer(
                          blur: 15,
                          opacity: 0.05,
                          borderRadius: BorderRadius.circular(24),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: QrImageView(
                              data: "freespc://add_friend?uid=${user.uid}",
                              version: QrVersions.auto,
                              size: 180,
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.all(12),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Scan Button
                      SizedBox(
                        height: 56,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent.withOpacity(0.9),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const Icon(Icons.qr_code_scanner, size: 22),
                          label: const Text(
                            "Scan a Friend's QR",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ScanScreen(),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 16),
                      const Row(
                        children: [
                          Expanded(child: Divider(color: Colors.white12)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              "OR",
                              style: TextStyle(
                                color: Colors.white30,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.white12)),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Share Link Button
                      SizedBox(
                        height: 56,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.2),
                            ),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const Icon(Icons.ios_share, size: 20),
                          label: const Text(
                            "Share Invite Link",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: () => _shareLink(user.uid),
                        ),
                      ),

                      const SizedBox(height: 48),
                    ],
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: Colors.blueAccent),
              ),
              error: (e, st) => Center(
                child: Text(
                  "Error: $e",
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ManualSearchSection extends ConsumerStatefulWidget {
  const _ManualSearchSection();

  @override
  ConsumerState<_ManualSearchSection> createState() =>
      _ManualSearchSectionState();
}

class _ManualSearchSectionState extends ConsumerState<_ManualSearchSection> {
  final TextEditingController _searchController = TextEditingController();
  List<PublicProfile> _searchResults = [];
  List<PublicProfile> _suggestedResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    final results = await ref.read(authServiceProvider).getSuggestedUsers();
    if (mounted) {
      setState(() {
        _suggestedResults = results;
      });
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _hasSearched = false;
        });
      }
      return;
    }

    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    final results = await ref
        .read(authServiceProvider)
        .searchUsers(query.trim());

    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.watch(userProfileProvider).value?.uid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassContainer(
          borderRadius: BorderRadius.circular(16),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            decoration: InputDecoration(
              hintText: "Search by username or name...",
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 15,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.white.withOpacity(0.4),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              suffixIcon: IconButton(
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.blueAccent,
                ),
                onPressed: () => _performSearch(_searchController.text),
              ),
            ),
            onSubmitted: _performSearch,
          ),
        ),

        if (_isSearching)
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            ),
          ),

        if (!_isSearching && _hasSearched && _searchResults.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Center(
              child: Text(
                "No users found.",
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ),

        if (!_isSearching && !_hasSearched && currentUserId != null)
          _PendingRequestsSection(currentUserId: currentUserId),

        if (!_isSearching && !_hasSearched && _suggestedResults.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 12),
                  child: Text(
                    "Suggested Friends",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.white54,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                GlassContainer(
                  borderRadius: BorderRadius.circular(16),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _suggestedResults.length > 5
                        ? 5
                        : _suggestedResults.length,
                    separatorBuilder: (context, index) =>
                        const Divider(color: Colors.white12, height: 1),
                    itemBuilder: (context, index) {
                      final result = _suggestedResults[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        leading: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white12,
                          backgroundImage: result.photoUrl != null
                              ? CachedNetworkImageProvider(result.photoUrl!)
                              : null,
                          child: result.photoUrl == null
                              ? const Icon(Icons.person, color: Colors.white54)
                              : null,
                        ),
                        title: Text(
                          "@${result.username}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        subtitle:
                            result.realNameVisibility == 'Everyone' ||
                                result.realNameVisibility == 'Friends Only'
                            ? Text(
                                "${result.firstName} ${result.lastName}",
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 13,
                                ),
                              )
                            : null,
                        trailing: currentUserId != null
                            ? _FriendshipStatusIcon(
                                currentUserId: currentUserId,
                                targetUser: result,
                              )
                            : null,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PublicProfileScreen(profile: result),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

        if (!_isSearching && _hasSearched && _searchResults.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 24),
            child: GlassContainer(
              borderRadius: BorderRadius.circular(16),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _searchResults.length > 10
                    ? 10
                    : _searchResults.length,
                separatorBuilder: (context, index) =>
                    const Divider(color: Colors.white12, height: 1),
                itemBuilder: (context, index) {
                  final result = _searchResults[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white12,
                      backgroundImage: result.photoUrl != null
                          ? CachedNetworkImageProvider(result.photoUrl!)
                          : null,
                      child: result.photoUrl == null
                          ? const Icon(Icons.person, color: Colors.white54)
                          : null,
                    ),
                    title: Text(
                      "@${result.username}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    subtitle:
                        result.realNameVisibility == 'Everyone' ||
                            result.realNameVisibility == 'Friends Only'
                        ? Text(
                            "${result.firstName} ${result.lastName}",
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                          )
                        : null,
                    trailing: currentUserId != null
                        ? _FriendshipStatusIcon(
                            currentUserId: currentUserId,
                            targetUser: result,
                          )
                        : null,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PublicProfileScreen(profile: result),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _PendingRequestsSection extends ConsumerWidget {
  final String currentUserId;

  const _PendingRequestsSection({required this.currentUserId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendsStream = ref.watch(friendsStreamProvider(currentUserId));

    return friendsStream.when(
      data: (friendsList) {
        final pendingRequests = friendsList
            .where((f) => f.status == 'received')
            .toList();

        if (pendingRequests.isEmpty) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.only(top: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  "Pending Requests",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.blueAccent,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              GlassContainer(
                borderRadius: BorderRadius.circular(16),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: pendingRequests.length,
                  separatorBuilder: (context, index) =>
                      const Divider(color: Colors.white12, height: 1),
                  itemBuilder: (context, index) {
                    final request = pendingRequests[index];
                    final senderId = request.user1Id == currentUserId
                        ? request.user2Id
                        : request.user1Id;
                    return _PendingRequestTile(
                      senderId: senderId,
                      currentUserId: currentUserId,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _PendingRequestTile extends ConsumerWidget {
  final String senderId;
  final String currentUserId;

  const _PendingRequestTile({
    required this.senderId,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<PublicProfile?>(
      future: ref.read(authServiceProvider).getPublicProfile(senderId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
            leading: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.blueAccent,
              ),
            ),
            title: Text(
              "Loading profile...",
              style: TextStyle(color: Colors.white54, fontSize: 15),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return ListTile(
            leading: const CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white12,
              child: Icon(Icons.error, color: Colors.redAccent),
            ),
            title: const Text(
              "Unknown User",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            subtitle: const Text(
              "Profile missing or deleted",
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.cancel, color: Colors.white54),
              onPressed: () async {
                await ref
                    .read(friendsRepositoryProvider)
                    .removeFriend(currentUserId, senderId);
              },
            ),
          );
        }

        final sender = snapshot.data!;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white12,
            backgroundImage: sender.photoUrl != null
                ? CachedNetworkImageProvider(sender.photoUrl!)
                : null,
            child: sender.photoUrl == null
                ? const Icon(Icons.person, color: Colors.white54)
                : null,
          ),
          title: Text(
            "@${sender.username}",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          subtitle: const Text(
            "Sent you a request",
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.check,
                    color: Colors.greenAccent,
                    size: 20,
                  ),
                  onPressed: () async {
                    try {
                      await ref
                          .read(friendsRepositoryProvider)
                          .acceptFriendRequest(currentUserId, sender.uid);
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
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                  onPressed: () async {
                    await ref
                        .read(friendsRepositoryProvider)
                        .removeFriend(currentUserId, sender.uid);
                  },
                ),
              ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PublicProfileScreen(profile: sender),
              ),
            );
          },
        );
      },
    );
  }
}

class _FriendshipStatusIcon extends ConsumerWidget {
  final String currentUserId;
  final PublicProfile targetUser;

  const _FriendshipStatusIcon({
    required this.currentUserId,
    required this.targetUser,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (currentUserId == targetUser.uid) {
      return const SizedBox.shrink();
    }

    final friendsStream = ref.watch(friendsStreamProvider(currentUserId));

    return friendsStream.when(
      data: (friendsList) {
        final friendRecord = friendsList
            .where(
              (f) => f.user2Id == targetUser.uid || f.user1Id == targetUser.uid,
            )
            .firstOrNull;

        if (friendRecord == null) {
          // Not friends
          return Container(
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.person_add,
                color: Colors.blueAccent,
                size: 20,
              ),
              onPressed: () async {
                try {
                  await ref
                      .read(friendsRepositoryProvider)
                      .sendFriendRequest(currentUserId, targetUser.uid);
                } catch (e) {}
              },
            ),
          );
        } else if (friendRecord.status == 'sent') {
          // Pending request sent by current user
          return Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.hourglass_empty,
                color: Colors.white54,
                size: 20,
              ),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF2C2C2C),
                    title: const Text(
                      "Cancel Friend Request?",
                      style: TextStyle(color: Colors.white),
                    ),
                    content: Text(
                      "Cancel request to @${targetUser.username}?",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("No"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          "Yes",
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await ref
                      .read(friendsRepositoryProvider)
                      .removeFriend(currentUserId, targetUser.uid);
                }
              },
            ),
          );
        } else if (friendRecord.status == 'received') {
          // Received a request from this user
          return Container(
            decoration: BoxDecoration(
              color: Colors.greenAccent.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.check_circle_outline,
                color: Colors.greenAccent,
                size: 20,
              ),
              onPressed: () async {
                try {
                  await ref
                      .read(friendsRepositoryProvider)
                      .acceptFriendRequest(currentUserId, targetUser.uid);
                } catch (e) {}
              },
            ),
          );
        } else {
          // Already friends
          return Container(
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
                        [currentUserId, targetUser.uid],
                        {
                          currentUserId:
                              ref.read(userProfileProvider).value?.username ??
                              "User",
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
                } catch (e) {}
              },
            ),
          );
        }
      },
      loading: () => const SizedBox.shrink(),
      error: (e, st) => const Icon(Icons.error, color: Colors.red),
    );
  }
}
