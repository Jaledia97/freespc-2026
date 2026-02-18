import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/tournament_model.dart';
import '../../../models/special_model.dart'; // For RecurrenceRule logic

final tournamentRepositoryProvider = Provider((ref) => TournamentRepository(FirebaseFirestore.instance));

final hallTournamentsProvider = StreamProvider.family<List<TournamentModel>, String>((ref, hallId) {
  return ref.watch(tournamentRepositoryProvider).streamTournaments(hallId);
});

final tournamentsFeedProvider = StreamProvider<List<TournamentModel>>((ref) {
  return ref.watch(tournamentRepositoryProvider).getTournamentsFeed();
});

class TournamentRepository {
  final FirebaseFirestore _firestore;

  TournamentRepository(this._firestore);

  // Stream All Tournaments (Active, Expired, Templates)
  Stream<List<TournamentModel>> streamTournaments(String hallId) {
    return _firestore
        .collection('bingo_halls')
        .doc(hallId)
        .collection('tournaments')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => TournamentModel.fromFirestore(doc)).toList();
    });
  }

  // Save (Create/Update)
  Future<void> saveTournament(String hallId, TournamentModel tournament) async {
    final collection = _firestore.collection('bingo_halls').doc(hallId).collection('tournaments');

    
    var data = Map<String, dynamic>.from(tournament.toJson());
    
    // Manual Fix 1: RecurrenceRule
    if (tournament.recurrenceRule != null) {
      data['recurrenceRule'] = tournament.recurrenceRule!.toJson();
    }

    // Manual Fix 2: Games List
    if (tournament.games.isNotEmpty) {
      data['games'] = tournament.games.map((g) => g.toJson()).toList();
    }
    
    if (tournament.id.isEmpty) {
      final docRef = collection.doc();
      final newTournament = tournament.copyWith(id: docRef.id);
      
      // Re-apply fixes
      var newData = Map<String, dynamic>.from(newTournament.toJson());
      if (newTournament.recurrenceRule != null) {
        newData['recurrenceRule'] = newTournament.recurrenceRule!.toJson();
      }
      if (newTournament.games.isNotEmpty) {
        newData['games'] = newTournament.games.map((g) => g.toJson()).toList();
      }
      
      await docRef.set(newData);
    } else {
      await collection.doc(tournament.id).set(data, SetOptions(merge: true));
    }
  }

  // Delete
  Future<void> deleteTournament(String hallId, String tournamentId) async {
    await _firestore.collection('bingo_halls').doc(hallId).collection('tournaments').doc(tournamentId).delete();

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

    final tournaments = snapshot.docs.map((doc) => TournamentModel.fromFirestore(doc)).toList();
    
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
               .where((t) => !t.isTemplate) // Client-side filter to avoid Index requirement
               .toList();
        });
  }
}
