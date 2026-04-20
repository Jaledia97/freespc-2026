import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/session_context_controller.dart';
import '../../../services/auth_service.dart';

final transactionServiceProvider = Provider(
  (ref) => TransactionService(FirebaseFirestore.instance, ref),
);

class TransactionService {
  final FirebaseFirestore _firestore;
  final Ref _ref;

  TransactionService(this._firestore, this._ref);

  Future<void> awardPoints({
    required String userId,
    required String venueId,
    required int points,
    required String description,
    String? authorizedByWorkerId,
  }) async {
    if (venueId.isEmpty) {
      throw Exception("Invalid Venue ID (Empty)");
    }

    final currentUser = _ref.read(userProfileProvider).value;
    if (currentUser != null && userId == currentUser.uid) {
      if (_ref.read(sessionContextProvider).isBusiness) {
        throw Exception("Point accrual is locked. You cannot earn consumer rewards while on-duty.");
      }
    }
    final userRef = _firestore.collection('users').doc(userId);
    final hallRef = _firestore.collection('venues').doc(venueId);
    final transactionRef = userRef.collection('transactions').doc();

    await _firestore.runTransaction((transaction) async {
      // 1. Validate Venue
      final hallSnapshot = await transaction.get(hallRef);
      if (!hallSnapshot.exists) {
        throw Exception("Invalid Venue: $venueId");
      }

      // 2. Validate Membership (User must be following)
      final membershipRef = userRef.collection('memberships').doc(venueId);
      final membershipSnapshot = await transaction.get(membershipRef);

      if (!membershipSnapshot.exists) {
        throw Exception("You must follow this Venue to earn points!");
      }

      // 3. Update Membership Balance
      final currentBalance =
          (membershipSnapshot.data()?['balance'] as num?)?.toDouble() ?? 0.0;
      final newBalance = currentBalance + points;

      transaction.update(membershipRef, {'balance': newBalance});

      // 4. Update Global Lifetime Points (Optional: Keep for legacy/leaderboards)
      final userSnapshot = await transaction.get(userRef);
      if (userSnapshot.exists) {
        final currentGlobal =
            (userSnapshot.data()?['currentPoints'] as int?) ?? 0;
        transaction.update(userRef, {'currentPoints': currentGlobal + points});
      }

      // 5. Log Transaction
      transaction.set(transactionRef, {
        'id': transactionRef.id,
        'userId': userId,
        'venueId': venueId,
        'amount': points,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'earn',
        'description': description,
        if (authorizedByWorkerId != null)
          'authorizedByWorkerId': authorizedByWorkerId,
      });
    });
  }

  Future<void> redeemItem({
    required String userId,
    required String venueId,
    required String itemId,
    required String itemName,
    required int quantity,
    required int totalCost,
  }) async {
    if (venueId.isEmpty || totalCost < 0 || quantity < 1) {
      throw Exception("Invalid redemption parameters");
    }

    final userRef = _firestore.collection('users').doc(userId);
    final membershipRef = userRef.collection('memberships').doc(venueId);
    final transactionRef = userRef.collection('transactions').doc();

    await _firestore.runTransaction((transaction) async {
      // 1. Validate Membership & Balance
      final membershipSnapshot = await transaction.get(membershipRef);
      if (!membershipSnapshot.exists) {
        throw Exception("You must follow this Venue to redeem items!");
      }

      final currentBalance =
          (membershipSnapshot.data()?['balance'] as num?)?.toDouble() ?? 0.0;
      if (currentBalance < totalCost) {
        throw Exception("Insufficient points. You need $totalCost PTS.");
      }

      // 2. Deduct Membership Balance
      final newBalance = currentBalance - totalCost;
      transaction.update(membershipRef, {'balance': newBalance});

      // 3. Deduct Global Lifetime Points
      final userSnapshot = await transaction.get(userRef);
      if (userSnapshot.exists) {
        final currentGlobal =
            (userSnapshot.data()?['currentPoints'] as int?) ?? 0;
        transaction.update(userRef, {
          'currentPoints': (currentGlobal - totalCost)
              .clamp(0, double.maxFinite)
              .toInt(),
        });
      }

      // 4. Log Transaction
      transaction.set(transactionRef, {
        'id': transactionRef.id,
        'userId': userId,
        'venueId': venueId,
        'amount': -totalCost, // Negative for spend
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'spend',
        'description': 'Redeemed ${quantity}x $itemName',
        'itemId': itemId,
      });

      // Optional: Add to a "My Items" collection for the user
      final myItemRef = userRef.collection('my_items').doc();
      transaction.set(myItemRef, {
        'id': myItemRef.id,
        'itemId': itemId,
        'itemName': itemName,
        'venueId': venueId,
        'quantity': quantity,
        'redeemedAt': FieldValue.serverTimestamp(),
        'status': 'active', // can be 'active', 'used', etc.
      });
    });
  }
}
