import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/auth_service.dart';
import '../../../services/notification_service.dart';
import '../../photos/repositories/photo_repository.dart';
import '../../photos/presentation/photo_detail_screen.dart';
import '../../manager/presentation/cms/photo_approval_screen.dart';
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

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.transparent,
      ),
      body: notificationsAsync.when(
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

                    // Handle 'photo_approval' routing
                    if (notification.type == 'photo_approval' && notification.metadata?.containsKey('photoId') == true) {
                      final photoId = notification.metadata!['photoId'];
                      final hallId = notification.hallId;
                      if (hallId != null) {
                        // Fetch the actual photo to fulfill the required PhotoDetailScreen parameter
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
                            // Photo might have been deleted since the notification was generated
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
                              hallName: 'Review Photos', // Fallback name
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
      case 'system': return Icons.info_outline;
      default: return Icons.notifications;
    }
  }
}
