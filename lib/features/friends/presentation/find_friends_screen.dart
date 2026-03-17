import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../services/auth_service.dart';
import '../../scan/presentation/scan_screen.dart'; // Ensure this path is correct, might be lib/features/scan/presentation/scan_screen.dart
import '../repositories/friends_repository.dart';
import '../../messaging/repositories/messaging_repository.dart';
import '../../messaging/presentation/chat_screen.dart';
import '../../../models/public_profile.dart';
import '../../profile/presentation/public_profile_screen.dart';

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

    final results = await ref.read(authServiceProvider).searchUsers(query.trim());
    
    if (mounted) {
      setState(() {
         // Filter out self if needed, but for simplicity let users see themselves
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
          
        if (!_isSearching && !_hasSearched && currentUserId != null)
          _PendingRequestsSection(currentUserId: currentUserId),

        if (!_isSearching && !_hasSearched && _suggestedResults.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 8, bottom: 8),
                  child: Text("Suggested Friends", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2C),
                    borderRadius: BorderRadius.circular(12)
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _suggestedResults.length > 5 ? 5 : _suggestedResults.length, // Limit visible results
                    separatorBuilder: (context, index) => const Divider(color: Colors.white12, height: 1),
                    itemBuilder: (context, index) {
                      final result = _suggestedResults[index];
                      return ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text("@${result.username}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: result.realNameVisibility == 'Everyone' || result.realNameVisibility == 'Friends Only'
                          ? Text("${result.firstName} ${result.lastName}", style: const TextStyle(color: Colors.white54))
                          : null,
                        trailing: currentUserId != null 
                            ? _FriendshipStatusIcon(currentUserId: currentUserId, targetUser: result)
                            : null,
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => PublicProfileScreen(profile: result)));
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
        if (!_isSearching && _hasSearched && _searchResults.isNotEmpty)
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
                  title: Text("@${result.username}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: result.realNameVisibility == 'Everyone' || result.realNameVisibility == 'Friends Only'
                    ? Text("${result.firstName} ${result.lastName}", style: const TextStyle(color: Colors.white54))
                    : null,
                  trailing: currentUserId != null 
                      ? _FriendshipStatusIcon(currentUserId: currentUserId, targetUser: result)
                      : null,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => PublicProfileScreen(profile: result)));
                  },
                );
              },
            ),
          )
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
        // Filter for requests where WE are the receiver and the status is 'received'
        final pendingRequests = friendsList.where((f) => f.status == 'received').toList();

        if (pendingRequests.isEmpty) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.only(top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 8, bottom: 8),
                child: Text("Pending Requests", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2C),
                  borderRadius: BorderRadius.circular(12)
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: pendingRequests.length,
                  separatorBuilder: (context, index) => const Divider(color: Colors.white12, height: 1),
                  itemBuilder: (context, index) {
                    final request = pendingRequests[index];
                    // The sender's ID is the one that differs from currentUserId
                    final senderId = request.user1Id == currentUserId ? request.user2Id : request.user1Id;

                    return _PendingRequestTile(senderId: senderId, currentUserId: currentUserId);
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

  const _PendingRequestTile({required this.senderId, required this.currentUserId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We need to fetch the sender's profile to display their info
    return FutureBuilder<PublicProfile?>(
      future: ref.read(authServiceProvider).getPublicProfile(senderId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
            leading: CircleAvatar(child: CircularProgressIndicator(strokeWidth: 2)),
            title: Text("Loading profile...", style: TextStyle(color: Colors.white54)),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.error, color: Colors.redAccent)),
            title: const Text("Unknown User", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: const Text("Profile missing or deleted", style: TextStyle(color: Colors.white54)),
            trailing: IconButton(
              icon: const Icon(Icons.cancel, color: Colors.white54),
              onPressed: () async {
                await ref.read(friendsRepositoryProvider).removeFriend(currentUserId, senderId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid request cleared."), backgroundColor: Colors.white30));
                }
              },
            ),
          );
        }

        final sender = snapshot.data!;

        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text("@${sender.username}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: const Text("Sent you a friend request", style: TextStyle(color: Colors.white54)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.check_circle, color: Colors.greenAccent),
                onPressed: () async {
                  try {
                    await ref.read(friendsRepositoryProvider).acceptFriendRequest(currentUserId, sender.uid);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("You are now friends with @${sender.username}!"), backgroundColor: Colors.green));
                    }
                  } catch (e) {
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.cancel, color: Colors.redAccent),
                onPressed: () async {
                  await ref.read(friendsRepositoryProvider).removeFriend(currentUserId, sender.uid);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Request declined."), backgroundColor: Colors.white30));
                  }
                },
              ),
            ],
          ),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => PublicProfileScreen(profile: sender)));
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
      return const SizedBox.shrink(); // No icon for self
    }

    final friendsStream = ref.watch(friendsStreamProvider(currentUserId));

    return friendsStream.when(
      data: (friendsList) {
        final friendRecord = friendsList.where((f) => f.user2Id == targetUser.uid || f.user1Id == targetUser.uid).firstOrNull;

        if (friendRecord == null) {
          // Not friends
          return IconButton(
            icon: const Icon(Icons.person_add, color: Colors.blueAccent),
            onPressed: () async {
              try {
                await ref.read(friendsRepositoryProvider).sendFriendRequest(currentUserId, targetUser.uid);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Request sent to @${targetUser.username}!"), backgroundColor: Colors.green));
                }
              } catch (e) {
                if (context.mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
                }
              }
            },
          );
        } else if (friendRecord.status == 'sent') {
          // Pending request sent by current user
          return IconButton(
            icon: const Icon(Icons.hourglass_empty, color: Colors.white54),
            onPressed: () async {
               // Confirm dialog
               final confirm = await showDialog<bool>(
                 context: context,
                 builder: (context) => AlertDialog(
                   backgroundColor: const Color(0xFF2C2C2C),
                   title: const Text("Cancel Friend Request?", style: TextStyle(color: Colors.white)),
                   content: Text("Are you sure you want to cancel the friend request to @${targetUser.username}?", style: const TextStyle(color: Colors.white70)),
                   actions: [
                     TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("No")),
                     TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Yes, Cancel", style: TextStyle(color: Colors.redAccent))),
                   ],
                 )
               );
               
               if (confirm == true) {
                 await ref.read(friendsRepositoryProvider).removeFriend(currentUserId, targetUser.uid);
                 if (context.mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Friend request canceled."), backgroundColor: Colors.white30));
                 }
               }
            },
          );
        } else if (friendRecord.status == 'received') {
          // Received a request from this user
          return IconButton(
            icon: const Icon(Icons.check_circle_outline, color: Colors.greenAccent),
            onPressed: () async {
              try {
                await ref.read(friendsRepositoryProvider).acceptFriendRequest(currentUserId, targetUser.uid);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("You are now friends with @${targetUser.username}!"), backgroundColor: Colors.green));
                }
              } catch (e) {
                if (context.mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
                }
              }
            },
          );
        } else {
          // Already friends - Message button
          return IconButton(
            icon: const Icon(Icons.chat_bubble_rounded, color: Colors.blueAccent),
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
            onPressed: () async {
              try {
                final chat = await ref.read(messagingRepositoryProvider).createChat(
                  [currentUserId, targetUser.uid],
                  {
                    currentUserId: ref.read(userProfileProvider).value?.username ?? "User",
                    targetUser.uid: targetUser.username,
                  }
                );
                
                if (context.mounted) {
                   Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(chatId: chat.id, chatName: targetUser.username)));
                }
              } catch (e) {
                 if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
              }
            },
          );
        }
      },
      loading: () => const SizedBox(width: 48, height: 48, child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)))),
      error: (e, st) => const Icon(Icons.error, color: Colors.red),
    );
  }
}

