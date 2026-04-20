import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/squad_model.dart';
import '../../../models/venue_model.dart';

double calculateSquadBonus(
  SquadModel? userSquad,
  List<String> currentlyCheckedInUserIds,
  VenueModel venue,
) {
  if (userSquad == null) return 1.0;
  if (!userSquad.isValidSquad) return 1.0;
  if (!venue.squadBonusConfig.isSquadBonusActive) return 1.0;

  final config = venue.squadBonusConfig;
  final now = DateTime.now();
  if (config.startTime != null && now.isBefore(config.startTime!)) return 1.0;
  if (config.endTime != null && now.isAfter(config.endTime!)) return 1.0;

  int squadMembersCheckedIn = 0;
  for (String memberId in userSquad.memberIds) {
    if (currentlyCheckedInUserIds.contains(memberId)) {
      squadMembersCheckedIn++;
    }
  }

  // The 51% Rule: Greater than 50% of the squad must be checked in
  double percentage = squadMembersCheckedIn / userSquad.memberIds.length;
  if (percentage > 0.50) {
    return config.squadBonusMultiplier;
  }

  return 1.0;
}

/// The local caching state for a running Squad Assembly Drop
class SquadAssemblyState {
  final DateTime? initialAssemblyTime;
  final DateTime? gracePeriodStartTime;

  SquadAssemblyState({
    this.initialAssemblyTime,
    this.gracePeriodStartTime,
  });

  bool get isActive => initialAssemblyTime != null;
  bool get inGracePeriod => gracePeriodStartTime != null;
}

class SquadAssemblyDropResult {
  final SquadAssemblyState newState;
  final bool shouldPayout;
  final bool warningTriggered;
  final bool lineBroken;

  SquadAssemblyDropResult({
    required this.newState,
    this.shouldPayout = false,
    this.warningTriggered = false,
    this.lineBroken = false,
  });
}

/// Evaluates if a squad maintains the 51% threshold, granting payouts or tripping graceful buffers
SquadAssemblyDropResult evaluateAssemblyDrop({
  required SquadModel squad,
  required List<String> presentMemberIds,
  required VenueModel venue,
  required SquadAssemblyState currentState,
}) {
  final config = venue.squadBonusConfig;
  if (!config.isSquadBonusActive) {
    return SquadAssemblyDropResult(newState: SquadAssemblyState());
  }

  // 1. Calculate Threshold
  int squadMembersCheckedIn = 0;
  for (String memberId in squad.memberIds) {
    if (presentMemberIds.contains(memberId)) {
      squadMembersCheckedIn++;
    }
  }
  double percentage = squadMembersCheckedIn / squad.memberIds.length;
  bool thresholdMet = percentage > 0.50;

  final now = DateTime.now();
  DateTime? initTime = currentState.initialAssemblyTime;
  DateTime? graceTime = currentState.gracePeriodStartTime;

  bool shouldPayout = false;
  bool warningTriggered = false;
  bool lineBroken = false;

  if (thresholdMet) {
    // We are ABOVE 51%
    if (initTime == null) {
      initTime = now; // Just formed the line!
    } else {
      // Line remains held. Check if we hit duration
      if (now.difference(initTime).inMinutes >= config.assemblyDurationMinutes) {
        shouldPayout = true;
        initTime = now; // Reset timer for next drop
      }
    }
    // Instantly clear grace period if it was running
    graceTime = null;
    
  } else {
    // We are BELOW 51%
    if (initTime != null) {
      if (graceTime == null) {
        graceTime = now; // Just dropped below!
        warningTriggered = true; // Send the warning!
      } else {
        // Buffer is running. Did it expire?
        if (now.difference(graceTime).inMinutes >= config.gracePeriodMinutes) {
          initTime = null; // Line broken!
          graceTime = null;
          lineBroken = true;
        }
      }
    }
  }

  return SquadAssemblyDropResult(
    newState: SquadAssemblyState(
      initialAssemblyTime: initTime,
      gracePeriodStartTime: graceTime,
    ),
    shouldPayout: shouldPayout,
    warningTriggered: warningTriggered,
    lineBroken: lineBroken,
  );
}

/// Checks the ledger to prevent daily double-dipping for the Assembly Drop
Future<List<String>> getEligiblePayoutMembers(
  FirebaseFirestore firestore,
  List<String> presentMemberIds,
  String venueId,
) async {
  List<String> eligible = [];
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

  for (String memberId in presentMemberIds) {
    try {
      final qs = await firestore
          .collection('users')
          .doc(memberId)
          .collection('transactions')
          .where('venueId', isEqualTo: venueId)
          .where('description', isEqualTo: 'Squad Assembly Drop')
          .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
          .where('timestamp', isLessThanOrEqualTo: endOfDay)
          .limit(1)
          .get();

      if (qs.docs.isEmpty) {
        eligible.add(memberId);
      }
    } catch (e) {
      debugPrint("Error checking eligibility for \$memberId: \$e");
    }
  }

  return eligible;
}
