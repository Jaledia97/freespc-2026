import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/squad_model.dart';
import 'package:uuid/uuid.dart';

final squadRepositoryProvider = Provider((ref) => SquadRepository(FirebaseFirestore.instance));

class SquadRepository {
  final FirebaseFirestore _firestore;

  SquadRepository(this._firestore);

  /// Creates a squad and natively updates the squadIds array securely mapping the captain and all initial members.
  Future<SquadModel> createSquad({
    required String name,
    required String captainId,
    required List<String> memberIds,
  }) async {
    final batch = _firestore.batch();
    
    final String fullId = const Uuid().v4();
    final squadId = "sq_\${fullId.substring(0, 8)}";

    // Ensure captain is explicitly mapped into the members matrix
    final List<String> finalMembers = List<String>.from(memberIds);
    if (!finalMembers.contains(captainId)) {
      finalMembers.add(captainId);
    }

    final squad = SquadModel(
      id: squadId,
      name: name,
      captainId: captainId,
      memberIds: finalMembers,
    );

    // 1. Create the Squad Document
    final squadRef = _firestore.collection('squads').doc(squadId);
    batch.set(squadRef, squad.toJson());

    // 2. Map the squadId to every member's private user document and public_profile payload
    for (String uid in finalMembers) {
      final userRef = _firestore.collection('users').doc(uid);
      batch.update(userRef, {
        'squadIds': FieldValue.arrayUnion([squadId])
      });

      final publicProfileRef = _firestore.collection('public_profiles').doc(uid);
      batch.update(publicProfileRef, {
        'squadIds': FieldValue.arrayUnion([squadId])
      });
    }

    // Commit the entire generation securely
    await batch.commit();

    return squad;
  }
}
