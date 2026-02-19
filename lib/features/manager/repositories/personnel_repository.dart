import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/user_model.dart';
import '../../../../core/utils/role_utils.dart';

final personnelRepositoryProvider = Provider((ref) => PersonnelRepository(FirebaseFirestore.instance));

class PersonnelRepository {
  final FirebaseFirestore _firestore;

  PersonnelRepository(this._firestore);

  // Get all staff for a specific hall (homeBaseId == hallId)
  Stream<List<UserModel>> getStaffStream(String hallId) {
    return _firestore
        .collection('users')
        .where('homeBaseId', isEqualTo: hallId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => UserModel.fromJson(doc.data())).toList());
  }

  // Update a user's role (Strict checks should be done in UI/Security Rules, but we add safe guards here if needed)
  Future<void> updateRole(String userId, String newRole) async {
    await _firestore.collection('users').doc(userId).update({'role': newRole});
  }

  // Remove staff from hall (reset homeBaseId and role)
  Future<void> removeStaff(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'homeBaseId': null,
      'role': RoleUtils.player, // Reset to player
    });
  }

  // Assign user to hall (e.g. from invite link)
  Future<void> joinHall(String userId, String hallId) async {
    await _firestore.collection('users').doc(userId).update({
      'homeBaseId': hallId,
      'role': RoleUtils.player, // Default to player, allow manager to promote
    });
  }

  // Search users by matching username or Name
  Future<List<UserModel>> searchUsers(String query) async {
    if (query.isEmpty) return [];
    
    // Simple prefix search on username
    final usernameSnapshot = await _firestore
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThan: query + 'z')
        .limit(10)
        .get();

    return usernameSnapshot.docs.map((doc) => UserModel.fromJson(doc.data())).toList();
  }
}
