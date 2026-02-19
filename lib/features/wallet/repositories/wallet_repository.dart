import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/transaction_model.dart';
import '../../../models/hall_membership_model.dart';
import '../../../models/raffle_ticket_model.dart';
import '../../../models/tournament_participation_model.dart';

final walletRepositoryProvider = Provider((ref) => WalletRepository(FirebaseFirestore.instance));

final myMembershipsStreamProvider = StreamProvider.family<List<HallMembershipModel>, ({String userId, List<String> followingIds})>((ref, args) {
  return ref.watch(walletRepositoryProvider).getMemberships(args.userId, args.followingIds);
});

final myRafflesStreamProvider = StreamProvider.family<List<RaffleTicketModel>, String>((ref, userId) {
  return ref.watch(walletRepositoryProvider).getMyRaffles(userId);
});

final myTournamentsStreamProvider = StreamProvider.family<List<TournamentParticipationModel>, String>((ref, userId) {
  return ref.watch(walletRepositoryProvider).getMyTournaments(userId);
});

// New Stream for Transactions
final myTransactionsStreamProvider = StreamProvider.family<List<TransactionModel>, String>((ref, userId) {
  return ref.watch(walletRepositoryProvider).getTransactions(userId);
});

class WalletRepository {
  final FirebaseFirestore _firestore;

  WalletRepository(this._firestore);

  // --- Streams ---

  Stream<List<HallMembershipModel>> getMemberships(String userId, List<String> followingIds) {
    return _firestore
    .collection('users')
    .doc(userId)
    .collection('memberships')
    .snapshots()
    .map((snapshot) {
      final allMemberships = snapshot.docs.map((doc) => HallMembershipModel.fromJson(doc.data())).toList();
      // Only return memberships for halls the user is currently following
      return allMemberships.where((m) => followingIds.contains(m.hallId)).toList();
    });
  }

  Stream<List<RaffleTicketModel>> getMyRaffles(String userId) {
    return _firestore
    .collection('users')
    .doc(userId)
    .collection('raffle_tickets')
    .orderBy('purchaseDate', descending: true)
    .snapshots()
    .map((snapshot) {
      return snapshot.docs.map((doc) => RaffleTicketModel.fromJson(doc.data())).toList();
    });
  }

  Stream<List<TournamentParticipationModel>> getMyTournaments(String userId) {
    return _firestore
    .collection('users')
    .doc(userId)
    .collection('tournaments')
    .orderBy('lastUpdated', descending: true)
    .snapshots()
    .map((snapshot) {
      return snapshot.docs.map((doc) => TournamentParticipationModel.fromJson(doc.data())).toList();
    });
  }

  Stream<List<TransactionModel>> getTransactions(String userId) {
    return _firestore
    .collection('users')
    .doc(userId)
    .collection('transactions')
    .orderBy('timestamp', descending: true)
    .limit(100) // Limit to recent 100
    .snapshots()
    .map((snapshot) {
      return snapshot.docs.map((doc) => TransactionModel.fromJson(doc.data())).toList();
    });
  }

  // --- Seeding ---

  Future<void> seedWalletData(String userId) async {
    final batch = _firestore.batch();
    final userRef = _firestore.collection('users').doc(userId);

    // 1. Seed Memberships (Hall Cards)
    final memberships = [
       HallMembershipModel(
        hallId: 'mary-esther-bingo',
        hallName: 'Mary Esther Bingo',
        balance: 1250,
        currencyName: 'Points',
        tier: 'Gold',
        bannerUrl: 'https://images.unsplash.com/photo-1518893063132-36e465be779d?auto=format&fit=crop&w=800&q=80',
      ),
       HallMembershipModel(
        hallId: 'grand-bingo-1',
        hallName: 'Grand Bingo Hall',
        balance: 450,
        currencyName: 'Credits',
        tier: 'Silver',
        bannerUrl: 'https://images.unsplash.com/photo-1596838132731-3301c3fd4317?auto=format&fit=crop&w=800&q=80',
      ),
       HallMembershipModel(
        hallId: 'beach-bingo',
        hallName: 'Beachside Bingo',
        balance: 50,
        currencyName: 'Tokens',
        tier: 'Bronze',
        bannerUrl: 'https://images.unsplash.com/photo-1563089145-599997674d42?auto=format&fit=crop&w=800&q=80',
      ),
    ];

    for (var m in memberships) {
      final doc = userRef.collection('memberships').doc(m.hallId);
      batch.set(doc, m.toJson());
    }


    // 2. Clear Raffle Tickets (Clean Slate)
    final existingTickets = await userRef.collection('raffle_tickets').get();
    for (var doc in existingTickets.docs) {
      batch.delete(doc.reference);
    }

    // 3. Clear Tournaments (Clean Slate)
    final existingTournaments = await userRef.collection('tournaments').get();
    for (var doc in existingTournaments.docs) {
      batch.delete(doc.reference);
    }
    
    // 4. Seed Mock Transactions
    // Clear old
    final existingTx = await userRef.collection('transactions').get();
    for (var doc in existingTx.docs) {
       batch.delete(doc.reference);
    }

    // Create new transactions across a few days
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final twoDaysAgo = now.subtract(const Duration(days: 2));

    final transactions = [
      // Today - Mary Esther
      TransactionModel(
        id: 'tx_1', userId: userId, hallId: 'mary-esther-bingo', hallName: 'Mary Esther Bingo', 
        amount: 50, description: 'Daily Check-in', timestamp: now.subtract(const Duration(hours: 1)),
      ),
      TransactionModel(
        id: 'tx_2', userId: userId, hallId: 'mary-esther-bingo', hallName: 'Mary Esther Bingo', 
        amount: -20, description: 'Raffle Ticket Purchase', timestamp: now.subtract(const Duration(hours: 2)),
      ),
       TransactionModel(
        id: 'tx_3', userId: userId, hallId: 'mary-esther-bingo', hallName: 'Mary Esther Bingo', 
        amount: 500, description: 'Jackpot Consolation', timestamp: now.subtract(const Duration(minutes: 30)),
      ),
      
      // Yesterday - Grand Bingo
      TransactionModel(
        id: 'tx_4', userId: userId, hallId: 'grand-bingo-1', hallName: 'Grand Bingo Hall', 
        amount: 100, description: 'Bingo Win', timestamp: yesterday.subtract(const Duration(hours: 4)),
      ),
      
      // Two Days Ago - Beach Bingo (Spend)
       TransactionModel(
        id: 'tx_5', userId: userId, hallId: 'beach-bingo', hallName: 'Beachside Bingo', 
        amount: -50, description: 'Snack Bar', timestamp: twoDaysAgo.subtract(const Duration(hours: 6)),
      ),
    ];
    
    for (var tx in transactions) {
       final doc = userRef.collection('transactions').doc(tx.id);
       batch.set(doc, tx.toJson());
    }

    await batch.commit();
  }
}
