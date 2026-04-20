import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import '../../../models/venue_model.dart';
import '../../../models/user_model.dart'; // Import UserModel
import '../../../models/special_model.dart';
import '../../../models/raffle_model.dart';
import '../../../models/tournament_model.dart';
import '../../../models/comment_model.dart';
import '../../../models/trivia_model.dart';
import '../../../models/bar_game_model.dart';
import 'dart:convert';
import '../../../core/utils/recurrence_utils.dart';
import 'dart:math';
import 'package:flutter/foundation.dart'; // For compute

import '../../../services/session_context_controller.dart';
import '../../../services/auth_service.dart';

final venueRepositoryProvider = Provider(
  (ref) => VenueRepository(FirebaseFirestore.instance, ref),
);

final venuesStreamProvider =
    StreamProvider.family<List<VenueModel>, List<String>>((ref, ids) {
      return ref.watch(venueRepositoryProvider).getHallsByIds(ids);
    });

final venueStreamProvider = StreamProvider.family<VenueModel?, String>((
  ref,
  id,
) {
  return ref.watch(venueRepositoryProvider).getHallStream(id);
});

final hallSpecialsProvider = StreamProvider.family<List<SpecialModel>, String>((
  ref,
  venueId,
) {
  return ref.read(venueRepositoryProvider).getSpecialsForHall(venueId);
});

final hallRafflesProvider = StreamProvider.family<List<RaffleModel>, String>((
  ref,
  venueId,
) {
  return ref.read(venueRepositoryProvider).getRaffles(venueId);
});

final hallTriviaProvider = StreamProvider.family<List<TriviaModel>, String>((
  ref,
  venueId,
) {
  return ref.read(venueRepositoryProvider).getTriviaForVenue(venueId);
});

final hallBarGamesProvider = StreamProvider.family<List<BarGameModel>, String>((
  ref,
  venueId,
) {
  return ref.read(venueRepositoryProvider).getBarGamesForVenue(venueId);
});

final specialsFeedProvider = StreamProvider<List<SpecialModel>>((ref) {
  return ref.watch(venueRepositoryProvider).getSpecialsFeed(null);
});

final rafflesFeedProvider = StreamProvider<List<RaffleModel>>((ref) {
  return ref.watch(venueRepositoryProvider).getActiveRafflesFeed(null);
});

final allCustomTagsProvider = Provider<Map<String, int>>((ref) {
  // We can derive this from the global specials feed so it updates live
  final specials = ref.watch(specialsFeedProvider).value ?? [];
  final counts = <String, int>{};
  for (final special in specials) {
    for (final tag in special.tags) {
      counts[tag] = (counts[tag] ?? 0) + 1;
    }
  }
  return counts;
});

class VenueRepository {
  final FirebaseFirestore _firestore;
  final Ref _ref;

  VenueRepository(this._firestore, this._ref);

  Stream<List<VenueModel>> getHallsByIds(List<String> ids) {
    if (ids.isEmpty) return Stream.value([]);

    // chunks of 10 for 'whereIn' limitation (max 30 in Firestore, but 10 is safe)
    // For MVP, assuming < 30 follows. If more, we'd need to merge streams or just limit.
    // Let's implement robust chunking or just standard 10 for now.
    // Actually, simply 'whereIn' ids.take(30) is a reasonable MVP limit.
    final safeIds = ids.take(30).toList();

    return _firestore
        .collection('venues')
        .where('id', whereIn: safeIds)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => VenueModel.fromJson(doc.data()))
              .toList();
        });
  }

  Stream<VenueModel?> getHallStream(String id) {
    return _firestore.collection('venues').doc(id).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      try {
        final data = doc.data()!;
        // Gracefully handle legacy or corrupted sandbox venues without strict geo fields
        if (data['latitude'] == null) data['latitude'] = 0.0;
        if (data['longitude'] == null) data['longitude'] = 0.0;
        
        return VenueModel.fromJson(data);
      } catch (e) {
        debugPrint("Error parsing venue $id: $e");
        return null;
      }
    });
  }

  // --- Specials Feed ---
  Stream<List<SpecialModel>> getSpecialsFeed(Position? userLocation) {
    return _firestore
        .collection('specials')
        .where('isTemplate', isEqualTo: false) // EXCLUDE TEMPLATES
        .where('isCancelled', isEqualTo: false) // EXCLUDE CANCELLED
        .limit(100) // SAFETY LIMIT
        .snapshots()
        .map((snapshot) {
          final specials = snapshot.docs
              .map((doc) => SpecialModel.fromJson(doc.data()))
              .toList();

          if (userLocation == null)
            return specials; // Return all if no location

          // 2. Filter by 75 mile radius
          final nearbySpecials = specials.where((s) {
            if (s.latitude == null || s.longitude == null)
              return true; // Keep if no coords

            final distanceMeters = Geolocator.distanceBetween(
              userLocation.latitude,
              userLocation.longitude,
              s.latitude!,
              s.longitude!,
            );

            return distanceMeters <= 120700; // 75 miles
          }).toList();

          // Fallback: If nothing nearby, show everything
          if (nearbySpecials.isEmpty && specials.isNotEmpty) {
            return specials;
          }

          return nearbySpecials;
        });
  }

  // --- Trivia Methods ---
  Stream<List<TriviaModel>> getTriviaForVenue(String venueId) {
    return _firestore
        .collection('trivia')
        .where('venueId', isEqualTo: venueId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TriviaModel.fromJson(doc.data()))
              .toList();
        });
  }

  Future<void> addTrivia(TriviaModel trivia) async {
    final data = trivia.toJson();
    await _firestore.collection('trivia').doc(trivia.id).set(data);
  }

  Future<void> updateTrivia(TriviaModel trivia) async {
    final data = trivia.toJson();
    await _firestore.collection('trivia').doc(trivia.id).update(data);
  }

  Future<void> deleteTrivia(String id) async {
    await _firestore.collection('trivia').doc(id).delete();
  }

  // --- Bar Games Methods ---
  Stream<List<BarGameModel>> getBarGamesForVenue(String venueId) {
    return _firestore
        .collection('bar_games')
        .where('venueId', isEqualTo: venueId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => BarGameModel.fromJson(doc.data()))
              .toList();
        });
  }

  Future<void> addBarGame(BarGameModel game) async {
    final data = game.toJson();
    await _firestore.collection('bar_games').doc(game.id).set(data);
  }

  Future<void> updateBarGame(BarGameModel game) async {
    final data = game.toJson();
    await _firestore.collection('bar_games').doc(game.id).update(data);
  }

  Future<void> deleteBarGame(String id) async {
    await _firestore.collection('bar_games').doc(id).delete();
  }

  Stream<List<SpecialModel>> getSpecialsForHall(String venueId) {
    return _firestore
        .collection('specials')
        .where('venueId', isEqualTo: venueId)
        .where('isTemplate', isEqualTo: false)
        .where('isCancelled', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
          final allSpecials = snapshot.docs
              .map((doc) => SpecialModel.fromJson(doc.data()))
              .toList();

          // Deduplicate recurring events: only show the first upcoming instance per template
          final uniqueSpecials = <String, SpecialModel>{};
          
          for (var special in allSpecials) {
            final tId = special.templateId;
            if (tId == null) {
              uniqueSpecials[special.id] = special; // Keep one-offs natively
            } else {
              // Group by templateId, keep the earliest one
              final existing = uniqueSpecials[tId];
              if (existing == null) {
                uniqueSpecials[tId] = special;
              } else if (special.startTime != null && existing.startTime != null) {
                if (special.startTime!.isBefore(existing.startTime!)) {
                  uniqueSpecials[tId] = special;
                }
              }
            }
          }
          
          return uniqueSpecials.values.toList()
             ..sort((a, b) => (a.startTime ?? DateTime.now()).compareTo((b.startTime ?? DateTime.now())));
        });
  }

  // --- Active Event Feeds ---
  Stream<List<RaffleModel>> getActiveRafflesFeed(Position? userLocation) {
    return _firestore
        .collection('raffles')
        .where('isTemplate', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
          final now = DateTime.now();
          final raffles = snapshot.docs
              .map((doc) => RaffleModel.fromJson(doc.data()))
              .toList();
          return raffles.where((r) => r.endsAt.isAfter(now)).toList();
        });
  }

  Stream<List<TournamentModel>> getActiveTournamentsFeed(
    Position? userLocation,
  ) {
    return _firestore
        .collection('tournaments')
        .where('isTemplate', isEqualTo: false)
        .where('isCancelled', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
          final now = DateTime.now();
          final tourneys = snapshot.docs
              .map((doc) => TournamentModel.fromJson(doc.data()))
              .toList();
          return tourneys
              .where((t) => t.endTime == null || t.endTime!.isAfter(now))
              .toList();
        });
  }

  // --- Specials Management (CMS) ---
  Future<void> addSpecial(
    SpecialModel special, {
    bool sendNotification = false,
  }) async {
    final docRef = _firestore.collection('specials').doc();
    final session = _ref.read(sessionContextProvider);
    final user = _ref.read(userProfileProvider).value;

    SpecialModel processedSpecial = special;
    if (session.isBusiness) {
      processedSpecial = special.copyWith(
        authorType: 'venue',
        authorId: session.activeVenueId,
        postedByUid: user?.uid,
      );
    } else {
      processedSpecial = special.copyWith(
        authorType: 'user',
        authorId: user?.uid,
        postedByUid: user?.uid,
      );
    }

    final newSpecial = processedSpecial.copyWith(id: docRef.id);
    
    final batch = _firestore.batch();
    batch.set(docRef, newSpecial.toJson());

    // Serialize Recurrences for 14 Days
    if (newSpecial.isTemplate && newSpecial.recurrenceRule != null && newSpecial.startTime != null && newSpecial.endTime != null) {
      final dates = RecurrenceUtils.generateOccurrenceDates(
        originalStart: newSpecial.startTime!,
        originalEnd: newSpecial.endTime!,
        rule: newSpecial.recurrenceRule!,
        maxDaysLimit: 14,
      );
      
      final duration = newSpecial.endTime!.difference(newSpecial.startTime!);

      for (var date in dates) {
        final compositeId = '${docRef.id}_${date.toUtc().toIso8601String().split('T')[0]}';
        final cloneRef = _firestore.collection('specials').doc(compositeId);
        
        final clone = newSpecial.copyWith(
          id: compositeId,
          isTemplate: false,
          templateId: docRef.id,
          startTime: date,
          endTime: date.add(duration),
          postedAt: newSpecial.postedAt,
          reactionUserIds: [],
          interestedUserIds: [],
          commentCount: 0,
          latestComment: null,
          isStarred: false,
        );
        batch.set(cloneRef, clone.toJson());
      }
    }

    await batch.commit();

    if (sendNotification) {
      debugPrint("PUSH NOTIFICATION TRIGGERED for Special: ${newSpecial.title}");
    }
  }

  Future<void> updateSpecial(
    SpecialModel special, {
    bool sendNotification = false,
  }) async {
    final batch = _firestore.batch();
    final docRef = _firestore.collection('specials').doc(special.id);
    batch.update(docRef, special.toJson());

    if (special.isTemplate && special.recurrenceRule != null && special.startTime != null && special.endTime != null) {
      // 1. Terminate pending Future versions
      final futureOrphans = await _firestore.collection('specials')
          .where('templateId', isEqualTo: special.id)
          .where('startTime', isGreaterThan: DateTime.now())
          .get();
          
      for (var doc in futureOrphans.docs) {
        batch.delete(doc.reference);
      }

      // 2. Synthesize updated pipeline
      final dates = RecurrenceUtils.generateOccurrenceDates(
        originalStart: special.startTime!,
        originalEnd: special.endTime!,
        rule: special.recurrenceRule!,
        maxDaysLimit: 14,
      );
      
      final duration = special.endTime!.difference(special.startTime!);
      final now = DateTime.now();

      for (var date in dates) {
        if (date.isBefore(now)) continue; 
        
        final compositeId = '${special.id}_${date.toUtc().toIso8601String().split('T')[0]}';
        final cloneRef = _firestore.collection('specials').doc(compositeId);
        
        final clone = special.copyWith(
          id: compositeId,
          isTemplate: false,
          templateId: special.id,
          startTime: date,
          endTime: date.add(duration),
          postedAt: date,
          reactionUserIds: [],
          interestedUserIds: [],
          commentCount: 0,
          latestComment: null,
          isStarred: false, 
        );
        batch.set(cloneRef, clone.toJson());
      }
    }

    await batch.commit();

    if (sendNotification) {
      debugPrint("PUSH NOTIFICATION TRIGGERED for Special: ${special.title}");
    }
  }

  Future<void> deleteSpecial(String specialId) async {
    final batch = _firestore.batch();
    batch.delete(_firestore.collection('specials').doc(specialId));
    
    final orphans = await _firestore.collection('specials')
        .where('templateId', isEqualTo: specialId)
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

  Future<void> updateHall(VenueModel venue) async {
    // Ensure we keep the geo field if we are replacing, or use merge.
    // If we use merge, we only update fields present in the map.
    // Ideally we pass a Map of changes, but passing Model is easier.
    // We must ensure we don't wipe 'geo' if the model doesn't have it fully hydrated (our model has geoFirePoint getter).

    final data = venue.toJson();
    // Re-calculate geo if lat/lng changed
    final geoPoint = GeoFirePoint(GeoPoint(venue.latitude, venue.longitude));
    data['geo'] = geoPoint
        .data; // Use 'data' property of GeoFirePoint which returns the Map needed

    await _firestore
        .collection('venues')
        .doc(venue.id)
        .set(data, SetOptions(merge: true));
  }

  Future<void> deleteHall(String venueId) async {
    // 1. Wipe orphan team associations structurally from all subcollections matching the venue
    final teamSnaps = await _firestore.collectionGroup('team').where('venueId', isEqualTo: venueId).get();
    final batch = _firestore.batch();
    for (var doc in teamSnaps.docs) {
      batch.delete(doc.reference);
    }
    
    // 2. Wipe the claim tracking 
    final claims = await _firestore.collection('venue_claims').where('requestedVenueId', isEqualTo: venueId).get();
    for (var claim in claims.docs) {
      batch.delete(claim.reference);
    }
    await batch.commit();

    // 3. Execute Hard Delete to wipe Sandbox completely
    await _firestore.collection('venues').doc(venueId).delete();
    await _firestore.collection('venues').doc(venueId).delete();
    
    // 4. Automatically evict user from active business routing back to Personal
    _ref.read(sessionContextProvider.notifier).switchToPersonal();
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
        venueId: 'mary-esther-bingo',
        venueName: 'Mary Esther Bingo',
        title: 'Friday Night Megapot',
        description: '\$10,000 Must Go! Doors open at 4pm.',
        imageUrl:
            'https://images.unsplash.com/photo-1518133910546-b6c2fb7d79e3?auto=format&fit=crop&w=800&q=80', // Money/Cash (Working)
        postedAt: now.subtract(const Duration(hours: 2)),
        startTime: now.add(const Duration(hours: 2)), // Happening soon
        latitude: baseLat,
        longitude: baseLng,
        tags: ['Session', 'Progressives'],
        recurrence: 'weekly',
      ),
      SpecialModel(
        id: 'sp1-raffle',
        venueId: 'mary-esther-bingo',
        venueName: 'Mary Esther Bingo',
        title: 'Weekly Cash Pot Raffle',
        description:
            'Win \$500 Cash! Tickets available at the counter or in the app.',
        imageUrl:
            'https://images.unsplash.com/photo-1518133910546-b6c2fb7d79e3?auto=format&fit=crop&w=800&q=80',
        postedAt: now.subtract(const Duration(hours: 1)),
        startTime: now.add(const Duration(days: 0, hours: 2)), // Today
        latitude: baseLat,
        longitude: baseLng,
        tags: ['Raffles'],
        recurrence: 'weekly',
      ),
      SpecialModel(
        id: 'sp2',
        venueId: 'grand-bingo-1',
        venueName: 'Grand Venue',
        title: 'BOGO Buy-In',
        description: 'Buy one pack, get one FREE all day Saturday.',
        imageUrl:
            'https://images.unsplash.com/photo-1596838132731-3301c3fd4317?auto=format&fit=crop&w=800&q=80', // Slots/Casino
        postedAt: now.subtract(const Duration(days: 1)),
        startTime: now.add(const Duration(days: 1, hours: 4)),
        latitude: baseLat + 0.1,
        longitude: baseLng + 0.1,
        tags: ['Specials', 'Session'],
      ),
      SpecialModel(
        id: 'sp3',
        venueId: 'beach-bingo',
        venueName: 'Beachside Bingo',
        title: 'Seafood & Slots',
        description: 'Free shrimp cocktail with every \$20 spend.',
        imageUrl:
            'https://images.unsplash.com/photo-1563089145-599997674d42?auto=format&fit=crop&w=800&q=80', // Neon/Nightlife
        postedAt: now.subtract(const Duration(hours: 5)),
        startTime: now.add(const Duration(minutes: 30)),
        latitude: baseLat - 0.05,
        longitude: baseLng + 0.05,
        tags: ['Pulltabs', 'Regular Program'],
      ),
      SpecialModel(
        id: 'sp4',
        venueId: 'downtown-venue',
        venueName: 'Downtown Gaming (Far)',
        title: 'Far Away Special',
        description: 'This is > 75 miles away.',
        imageUrl:
            'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=800&q=80', // Crowd/Event
        postedAt: now.subtract(const Duration(minutes: 30)),
        startTime: now.add(const Duration(hours: 5)),
        latitude: baseLat + 2.0,
        longitude: baseLng,
        tags: ['Session', 'Raffles'],
      ),
      SpecialModel(
        id: 'sp5',
        venueId: 'westside-venue',
        venueName: 'Westside Winners',
        title: 'New Player Bonus',
        description: '\$20 Free Play for all new signups this week.',
        imageUrl:
            'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?auto=format&fit=crop&w=800&q=80', // Abstract/Fun
        postedAt: now.subtract(const Duration(days: 2)),
        startTime: now.add(const Duration(days: 0)), // Ongoing
        latitude: baseLat + 0.02,
        longitude: baseLng - 0.02,
        tags: ['Specials', 'New Player'],
      ),
    ];

    for (var special in specials) {
      await collection.doc(special.id).set(special.toJson());

      // Also ensure the Venue exists with GeoHash for the Map
      // This is a "Backfill" for our mock data
      final venueId = special.venueId;
      final venueName = special.venueName;
      final lat = special.latitude ?? baseLat;
      final lng = special.longitude ?? baseLng;

      // Check if venue exists first to avoid overwriting real data?
      // For seed tool, overwriting is expected.

      final geoPoint = GeoFirePoint(GeoPoint(lat, lng));

      final venue = VenueModel(
        id: venueId,
        name: venueName,
        beaconUuid: "mock-$venueId",
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

      final hallData = venue.toJson();
      hallData['geo'] = venue.geoFirePoint;

      await _firestore
          .collection('venues')
          .doc(venueId)
          .set(hallData, SetOptions(merge: true));
    }
  }

  // --- GPS Suggestions ---
  Future<List<VenueModel>> getNearbyHalls(
    List<String> subscribedHallIds, {
    Position? location,
    int limit = 5,
  }) async {
    try {
      // 1. Get User Location (Use cached if provided, otherwise fetch fresh)
      Position? position = location ?? await Geolocator.getLastKnownPosition();

      if (position == null) {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 5),
          ),
        );
      }

      // 2. Fetch Venues (Limit to 50 for sanity)
      // Note: Geo-querying Firestore is complex without dedicated libs (GeoFlutterFire).
      // For this scale (<50 venues), filtering client-side is acceptable.
      final snapshot = await _firestore
          .collection('venues')
          .limit(20)
          .get();
      final allHalls = snapshot.docs
          .map((doc) => VenueModel.fromJson(doc.data()))
          .toList();

      // 3. Filter & Sort
      final List<MapEntry<VenueModel, double>> rankedHalls = [];

      for (var venue in allHalls) {
        // Skip subscribed venues
        if (subscribedHallIds.contains(venue.id)) continue;

        final distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          venue.latitude,
          venue.longitude,
        );

        rankedHalls.add(MapEntry(venue, distance));
      }

      // Sort by distance (nearest first)
      rankedHalls.sort((a, b) => a.value.compareTo(b.value));

      // Take top N
      return rankedHalls.take(limit).map((e) => e.key).toList();
    } catch (e) {
      debugPrint("Error fetching nearby venues: $e");
      return [];
    }
  }

  Future<void> createMockHall() async {
    final random = Random();
    final lat = 30.0 + random.nextDouble();
    final lng = -86.0 - random.nextDouble();

    final geoPoint = GeoFirePoint(GeoPoint(lat, lng));

    final mockHall = VenueModel(
      id: '',
      name: "Grand Venue ${random.nextInt(100)}",
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

    final docRef = _firestore.collection('venues').doc();

    final hallWithId = mockHall.copyWith(id: docRef.id);

    final hallData = hallWithId.toJson();
    hallData['geo'] = hallWithId.geoFirePoint;

    await docRef.set(hallData);
  }

  Future<List<VenueModel>> getAllHalls() async {
    try {
      final snapshot = await _firestore.collection('venues').get();
      return snapshot.docs
          .map((doc) => VenueModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint("Error getting all venues: $e");
      return [];
    }
  }

  // --- Advanced Search ---
  Future<List<VenueModel>> searchHalls(
    String query, {
    Position? userLocation,
  }) async {
    try {
      final lowerQuery = query.toLowerCase().trim();

      // Fetch all venues (optimize later with algolia/elastic if needed)
      final snapshot = await _firestore
          .collection('venues')
          .limit(25)
          .get();
      final allHalls = snapshot.docs
          .map((doc) => VenueModel.fromJson(doc.data()))
          .toList();

      if (allHalls.isEmpty) return [];

      // 1. Initial Filter (Name, City, Zip)
      List<VenueModel> matches = allHalls.where((venue) {
        final name = venue.name.toLowerCase();
        final city = venue.city?.toLowerCase() ?? '';
        final zip = venue.zipCode ?? '';

        return name.contains(lowerQuery) ||
            city.contains(lowerQuery) ||
            zip.contains(lowerQuery);
      }).toList();

      // 2. Zip Code Logic (The "Fill to 10" Rule)
      final isZipSearch =
          int.tryParse(lowerQuery) != null && lowerQuery.length == 5;

      if (isZipSearch) {
        // If we have less than 10 results, we need to fill with spatially nearest venues.
        if (matches.length < 10) {
          // Determine Anchor Point
          double anchorLat;
          double anchorLng;

          if (matches.isNotEmpty) {
            // Best case: We have at least one venue in that zip. Use it as anchor.
            anchorLat = matches.first.latitude;
            anchorLng = matches.first.longitude;
          } else if (userLocation != null) {
            // Fallback: If no venues match the zip, use the User's location as the anchor.
            // This fulfills: "If there isn't ATLEAST 10 venues... grab the nearest venues to fill".
            // Since we can't geocode, we grab nearest to the USER.
            anchorLat = userLocation.latitude;
            anchorLng = userLocation.longitude;
          } else {
            // No matches and no user location? Return empty.
            return [];
          }

          // 3. Find Neighbors
          final otherHalls = allHalls
              .where((h) => !matches.any((m) => m.id == h.id))
              .toList();

          final List<MapEntry<VenueModel, double>> neighbors = [];
          for (var venue in otherHalls) {
            final distance = Geolocator.distanceBetween(
              anchorLat,
              anchorLng,
              venue.latitude,
              venue.longitude,
            );
            neighbors.add(MapEntry(venue, distance));
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
      debugPrint("Error searching venues: $e");
      return [];
    }
  }

  Future<void> seedMaryEstherEnv(String userId) async {
    const venueId = 'mary-esther-bingo';

    // Generate GeoHash
    final GeoFirePoint geoPoint = GeoFirePoint(GeoPoint(30.407, -86.662));

    // 1. Create/Update the specific Venue
    final venue = VenueModel(
      id: venueId,
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
    final hallData = venue.toJson();
    hallData['geo'] = venue.geoFirePoint;

    await _firestore.collection('venues').doc(venueId).set(hallData);

    // 2. Update the User to be Owner
    final userRef = _firestore.collection('users').doc(userId);

    await userRef.update({
      'role': 'superadmin', // Updated to Super Admin per user request
      'homeBaseId': venueId,
      'qrToken':
          'meb-owner-token-${userId.substring(0, 5)}', // Semi-stable token
    });

    // 3. Create Public Worker Profile (Safe for scanning)
    await _firestore.collection('public_workers').doc(userId).set({
      'uid': userId,
      'firstName':
          'Mary Esther Owner', // ideally fetch this from user profile if available, but for seed we hardcode or query first
      'role': 'owner',
      'qrToken': 'meb-owner-token-${userId.substring(0, 5)}',
      'homeBaseId': venueId,
    });
  }

  Future<void> promoteToSuperAdmin(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'role': 'superadmin',
    });
  }

  Future<void> checkHallData(String venueId) async {
    final doc = await _firestore.collection('venues').doc(venueId).get();
    debugPrint("DEBUG: Raw Venue Data for $venueId:");
    debugPrint(doc.data()?.toString());
    if (doc.data() != null && doc.data()!.containsKey('geo')) {
      debugPrint("DEBUG: 'geo' field type: ${doc.data()!['geo'].runtimeType}");
      debugPrint("DEBUG: Venue $venueId has \${projected.length} items to show.");
    } else {
      debugPrint("DEBUG: No 'geo' field found!");
    }
  }

  // --- Scalable Search ---
  // Replaces getAllHalls and old getHallsInRadius
  Stream<List<VenueModel>> getHallsInRadius({
    required double latitude,
    required double longitude,
    required double radiusInMiles,
  }) {
    final center = GeoFirePoint(GeoPoint(latitude, longitude));
    final radiusInKm = radiusInMiles * 1.60934;

    final collection = _firestore.collection('venues');

    // Subscribes to updates within the radius
    return GeoCollectionReference(collection)
        .subscribeWithin(
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
              // debugPrint('Error parsing geopoint: $e'); // Optional: noisy log
              return const GeoPoint(
                0,
                0,
              ); // Fallback to avoid crash, will likely be filtered out or show at 0,0
            }
          },
        )
        .map((snapshots) {
          debugPrint("GeoFire Query: Found ${snapshots.length} potential matches");
          return snapshots
              .map((doc) {
                final data = doc.data();
                if (data == null) return null;
                // Verify geo field exists before returning model, otherwise standard json parsing might fail if we relied on it
                // Actually locally we use lat/lng from model, not 'geo'
                try {
                  return VenueModel.fromJson(data);
                } catch (e) {
                  debugPrint("Error parsing venue model: $e");
                  return null;
                }
              })
              .whereType<VenueModel>()
              .toList();
        });
  }

  // --- Generic Interactions ---
  Future<void> toggleInteraction(
    String collectionName,
    String docId,
    String arrayField,
    String userId,
    bool isAdding,
  ) async {
    try {
      final docRef = _firestore.collection(collectionName).doc(docId);
      if (isAdding) {
        await docRef.update({
          arrayField: FieldValue.arrayUnion([userId]),
        });
      } else {
        await docRef.update({
          arrayField: FieldValue.arrayRemove([userId]),
        });
      }
    } catch (e) {
      debugPrint("Error toggling interaction: $e");
      throw Exception('Failed to synchronize interaction state to backend: $e');
    }
  }

  // --- Comments ---
  Future<void> checkIn({
    required String userId,
    required String venueId,
    required String venueName,
  }) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return;

      final userData = userDoc.data()!;
      final userName =
          userData['username'] ?? userData['firstName'] ?? 'Player';
      final String? photoUrl = userData['photoUrl'];

      final feedRef = _firestore
          .collection('venues')
          .doc(venueId)
          .collection('feed')
          .doc();

      final batch = _firestore.batch();

      batch.set(feedRef, {
        'id': feedRef.id,
        'type': 'checkIn',
        'title': "Checked In!",
        'description': "$userName is playing at $venueName!",
        'userId': userId,
        'userName': userName,
        'userProfilePicture': photoUrl,
        'venueId': venueId,
        'venueName': venueName,
        'createdAt': FieldValue.serverTimestamp(),
        'reactionUserIds': [],
        'interestedUserIds': [],
        'commentCount': 0,
        'latestComment': null,
      });

      batch.update(_firestore.collection('users').doc(userId), {
        'currentCheckInHallId': venueId,
      });
      batch.update(_firestore.collection('public_profiles').doc(userId), {
        'currentCheckInHallId': venueId,
      });

      await batch.commit();
    } catch (e) {
      debugPrint('Check-in failed: $e');
    }
  }

  Stream<List<CommentModel>> getComments(String collectionName, String docId) {
    return _firestore
        .collection(collectionName)
        .doc(docId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CommentModel.fromFirestore(doc))
              .toList(),
        );
  }

  Future<void> addComment(
    String collectionName,
    String docId,
    CommentModel comment,
  ) async {
    final commentRef = _firestore
        .collection(collectionName)
        .doc(docId)
        .collection('comments')
        .doc();
    await commentRef.set(comment.toJson());

    // Serialize payload for the Feed Snippet
    final snippetPayload = jsonEncode({
      'authorName': comment.authorName,
      'authorAvatarUrl': comment.authorAvatarUrl ?? '',
      'text': comment.text,
    });

    await _firestore.collection(collectionName).doc(docId).update({
      'commentCount': FieldValue.increment(1),
      'latestComment': snippetPayload,
    });

    // Explicitly notify the Post/Comment Author
    try {
      final postDoc = await _firestore.collection(collectionName).doc(docId).get();
      if (postDoc.exists) {
        final postData = postDoc.data() as Map<String, dynamic>;
        String? targetUserId;
        String? threadGroupStr = docId;

        if (comment.parentId != null) {
          final parentDoc = await _firestore.collection(collectionName).doc(docId).collection('comments').doc(comment.parentId).get();
          targetUserId = parentDoc.data()?['authorId'] as String?;
          threadGroupStr = comment.parentId!;
        } else {
          targetUserId = (postData['userId'] ?? postData['authorId']) as String?;
        }
            
        if (targetUserId != null && targetUserId != comment.authorId) {
          final notifRef = _firestore.collection('users').doc(targetUserId).collection('notifications').doc();
          await notifRef.set({
            'id': notifRef.id,
            'userId': targetUserId,
            'title': comment.parentId != null ? "New Reply" : "New Comment",
            'body': "${comment.authorName} commented: ${comment.text}",
            'type': 'new_comment',
            'createdAt': FieldValue.serverTimestamp(),
            'isRead': false,
            'metadata': {
              'postId': threadGroupStr,
              'collectionName': collectionName,
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Error sending comment notification: \$e");
    }
  }

  Future<void> updateComment(
    String collectionName,
    String docId,
    String commentId,
    String text,
  ) async {
    await _firestore
        .collection(collectionName)
        .doc(docId)
        .collection('comments')
        .doc(commentId)
        .update({'text': text});
  }

  Future<void> deleteComment(
    String collectionName,
    String docId,
    String commentId,
  ) async {
    await _firestore
        .collection(collectionName)
        .doc(docId)
        .collection('comments')
        .doc(commentId)
        .delete();
    await _firestore.collection(collectionName).doc(docId).update({
      'commentCount': FieldValue.increment(-1),
    });
  }

  Future<void> reactToComment(
    String collectionName,
    String targetId,
    String commentId,
    String userId,
    String emoji,
  ) async {
    final commentRef = _firestore
        .collection(collectionName)
        .doc(targetId)
        .collection('comments')
        .doc(commentId);

    final doc = await commentRef.get();
    if (!doc.exists) return;
    final data = doc.data() as Map<String, dynamic>;
    final currentReactions = (data['reactions'] as Map<String, dynamic>?) ?? {};

    if (currentReactions[userId] == emoji) {
      await commentRef.set({
        'reactions': {userId: FieldValue.delete()}
      }, SetOptions(merge: true));
    } else {
      await commentRef.set({
        'reactions': {userId: emoji}
      }, SetOptions(merge: true));

      // Quietly notify the target comment author
      try {
        final targetUserId = data['authorId'] as String?;
        if (targetUserId != null && targetUserId != userId) {
          final userDoc = await _firestore.collection('users').doc(userId).get();
          final userData = userDoc.data() ?? {};
          final reactorsName = userData['username'] ?? userData['firstName'] ?? 'Someone';
          
          final notifRef = _firestore.collection('users').doc(targetUserId).collection('notifications').doc();
          await notifRef.set({
            'id': notifRef.id,
            'userId': targetUserId,
            'title': "New Reaction",
            'body': "$reactorsName reacted $emoji to your comment.",
            'type': 'new_reaction',
            'createdAt': FieldValue.serverTimestamp(),
            'isRead': false,
            'metadata': {
              'commentId': targetId, // Groups elegantly natively with main Post id or standard thread
            }
          });
        }
      } catch (e) {
        debugPrint("Error sending reaction notification: \$e");
      }
    }
  }

  Future<Map<String, dynamic>?> getWorkerFromQr(String qrToken) async {
    try {
      debugPrint('Scanning for Token: \$qrToken');
      // Query the SAFE collection
      final querySnapshot = await _firestore
          .collection('public_workers')
          .where('qrToken', isEqualTo: qrToken)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      final data = querySnapshot.docs.first.data();

      return data;
    } catch (e) {
      debugPrint("Error finding worker: \$e");
      return null;
    }
  }

  Future<void> toggleFollow(
    String userId,
    String venueId,
    bool isFollowing,
    String venueName,
  ) async {
    final userRef = _firestore.collection('users').doc(userId);
    if (isFollowing) {
      // Unfollow
      await userRef.update({
        'following': FieldValue.arrayRemove([venueId]),
      });
    } else {
      // Follow
      // 1. Update List
      await userRef.update({
        'following': FieldValue.arrayUnion([venueId]),
      });

      // 2. Ensure Membership Card Exists & Check for Bonus
      final membershipRef = userRef.collection('memberships').doc(venueId);
      final doc = await membershipRef.get();

      if (!doc.exists) {
        // Fetch Venue Details to check for Bonus
        double initialBalance = 0.0;
        final hallDoc = await _firestore
            .collection('venues')
            .doc(venueId)
            .get();
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
              'venueId': venueId,
              'amount': bonus
                  .toInt(), // Stored as int usually, or double? keeping consistency
              'timestamp': FieldValue.serverTimestamp(),
              'type': 'bonus',
              'description': 'New Follow Bonus',
            });
          }
        }

        // Create default membership
        await membershipRef.set({
          'venueId': venueId,
          'venueName': venueName,
          'balance': initialBalance,
          'currencyName': 'Points',
          'tier': 'Member',
          'joinedAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  Future<void> toggleHomeBase(
    String userId,
    String venueId,
    String? currentHomeBaseId,
  ) async {
    // If already set to this venue, unset it. Otherwise, set it.
    final newHomeBaseId = (currentHomeBaseId == venueId) ? null : venueId;

    await _firestore.collection('users').doc(userId).update({
      'homeBaseId': newHomeBaseId,
    });
  }

  // --- Raffles Management (CMS) ---
  Stream<List<RaffleModel>> getRaffles(String venueId) {
    return _firestore
        .collection('raffles')
        .where('venueId', isEqualTo: venueId)
        .orderBy('endsAt', descending: false)
        .snapshots()
        .map(
          (snapshot) {
            final allRaffles = snapshot.docs
                .map((doc) => RaffleModel.fromJson(doc.data()))
                .toList();

            final uniqueRaffles = <String, RaffleModel>{};
            
            for (var raffle in allRaffles) {
              final tId = raffle.templateId;
              if (tId == null) {
                uniqueRaffles[raffle.id] = raffle;
              } else {
                final existing = uniqueRaffles[tId];
                if (existing == null) {
                  uniqueRaffles[tId] = raffle;
                } else if (raffle.endsAt.isBefore(existing.endsAt)) {
                  uniqueRaffles[tId] = raffle;
                }
              }
            }
            
            return uniqueRaffles.values.toList()
               ..sort((a, b) => a.endsAt.compareTo(b.endsAt));
          }
        );
  }

  Future<void> addRaffle(RaffleModel raffle) async {
    final docRef = _firestore.collection('raffles').doc();
    final newRaffle = raffle.copyWith(id: docRef.id);
    
    final batch = _firestore.batch();
    batch.set(docRef, newRaffle.toJson());

    // Process Recurrence Windows
    if (newRaffle.isTemplate && newRaffle.recurrenceRule != null) {
      // For Raffles, we only have endsAt. Assuming a 7 day rolling period natively
      final dates = RecurrenceUtils.generateOccurrenceDates(
        originalStart: newRaffle.endsAt.subtract(const Duration(days: 7)), // Pseudo-start
        originalEnd: newRaffle.endsAt,
        rule: newRaffle.recurrenceRule!,
        maxDaysLimit: 14,
      );

      final duration = const Duration(days: 7);

      for (var date in dates) {
        final compositeId = '${docRef.id}_${date.toUtc().toIso8601String().split('T')[0]}';
        final cloneRef = _firestore.collection('raffles').doc(compositeId);
        
        final clone = newRaffle.copyWith(
          id: compositeId,
          isTemplate: false,
          templateId: docRef.id,
          endsAt: date.add(duration),
          reactionUserIds: [],
          interestedUserIds: [],
          commentCount: 0,
          latestComment: null,
          isStarred: false,
        );
        batch.set(cloneRef, clone.toJson());
      }
    }

    await batch.commit();
  }

  Future<void> updateRaffle(RaffleModel raffle) async {
    final batch = _firestore.batch();
    final docRef = _firestore.collection('raffles').doc(raffle.id);
    batch.update(docRef, raffle.toJson());

    if (raffle.isTemplate && raffle.recurrenceRule != null) {
      final orphans = await _firestore.collection('raffles')
          .where('templateId', isEqualTo: raffle.id)
          .where('endsAt', isGreaterThan: DateTime.now())
          .get();
          
      for (var doc in orphans.docs) {
        batch.delete(doc.reference);
      }

      final dates = RecurrenceUtils.generateOccurrenceDates(
        originalStart: raffle.endsAt.subtract(const Duration(days: 7)),
        originalEnd: raffle.endsAt,
        rule: raffle.recurrenceRule!,
        maxDaysLimit: 14,
      );
      
      final duration = const Duration(days: 7);
      final now = DateTime.now();

      for (var date in dates) {
        if (date.add(duration).isBefore(now)) continue; 
        
        final compositeId = '${raffle.id}_${date.toUtc().toIso8601String().split('T')[0]}';
        final cloneRef = _firestore.collection('raffles').doc(compositeId);
        
        final clone = raffle.copyWith(
          id: compositeId,
          isTemplate: false,
          templateId: raffle.id,
          endsAt: date.add(duration),
          reactionUserIds: [],
          interestedUserIds: [],
          commentCount: 0,
          latestComment: null,
          isStarred: false, 
        );
        batch.set(cloneRef, clone.toJson());
      }
    }

    await batch.commit();
  }

  Future<void> deleteRaffle(String raffleId) async {
    final batch = _firestore.batch();
    batch.delete(_firestore.collection('raffles').doc(raffleId));
    
    final orphans = await _firestore.collection('raffles')
        .where('templateId', isEqualTo: raffleId)
        .get();
        
    final now = DateTime.now();
    for (var doc in orphans.docs) {
       final data = doc.data();
       final isStarred = data['isStarred'] ?? false;
       final endTimeTimestamp = data['endsAt'];
       final endTime = endTimeTimestamp is Timestamp ? endTimeTimestamp.toDate() : null;
       
       if (endTime != null && endTime.isAfter(now)) {
           batch.delete(doc.reference);
       } else if (!isStarred) {
           batch.delete(doc.reference);
       }
    }
    
    await batch.commit();
  }

  Future<void> seedRaffles(String venueId) async {
    final collection = _firestore.collection('raffles');
    final now = DateTime.now();

    final raffles = [
      RaffleModel(
        id: 'raffle-$venueId-1',
        venueId: venueId,
        name: 'Weekly Cash Pot',
        description: 'Win \$500 Cash! Winner drawn Friday night.',
        imageUrl:
            'https://images.unsplash.com/photo-1518133910546-b6c2fb7d79e3?auto=format&fit=crop&w=800&q=80', // Money/Cash
        maxTickets: 200,
        soldTickets: 45,
        endsAt: now.add(const Duration(days: 4)),
      ),
      RaffleModel(
        id: 'raffle-$venueId-2',
        venueId: venueId,
        name: 'Luxury Spa Day',
        description: 'Full day package at Serenity Spa.',
        imageUrl:
            'https://images.unsplash.com/photo-1540555700478-4be289fbecef?auto=format&fit=crop&w=800&q=80', // Spa
        maxTickets: 100,
        soldTickets: 12,
        endsAt: now.add(const Duration(days: 10)),
      ),
      RaffleModel(
        id: 'raffle-$venueId-3',
        venueId: venueId,
        name: '65" 4K TV',
        description: 'Upgrade your living room!',
        imageUrl:
            'https://images.unsplash.com/photo-1593784991095-a205069470b6?auto=format&fit=crop&w=800&q=80', // TV
        maxTickets: 50,
        soldTickets: 2,
        endsAt: now.add(const Duration(days: 30)),
      ),
    ];

    for (var r in raffles) {
      await collection.doc(r.id).set(r.toJson());
    }
  }

  Future<void> seedCarouselEvents() async {
    final now = DateTime.now();

    // 1. Seed Raffles at non-Mary Esther venues
    final rafflesCollection = _firestore.collection('raffles');
    final raffles = [
      RaffleModel(
        id: 'seed-raffle-grand-1',
        venueId: 'grand-bingo-1',
        name: 'Grand Cash Bonanza',
        description: 'Win \$2,500 cash! Drawing at the end of the month.',
        imageUrl:
            'https://images.unsplash.com/photo-1559825481-12a05cc00344?auto=format&fit=crop&w=800&q=80', // Cash/Casino vibe
        maxTickets: 1000,
        soldTickets: 250,
        endsAt: now.add(const Duration(days: 20)),
      ),
      RaffleModel(
        id: 'seed-raffle-beach-1',
        venueId: 'beach-bingo',
        name: 'Beach Getaway Package',
        description: 'A weekend stay at the resort + \$500 spending money.',
        imageUrl:
            'https://images.unsplash.com/photo-1499793983690-e29da59ef1c2?auto=format&fit=crop&w=800&q=80', // Beach house
        maxTickets: 500,
        soldTickets: 490,
        endsAt: now.add(const Duration(days: 2)),
      ),
    ];

    for (var r in raffles) {
      await rafflesCollection.doc(r.id).set(r.toJson());
    }

    // 2. Seed Tournaments at non-Mary Esther venues
    final tournamentsCollection = _firestore.collection('tournaments');
    final tournaments = [
      TournamentModel(
        id: 'seed-tourney-grand-1',
        venueId: 'grand-bingo-1',
        title: 'Spring Fling Slots Tournament',
        description:
            'Compete across all slot machines. Top 10 players win a share of \$5,000!',
        startTime: now.add(const Duration(days: 5)),
        endTime: now.add(const Duration(days: 12)),
        games: [
          const TournamentGame(id: 'g1', title: 'Lucky 7s', value: 100),
          const TournamentGame(id: 'g2', title: 'Mega Wheel', value: 250),
        ],
      ),
      TournamentModel(
        id: 'seed-tourney-downtown-1',
        venueId: 'downtown-venue',
        title: 'Downtown Master Series',
        description: 'A month-long bingo elimination tournament.',
        startTime: now.add(const Duration(days: 1)),
        endTime: now.add(const Duration(days: 28)),
        games: [const TournamentGame(id: 'g1', title: 'Coverall', value: 500)],
      ),
    ];

    for (var t in tournaments) {
      await tournamentsCollection.doc(t.id).set(t.toJson());
    }
  }

  // --- Asset Library ---
  Future<void> addToAssetLibrary(String venueId, String url, String type) async {
    await _firestore
        .collection('venues')
        .doc(venueId)
        .collection('assets')
        .add({
          'url': url,
          'type': type,
          'uploadedAt': FieldValue.serverTimestamp(),
        });
  }

  Stream<List<String>> getAssetLibrary(String venueId, String type) {
    return _firestore
        .collection('venues')
        .doc(venueId)
        .collection('assets')
        .where('type', isEqualTo: type)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((d) => d.data()['url'] as String).toList(),
        );
  }

  // --- Historic Image Usage (Quick Select) ---
  Stream<List<String>> getRecentSpecialImages(String venueId) {
    return _firestore
        .collection('specials')
        .where('venueId', isEqualTo: venueId)
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

  // --- PAGINATION FUTURES ---
  Future<List<SpecialModel>> fetchSpecialsPage({
    DateTime? startAfterTimestamp,
    int limit = 20,
    Position? userLoc,
  }) async {
    Query query = _firestore
        .collection('specials')
        .where('isTemplate', isEqualTo: false)
        .orderBy('postedAt', descending: true)
        .limit(limit);

    if (startAfterTimestamp != null) {
      query = query.startAfter([Timestamp.fromDate(startAfterTimestamp)]);
    }

    final snap = await query.get();
    var specials = snap.docs
        .map((d) => SpecialModel.fromJson(d.data() as Map<String, dynamic>))
        .toList();

    // physical events arrive fully synthesized

    if (userLoc != null) {
      specials = specials.where((s) {
        if (s.latitude == null || s.longitude == null) return true;
        return Geolocator.distanceBetween(
              userLoc.latitude,
              userLoc.longitude,
              s.latitude!,
              s.longitude!,
            ) <=
            120700;
      }).toList();
    }
    return specials;
  }

  Future<List<TriviaModel>> fetchTriviaPage({
    DateTime? startAfterTimestamp,
    int limit = 20,
    Position? userLoc,
  }) async {
    Query query = _firestore
        .collectionGroup('trivia')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (startAfterTimestamp != null) {
      query = query.startAfter([Timestamp.fromDate(startAfterTimestamp)]);
    }

    final snap = await query.get();
    var triviaList = snap.docs
        .map((d) => TriviaModel.fromJson(d.data() as Map<String, dynamic>))
        .toList();

    return triviaList;
  }

  Future<List<RaffleModel>> fetchRafflesPage({
    DateTime? startAfterTimestamp,
    int limit = 20,
    Position? userLoc,
  }) async {
    Query query = _firestore
        .collection('raffles')
        .where('isTemplate', isEqualTo: false)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (startAfterTimestamp != null) {
      query = query.startAfter([Timestamp.fromDate(startAfterTimestamp)]);
    }

    final snap = await query.get();
    var raffles = snap.docs
        .map((d) => RaffleModel.fromJson(d.data() as Map<String, dynamic>))
        .toList();

    return raffles;
  }

  Future<List<TournamentModel>> fetchTournamentsPage({
    DateTime? startAfterTimestamp,
    int limit = 20,
    Position? userLoc,
  }) async {
    Query query = _firestore
        .collection('tournaments')
        .where('isTemplate', isEqualTo: false)
        .where('status', isEqualTo: 'published')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (startAfterTimestamp != null) {
      query = query.startAfter([Timestamp.fromDate(startAfterTimestamp)]);
    }

    final snap = await query.get();
    var tourneys = snap.docs
        .map((d) => TournamentModel.fromJson(d.data() as Map<String, dynamic>))
        .toList();

    return tourneys;
  }
}
