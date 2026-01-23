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
  }) async {
    if (hallId.isEmpty) {
       throw Exception("Invalid Hall ID (Empty)");
    }
    final userRef = _firestore.collection('users').doc(userId);
    final hallRef = _firestore.collection('bingo_halls').doc(hallId);
    final transactionRef = _firestore.collection('transactions').doc();

    await _firestore.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);
      final hallSnapshot = await transaction.get(hallRef);

      if (!userSnapshot.exists) {
        throw Exception("User does not exist!");
      }
      if (!hallSnapshot.exists) {
        throw Exception("Invalid Hall: $hallId");
      }

      final currentPoints = (userSnapshot.data()?['currentPoints'] as int?) ?? 0;
      final newPoints = currentPoints + points;

      transaction.update(userRef, {'currentPoints': newPoints});

      transaction.set(transactionRef, {
        'id': transactionRef.id,
        'userId': userId,
        'hallId': hallId,
        'amount': points,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'earn',
        'description': description,
      });
    });
  }
}
