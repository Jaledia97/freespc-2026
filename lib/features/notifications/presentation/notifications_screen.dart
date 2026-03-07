import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/auth_service.dart';
import '../../../services/notification_service.dart';
import '../../photos/repositories/photo_repository.dart';
import '../../photos/presentation/photo_detail_screen.dart';
import '../../manager/presentation/cms/photo_approval_screen.dart';
import '../../profile/presentation/public_profile_screen.dart';
import '../../friends/repositories/friends_repository.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
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

    return Container(
      color: const Color(0xFF141414),
      child: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(child: Text("No notifications yet.", style: TextStyle(color: Colors.white54)));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final isUnread = !notification.isRead;

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    if (isUnread) {
                      final user = ref.read(userProfileProvider).value;
                      if (user != null) {
                         ref.read(notificationServiceProvider).markAsRead(user.uid, notification.id);
                      }
                    }
                    // Handle 'friend_request' routing
                    if (notification.type == 'friend_request' && notification.metadata?.containsKey('senderId') == true) {
                      final senderId = notification.metadata!['senderId'];
                      final senderProfile = await ref.read(authServiceProvider).getPublicProfile(senderId);

                      if (context.mounted && senderProfile != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PublicProfileScreen(profile: senderProfile),
                          ),
                        );
                      }
                    }

                    // Handle 'photo_approval' routing
                    if (notification.type == 'photo_approval' && notification.metadata?.containsKey('photoId') == true) {
                      final photoId = notification.metadata!['photoId'];
                      final hallId = notification.hallId;
                      if (hallId != null) {
                        final photo = await ref.read(photoRepositoryProvider).getPhotoById(photoId);
                        
                        if (context.mounted) {
                          if (photo != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PhotoDetailScreen(photo: photo),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("This photo is no longer available.")),
                            );
                          }
                        }
                      }
                    }

                    // Handle 'hall_photo_pending' routing (for managers/workers)
                    if (notification.type == 'hall_photo_pending' && notification.hallId != null) {
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PhotoApprovalScreen(
                              hallId: notification.hallId!,
                              hallName: 'Review Photos', 
                            ),
                          ),
                        );
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isUnread ? Colors.blue.withOpacity(0.1) : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: isUnread ? Border.all(color: Colors.blueAccent.withOpacity(0.5)) : null,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          _getIconForType(notification.type),
                          color: isUnread ? Colors.blueAccent : Colors.white54,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notification.title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                notification.body,
                                style: const TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _timeAgo(notification.createdAt),
                                style: const TextStyle(color: Colors.white38, fontSize: 12),
                              ),
                              if (notification.type == 'friend_request' && notification.metadata?.containsKey('senderId') == true)
                                _FriendRequestActions(senderId: notification.metadata!['senderId'], notificationId: notification.id),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
      ),
    );
  }

  String _timeAgo(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inHours < 1) {
      if (difference.inMinutes == 0) return "Just now";
      return "${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago";
    } else if (difference.inDays < 7) {
      return "${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago";
    } else {
      return DateFormat('MMM d, yyyy').format(createdAt);
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'photo_approval': return Icons.photo_camera;
      case 'photo_declined': return Icons.broken_image;
      case 'friend_request': return Icons.person_add;
      case 'system': return Icons.info_outline;
      default: return Icons.notifications;
    }
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
          // If we already accepted/declined, or it's not pending anymore, hide actions
          return const SizedBox.shrink(); 
        }

        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: [
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () async {
                    try {
                      await ref.read(friendsRepositoryProvider).acceptFriendRequest(currentUserId, senderId);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Friend request accepted!"), backgroundColor: Colors.green));
                      }
                    } catch (e) {
                      if (context.mounted) {
                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: \$e"), backgroundColor: Colors.red));
                      }
                    }
                  },
                  child: const Text("Accept", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () async {
                     await ref.read(friendsRepositoryProvider).removeFriend(currentUserId, senderId);
                     if (context.mounted) {
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Friend request declined."), backgroundColor: Colors.white30));
                     }
                  },
                  child: const Text("Decline", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () async {
                     await ref.read(notificationServiceProvider).deleteNotification(currentUserId, notificationId);
                     if (context.mounted) {
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Notification ignored."), backgroundColor: Colors.white30));
                     }
                  },
                  child: const Text("Ignore", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: Padding(padding: EdgeInsets.only(top: 8.0), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
