import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../../models/venue_claim_model.dart';
import '../../../models/venue_model.dart';

final adminRepositoryProvider = Provider((ref) => AdminRepository());

final pendingClaimsProvider = StreamProvider.autoDispose<List<VenueClaimModel>>((ref) {
  return ref.read(adminRepositoryProvider).getPendingClaims();
});

class AdminRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Stream<List<VenueClaimModel>> getPendingClaims() {
    return _firestore
        .collection('venue_claims')
        .where('status', isEqualTo: 'pending')
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final claims = <VenueClaimModel>[];
      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();
          data['id'] = doc.id;
          claims.add(VenueClaimModel.fromJson(data));
        } catch (e) {
          debugPrint('Error mapping claim ${doc.id}: $e');
        }
      }
      return claims;
    });
  }

  Future<void> approveClaim(String claimId) async {
    final callable = _functions.httpsCallable('onApproveClaim');
    await callable.call({'claimId': claimId});
  }

  Future<void> rejectClaim(String claimId, String rejectReason) async {
    final callable = _functions.httpsCallable('onRejectClaim');
    await callable.call({'claimId': claimId, 'rejectReason': rejectReason});
  }

  // Helper just to display venue details on the claim card
  Future<VenueModel?> getHallDetails(String venueId) async {
    try {
      final doc = await _firestore.collection('venues').doc(venueId).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return VenueModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('Error fetching venue for claim: \$e');
    }
    return null;
  }
}
