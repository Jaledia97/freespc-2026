import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/venue_team_member_model.dart';
import '../../../../models/user_model.dart';
import '../../../../core/utils/role_utils.dart';

final personnelRepositoryProvider = Provider(
  (ref) => PersonnelRepository(FirebaseFirestore.instance),
);

class PersonnelRepository {
  final FirebaseFirestore _firestore;

  PersonnelRepository(this._firestore);

  // Get all staff for a specific hall
  Stream<List<VenueTeamMemberModel>> getStaffStream(String hallId) {
    return _firestore
        .collection('venues')
        .doc(hallId)
        .collection('team')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => VenueTeamMemberModel.fromJson(doc.data()))
              .toList(),
        );
  }

  // Update a user's role (Strict checks should be done in UI/Security Rules, but we add safe guards here if needed)
  Future<void> updateRole(String hallId, String userId, String newRole) async {
    await _firestore
        .collection('venues')
        .doc(hallId)
        .collection('team')
        .doc(userId)
        .update({'assignedRole': newRole});
  }

  // Remove staff from hall (delete team document)
  Future<void> removeStaff(String hallId, String userId) async {
    await _firestore
        .collection('venues')
        .doc(hallId)
        .collection('team')
        .doc(userId)
        .delete();
  }

  // Assign user to hall (e.g. from invite link) - often done by Cloud Function but fallback here
  Future<void> joinHall(String hallId, String hallName, UserModel user, String addedByUid) async {
    final teamDoc = _firestore.collection('venues').doc(hallId).collection('team').doc(user.uid);
    
    final newMember = VenueTeamMemberModel(
      uid: user.uid,
      venueId: hallId,
      venueName: hallName,
      firstName: user.firstName,
      lastName: user.lastName,
      username: user.username,
      photoUrl: user.photoUrl,
      assignedRole: RoleUtils.worker,
      addedAt: DateTime.now(),
      addedByUid: addedByUid,
    );
    
    await teamDoc.set(newMember.toJson());
  }

  // Search users by matching username or Name FOR INVITES
  Future<List<UserModel>> searchUsers(String query) async {
    if (query.isEmpty) return [];

    // Simple prefix search on username
    final usernameSnapshot = await _firestore
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThan: '${query}z')
        .limit(10)
        .get();

    return usernameSnapshot.docs
        .map((doc) => UserModel.fromJson(doc.data()))
        .toList();
  }
}
