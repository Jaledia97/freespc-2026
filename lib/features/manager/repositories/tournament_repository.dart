import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/tournament_model.dart';
// For RecurrenceRule logic

import '../../../services/auth_service.dart';
import '../../../services/session_context_controller.dart';
import '../../../core/utils/recurrence_utils.dart';

final tournamentRepositoryProvider = Provider(
  (ref) => TournamentRepository(FirebaseFirestore.instance, ref),
);

final hallTournamentsProvider =
    StreamProvider.family<List<TournamentModel>, String>((ref, hallId) {
      return ref.watch(tournamentRepositoryProvider).streamTournaments(hallId);
    });

final tournamentsFeedProvider = StreamProvider<List<TournamentModel>>((ref) {
  return ref.watch(tournamentRepositoryProvider).getTournamentsFeed();
});

class TournamentRepository {
  final FirebaseFirestore _firestore;
  final Ref _ref;

  TournamentRepository(this._firestore, this._ref);

  // Stream All Tournaments (Active, Expired, Templates)
  Stream<List<TournamentModel>> streamTournaments(String hallId) {
    return _firestore
        .collection('tournaments')
        .where('hallId', isEqualTo: hallId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TournamentModel.fromFirestore(doc))
              .toList();
        });
  }

  // Save (Create/Update)
  Future<void> saveTournament(String hallId, TournamentModel tournament) async {
    final collection = _firestore.collection('tournaments');

    final session = _ref.read(sessionContextProvider);
    final user = _ref.read(userProfileProvider).value;

    TournamentModel processedTournament = tournament.copyWith(hallId: hallId);
    if (session.isBusiness) {
      processedTournament = processedTournament.copyWith(
        authorType: 'venue',
        authorId: session.activeVenueId,
        postedByUid: user?.uid,
      );
    } else {
      processedTournament = processedTournament.copyWith(
        authorType: 'user',
        authorId: user?.uid,
        postedByUid: user?.uid,
      );
    }

    final isNew = processedTournament.id.isEmpty;
    final docRef = isNew ? collection.doc() : collection.doc(processedTournament.id);
    final finalTournament = processedTournament.copyWith(id: docRef.id);

    var data = Map<String, dynamic>.from(finalTournament.toJson());
    if (finalTournament.recurrenceRule != null) {
      data['recurrenceRule'] = finalTournament.recurrenceRule!.toJson();
    }
    if (finalTournament.games.isNotEmpty) {
      data['games'] = finalTournament.games.map((g) => g.toJson()).toList();
    }

    final batch = _firestore.batch();
    if (isNew) {
      batch.set(docRef, data);
    } else {
      batch.set(docRef, data, SetOptions(merge: true));
    }

    // Process Recurrence Windows
    if (finalTournament.isTemplate && finalTournament.recurrenceRule != null && finalTournament.startTime != null && finalTournament.endTime != null) {
      if (!isNew) {
        final orphans = await _firestore.collection('tournaments')
          .where('templateId', isEqualTo: finalTournament.id)
          .where('startTime', isGreaterThan: DateTime.now())
          .get();
        for (var doc in orphans.docs) {
          batch.delete(doc.reference);
        }
      }

      final dates = RecurrenceUtils.generateOccurrenceDates(
        originalStart: finalTournament.startTime!,
        originalEnd: finalTournament.endTime!,
        rule: finalTournament.recurrenceRule!,
        maxDaysLimit: 14,
      );
      
      final duration = finalTournament.endTime!.difference(finalTournament.startTime!);
      final now = DateTime.now();

      for (var date in dates) {
        if (!isNew && date.isBefore(now)) continue; 
        
        final compositeId = '${finalTournament.id}_${date.toUtc().toIso8601String().split('T')[0]}';
        final cloneRef = _firestore.collection('tournaments').doc(compositeId);
        
        final clone = finalTournament.copyWith(
          id: compositeId,
          isTemplate: false,
          templateId: finalTournament.id,
          startTime: date,
          endTime: date.add(duration),
          createdAt: date,
          reactionUserIds: [],
          interestedUserIds: [],
          commentCount: 0,
          latestComment: null,
          isStarred: false, 
        );
        
        var cloneData = Map<String, dynamic>.from(clone.toJson());
        if (clone.recurrenceRule != null) cloneData['recurrenceRule'] = clone.recurrenceRule!.toJson();
        if (clone.games.isNotEmpty) cloneData['games'] = clone.games.map((g) => g.toJson()).toList();

        batch.set(cloneRef, cloneData);
      }
    }

    await batch.commit();
  }

  // Delete
  Future<void> deleteTournament(String hallId, String tournamentId) async {
    final batch = _firestore.batch();
    batch.delete(_firestore.collection('tournaments').doc(tournamentId));

    final orphans = await _firestore.collection('tournaments')
        .where('templateId', isEqualTo: tournamentId)
        .get();
        
    final now = DateTime.now();
    for (var doc in orphans.docs) {
       final data = doc.data();
       final isStarred = data['isStarred'] ?? false;
       final endTimeTimestamp = data['endTime'];
       final endTime = endTimeTimestamp is Timestamp ? endTimeTimestamp.toDate() : null;
       
       if (endTime != null && endTime.isAfter(now)) {
           batch.delete(doc.reference);
       } else if (!isStarred) {
           batch.delete(doc.reference);
       }
    }
    
    await batch.commit();
  }

  // Get Currently Active Tournament (for Scanner)
  Future<TournamentModel?> getActiveTournament(String hallId) async {
    // Fetch all non-template tournaments
    // In production, might want to query active ones only, but for now fetching all is fine for MVP volume.
    final snapshot = await _firestore
        .collection('bingo_halls')
        .doc(hallId)
        .collection('tournaments')
        .where('isTemplate', isEqualTo: false)
        .get();

    final tournaments = snapshot.docs
        .map((doc) => TournamentModel.fromFirestore(doc))
        .toList();

    final now = DateTime.now();

    // Find one that is active NOW (considering recurrence)
    for (var t in tournaments) {
      // 1. Simple Date Check
      if (t.startTime != null && t.endTime != null) {
        if (now.isAfter(t.startTime!) && now.isBefore(t.endTime!)) {
          return t;
        }
      }

      // 2. Recurrence Check (Projecting)
      // Reuse logic from HallRepository if possible, or duplicate for now.
      // For MVP, let's assume if it has recurrence, we check if "today" matches and time matches.

      if (t.recurrenceRule != null && t.recurrenceRule!.frequency != 'none') {
        // Simple projection: Check if startTime's time-of-day has passed, and if current day matches rule
        // This is complex.
        // Let's implement full active check later.
        // For now, return the first one that matches simple start/end OR is "Recurring Today".
      }
    }

    return null;
  }

  // Stream ALL Active Tournaments (Global Feed)
  Stream<List<TournamentModel>> getTournamentsFeed() {
    // Note: This requires a Firestore Index to sort by startTime
    return _firestore
        .collectionGroup('tournaments')
        // .where('isTemplate', isEqualTo: false) // Commented out to debug Index
        // .where('startTime', isGreaterThan: DateTime.now()) // Optional: Filter past?
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TournamentModel.fromFirestore(doc))
              .where(
                (t) => !t.isTemplate,
              ) // Client-side filter to avoid Index requirement
              .toList();
        });
  }
}
