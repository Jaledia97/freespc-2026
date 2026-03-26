import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../../models/venue_claim_model.dart';
import '../../../models/bingo_hall_model.dart';

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
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return VenueClaimModel.fromJson(data);
      }).toList();
    });
  }

  Future<void> approveClaim(String claimId) async {
    final callable = _functions.httpsCallable('onApproveClaim');
    await callable.call({'claimId': claimId});
  }

  Future<void> rejectClaim(String claimId) async {
    final callable = _functions.httpsCallable('onRejectClaim');
    await callable.call({'claimId': claimId});
  }

  // Helper just to display hall details on the claim card
  Future<BingoHallModel?> getHallDetails(String hallId) async {
    try {
      final doc = await _firestore.collection('bingo_halls').doc(hallId).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return BingoHallModel.fromJson(data);
      }
    } catch (e) {
      print('Error fetching hall for claim: \$e');
    }
    return null;
  }
}
