import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/notification_model.dart';
import 'auth_service.dart';

final notificationServiceProvider = Provider(
  (ref) => NotificationService(FirebaseFirestore.instance),
);

/// Provides a stream of all notifications for the current user
final userNotificationsProvider = StreamProvider<List<NotificationModel>>((
  ref,
) {
  final userAsync = ref.watch(userProfileProvider);
  final user = userAsync.value;
  if (user == null) return Stream.value([]);

  return ref.watch(notificationServiceProvider).getUserNotifications(user.uid);
});

/// Provides a count of unread system notifications (doesn't include Pending Photos count or B2B Alerts)
final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notificationsAsync = ref.watch(userNotificationsProvider);
  return notificationsAsync.value
          ?.where((n) => !n.isRead && !n.type.startsWith('b2b_'))
          .length ??
      0;
});

/// Provides a count of unread B2B notifications (Manager Dashboard)
final unreadB2BNotificationsCountProvider = Provider<int>((ref) {
  final notificationsAsync = ref.watch(userNotificationsProvider);
  return notificationsAsync.value
          ?.where((n) => !n.isRead && n.type.startsWith('b2b_'))
          .length ??
      0;
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
        .map((snapshot) {
          final docs = snapshot.docs
              .map((doc) => NotificationModel.fromJson(doc.data()))
              .toList();
          docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return docs;
        });
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

  Future<void> markTypeAsRead(String userId, String type) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('type', isEqualTo: type)
        .where('isRead', isEqualTo: false)
        .get();

    if (snapshot.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> deleteNotification(String userId, String notificationId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }
}
