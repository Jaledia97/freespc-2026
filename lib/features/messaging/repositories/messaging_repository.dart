import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../models/chat_model.dart';
import '../../../models/message_model.dart';
import '../../../models/notification_model.dart';

final messagingRepositoryProvider = Provider<MessagingRepository>((ref) {
  return MessagingRepository(FirebaseFirestore.instance);
});

class MessagingRepository {
  final FirebaseFirestore _firestore;

  MessagingRepository(this._firestore);

  /// Streams the list of chats for the user (Inbox).
  /// This only fetches the metadata (`ChatModel`) which includes the `lastMessage`.
  /// By NOT fetching individual messages here, we save massive on billing.
  Stream<List<ChatModel>> streamUserChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participantIds', arrayContains: userId)
        .orderBy('lastMessageAt', descending: true)
        .limit(30)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ChatModel.fromJson(doc.data())).toList();
    });
  }

  /// Streams the most recent messages for a specific chat.
  /// Cursor pagination can be layered on top of this by adjusting the limit or startAfter.
  Stream<List<MessageModel>> streamChatMessages(String chatId, {int limit = 50}) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => MessageModel.fromJson(doc.data())).toList();
    });
  }

  /// Sends a message and performs a batched write to update the parent chat's `lastMessage` metadata.
  Future<void> sendMessage(String chatId, String text, String senderId) async {
    final batch = _firestore.batch();
    
    final messageRef = _firestore.collection('chats').doc(chatId).collection('messages').doc();
    final chatRef = _firestore.collection('chats').doc(chatId);
    
    final now = DateTime.now();

    final message = MessageModel(
      id: messageRef.id,
      chatId: chatId,
      senderId: senderId,
      text: text,
      createdAt: now,
    );

    // 1. Write the message
    batch.set(messageRef, message.toJson());
    
    // 2. Update the Chat metadata
    batch.update(chatRef, {
      'lastMessage': text,
      'lastMessageAt': now.toIso8601String(),
      'lastMessageSenderId': senderId,
      // Note: A cloud function would be ideal to iterate `unreadCounts` securely, 
      // but for client-side we'd either transaction it or calculate it on load.
      // We will leave unreadCounts to a cloud function or simple read-state for this scale.
    });

    await batch.commit();
  }

  /// Creates a new Chat or Group Chat.
  Future<ChatModel> createChat(List<String> participantIds, Map<String, String> participantNames, {String? groupName}) async {
    // Basic existence check to see if a 1-on-1 already exists
    if (participantIds.length == 2) {
      final existingParams = await _firestore
          .collection('chats')
          .where('participantIds', arrayContains: participantIds.first)
          .get();
          
      for (var doc in existingParams.docs) {
        final chat = ChatModel.fromJson(doc.data());
        if (!chat.isGroup && chat.participantIds.contains(participantIds[1])) {
          return chat; // Chat already exists
        }
      }
    }

    final id = const Uuid().v4();
    final now = DateTime.now();

    final chat = ChatModel(
      id: id,
      name: groupName,
      isGroup: participantIds.length > 2,
      participantIds: participantIds,
      participantNames: participantNames,
      lastMessage: 'Chat created',
      lastMessageAt: now,
    );

    await _firestore.collection('chats').doc(id).set(chat.toJson());
    return chat;
  }

  /// Streams notifications targeted at the user.
  Stream<List<NotificationModel>> streamNotifications(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(30)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => NotificationModel.fromJson(doc.data())).toList();
    });
  }
}
