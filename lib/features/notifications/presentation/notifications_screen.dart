import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../../../services/auth_service.dart';
import '../../../services/notification_service.dart';
import '../../photos/repositories/photo_repository.dart';
import '../../photos/presentation/photo_detail_screen.dart';
import '../../manager/presentation/cms/photo_approval_screen.dart';
import '../../profile/presentation/public_profile_screen.dart';
import '../../friends/repositories/friends_repository.dart';
import '../../../models/notification_model.dart';
import '../../../models/public_profile.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(userProfileProvider).value;
      if (user != null) {
        ref.read(notificationServiceProvider).markAllAsRead(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(userNotificationsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F), // Deep premium black
      body: notificationsAsync.when(
        data: (notifications) {
          // Filter out chat pushes
          final displayNotifs = notifications
              .where((n) => n.type != 'new_message')
              .toList();

          if (displayNotifs.isEmpty) {
            return CustomScrollView(
              slivers: [
                _buildSliverAppBar(),
                const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      "All caught up! 🎉",
                      style: TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                  ),
                ),
              ],
            );
          }

          final now = DateTime.now();
          final newNotifs = displayNotifs
              .where((n) => !n.isRead || now.difference(n.createdAt).inHours < 24)
              .toList();
          final earlierNotifs = displayNotifs
              .where((n) => n.isRead && now.difference(n.createdAt).inHours >= 24)
              .toList();

          return CustomScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              _buildSliverAppBar(),
              if (newNotifs.isNotEmpty) ...[
                _buildHeader("New"),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _NotificationTile(
                      notification: newNotifs[index],
                      index: index,
                    ),
                    childCount: newNotifs.length,
                  ),
                ),
              ],
              if (earlierNotifs.isNotEmpty) ...[
                _buildHeader("Earlier"),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _NotificationTile(
                      notification: earlierNotifs[index],
                      index: newNotifs.length + index,
                    ),
                    childCount: earlierNotifs.length,
                  ),
                ),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 100)), // Bottom buffer
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
        error: (e, _) => Center(child: Text("Error: $e", style: const TextStyle(color: Colors.redAccent))),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 120,
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(color: Colors.black.withValues(alpha: 0.5)),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          alignment: Alignment.bottomLeft,
          padding: const EdgeInsets.only(left: 20, bottom: 16, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                "Notifications",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              InkWell(
                onTap: () {
                  final user = ref.read(userProfileProvider).value;
                  if (user != null) {
                    ref.read(notificationServiceProvider).markAllAsRead(user.uid);
                  }
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.done_all, color: Colors.blueAccent, size: 16),
                      SizedBox(width: 4),
                      Text("Mark all read", style: TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ).animate().fade().slideX(begin: -0.1),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  final NotificationModel notification;
  final int index;

  const _NotificationTile({required this.notification, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUnread = !notification.isRead;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Dismissible(
        key: ValueKey(notification.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.redAccent.shade700,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.delete_sweep, color: Colors.white, size: 28),
        ),
        onDismissed: (_) {
          final user = ref.read(userProfileProvider).value;
          if (user != null) {
            ref.read(notificationServiceProvider).deleteNotification(user.uid, notification.id);
          }
        },
        child: GestureDetector(
          onTap: () async {
            if (isUnread) {
              final user = ref.read(userProfileProvider).value;
              if (user != null) {
                ref.read(notificationServiceProvider).markAsRead(user.uid, notification.id);
              }
            }
            _handleRouting(context, ref, notification);
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isUnread ? Colors.blueAccent.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isUnread ? Colors.blueAccent.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.05),
                    width: isUnread ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _NotificationAvatar(notification: notification),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  notification.title,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: isUnread ? FontWeight.w800 : FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              if (isUnread)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.blueAccent,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blueAccent.withValues(alpha: 0.8),
                                        blurRadius: 6,
                                        spreadRadius: 2,
                                      )
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notification.body,
                            style: TextStyle(
                              color: isUnread ? Colors.white70 : Colors.white54,
                              fontSize: 14,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _timeAgo(notification.createdAt),
                            style: const TextStyle(
                              color: Colors.white30,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (notification.type == 'friend_request' && notification.metadata?.containsKey('senderId') == true)
                            _FriendRequestActions(
                              senderId: notification.metadata!['senderId'],
                              notificationId: notification.id,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ).animate(delay: (index * 40).ms).fade(duration: 300.ms).slideY(begin: 0.2, duration: 400.ms, curve: Curves.easeOutCubic),
    );
  }

  Future<void> _handleRouting(BuildContext context, WidgetRef ref, NotificationModel notification) async {
    // Handling friend requests
    if (notification.type == 'friend_request' && notification.metadata?.containsKey('senderId') == true) {
      final senderId = notification.metadata!['senderId'];
      final senderProfile = await ref.read(authServiceProvider).getPublicProfile(senderId);
      if (context.mounted && senderProfile != null) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => PublicProfileScreen(profile: senderProfile)));
      }
    }
    // Handling photo approvals (for regular users reviewing their photo states)
    if (notification.type == 'photo_approval' && notification.metadata?.containsKey('photoId') == true) {
      final photoId = notification.metadata!['photoId'];
      final photo = await ref.read(photoRepositoryProvider).getPhotoById(photoId);
      if (context.mounted) {
        if (photo != null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => PhotoDetailScreen(photo: photo)));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("This photo is no longer available.")));
        }
      }
    }
    // Handling manager photo queues
    if (notification.type == 'hall_photo_pending' && notification.hallId != null) {
      if (context.mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => PhotoApprovalScreen(hallId: notification.hallId!, hallName: 'Review Photos')));
      }
    }
  }

  String _timeAgo(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    if (difference.inHours < 1) {
      if (difference.inMinutes == 0) return "Just now";
      return "${difference.inMinutes}m ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours}h ago";
    } else if (difference.inDays < 7) {
      return "${difference.inDays}d ago";
    } else {
      return DateFormat('MMM d, yyyy').format(createdAt);
    }
  }
}

class _NotificationAvatar extends ConsumerWidget {
  final NotificationModel notification;
  const _NotificationAvatar({required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final senderId = notification.metadata?['senderId'];
    if (senderId != null) {
      return FutureBuilder<PublicProfile?>(
        future: ref.read(authServiceProvider).getPublicProfile(senderId),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            final profile = snapshot.data!;
            if (profile.photoUrl != null) {
              return Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, width: 2),
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(profile.photoUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            }
            return _buildGradientInitials(profile.username);
          }
          return _buildStaticIcon();
        },
      );
    }
    return _buildStaticIcon();
  }

  Widget _buildGradientInitials(String username) {
    final letter = username.isNotEmpty ? username[0].toUpperCase() : "?";
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Colors.purpleAccent, Colors.blueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(letter, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildStaticIcon() {
    IconData icon;
    Color color;
    switch (notification.type) {
      case 'photo_approval':
        icon = Icons.photo_camera;
        color = Colors.greenAccent;
        break;
      case 'photo_declined':
        icon = Icons.broken_image;
        color = Colors.redAccent;
        break;
      case 'friend_request':
        icon = Icons.person_add;
        color = Colors.purpleAccent;
        break;
      case 'system':
        icon = Icons.info_outline;
        color = Colors.amberAccent;
        break;
      default:
        icon = Icons.notifications;
        color = Colors.blueAccent;
    }
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}

class _FriendRequestActions extends ConsumerWidget {
  final String senderId;
  final String notificationId;

  const _FriendRequestActions({required this.senderId, required this.notificationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.watch(userProfileProvider).value?.uid;
    if (currentUserId == null) return const SizedBox.shrink();

    final friendsStream = ref.watch(friendsStreamProvider(currentUserId));

    return friendsStream.when(
      data: (friendsList) {
        final friendRecord = friendsList.where((f) => f.user1Id == senderId || f.user2Id == senderId).firstOrNull;
        if (friendRecord == null || friendRecord.status != 'received') {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(top: 14.0),
          child: Row(
            children: [
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () async {
                    try {
                      await ref.read(friendsRepositoryProvider).acceptFriendRequest(currentUserId, senderId);
                    } catch (_) {}
                  },
                  child: const Text("Accept", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                    shape: const StadiumBorder(),
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () async {
                    try {
                      await ref.read(friendsRepositoryProvider).removeFriend(currentUserId, senderId);
                    } catch (_) {}
                  },
                  child: const Text("Decline", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
