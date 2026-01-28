import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final transactionServiceProvider = Provider((ref) => TransactionService(FirebaseFirestore.instance));

class TransactionService {
  final FirebaseFirestore _firestore;

  TransactionService(this._firestore);

  Future<void> awardPoints({
    required String userId,
    required String hallId,
    required int points,
    required String description,
    String? authorizedByWorkerId,
  }) async {
    if (hallId.isEmpty) {
       throw Exception("Invalid Hall ID (Empty)");
    }
    final userRef = _firestore.collection('users').doc(userId);
    final hallRef = _firestore.collection('bingo_halls').doc(hallId);
    final transactionRef = _firestore.collection('transactions').doc();

    await _firestore.runTransaction((transaction) async {
      // 1. Validate Hall
      final hallSnapshot = await transaction.get(hallRef);
      if (!hallSnapshot.exists) {
        throw Exception("Invalid Hall: $hallId");
      }

      // 2. Validate Membership (User must be following)
      final membershipRef = userRef.collection('memberships').doc(hallId);
      final membershipSnapshot = await transaction.get(membershipRef);

      if (!membershipSnapshot.exists) {
        throw Exception("You must follow this Hall to earn points!");
      }

      // 3. Update Membership Balance
      final currentBalance = (membershipSnapshot.data()?['balance'] as num?)?.toDouble() ?? 0.0;
      final newBalance = currentBalance + points;

      transaction.update(membershipRef, {'balance': newBalance});

      // 4. Update Global Lifetime Points (Optional: Keep for legacy/leaderboards)
      final userSnapshot = await transaction.get(userRef);
      if (userSnapshot.exists) {
         final currentGlobal = (userSnapshot.data()?['currentPoints'] as int?) ?? 0;
         transaction.update(userRef, {'currentPoints': currentGlobal + points});
      }

      // 5. Log Transaction
      transaction.set(transactionRef, {
        'id': transactionRef.id,
        'userId': userId,
        'hallId': hallId,
        'amount': points,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'earn',
        'description': description,
        if (authorizedByWorkerId != null) 'authorizedByWorkerId': authorizedByWorkerId,
      });
    });
  }
}
