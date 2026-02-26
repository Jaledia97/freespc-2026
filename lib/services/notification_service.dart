import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/notification_model.dart';
import 'auth_service.dart';

final notificationServiceProvider = Provider((ref) => NotificationService(FirebaseFirestore.instance));

/// Provides a stream of all notifications for the current user
final userNotificationsProvider = StreamProvider<List<NotificationModel>>((ref) {
  final userAsync = ref.watch(userProfileProvider);
  final user = userAsync.value;
  if (user == null) return Stream.value([]);

  return ref.watch(notificationServiceProvider).getUserNotifications(user.uid);
});

/// Provides a count of unread system notifications (doesn't include Pending Photos count)
final unreadNotificationsCountProvider = StreamProvider<int>((ref) {
  return ref.watch(userNotificationsProvider.stream).map((notifications) {
    return notifications.where((n) => !n.isRead).length;
  });
});

class NotificationService {
  final FirebaseFirestore _firestore;

  NotificationService(this._firestore);

  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromJson(doc.data()))
            .toList());
  }

  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    String? hallId,
    Map<String, dynamic>? metadata,
  }) async {
    final id = const Uuid().v4();
    final notification = NotificationModel(
      id: id,
      userId: userId,
      title: title,
      body: body,
      type: type,
      hallId: hallId,
      metadata: metadata,
      createdAt: DateTime.now(),
      isRead: false,
    );

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(id)
        .set(notification.toJson());
  }

  Future<void> markAsRead(String userId, String notificationId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  Future<void> markAllAsRead(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}
