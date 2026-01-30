import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/user_model.dart';
import 'dart:math';

final raffleManagerRepositoryProvider = Provider((ref) => RaffleManagerRepository(FirebaseFirestore.instance));

final activeRaffleSessionProvider = StreamProvider.family<Map<String, dynamic>?, String>((ref, hallId) {
  return ref.watch(raffleManagerRepositoryProvider).getSession(hallId);
});

class RaffleManagerRepository {
  final FirebaseFirestore _firestore;

  RaffleManagerRepository(this._firestore);

  Stream<Map<String, dynamic>?> getSession(String hallId) {
    return _firestore.collection('raffle_sessions').doc(hallId).snapshots().map((doc) => doc.data());
  }

  // Step 1: Start Roll Call
  Future<void> startRollCall(String hallId) async {
    final code = (Random().nextInt(9000) + 1000).toString(); // 4 Digit 1000-9999
    
    await _firestore.collection('raffle_sessions').doc(hallId).set({
      'hallId': hallId,
      'status': 'roll_call', // roll_call, locked, distributing, complete
      'code': code,
      'createdAt': FieldValue.serverTimestamp(),
      'participants': [], // Start empty
      'winner': null,
    });
  }

  // Step 1.5: User Joins (This would be called by User App, but putting here for logic ref)
  Future<void> joinRollCall(String hallId, String inputCode, UserModel user) async {
    final docRef = _firestore.collection('raffle_sessions').doc(hallId);
    
    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) throw Exception("No active session");
      
      final data = snapshot.data()!;
      if (data['status'] != 'roll_call') throw Exception("Roll call is closed");
      if (data['code'] != inputCode) throw Exception("Invalid Code");
      
      final List participants = List.from(data['participants'] ?? []);
      
      // Check duplicate
      if (participants.any((p) => p['uid'] == user.uid)) {
         return; // Already joined
      }
      
      participants.add({
        'uid': user.uid,
        'name': user.firstName ?? 'Unknown',
        'joinedAt': DateTime.now().toIso8601String(),
      });
      
      transaction.update(docRef, {'participants': participants});
    });
  }

  // Step 2: Lock
  Future<void> lockRollCall(String hallId) async {
    await _firestore.collection('raffle_sessions').doc(hallId).update({
      'status': 'locked',
    });
  }

  // Step 3: Distribute Tickets (Adds 1 ticket to each user's wallet)
  Future<void> distributeTickets(String hallId, String raffleName, {required String raffleId, required String imageUrl}) async {
    final docRef = _firestore.collection('raffle_sessions').doc(hallId);
    final data = (await docRef.get()).data();
    if (data == null) return;
    
    final participants = List<Map<String, dynamic>>.from(data['participants'] ?? []);
    
    // Batch write to user wallets
    final batch = _firestore.batch();
    
    for (var p in participants) {
      final uid = p['uid'];
      final ticketRef = _firestore.collection('users').doc(uid).collection('raffle_tickets').doc();
      
      batch.set(ticketRef, {
        'id': ticketRef.id,
        'raffleId': raffleId, // Link to real raffle
        'hallId': hallId,
        'title': raffleName, 
        'hallName': 'Hall Draw', // fetch real name later
        'quantity': 1,
        'purchaseDate': FieldValue.serverTimestamp(),
        'imageUrl': imageUrl, 
      });
    }

    // Update status
    batch.update(docRef, {'status': 'active_draw'}); // Ready to draw
    
    await batch.commit();
  }

  // Step 4: Draw Winner
  Future<void> drawWinner(String hallId) async {
    final docRef = _firestore.collection('raffle_sessions').doc(hallId);
    
    await _firestore.runTransaction((transaction) async {
       final snapshot = await transaction.get(docRef);
       if (!snapshot.exists) return;
       final data = snapshot.data()!;
       
       final participants = List.from(data['participants'] ?? []);
       if (participants.isEmpty) throw Exception("No participants");
       
       final winnerIndex = Random().nextInt(participants.length);
       final winner = participants[winnerIndex];
       
       transaction.update(docRef, {
         'winner': winner,
         'status': 'winner_drawn'
       });
    });
  }
  
  // Step 5: Reset
  Future<void> resetSession(String hallId) async {
    await _firestore.collection('raffle_sessions').doc(hallId).delete();
  }
}
