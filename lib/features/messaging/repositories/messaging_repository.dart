import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../models/chat_model.dart';
import '../../../models/message_model.dart';
import '../../../models/notification_model.dart';
import '../../../services/auth_service.dart';

final messagingRepositoryProvider = Provider<MessagingRepository>((ref) {
  return MessagingRepository(FirebaseFirestore.instance, ref);
});

class MessagingRepository {
  final FirebaseFirestore _firestore;
  final Ref _ref;

  MessagingRepository(this._firestore, this._ref);

  /// Streams the list of chats for the user (Inbox).
  /// This only fetches the metadata (`ChatModel`) which includes the `lastMessage`.
  /// By NOT fetching individual messages here, we save massive on billing.
  Stream<List<ChatModel>> streamUserChats(String userId) {
    final userProfile = _ref.watch(userProfileProvider).value;
    final blockedUsers = userProfile?.blockedUsers ?? [];

    return _firestore
        .collection('chats')
        .where('participantIds', arrayContains: userId)
        .orderBy('lastMessageAt', descending: true)
        .limit(30)
        .snapshots()
        .map((snapshot) {
      final chats = snapshot.docs.map((doc) => ChatModel.fromJson(doc.data())).toList();
      
      // Filter out 1-on-1 chats with blocked users
      return chats.where((chat) {
        if (chat.isGroup) return true; // Keep groups, but we'll mask messages later
        
        final otherUserId = chat.participantIds.firstWhere((id) => id != userId, orElse: () => '');
        return !blockedUsers.contains(otherUserId);
      }).toList();
    });
  }

  /// Streams the most recent messages for a specific chat.
  /// Cursor pagination can be layered on top of this by adjusting the limit or startAfter.
  Stream<List<MessageModel>> streamChatMessages(String chatId, {int limit = 50}) {
    final userProfile = _ref.watch(userProfileProvider).value;
    final blockedUsers = userProfile?.blockedUsers ?? [];

    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      final messages = snapshot.docs.map((doc) => MessageModel.fromJson(doc.data())).toList();
      
      // Map messages sent by blocked users to a "Blocked Message" placeholder
      return messages.map((msg) {
        if (blockedUsers.contains(msg.senderId)) {
          return msg.copyWith(text: "You blocked this user.");
        }
        return msg;
      }).toList();
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

  /// Renames an existing Group Chat
  Future<void> renameGroupChat(String chatId, String newName) async {
    final chatDoc = await _firestore.collection('chats').doc(chatId).get();
    if (!chatDoc.exists) throw Exception("Chat not found");

    final chat = ChatModel.fromJson(chatDoc.data()!);
    if (!chat.isGroup) throw Exception("Cannot rename a 1-on-1 chat");

    await _firestore.collection('chats').doc(chatId).update({'name': newName});
  }

  /// Toggles the mute status for a chat
  Future<void> toggleMuteChat(String chatId, String userId) async {
    final chatDoc = await _firestore.collection('chats').doc(chatId).get();
    if (!chatDoc.exists) return;

    final chat = ChatModel.fromJson(chatDoc.data()!);
    final isMuted = chat.mutedBy.contains(userId);

    await _firestore.collection('chats').doc(chatId).update({
      'mutedBy': isMuted
          ? FieldValue.arrayRemove([userId])
          : FieldValue.arrayUnion([userId])
    });
  }

  /// Generic Report Function
  Future<void> submitReport({
    required String reporterId,
    required String targetId,
    required String targetType, // 'user', 'chat', 'photo', 'message'
    required String reason,
  }) async {
    await _firestore.collection('reports').add({
      'reporterId': reporterId,
      'targetId': targetId,
      'targetType': targetType,
      'reason': reason,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'pending', 
    });
  }

  /// Blocks a user by adding them to the User Profile's `blockedUsers` array
  Future<void> blockUser(String currentUserId, String userToBlockId) async {
    await _firestore.collection('users').doc(currentUserId).update({
      'blockedUsers': FieldValue.arrayUnion([userToBlockId])
    });
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
