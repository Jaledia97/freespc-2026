import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../models/friendship_model.dart';

final friendsRepositoryProvider = Provider((ref) => FriendsRepository());

class FriendsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Since we need bidirectionality, a root level 'friendships' collection is often easiest to query,
  // OR we store friendships under each user. For simplicity and security rules, we'll store friendships 
  // as documents in a root collection, or subcollections.
  // 
  // Let's use a subcollection `friends` under `users/{userId}` to authorize read/write easily.
  
  Stream<List<FriendshipModel>> streamFriends(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('friends')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FriendshipModel.fromJson(doc.data()))
            .toList());
  }

  Future<void> sendFriendRequest(String currentUserId, String targetUserId) async {
    // Check if already friends or pending
    final existingParams = await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('friends')
        .where('user2Id', isEqualTo: targetUserId)
        .get();

    if (existingParams.docs.isNotEmpty) {
      throw Exception("Friend request already sent or user is already a friend.");
    }

    final id = const Uuid().v4();
    final now = DateTime.now();

    // The request on the sender's side
    final senderRecord = FriendshipModel(
      id: id,
      user1Id: currentUserId,
      user2Id: targetUserId,
      status: 'pending', // could be 'sent' here and 'pending' on the other
      createdAt: now,
    );

    // The request on the receiver's side
    final receiverRecord = FriendshipModel(
      id: id,
      user1Id: targetUserId, // They are user1 in their own subcollection
      user2Id: currentUserId, // Sender is user2
      status: 'pending',
      createdAt: now,
    );

    final batch = _firestore.batch();
    batch.set(_firestore.collection('users').doc(currentUserId).collection('friends').doc(targetUserId), senderRecord.toJson());
    batch.set(_firestore.collection('users').doc(targetUserId).collection('friends').doc(currentUserId), receiverRecord.toJson());
    await batch.commit();
  }

  Future<void> acceptFriendRequest(String currentUserId, String targetUserId) async {
    final batch = _firestore.batch();
    
    batch.update(
      _firestore.collection('users').doc(currentUserId).collection('friends').doc(targetUserId),
      {'status': 'accepted'}
    );
    batch.update(
      _firestore.collection('users').doc(targetUserId).collection('friends').doc(currentUserId),
      {'status': 'accepted'}
    );

    await batch.commit();
  }

  Future<void> removeFriend(String currentUserId, String targetUserId) async {
    final batch = _firestore.batch();
    
    batch.delete(_firestore.collection('users').doc(currentUserId).collection('friends').doc(targetUserId));
    batch.delete(_firestore.collection('users').doc(targetUserId).collection('friends').doc(currentUserId));

    await batch.commit();
  }
}
