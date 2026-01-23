import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/bingo_hall_model.dart';
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
}
