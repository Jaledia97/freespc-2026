import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Added
import 'package:cloud_firestore/cloud_firestore.dart'; // Added
import 'package:cloud_firestore/cloud_firestore.dart'; // Added
import '../../../services/auth_service.dart';
import '../../main_layout.dart';
import '../../onboarding/presentation/onboarding_screen.dart';
import 'login_screen.dart';
import '../../settings/data/display_settings_repository.dart'; // Added for sharedPreferencesProvider
import '../../friends/repositories/friends_repository.dart'; // Added
import '../../../models/public_profile.dart'; // Added

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);
    
    // PERFORMANCE OPTIMIZATION: 
    // We only care if the profile *exists* to decide routing.
    // We do NOT want to rebuild the entire AuthWrapper (and thus the App)
    // every time the user gets 10 points. 
    // So we select only the 'hasValue' state essentially.
    final hasProfileAsync = ref.watch(userProfileProvider.select((value) => value.whenData((profile) => profile != null)));

    return authState.when(
      data: (user) {
        if (user == null) {
          return const LoginScreen();
        }

        // Authenticated, check profile existence
        return hasProfileAsync.when(
          data: (hasProfile) {
            if (!hasProfile) {
              return const OnboardingScreen();
            }
            // Once we have a profile, we mount the MainLayout.
            // MainLayout can then listen to the specific user streams it needs deeper down.
            
            // CHECK FOR PENDING INVITES
            // We use a FutureBuilder here or a side-effect, but since we are in build(),
            // it's safer to have a small wrapper widget that checks on mount.
            return _AuthHandler(child: const MainLayout());
          },
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (err, stack) => Scaffold(
            body: Center(child: Text('Error: $err')),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        body: Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _AuthHandler extends ConsumerStatefulWidget {
  final Widget child;
  const _AuthHandler({required this.child});

  @override
  ConsumerState<_AuthHandler> createState() => _AuthHandlerState();
}

class _AuthHandlerState extends ConsumerState<_AuthHandler> {
  @override
  void initState() {
    super.initState();
    // Check for pending invites after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPendingInvites();

      // Setup FCM Token
      final user = ref.read(authStateChangesProvider).value;
      if (user != null) {
        ref.read(authServiceProvider).updateFcmToken(user.uid);
      }
    });
  }

  // Also listen for deep link updates
  @override 
  void didUpdateWidget(covariant _AuthHandler oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If provider changed (signaled by main.dart)
    // Actually we need to watch it in build.
  }

  Future<void> _checkPendingInvites() async {
    final prefs = ref.read(sharedPreferencesProvider);
    
    // 1. Check Hall Join
    final hallId = prefs.getString('pending_join_hall');
    if (hallId != null && mounted) {
       showDialog(
         context: context,
         barrierDismissible: false,
         builder: (ctx) => _JoinHallDialog(hallId: hallId, prefs: prefs),
       );
    }

    // 2. Check Friend Request
    final friendUid = prefs.getString('pending_add_friend');
    if (friendUid != null && mounted) {
       showDialog(
         context: context,
         barrierDismissible: false,
         builder: (ctx) => _AddFriendDialog(friendUid: friendUid, prefs: prefs),
       );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch signal from main.dart
    // We import pendingInviteProvider from main.dart... or duplicated here?
    // Ideally it's in a shared file. For now let's assume we need to import it or 
    // simply rely on the fact that MainLayout rebuilds if we pass a key.
    
    // To properly react to the invalidation in main.dart:
    // ref.watch(pendingInviteProvider); // This requires importing main.dart which is circular or messy.
    // Better pattern: Move `pendingInviteProvider` to `auth_service.dart` or a new `deep_link_service.dart`.
    // But for this quick implementation, we can just rely on `initState` (App Launch)
    // AND we can add a listener to AppLifecycleState if needed.
    // OR: `main.dart` rebuilds the entire app? No, `runApp` is static.
    
    // Optimization: We will move `pendingInviteProvider` to `auth_service.dart` to avoid circular deps with main.dart.
    
    return widget.child;
  }
}

class _JoinHallDialog extends ConsumerWidget {
  final String hallId;
  final SharedPreferences prefs;

  const _JoinHallDialog({required this.hallId, required this.prefs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2C2C2C),
      title: const Text("Join Hall Team?", style: TextStyle(color: Colors.white)),
      content: const Text(
        "You have been invited to join a Bingo Hall staff team. Do you want to accept?",
        style: TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () {
            prefs.remove('pending_join_hall');
            Navigator.pop(context);
          },
          child: const Text("Decline", style: TextStyle(color: Colors.red)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
          onPressed: () async {
            // Logic to join
            final user = ref.read(userProfileProvider).value;
            if (user != null) {
               // Update Firestore
               // We need dependency on PersonnelRepository or direct Firestore
               // Importing PersonnelRepository here might be circular if not careful, but usually Repository depends on Model/Service, not vice versa.
               // Let's use direct firestore for simplicity or import the repo.
               // Actually we can't import `personnel_repository.dart` effectively if it's in features/manager.
               // Let's create a `JoinHallService` or just do it here.
               
               try {
                 await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                   'homeBaseId': hallId,
                   'role': 'player', // Reset role to player pending assignment
                 });
                 
                 // Refresh User
                 ref.invalidate(userProfileProvider);
                 
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Joined Hall! Ask a manager to assign your role.")));
               } catch (e) {
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
               }
            }
            
            prefs.remove('pending_join_hall');
            Navigator.pop(context);
          },
          child: const Text("Accept Invite"),
        ),
      ],
    );
  }
}

class _AddFriendDialog extends ConsumerStatefulWidget {
  final String friendUid;
  final SharedPreferences prefs;

  const _AddFriendDialog({required this.friendUid, required this.prefs});

  @override
  ConsumerState<_AddFriendDialog> createState() => _AddFriendDialogState();
}

class _AddFriendDialogState extends ConsumerState<_AddFriendDialog> {
  PublicProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('public_profiles').doc(widget.friendUid).get();
      if (doc.exists && doc.data() != null) {
        if (mounted) {
          setState(() {
            _profile = PublicProfile.fromJson(doc.data()!);
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch(e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AlertDialog(
        backgroundColor: Color(0xFF2C2C2C),
        content: SizedBox(height: 50, child: Center(child: CircularProgressIndicator())),
      );
    }

    if (_profile == null) {
      widget.prefs.remove('pending_add_friend');
      return AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: const Text("User Not Found", style: TextStyle(color: Colors.white)),
        content: const Text("This friend link is invalid or the user no longer exists.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK", style: TextStyle(color: Colors.blueAccent))),
        ]
      );
    }

    return AlertDialog(
      backgroundColor: const Color(0xFF2C2C2C),
      title: const Text("Add Friend?", style: TextStyle(color: Colors.white)),
      content: Text(
        "Send friend request to @${_profile!.username}?",
        style: const TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.prefs.remove('pending_add_friend');
            Navigator.pop(context);
          },
          child: const Text("Cancel", style: TextStyle(color: Colors.red)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
          onPressed: () async {
            final user = ref.read(userProfileProvider).value;
            if (user != null) {
               try {
                 await ref.read(friendsRepositoryProvider).sendFriendRequest(user.uid, widget.friendUid);
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Friend Request Sent!"), backgroundColor: Colors.green));
               } catch (e) {
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
               }
            }
            widget.prefs.remove('pending_add_friend');
            Navigator.pop(context);
          },
          child: const Text("Send Request", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

