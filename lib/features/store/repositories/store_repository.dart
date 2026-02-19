import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/store_item_model.dart';

final storeRepositoryProvider = Provider((ref) => StoreRepository(FirebaseFirestore.instance));

final storeItemsProvider = StreamProvider.family<List<StoreItemModel>, String>((ref, hallId) {
  return ref.watch(storeRepositoryProvider).getStoreItems(hallId);
});

class StoreRepository {
  final FirebaseFirestore _firestore;

  StoreRepository(this._firestore);

  // Get all items for a hall (Realtime)
  Stream<List<StoreItemModel>> getStoreItems(String hallId) {
    return _firestore
        .collection('bingo_halls')
        .doc(hallId)
        .collection('store_items')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => StoreItemModel.fromJson(doc.data())).toList();
        });
  }

  // Get ONLY active items (For Consumer View)
  Stream<List<StoreItemModel>> getActiveStoreItems(String hallId) {
    return _firestore
        .collection('bingo_halls')
        .doc(hallId)
        .collection('store_items')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => StoreItemModel.fromJson(doc.data())).toList();
        });
  }

  Future<void> createStoreItem(StoreItemModel item) async {
    await _firestore
        .collection('bingo_halls')
        .doc(item.hallId)
        .collection('store_items')
        .doc(item.id)
        .set(item.toJson());
  }

  Future<void> updateStoreItem(StoreItemModel item) async {
    await _firestore
        .collection('bingo_halls')
        .doc(item.hallId)
        .collection('store_items')
        .doc(item.id)
        .update(item.toJson());
  }

  Future<void> deleteStoreItem(String hallId, String itemId) async {
    await _firestore
        .collection('bingo_halls')
        .doc(hallId)
        .collection('store_items')
        .doc(itemId)
        .delete();
  }
}
