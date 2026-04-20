import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/venue_model.dart';

import '../features/home/repositories/venue_repository.dart';
import '../services/location_service.dart';
import 'session_context_controller.dart';

final consumerBeaconServiceProvider =
    StateNotifierProvider<ConsumerBeaconService, BeaconScanState>((ref) {
  return ConsumerBeaconService(ref);
});

class BeaconScanState {
  final bool isScanning;
  final VenueModel? detectedHall;
  final bool hasTriggeredCheckIn;

  BeaconScanState({
    required this.isScanning,
    this.detectedHall,
    required this.hasTriggeredCheckIn,
  });

  BeaconScanState copyWith({
    bool? isScanning,
    VenueModel? detectedHall,
    bool? hasTriggeredCheckIn,
  }) {
    return BeaconScanState(
      isScanning: isScanning ?? this.isScanning,
      detectedHall: detectedHall ?? this.detectedHall,
      hasTriggeredCheckIn: hasTriggeredCheckIn ?? this.hasTriggeredCheckIn,
    );
  }
}

class ConsumerBeaconService extends StateNotifier<BeaconScanState> {
  final Ref ref;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  Map<String, int> _squelchCounters = {};
  static const int _requiredPings = 3; // Number of consecutive hits > threshold
  static const int _rssiThreshold = -85; // Strong enough to be inside

  ConsumerBeaconService(this.ref)
      : super(BeaconScanState(isScanning: false, hasTriggeredCheckIn: false));

  /// Starts an aggressive, continuous foreground BLE scan tailored for Bingo Venues.
  Future<void> startListeningForVenues() async {
    if (state.isScanning) return;

    // Fetch active venues from Firestore natively
    final userLoc = ref.read(userLocationStreamProvider).valueOrNull;
    final activeHalls = await ref.read(venueRepositoryProvider).getHallsInRadius(
      latitude: userLoc?.latitude ?? 39.8283,
      longitude: userLoc?.longitude ?? -98.5795,
      radiusInMiles: 50,
    ).first;

    // Filter down to only venues that actually have a registered beacon UUID.
    final hallUUIDs = activeHalls
        .where((h) => h.beaconUuid.isNotEmpty)
        .fold<Map<String, VenueModel>>({}, (map, venue) {
      // Normalize UUIDs (lowercase, no hyphens) for robust matching.
      final cleanUuid = venue.beaconUuid.replaceAll('-', '').toLowerCase();
      map[cleanUuid] = venue;
      return map;
    });

    if (hallUUIDs.isEmpty) return; // No beacons in radar

    // Ensure Bluetooth is on natively
    if (await FlutterBluePlus.adapterState.first == BluetoothAdapterState.off) {
      return; 
    }

    state = state.copyWith(isScanning: true, hasTriggeredCheckIn: false);
    _squelchCounters.clear();

    // Start aggressive background-capable native continuous scan
    await FlutterBluePlus.startScan(continuousUpdates: true);

    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      if (state.hasTriggeredCheckIn) return; // Already checked in
      
      final session = ref.read(sessionContextProvider);
      if (session.isBusiness) {
        // Stop scanning for consumer check-ins if strictly operating in a business context
        stopListening();
        return;
      }

      for (var result in results) {
        if (result.rssi < _rssiThreshold) continue;

        // Inspect Service Data and Manufacturer Data mapping known UUIDs
        // Usually, UUIDs are blasted in the advertisement data.
        final scannedData = _extractPossibleUuids(result.advertisementData);

        for (var scannedUuid in scannedData) {
          final cleanScanned = scannedUuid.replaceAll('-', '').toLowerCase();

          if (hallUUIDs.containsKey(cleanScanned)) {
            final targetHall = hallUUIDs[cleanScanned]!;
            
            _squelchCounters[cleanScanned] =
                (_squelchCounters[cleanScanned] ?? 0) + 1;

            if (_squelchCounters[cleanScanned]! >= _requiredPings) {
              // Squelch passed! We are firmly inside the Venue.
              _triggerCheckInModal(targetHall);
              return;
            }
          }
        }
      }
    });
  }

  void _triggerCheckInModal(VenueModel venue) {
    // Lock the state so we don't spam the UI
    state = state.copyWith(detectedHall: venue, hasTriggeredCheckIn: true);
    stopListening();
  }

  void resetCheckInState() {
    state = state.copyWith(detectedHall: null, hasTriggeredCheckIn: false);
  }

  Future<void> stopListening() async {
    await FlutterBluePlus.stopScan();
    await _scanSubscription?.cancel();
    state = state.copyWith(isScanning: false);
  }

  /// Extracts hexadecimal UUID chunks from BLE Advertisement Packets.
  List<String> _extractPossibleUuids(AdvertisementData data) {
    List<String> uuids = [];

    // Service UUIDs (Standard 128-bit)
    for (var uuid in data.serviceUuids) {
      uuids.add(uuid.toString());
    }

    // Manufacturer Data (often used by iBeacon / custom beacons)
    data.manufacturerData.forEach((key, value) {
      final hexString = value.map((b) => b.toRadixString(16).padLeft(2, '0')).join('');
      if (hexString.length >= 32) {
        // Naive extraction of a 32-char UUID sequence if present
        uuids.add(hexString);
      }
    });

    return uuids;
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
