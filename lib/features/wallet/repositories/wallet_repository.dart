import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  // --- Seeding ---

  Future<void> seedWalletData(String userId) async {
    final batch = _firestore.batch();
    final userRef = _firestore.collection('users').doc(userId);

    // 1. Seed Memberships (Hall Cards)
    final memberships = [
      const HallMembershipModel(
        hallId: 'mary-esther-bingo',
        hallName: 'Mary Esther Bingo',
        balance: 1250,
        currencyName: 'Points',
        tier: 'Gold',
        bannerUrl: 'https://images.unsplash.com/photo-1518893063132-36e465be779d?auto=format&fit=crop&w=800&q=80',
      ),
      const HallMembershipModel(
        hallId: 'grand-bingo-1',
        hallName: 'Grand Bingo Hall',
        balance: 450,
        currencyName: 'Credits',
        tier: 'Silver',
        bannerUrl: 'https://images.unsplash.com/photo-1596838132731-3301c3fd4317?auto=format&fit=crop&w=800&q=80',
      ),
      const HallMembershipModel(
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

    // 2. Seed Raffle Tickets
    final tickets = [
      RaffleTicketModel(
        id: 'ticket-001',
        raffleId: 'raffle-mega',
        title: 'MacBook Pro Giveaway',
        hallName: 'Mary Esther Bingo',
        quantity: 5,
        purchaseDate: DateTime.now().subtract(const Duration(days: 1)),
        imageUrl: 'https://images.unsplash.com/photo-1517336714731-489689fd1ca4?auto=format&fit=crop&w=200&q=80',
      ),
      RaffleTicketModel(
        id: 'ticket-002',
        raffleId: 'raffle-cash',
        title: '\$500 Cash Pot',
        hallName: 'Grand Bingo Hall',
        quantity: 2,
        purchaseDate: DateTime.now().subtract(const Duration(days: 3)),
        imageUrl: 'https://images.unsplash.com/photo-1518183214770-9cffbec72538?auto=format&fit=crop&w=200&q=80',
      ),
    ];

    for (var t in tickets) {
      final doc = userRef.collection('raffle_tickets').doc(t.id);
      batch.set(doc, t.toJson());
    }

    // 3. Seed Tournaments
    final tournaments = [
      TournamentParticipationModel(
        id: 'tourney-001',
        tournamentId: 't-weekly',
        title: 'Weekly High Rollers',
        hallName: 'Mary Esther Bingo',
        currentPlacement: '3rd',
        status: 'Active',
        lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      TournamentParticipationModel(
        id: 'tourney-002',
        tournamentId: 't-slots',
        title: 'Slot Mania',
        hallName: 'Beachside Bingo',
        currentPlacement: 'Qualifying',
        status: 'Pending',
        lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    for (var t in tournaments) {
      final doc = userRef.collection('tournaments').doc(t.id);
      batch.set(doc, t.toJson());
    }

    await batch.commit();
  }
}
