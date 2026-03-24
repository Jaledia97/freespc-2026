import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final moderationRepositoryProvider = Provider((ref) => ModerationRepository(FirebaseFirestore.instance));

class ModerationRepository {
  final FirebaseFirestore _firestore;

  ModerationRepository(this._firestore);

  /// Submits a formal UGC abuse report to the centralized `reports` collection.
  /// 
  /// The [reporterId] is the user making the claim.
  /// The [targetId] is the UID of the author or the Document ID of the specific post.
  /// The [targetType] declares if it is a 'user', 'post', 'comment', etc.
  /// The [reason] specifies the categorization (Spam, Harassment, Inappropriate).
  Future<void> submitReport({
    required String reporterId,
    required String targetId,
    required String targetType,
    required String reason,
    String? additionalNotes,
  }) async {
    try {
      final String reportId = const Uuid().v4();
      
      await _firestore.collection('reports').doc(reportId).set({
        'id': reportId,
        'reporterId': reporterId,
        'targetId': targetId,
        'targetType': targetType,
        'reason': reason,
        'additionalNotes': additionalNotes ?? '',
        'status': 'pending', // pending, reviewed, dismissed
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to submit report. Please try again later.');
    }
  }
}
