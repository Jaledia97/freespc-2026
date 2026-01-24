import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../models/bingo_hall_model.dart';
import '../../../models/user_model.dart'; // Import UserModel
import '../../../models/special_model.dart';
import 'dart:math';

final hallRepositoryProvider = Provider((ref) => HallRepository(FirebaseFirestore.instance));

final hallsStreamProvider = StreamProvider.family<List<BingoHallModel>, List<String>>((ref, ids) {
  return ref.watch(hallRepositoryProvider).getHallsByIds(ids);
});

class HallRepository {
  final FirebaseFirestore _firestore;

  HallRepository(this._firestore);

  Stream<List<BingoHallModel>> getHallsByIds(List<String> ids) {
    if (ids.isEmpty) return Stream.value([]);
    
    // chunks of 10 for 'whereIn' limitation (max 30 in Firestore, but 10 is safe)
    // For MVP, assuming < 30 follows. If more, we'd need to merge streams or just limit.
    // Let's implement robust chunking or just standard 10 for now.
    // Actually, simply 'whereIn' ids.take(30) is a reasonable MVP limit.
    final safeIds = ids.take(30).toList();
    
    return _firestore
        .collection('bingo_halls')
        .where('id', whereIn: safeIds)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => BingoHallModel.fromJson(doc.data())).toList();
    });
  }

  // --- Specials Feed ---
  Stream<List<SpecialModel>> getSpecialsFeed(Position? userLocation) {
    return _firestore
        .collection('specials')
        .orderBy('startTime', descending: false) // Closest upcoming first
        // .where('startTime', isGreaterThan: DateTime.now().subtract(const Duration(hours: 12))) // Optional optimization
        .snapshots()
        .map((snapshot) {
          final specials = snapshot.docs.map((doc) => SpecialModel.fromJson(doc.data())).toList();

          if (userLocation == null) return specials; // Return all if no location

          // Filter by 75 mile radius
          return specials.where((s) {
            if (s.latitude == null || s.longitude == null) return true; // Keep if no coords (legacy/global)
            
            final distanceMeters = Geolocator.distanceBetween(
              userLocation.latitude, 
              userLocation.longitude, 
              s.latitude!, 
              s.longitude!
            );
            
            // 75 miles in meters ~= 120,700
            return distanceMeters <= 120700;
          }).toList();
    });
  }

  // --- Admin/Seed Tools ---
  Future<void> seedSpecials() async {
    final collection = _firestore.collection('specials');
    // For seeding, let's delete existing to ensure schema update
    final existing = await collection.limit(50).get();
    for (var doc in existing.docs) {
      await doc.reference.delete();
    }

    final now = DateTime.now();
    // Use Mary Esther coords as base for most (30.407, -86.662)
    const baseLat = 30.407;
    const baseLng = -86.662;

    final specials = [
      SpecialModel(
        id: 'sp1',
        hallId: 'mary-esther-bingo',
        hallName: 'Mary Esther Bingo',
        title: 'Friday Night Megapot',
        description: '\$10,000 Must Go! Doors open at 4pm.',
        imageUrl: 'https://loremflickr.com/800/400/bingo?lock=1',
        postedAt: now.subtract(const Duration(hours: 2)),
        startTime: now.add(const Duration(hours: 2)), // Happening soon
        latitude: baseLat,
        longitude: baseLng,
        tags: ['Session', 'Progressives'],
      ),
      SpecialModel(
        id: 'sp2',
        hallId: 'grand-bingo-1',
        hallName: 'Grand Bingo Hall',
        title: 'BOGO Buy-In',
        description: 'Buy one pack, get one FREE all day Saturday.',
        imageUrl: 'https://loremflickr.com/800/400/bingo?lock=2',
        postedAt: now.subtract(const Duration(days: 1)),
        startTime: now.add(const Duration(days: 1, hours: 4)),
        latitude: baseLat + 0.1, // Nearby
        longitude: baseLng + 0.1,
        tags: ['Specials', 'Session'],
      ),
      SpecialModel(
        id: 'sp3',
        hallId: 'beach-bingo',
        hallName: 'Beachside Bingo',
        title: 'Seafood & Slots',
        description: 'Free shrimp cocktail with every \$20 spend.',
        imageUrl: 'https://loremflickr.com/800/400/casino?lock=3',
        postedAt: now.subtract(const Duration(hours: 5)),
        startTime: now.add(const Duration(minutes: 30)), // Starting VERY soon
        latitude: baseLat - 0.05,
        longitude: baseLng + 0.05,
        tags: ['Pulltabs', 'Regular Program'],
      ),
      SpecialModel(
        id: 'sp4', // Far away example (should be filtered out if we test radius)
        hallId: 'downtown-hall', 
        hallName: 'Downtown Gaming (Far)',
        title: 'Far Away Special',
        description: 'This is > 75 miles away.',
        imageUrl: 'https://loremflickr.com/800/400/gambling?lock=4',
        postedAt: now.subtract(const Duration(minutes: 30)),
        startTime: now.add(const Duration(hours: 5)),
        latitude: baseLat + 2.0, // ~138 miles away (1 deg lat ~ 69 miles)
        longitude: baseLng,
        tags: ['Session', 'Raffles'],
      ),
      SpecialModel(
        id: 'sp5',
        hallId: 'westside-hall',
        hallName: 'Westside Winners',
        title: 'New Player Bonus',
        description: '\$20 Free Play for all new signups this week.',
        imageUrl: 'https://loremflickr.com/800/400/bingo,balls?lock=5',
        postedAt: now.subtract(const Duration(days: 2)),
        startTime: now.add(const Duration(days: 0)), // Ongoing
        latitude: baseLat + 0.02,
        longitude: baseLng - 0.02,
        tags: ['Specials', 'New Player'],
      ),
    ];

    for (var special in specials) {
      await collection.doc(special.id).set(special.toJson());
    }
  }

  // --- GPS Suggestions ---
  Future<List<BingoHallModel>> getNearbyHalls(List<String> subscribedHallIds, {Position? location, int limit = 5}) async {
    try {
      // 1. Get User Location (Use cached if provided, otherwise fetch fresh)
      final Position position = location ?? await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium
      );

      // 2. Fetch Halls (Limit to 50 for sanity)
      // Note: Geo-querying Firestore is complex without dedicated libs (GeoFlutterFire).
      // For this scale (<50 halls), filtering client-side is acceptable.
      final snapshot = await _firestore.collection('bingo_halls').limit(20).get();
      final allHalls = snapshot.docs.map((doc) => BingoHallModel.fromJson(doc.data())).toList();

      // 3. Filter & Sort
      final List<MapEntry<BingoHallModel, double>> rankedHalls = [];

      for (var hall in allHalls) {
        // Skip subscribed halls
        if (subscribedHallIds.contains(hall.id)) continue;

        final distance = Geolocator.distanceBetween(
          position.latitude, 
          position.longitude, 
          hall.latitude, 
          hall.longitude
        );

        rankedHalls.add(MapEntry(hall, distance));
      }

      // Sort by distance (nearest first)
      rankedHalls.sort((a, b) => a.value.compareTo(b.value));

      // Take top N
      return rankedHalls.take(limit).map((e) => e.key).toList();
    } catch (e) {
      print("Error fetching nearby halls: $e");
      return [];
    }
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
      street: "123 Random St",
      city: "Mary Esther",
      state: "FL",
      zipCode: "32569", 
    );

    // We need to exclude ID from the data we set if we want Firestore to generate one, 
    // or generate one ourselves. BingoHallModel requires ID. 
    // Let's create a new doc ref first.
    final docRef = _firestore.collection('bingo_halls').doc();
    
    // Create copy with the generated Doc ID
    final hallWithId = mockHall.copyWith(id: docRef.id);
    
    await docRef.set(hallWithId.toJson());
  }

  // --- Advanced Search ---
  Future<List<BingoHallModel>> searchHalls(String query, {Position? userLocation}) async {
    try {
      final lowerQuery = query.toLowerCase().trim();
      
      // Fetch all halls (optimize later with algolia/elastic if needed)
      final snapshot = await _firestore.collection('bingo_halls').limit(25).get();
      final allHalls = snapshot.docs.map((doc) => BingoHallModel.fromJson(doc.data())).toList();

      if (allHalls.isEmpty) return [];

      // 1. Initial Filter (Name, City, Zip)
      List<BingoHallModel> matches = allHalls.where((hall) {
        final name = hall.name.toLowerCase();
        final city = hall.city?.toLowerCase() ?? '';
        final zip = hall.zipCode ?? '';
        
        return name.contains(lowerQuery) || city.contains(lowerQuery) || zip.contains(lowerQuery);
      }).toList();

      // 2. Zip Code Logic (The "Fill to 10" Rule)
      final isZipSearch = int.tryParse(lowerQuery) != null && lowerQuery.length == 5;
      
      if (isZipSearch) {
        // If we have less than 10 results, we need to fill with spatially nearest halls.
        if (matches.length < 10) {
          // Determine Anchor Point
          double anchorLat;
          double anchorLng;

          if (matches.isNotEmpty) {
            // Best case: We have at least one hall in that zip. Use it as anchor.
            anchorLat = matches.first.latitude;
            anchorLng = matches.first.longitude;
          } else if (userLocation != null) {
             // Fallback: If no halls match the zip, use the User's location as the anchor.
             // This fulfills: "If there isn't ATLEAST 10 halls... grab the nearest halls to fill".
             // Since we can't geocode, we grab nearest to the USER.
             anchorLat = userLocation.latitude;
             anchorLng = userLocation.longitude;
          } else {
            // No matches and no user location? Return empty.
            return [];
          }

          // 3. Find Neighbors
          final otherHalls = allHalls.where((h) => !matches.any((m) => m.id == h.id)).toList();
          
          final List<MapEntry<BingoHallModel, double>> neighbors = [];
          for (var hall in otherHalls) {
             final distance = Geolocator.distanceBetween(anchorLat, anchorLng, hall.latitude, hall.longitude);
             neighbors.add(MapEntry(hall, distance));
          }

          // Sort by distance
          neighbors.sort((a, b) => a.value.compareTo(b.value));

          // Take enough to reach 10
          final needed = 10 - matches.length;
          matches.addAll(neighbors.take(needed).map((e) => e.key));
        }
      }

      return matches;

    } catch (e) {
      print("Error searching halls: $e");
      return [];
    }
  }

  Future<void> seedMaryEstherEnv(String userId) async {
    const hallId = 'mary-esther-bingo';
    
    // 1. Create/Update the specific Hall
    final hall = BingoHallModel(
      id: hallId,
      name: "Mary Esther Bingo",
      beaconUuid: "meb-beacon-001",
      latitude: 30.407,
      longitude: -86.662,
      isActive: true,
      street: "205 Mary Esther Blvd",
      city: "Mary Esther",
      state: "FL",
      zipCode: "32569",
    );
    
    await _firestore.collection('bingo_halls').doc(hallId).set(hall.toJson());
    
    // 2. Update the User to be Owner
    final userRef = _firestore.collection('users').doc(userId);
    
    await userRef.update({
      'role': 'owner',
      'homeBaseId': hallId,
      'qrToken': 'meb-owner-token-${userId.substring(0, 5)}', // Semi-stable token
    });

    // 3. Create Public Worker Profile (Safe for scanning)
    await _firestore.collection('public_workers').doc(userId).set({
      'uid': userId,
      'firstName': 'Mary Esther Owner', // ideally fetch this from user profile if available, but for seed we hardcode or query first
      'role': 'owner',
      'qrToken': 'meb-owner-token-${userId.substring(0, 5)}',
      'homeBaseId': hallId,
    });
  }

  Future<UserModel?> getWorkerFromQr(String qrToken) async {
    try {
      print('Scanning for Token: $qrToken');
      // Query the SAFE collection
      final querySnapshot = await _firestore
          .collection('public_workers')
          .where('qrToken', isEqualTo: qrToken)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      final data = querySnapshot.docs.first.data();
      
      // Return safe partial user model
      return UserModel(
        uid: data['uid'],
        email: '', // Not exposed
        firstName: data['firstName'] ?? 'Worker',
        lastName: '',
        username: '',
        birthday: DateTime.now(), // Dummy
        role: data['role'],
        homeBaseId: data['homeBaseId'],
        qrToken: data['qrToken'],
      );
    } catch (e) {
      print("Error finding worker: $e");
      return null;
    }
  }

  Future<void> toggleFollow(String userId, String hallId, bool isFollowing) async {
    final userRef = _firestore.collection('users').doc(userId);
    if (isFollowing) {
      // Unfollow
      await userRef.update({
        'following': FieldValue.arrayRemove([hallId])
      });
    } else {
      // Follow
      await userRef.update({
        'following': FieldValue.arrayUnion([hallId])
      });
    }
  }

  Future<void> toggleHomeBase(String userId, String hallId, String? currentHomeBaseId) async {
    // If already set to this hall, unset it. Otherwise, set it.
    final newHomeBaseId = (currentHomeBaseId == hallId) ? null : hallId;
    
    await _firestore.collection('users').doc(userId).update({
      'homeBaseId': newHomeBaseId
    });
  }
}
