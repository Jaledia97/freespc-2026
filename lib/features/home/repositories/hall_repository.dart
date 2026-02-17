import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart'; 
import '../../../models/bingo_hall_model.dart';
import '../../../models/user_model.dart'; // Import UserModel
import '../../../models/special_model.dart';
import '../../../models/raffle_model.dart';
import 'dart:math';

final hallRepositoryProvider = Provider((ref) => HallRepository(FirebaseFirestore.instance));

final hallsStreamProvider = StreamProvider.family<List<BingoHallModel>, List<String>>((ref, ids) {
  return ref.watch(hallRepositoryProvider).getHallsByIds(ids);
});

final hallStreamProvider = StreamProvider.family<BingoHallModel?, String>((ref, id) {
  return ref.watch(hallRepositoryProvider).getHallStream(id);
});

final hallSpecialsProvider = StreamProvider.family<List<SpecialModel>, String>((ref, hallId) {
  return ref.read(hallRepositoryProvider).getSpecialsForHall(hallId);
});

final hallRafflesProvider = StreamProvider.family<List<RaffleModel>, String>((ref, hallId) {
  return ref.read(hallRepositoryProvider).getRaffles(hallId);
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

  Stream<BingoHallModel?> getHallStream(String id) {
    return _firestore.collection('bingo_halls').doc(id).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      try {
        return BingoHallModel.fromJson(doc.data()!);
      } catch (e) {
        print("Error parsing hall $id: $e");
        return null;
      }
    });
  }

  // --- Specials Feed ---
  Stream<List<SpecialModel>> getSpecialsFeed(Position? userLocation) {
    return _firestore
        .collection('specials')
        .where('isTemplate', isEqualTo: false) // EXCLUDE TEMPLATES
        // .orderBy('startTime', descending: false) // Removed ordering here as we re-sort after projection
        .snapshots()
        .map((snapshot) {
          final specials = snapshot.docs.map((doc) => SpecialModel.fromJson(doc.data())).toList();
          
          // 1. Project Recurring Events
          final projectedSpecials = _projectSpecials(specials);

          if (userLocation == null) return projectedSpecials; // Return all if no location

          // 2. Filter by 75 mile radius
          final nearbySpecials = projectedSpecials.where((s) {
            if (s.latitude == null || s.longitude == null) return true; // Keep if no coords
            
            final distanceMeters = Geolocator.distanceBetween(
              userLocation.latitude, 
              userLocation.longitude, 
              s.latitude!, 
              s.longitude!
            );
            
            return distanceMeters <= 120700; // 75 miles
          }).toList();

          // Fallback: If nothing nearby, show everything (Demo Mode behavior)
          if (nearbySpecials.isEmpty && projectedSpecials.isNotEmpty) {
             return projectedSpecials;
          }
          
          return nearbySpecials;
    });
  }

  Stream<List<SpecialModel>> getSpecialsForHall(String hallId) {
    return _firestore
        .collection('specials')
        .where('hallId', isEqualTo: hallId)
        .snapshots()
        .map((snapshot) {
           final specials = snapshot.docs.map((doc) => SpecialModel.fromJson(doc.data())).toList();
           // For CMS, we want EVERYTHING.
           // However, _projectSpecials is designed for the FEED (hiding expired).
           // Let's create a separate helper or flag.
           return _projectSpecials(specials, includeAll: true);
        });
  }

  // Helper: Projects recurring events into the future
  List<SpecialModel> _projectSpecials(List<SpecialModel> input, {bool includeAll = false}) {
    final now = DateTime.now();
    final output = <SpecialModel>[];

    for (var s in input) {
      if (includeAll) {
        output.add(s);
        continue;
      }
      
      // 1. If not recurring, check expiry
      if (s.recurrence == 'none') {
        // Only show if not expired more than 24 hours ago? Or keep history?
        // For feed, usually only upcoming or active.
        final end = s.endTime ?? s.startTime?.add(const Duration(hours: 2));
        if (end != null && end.isAfter(now.subtract(const Duration(hours: 12)))) {
           output.add(s);
        }
        continue;
      }

      // 2. Recurring Logic
      if (s.startTime == null) continue;

      final originalStart = s.startTime!;
      // FIX: Convert to Local to get the correct "Wall Clock" hour/minute as intended by the user.
      // Firestore stores as UTC. If we use UTC hour (e.g. 00:00 for 7pm EST), we project to 00:00 Today, which is wrong.
      final localStart = originalStart.toLocal();
      
      final originalEnd = s.endTime ?? originalStart.add(const Duration(hours: 4)); 
      final duration = originalEnd.difference(originalStart);
      
      DateTime activeStart = localStart; // Default to local version logic
      // Note: We don't really use 'activeStart' except as a base for candidates.
      
      // Calculate Candidate base using LOCAL time components
      DateTime createCandidate(DateTime base, int addedDays) {
         return DateTime(base.year, base.month, base.day, localStart.hour, localStart.minute).add(Duration(days: addedDays));
      }
      DateTime activeEnd = originalEnd;
      
      // If the original instance is already past, find the NEXT instance relative to NOW
      if (activeEnd.isBefore(now)) {
        if (s.recurrence == 'daily') {
          // Project to today with same time
          var candidate = createCandidate(now, 0);
          // If that candidate is already over (or started?), move to tomorrow?
          // Let's say we want to show it if it ends in future.
          var candidateEnd = candidate.add(duration);
          
          if (candidateEnd.isBefore(now)) {
             candidate = candidate.add(const Duration(days: 1));
          }
          activeStart = candidate;
        } else if (s.recurrence == 'weekly') {
           // Find offset to next weekday
           // use localStart.weekday to ensure it matches the user's intended day
           int daysToAdd = (localStart.weekday - now.weekday + 7) % 7;
           var candidate = createCandidate(now, daysToAdd);
           var candidateEnd = candidate.add(duration);
           
           if (candidateEnd.isBefore(now)) {
              candidate = candidate.add(const Duration(days: 7));
           }
           activeStart = candidate;
        } else if (s.recurrence == 'monthly') {
           // Try this month
           var candidate = DateTime(now.year, now.month, localStart.day, localStart.hour, localStart.minute);
           var candidateEnd = candidate.add(duration);
           
           if (candidateEnd.isBefore(now)) {
              // Move to next month
              // Handle Dec -> Jan wrap automatically by DateTime
              candidate = DateTime(now.year, now.month + 1, localStart.day, localStart.hour, localStart.minute);
           }
           activeStart = candidate;
        }
        
        activeEnd = activeStart.add(duration);
        
        // Use the projected times
        output.add(s.copyWith(
          startTime: activeStart,
          endTime: activeEnd,
        ));
      } else {
        // Original instance is still valid
        output.add(s);
      }
    }

    // Sort valid/projected list
    output.sort((a, b) => (a.startTime ?? DateTime.now()).compareTo(b.startTime ?? DateTime.now()));
    
    return output;
  }

  // --- Specials Management (CMS) ---
  Future<void> addSpecial(SpecialModel special, {bool sendNotification = false}) async {
    // Generate ID if empty
    final docRef = _firestore.collection('specials').doc();
    final newSpecial = special.copyWith(id: docRef.id);
    await docRef.set(newSpecial.toJson());

    if (sendNotification) {
      // Mock Cloud Function Trigger
      print("PUSH NOTIFICATION TRIGGERED for Special: ${newSpecial.title}");
    }
  }

  Future<void> updateSpecial(SpecialModel special, {bool sendNotification = false}) async {
    await _firestore.collection('specials').doc(special.id).update(special.toJson());

    if (sendNotification) {
      // Mock Cloud Function Trigger
      print("PUSH NOTIFICATION TRIGGERED for Special: ${special.title}");
    }
  }

  Future<void> deleteSpecial(String specialId) async {
    await _firestore.collection('specials').doc(specialId).delete();
  }

  Future<void> updateHall(BingoHallModel hall) async {
    // Ensure we keep the geo field if we are replacing, or use merge.
    // If we use merge, we only update fields present in the map.
    // Ideally we pass a Map of changes, but passing Model is easier.
    // We must ensure we don't wipe 'geo' if the model doesn't have it fully hydrated (our model has geoFirePoint getter).
    
    final data = hall.toJson();
    // Re-calculate geo if lat/lng changed
    final geoPoint = GeoFirePoint(GeoPoint(hall.latitude, hall.longitude));
    data['geo'] = geoPoint.data; // Use 'data' property of GeoFirePoint which returns the Map needed

    await _firestore.collection('bingo_halls').doc(hall.id).set(data, SetOptions(merge: true));
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
        imageUrl: 'https://images.unsplash.com/photo-1518133910546-b6c2fb7d79e3?auto=format&fit=crop&w=800&q=80', // Money/Cash (Working)
        postedAt: now.subtract(const Duration(hours: 2)),
        startTime: now.add(const Duration(hours: 2)), // Happening soon
        latitude: baseLat,
        longitude: baseLng,
        tags: ['Session', 'Progressives'],
        recurrence: 'weekly',
      ),
      SpecialModel(
        id: 'sp1-raffle',
        hallId: 'mary-esther-bingo',
        hallName: 'Mary Esther Bingo',
        title: 'Weekly Cash Pot Raffle',
        description: 'Win \$500 Cash! Tickets available at the counter or in the app.',
        imageUrl: 'https://images.unsplash.com/photo-1518133910546-b6c2fb7d79e3?auto=format&fit=crop&w=800&q=80',
        postedAt: now.subtract(const Duration(hours: 1)),
        startTime: now.add(const Duration(days: 0, hours: 2)), // Today
        latitude: baseLat,
        longitude: baseLng,
        tags: ['Raffles'],
        recurrence: 'weekly',
      ),
      SpecialModel(
        id: 'sp2',
        hallId: 'grand-bingo-1',
        hallName: 'Grand Bingo Hall',
        title: 'BOGO Buy-In',
        description: 'Buy one pack, get one FREE all day Saturday.',
        imageUrl: 'https://images.unsplash.com/photo-1596838132731-3301c3fd4317?auto=format&fit=crop&w=800&q=80', // Slots/Casino
        postedAt: now.subtract(const Duration(days: 1)),
        startTime: now.add(const Duration(days: 1, hours: 4)),
        latitude: baseLat + 0.1, 
        longitude: baseLng + 0.1,
        tags: ['Specials', 'Session'],
      ),
      SpecialModel(
        id: 'sp3',
        hallId: 'beach-bingo',
        hallName: 'Beachside Bingo',
        title: 'Seafood & Slots',
        description: 'Free shrimp cocktail with every \$20 spend.',
        imageUrl: 'https://images.unsplash.com/photo-1563089145-599997674d42?auto=format&fit=crop&w=800&q=80', // Neon/Nightlife
        postedAt: now.subtract(const Duration(hours: 5)),
        startTime: now.add(const Duration(minutes: 30)), 
        latitude: baseLat - 0.05,
        longitude: baseLng + 0.05,
        tags: ['Pulltabs', 'Regular Program'],
      ),
      SpecialModel(
        id: 'sp4',
        hallId: 'downtown-hall', 
        hallName: 'Downtown Gaming (Far)',
        title: 'Far Away Special',
        description: 'This is > 75 miles away.',
        imageUrl: 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=800&q=80', // Crowd/Event
        postedAt: now.subtract(const Duration(minutes: 30)),
        startTime: now.add(const Duration(hours: 5)),
        latitude: baseLat + 2.0, 
        longitude: baseLng,
        tags: ['Session', 'Raffles'],
      ),
      SpecialModel(
        id: 'sp5',
        hallId: 'westside-hall',
        hallName: 'Westside Winners',
        title: 'New Player Bonus',
        description: '\$20 Free Play for all new signups this week.',
        imageUrl: 'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?auto=format&fit=crop&w=800&q=80', // Abstract/Fun
        postedAt: now.subtract(const Duration(days: 2)),
        startTime: now.add(const Duration(days: 0)), // Ongoing
        latitude: baseLat + 0.02,
        longitude: baseLng - 0.02,
        tags: ['Specials', 'New Player'],
      ),
    ];

    for (var special in specials) {
      await collection.doc(special.id).set(special.toJson());
      
      // Also ensure the Hall exists with GeoHash for the Map
      // This is a "Backfill" for our mock data
      final hallId = special.hallId;
      final hallName = special.hallName;
      final lat = special.latitude ?? baseLat;
      final lng = special.longitude ?? baseLng;
      
      // Check if hall exists first to avoid overwriting real data? 
      // For seed tool, overwriting is expected.
      
      final geoPoint = GeoFirePoint(GeoPoint(lat, lng));
      
      final hall = BingoHallModel(
        id: hallId,
        name: hallName,
        beaconUuid: "mock-$hallId",
        latitude: lat,
        longitude: lng,
        isActive: true,
        street: "Mock Street",
        city: "Mary Esther", 
        state: "FL",
        zipCode: "32569",
        geoHash: geoPoint.geohash,
        followBonus: 50.0, // Bonus for following
      );
      
      final hallData = hall.toJson();
      hallData['geo'] = hall.geoFirePoint;
      
      await _firestore.collection('bingo_halls').doc(hallId).set(hallData, SetOptions(merge: true));
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
    final lat = 30.0 + random.nextDouble();
    final lng = -86.0 - random.nextDouble();
    
    final geoPoint = GeoFirePoint(GeoPoint(lat, lng));

    final mockHall = BingoHallModel(
      id: '', 
      name: "Grand Bingo Hall ${random.nextInt(100)}",
      beaconUuid: "mock-uuid-${random.nextInt(1000)}",
      latitude: lat,
      longitude: lng,
      isActive: true,
      street: "123 Random St",
      city: "Mary Esther",
      state: "FL",
      zipCode: "32569", 
      geoHash: geoPoint.geohash,
    );

    final docRef = _firestore.collection('bingo_halls').doc();
    
    final hallWithId = mockHall.copyWith(id: docRef.id);
    
    final hallData = hallWithId.toJson();
    hallData['geo'] = hallWithId.geoFirePoint;
    
    await docRef.set(hallData);
  }

  Future<List<BingoHallModel>> getAllHalls() async {
    try {
      final snapshot = await _firestore.collection('bingo_halls').get();
      return snapshot.docs.map((doc) => BingoHallModel.fromJson(doc.data())).toList();
    } catch (e) {
      print("Error getting all halls: $e");
      return [];
    }
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
    
    // Generate GeoHash
    final GeoFirePoint geoPoint = GeoFirePoint(GeoPoint(30.407, -86.662));

    // 1. Create/Update the specific Hall
    final hall = BingoHallModel(
      id: hallId,
      name: "Mary Esther Bingo",
      beaconUuid: "meb-beacon-001",
      latitude: 30.407,
      longitude: -86.662,
      isActive: true, // ... other fields
      street: "205 Mary Esther Blvd",
      city: "Mary Esther",
      state: "FL",
      zipCode: "32569",
      geoHash: geoPoint.geohash, // Scalable field
    );
    
    // We need to store the 'geo' object as a Map for GFF+
    final hallData = hall.toJson();
    hallData['geo'] = hall.geoFirePoint;

    await _firestore.collection('bingo_halls').doc(hallId).set(hallData);
    
    // 2. Update the User to be Owner
    final userRef = _firestore.collection('users').doc(userId);
    
    await userRef.update({
      'role': 'super-admin', // Updated per user request
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



  Future<void> checkHallData(String hallId) async {
    final doc = await _firestore.collection('bingo_halls').doc(hallId).get();
    print("DEBUG: Raw Hall Data for $hallId:");
    print(doc.data());
    if (doc.data() != null && doc.data()!.containsKey('geo')) {
      print("DEBUG: 'geo' field type: ${doc.data()!['geo'].runtimeType}");
      print("DEBUG: 'geo' content: ${doc.data()!['geo']}");
    } else {
      print("DEBUG: No 'geo' field found!");
    }
  }

  // --- Scalable Search ---
  // Replaces getAllHalls and old getHallsInRadius
  Stream<List<BingoHallModel>> getHallsInRadius({
    required double latitude,
    required double longitude,
    required double radiusInMiles,
  }) {
    final center = GeoFirePoint(GeoPoint(latitude, longitude));
    final radiusInKm = radiusInMiles * 1.60934;

    final collection = _firestore.collection('bingo_halls');
    
    // Subscribes to updates within the radius
    return GeoCollectionReference(collection).subscribeWithin(
      center: center,
      radiusInKm: radiusInKm,
      field: 'geo', 
      geopointFrom: (data) {
        // Robust parsing
        try {
          if (data['geo'] == null || data['geo'] is! Map) {
             throw Exception('Invalid geo field');
          }
          return (data['geo'] as Map)['geopoint'] as GeoPoint;
        } catch (e) {
          // print('Error parsing geopoint: $e'); // Optional: noisy log
          return const GeoPoint(0, 0); // Fallback to avoid crash, will likely be filtered out or show at 0,0
        }
      },
    ).map((snapshots) {
      print("GeoFire Query: Found ${snapshots.length} potential matches");
      return snapshots.map((doc) {
        final data = doc.data(); 
        if (data == null) return null;
        // Verify geo field exists before returning model, otherwise standard json parsing might fail if we relied on it
        // Actually locally we use lat/lng from model, not 'geo'
        try {
           return BingoHallModel.fromJson(data);
        } catch (e) {
           print("Error parsing hall model: $e");
           return null;
        } 
      }).whereType<BingoHallModel>().toList();
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

  Future<void> toggleFollow(String userId, String hallId, bool isFollowing, String hallName) async {
    final userRef = _firestore.collection('users').doc(userId);
    if (isFollowing) {
      // Unfollow
      await userRef.update({
        'following': FieldValue.arrayRemove([hallId])
      });
    } else {
      // Follow
      // 1. Update List
      await userRef.update({
        'following': FieldValue.arrayUnion([hallId])
      });

      // 2. Ensure Membership Card Exists & Check for Bonus
      final membershipRef = userRef.collection('memberships').doc(hallId);
      final doc = await membershipRef.get();
      
      if (!doc.exists) {
        // Fetch Hall Details to check for Bonus
        double initialBalance = 0.0;
        final hallDoc = await _firestore.collection('bingo_halls').doc(hallId).get();
        if (hallDoc.exists) {
          final hallData = hallDoc.data();
          final bonus = (hallData?['followBonus'] as num?)?.toDouble() ?? 0.0;
          if (bonus > 0) {
            initialBalance = bonus;
            
            // Log Transaction for Bonus
            final transactionRef = _firestore.collection('transactions').doc();
             await transactionRef.set({
              'id': transactionRef.id,
              'userId': userId,
              'hallId': hallId,
              'amount': bonus.toInt(), // Stored as int usually, or double? keeping consistency
              'timestamp': FieldValue.serverTimestamp(),
              'type': 'bonus',
              'description': 'New Follow Bonus',
            });
          }
        }

        // Create default membership
        await membershipRef.set({
          'hallId': hallId,
          'hallName': hallName,
          'balance': initialBalance, 
          'currencyName': 'Points',
          'tier': 'Member',
          'joinedAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  Future<void> toggleHomeBase(String userId, String hallId, String? currentHomeBaseId) async {
    // If already set to this hall, unset it. Otherwise, set it.
    final newHomeBaseId = (currentHomeBaseId == hallId) ? null : hallId;
    
    await _firestore.collection('users').doc(userId).update({
      'homeBaseId': newHomeBaseId
    });
  }

  // --- Raffles Management (CMS) ---
  Stream<List<RaffleModel>> getRaffles(String hallId) {
    return _firestore
        .collection('raffles')
        .where('hallId', isEqualTo: hallId)
        .orderBy('endsAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => RaffleModel.fromJson(doc.data())).toList());
  }

  Future<void> addRaffle(RaffleModel raffle) async {
    final docRef = _firestore.collection('raffles').doc();
    final newRaffle = raffle.copyWith(id: docRef.id);
    await docRef.set(newRaffle.toJson());
  }

  Future<void> updateRaffle(RaffleModel raffle) async {
    await _firestore.collection('raffles').doc(raffle.id).set(raffle.toJson());
  }

  Future<void> deleteRaffle(String raffleId) async {
    await _firestore.collection('raffles').doc(raffleId).delete();
  }

  Future<void> seedRaffles(String hallId) async {
    final collection = _firestore.collection('raffles');
    final now = DateTime.now();

    final raffles = [
      RaffleModel(
        id: 'raffle-${hallId}-1',
        hallId: hallId,
        name: 'Weekly Cash Pot',
        description: 'Win \$500 Cash! Winner drawn Friday night.',
        imageUrl: 'https://images.unsplash.com/photo-1518133910546-b6c2fb7d79e3?auto=format&fit=crop&w=800&q=80', // Money/Cash
        maxTickets: 200,
        soldTickets: 45,
        endsAt: now.add(const Duration(days: 4)),
      ),
      RaffleModel(
        id: 'raffle-${hallId}-2',
        hallId: hallId,
        name: 'Luxury Spa Day',
        description: 'Full day package at Serenity Spa.',
        imageUrl: 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?auto=format&fit=crop&w=800&q=80', // Spa
        maxTickets: 100,
        soldTickets: 12,
        endsAt: now.add(const Duration(days: 10)),
      ),
       RaffleModel(
        id: 'raffle-${hallId}-3',
        hallId: hallId,
        name: '65" 4K TV',
        description: 'Upgrade your living room!',
        imageUrl: 'https://images.unsplash.com/photo-1593784991095-a205069470b6?auto=format&fit=crop&w=800&q=80', // TV
        maxTickets: 50,
        soldTickets: 2,
        endsAt: now.add(const Duration(days: 30)),
      ),
    ];

    for (var r in raffles) {
      await collection.doc(r.id).set(r.toJson());
    }
  }
  // --- Asset Library ---
  Future<void> addToAssetLibrary(String hallId, String url, String type) async {
    await _firestore.collection('bingo_halls').doc(hallId).collection('assets').add({
      'url': url,
      'type': type,
      'uploadedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<String>> getAssetLibrary(String hallId, String type) {
    return _firestore
        .collection('bingo_halls')
        .doc(hallId)
        .collection('assets')
        .where('type', isEqualTo: type)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((d) => d.data()['url'] as String).toList());
  }

  // --- Historic Image Usage (Quick Select) ---
  Stream<List<String>> getRecentSpecialImages(String hallId) {
    return _firestore
        .collection('specials')
        .where('hallId', isEqualTo: hallId)
        .orderBy('postedAt', descending: true)
        .limit(20) // Fetch top 20 to get enough unique ones
        .snapshots()
        .map((snapshot) {
          final urls = <String>{};
          for (var doc in snapshot.docs) {
            final data = doc.data();
            if (data['imageUrl'] != null) {
              urls.add(data['imageUrl'] as String);
            }
          }
          return urls.toList();
        });
  }
}
