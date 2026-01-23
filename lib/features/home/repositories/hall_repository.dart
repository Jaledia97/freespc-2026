import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/bingo_hall_model.dart';
import '../../../models/user_model.dart'; // Import UserModel
import 'dart:math';

final hallRepositoryProvider = Provider((ref) => HallRepository(FirebaseFirestore.instance));

final hallsStreamProvider = StreamProvider<List<BingoHallModel>>((ref) {
  return ref.watch(hallRepositoryProvider).getHalls();
});

class HallRepository {
  final FirebaseFirestore _firestore;

  HallRepository(this._firestore);

  Stream<List<BingoHallModel>> getHalls() {
    return _firestore.collection('bingo_halls').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => BingoHallModel.fromJson(doc.data())).toList();
    });
  }

  Future<void> createMockHall() async {
    final random = Random();
    final mockHall = BingoHallModel(
      id: '', // Firestone will generate ID if we add it differently, but for set() we need one. Let's rely on doc reference for ID or assign UUID.
      // Ideally id matches Doc ID. Let's generate a new Doc ref.
      name: "Grand Bingo Hall ${random.nextInt(100)}",
      beaconUuid: "mock-uuid-${random.nextInt(1000)}",
      latitude: 30.0 + random.nextDouble(),
      longitude: -86.0 - random.nextDouble(),
      isActive: true,
    );

    // We need to exclude ID from the data we set if we want Firestore to generate one, 
    // or generate one ourselves. BingoHallModel requires ID. 
    // Let's create a new doc ref first.
    final docRef = _firestore.collection('bingo_halls').doc();
    
    // Create copy with the generated Doc ID
    final hallWithId = mockHall.copyWith(id: docRef.id);
    
    await docRef.set(hallWithId.toJson());
  }

  Future<void> seedMaryEstherEnv(String userId) async {
    const hallId = 'mary-esther-bingo';
    
    // 1. Create/Update the specific Hall
    final hall = BingoHallModel(
      id: hallId,
      name: "Mary Esther Bingo",
      beaconUuid: "meb-beacon-001",
      latitude: 30.407,
      longitude: -86.662,
      isActive: true,
    );
    
    await _firestore.collection('bingo_halls').doc(hallId).set(hall.toJson());
    
    // 2. Update the User to be Owner
    final userRef = _firestore.collection('users').doc(userId);
    
    await userRef.update({
      'role': 'owner',
      'homeBaseId': hallId,
      'qrToken': 'meb-owner-token-${userId.substring(0, 5)}', // Semi-stable token
    });
  }

  Future<UserModel?> getWorkerFromQr(String qrToken) async {
    try {
      print('Scanning for Token: $qrToken');
      final querySnapshot = await _firestore
          .collection('users')
          .where('qrToken', isEqualTo: qrToken)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      final userDoc = querySnapshot.docs.first;
      final user = UserModel.fromJson(userDoc.data());

      // Validate Role
      final validRoles = ['worker', 'admin', 'owner'];
      if (!validRoles.contains(user.role)) {
        return null; // Found user but not authorized
      }

      return user;
    } catch (e) {
      print("Error finding worker: $e");
      return null;
    }
  }
}
