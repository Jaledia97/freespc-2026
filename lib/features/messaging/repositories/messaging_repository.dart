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

/// Provides a stream of all chats for the current user (Inbox)
final userChatsProvider = StreamProvider<List<ChatModel>>((ref) {
  final user = ref.watch(userProfileProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(messagingRepositoryProvider).streamUserChats(user.uid);
});

/// Provides a count of all unread messages across all active chats
final unreadMessagesCountProvider = Provider<int>((ref) {
  final chatsAsync = ref.watch(userChatsProvider);
  final user = ref.watch(userProfileProvider).value;
  if (user == null || chatsAsync.value == null) return 0;
  
  int count = 0;
  for (var chat in chatsAsync.value!) {
    count += (chat.unreadCounts[user.uid] ?? 0);
  }
  return count;
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
      
      // Filter out 1-on-1 chats with blocked users and chats deleted by the user
      return chats.where((chat) {
        if (chat.deletedBy.contains(userId)) return false; // Hidden from this user's Inbox
        
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
  Future<void> sendMessage(
      String chatId, String text, String senderId, {
      String? replyToMessageId,
      String? replyToText,
      String? replyToSenderName,
  }) async {
    final chatDoc = await _firestore.collection('chats').doc(chatId).get();
    if (!chatDoc.exists) return;
    final chat = ChatModel.fromJson(chatDoc.data()!);

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
      replyToMessageId: replyToMessageId,
      replyToText: replyToText,
      replyToSenderName: replyToSenderName,
    );

    // 1. Write the message
    batch.set(messageRef, message.toJson());
    
    // 2. Increment unreadCounts for all other participants
    Map<String, int> updatedUnreadCounts = Map.from(chat.unreadCounts);
    for (String participantId in chat.participantIds) {
      if (participantId != senderId) {
        updatedUnreadCounts[participantId] = (updatedUnreadCounts[participantId] ?? 0) + 1;
      }
    }

    // 3. Update the Chat metadata and clear deletedBy so it reappears for both users
    batch.update(chatRef, {
      'lastMessage': text,
      'lastMessageAt': now.toIso8601String(),
      'lastMessageSenderId': senderId,
      'unreadCounts': updatedUnreadCounts,
      'deletedBy': [], 
    });

    await batch.commit();
  }

  /// Marks a chat as read for a specific user by setting their unread count to 0.
  Future<void> markChatAsRead(String chatId, String userId) async {
    await _firestore.collection('chats').doc(chatId).update({
      'unreadCounts.$userId': 0,
    });
  }

  /// Hides a chat from the user's inbox by adding them to the 'deletedBy' array.
  /// If the other person sends a new message, the chat will reappear because 'deletedBy' gets cleared.
  Future<void> hideChat(String chatId, String userId) async {
    await _firestore.collection('chats').doc(chatId).update({
      'deletedBy': FieldValue.arrayUnion([userId])
    });
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
    final isGroup = participantIds.length > 2;

    final chat = ChatModel(
      id: id,
      name: groupName,
      isGroup: isGroup,
      ownerId: isGroup ? participantIds.first : null, // The creator is the owner
      participantIds: participantIds,
      pendingParticipantIds: [],
      participantNames: participantNames,
      lastMessage: 'Chat created',
      lastMessageAt: now,
    );

    await _firestore.collection('chats').doc(id).set(chat.toJson());
    return chat;
  }

  /// Updates the typing status for a user in a chat
  Future<void> setTypingStatus(String chatId, String userId, bool isTyping) async {
    final chatRef = _firestore.collection('chats').doc(chatId);
    
    // We use arrayUnion / arrayRemove so multiple people can type at once
    await chatRef.update({
      'isTyping': isTyping 
          ? FieldValue.arrayUnion([userId]) 
          : FieldValue.arrayRemove([userId])
    });
  }

  /// Invites a user to a group chat. Enforces friendship and owner rules.
  Future<void> inviteToGroupChat(String chatId, String inviterId, String targetUserId, String targetUsername) async {
    // 1. Verify Friendship
    final friendshipDoc = await _firestore
        .collection('users').doc(inviterId)
        .collection('friends').doc(targetUserId)
        .get();

    if (!friendshipDoc.exists || friendshipDoc.data()?['status'] != 'accepted') {
      throw Exception("You can only invite accepted friends to a group chat.");
    }

    // 2. Enforce Ownership rules
    final chatDoc = await _firestore.collection('chats').doc(chatId).get();
    if (!chatDoc.exists) throw Exception("Chat not found.");
    
    final chat = ChatModel.fromJson(chatDoc.data()!);
    if (!chat.isGroup) throw Exception("Cannot invite members to a 1-on-1 chat.");
    
    if (chat.participantIds.contains(targetUserId)) {
      throw Exception("User is already in this chat.");
    }
    
    if (chat.pendingParticipantIds.contains(targetUserId)) {
      throw Exception("User has already been invited and is awaiting owner approval.");
    }

    final batch = _firestore.batch();
    final chatRef = _firestore.collection('chats').doc(chatId);

    if (chat.ownerId == inviterId) {
      // Owner can instantly add
      batch.update(chatRef, {
        'participantIds': FieldValue.arrayUnion([targetUserId]),
        'participantNames.$targetUserId': targetUsername,
      });

      // Send System Message indicating they joined
      final msgRef = chatRef.collection('messages').doc();
      batch.set(msgRef, {
        'id': msgRef.id,
        'chatId': chatId,
        'senderId': 'system',
        'text': '@${targetUsername} was added to the group by the owner.',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      // Non-owner must request addition
      batch.update(chatRef, {
        'pendingParticipantIds': FieldValue.arrayUnion([targetUserId]),
        'participantNames.$targetUserId': targetUsername, // Prep their name for the approval UI
      });
      
      // Optionally create a notification for the owner here
      if (chat.ownerId != null) {
        final notifRef = _firestore.collection('users').doc(chat.ownerId).collection('notifications').doc();
        batch.set(notifRef, {
          'id': notifRef.id,
          'userId': chat.ownerId,
          'title': 'Group Chat Request',
          'body': 'A member wants to add @${targetUsername} to ${chat.name ?? "your group"}.',
          'type': 'group_invite_request',
          'createdAt': FieldValue.serverTimestamp(),
          'metadata': {'chatId': chatId, 'targetUserId': targetUserId},
        });
      }
    }

    await batch.commit();
  }

  /// Owner approves a pending invite
  Future<void> approveGroupInvite(String chatId, String targetUserId, String targetUsername) async {
    final chatRef = _firestore.collection('chats').doc(chatId);
    final batch = _firestore.batch();

    batch.update(chatRef, {
      'pendingParticipantIds': FieldValue.arrayRemove([targetUserId]),
      'participantIds': FieldValue.arrayUnion([targetUserId]),
    });

    final msgRef = chatRef.collection('messages').doc();
    batch.set(msgRef, {
      'id': msgRef.id,
      'chatId': chatId,
      'senderId': 'system',
      'text': '@$targetUsername was approved to join the group.',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
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
      final docs = snapshot.docs.map((doc) => NotificationModel.fromJson(doc.data())).toList();
      docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return docs;
    });
  }
}
