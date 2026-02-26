import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/photos/repositories/photo_repository.dart';
import '../../services/notification_service.dart';

class NotificationBadge extends ConsumerWidget {
  final Widget child;
  final bool showForGeneral;
  final bool showForManager;

  const NotificationBadge({
    super.key,
    required this.child,
    this.showForGeneral = true,
    this.showForManager = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int count = 0;

    if (showForGeneral) {
      final generalAsync = ref.watch(unreadNotificationsCountProvider);
      if (!generalAsync.hasError && generalAsync.value != null) {
        count += generalAsync.value!;
      }
    }

    if (showForManager) {
      final managerAsync = ref.watch(unreadPendingPhotosCountProvider);
      if (!managerAsync.hasError && managerAsync.value != null) {
        count += managerAsync.value!;
      }
    }

    if (count == 0) {
      return child;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          right: -2,
          top: -2,
          child: Container(
            width: 8,
            height: 8,
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.redAccent,
              shape: BoxShape.circle,
            ),
            // The size and shape acts as the dot without necessarily a number
          ),
        ),
      ],
    );
  }
}
