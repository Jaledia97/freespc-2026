import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/venue_team_member_model.dart';
import 'auth_service.dart';

class SessionState {
  final String activeContext; // 'personal' or 'business'
  final String? activeVenueId;
  final String? activeVenueName;
  final String? activeRole; // 'owner', 'manager', 'worker'
  final bool isEjected;

  const SessionState({
    this.activeContext = 'personal',
    this.activeVenueId,
    this.activeVenueName,
    this.activeRole,
    this.isEjected = false,
  });

  SessionState copyWith({
    String? activeContext,
    String? activeVenueId,
    String? activeVenueName,
    String? activeRole,
    bool? isEjected,
  }) {
    return SessionState(
      activeContext: activeContext ?? this.activeContext,
      activeVenueId: activeVenueId ?? this.activeVenueId,
      activeVenueName: activeVenueName ?? this.activeVenueName,
      activeRole: activeRole ?? this.activeRole,
      isEjected: isEjected ?? this.isEjected,
    );
  }

  bool get isBusiness => activeContext == 'business';
  bool get isOwner => activeRole == 'owner';
  bool get isManager => activeRole == 'manager' || activeRole == 'owner';
}

class SessionContextController extends StateNotifier<SessionState> {
  final Ref ref;
  StreamSubscription<DocumentSnapshot>? _roleSubscription;

  SessionContextController(this.ref) : super(const SessionState());

  @override
  void dispose() {
    _roleSubscription?.cancel();
    super.dispose();
  }

  void switchToPersonal() {
    _roleSubscription?.cancel();
    state = const SessionState(activeContext: 'personal');
  }

  void switchToBusiness(String venueId, String venueName, String role, {bool isSuperAdmin = false}) {
    _roleSubscription?.cancel();
    state = SessionState(
      activeContext: 'business',
      activeVenueId: venueId,
      activeVenueName: venueName,
      activeRole: role,
    );

    if (!isSuperAdmin) {
      _listenToLiveRole(venueId);
    }
  }

  void _listenToLiveRole(String venueId) {
    final user = ref.read(userProfileProvider).value;
    if (user == null) return;

    _roleSubscription = FirebaseFirestore.instance
        .collection('venues')
        .doc(venueId)
        .collection('team')
        .doc(user.uid)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists) {
        // Ejected! The team document was deleted.
        state = const SessionState(activeContext: 'personal', isEjected: true);
        _roleSubscription?.cancel();
        return;
      }

      final teamData = VenueTeamMemberModel.fromJson(snapshot.data() as Map<String, dynamic>);
      
      // If the role changed remotely (e.g. demotion), update it live.
      // Or if we need strict eviction, we can handle it here.
      if (teamData.assignedRole != state.activeRole) {
        state = state.copyWith(activeRole: teamData.assignedRole);
      }
    }, onError: (e) {
      // If we lose permission entirely (Firebase rules), also eject.
      state = const SessionState(activeContext: 'personal', isEjected: true);
      _roleSubscription?.cancel();
    });
  }
}

final sessionContextProvider = StateNotifierProvider<SessionContextController, SessionState>((ref) {
  return SessionContextController(ref);
});
