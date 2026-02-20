import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../wallet/services/transaction_service.dart';
import '../../../services/auth_service.dart';
import '../../home/repositories/hall_repository.dart';
import '../../manager/repositories/tournament_repository.dart'; // Import
import '../../../models/user_model.dart';
import '../../../models/tournament_model.dart'; // Import
import '../../friends/repositories/friends_repository.dart'; // Import
import '../../../models/public_profile.dart'; // Import
import 'package:cloud_firestore/cloud_firestore.dart'; // Import

// Added notFound state
enum DialogState { checking, idle, loading, success, notFound, addFriend }

class ScanActionDialog extends ConsumerStatefulWidget {
  final String content; 
  final VoidCallback onResumeCamera;

  const ScanActionDialog({
    super.key,
    required this.content,
    required this.onResumeCamera,
  });

  @override
  ConsumerState<ScanActionDialog> createState() => _ScanActionDialogState();
}

class _ScanActionDialogState extends ConsumerState<ScanActionDialog> {
  DialogState _state = DialogState.checking;
  UserModel? _verifiedWorker;
  String? _targetHallId;
  TournamentModel? _activeTournament; // Track active tournament
  PublicProfile? _friendProfile;
  String? _friendUid;

  @override
  void initState() {
    super.initState();
    _verifyScanContent();
  }

  Future<void> _verifyScanContent() async {
    // 1. Check if this is a friend request deep link
    if (widget.content.startsWith('freespc://add_friend?uid=')) {
      try {
        final uri = Uri.parse(widget.content);
        final uid = uri.queryParameters['uid'];
        if (uid != null) {
          // Fetch public profile to confirm and show details
          final doc = await FirebaseFirestore.instance.collection('public_profiles').doc(uid).get();
          if (doc.exists && doc.data() != null) {
            if (mounted) {
              setState(() {
                _friendProfile = PublicProfile.fromJson(doc.data()!);
                _friendUid = uid;
                _state = DialogState.addFriend;
              });
            }
            return;
          }
        }
      } catch (e) {
        print("Error parsing deep link: $e");
      }
    }

    // 2. Check if this is a worker
    final worker = await ref.read(hallRepositoryProvider).getWorkerFromQr(widget.content);
    
    if (worker != null && worker.homeBaseId != null) {
      // Worker Found! Now check for active tournament
      final hallId = worker.homeBaseId!;
      final tournament = await ref.read(tournamentRepositoryProvider).getActiveTournament(hallId);

      if (mounted) {
        setState(() {
           _verifiedWorker = worker;
           _targetHallId = hallId;
           _activeTournament = tournament;
           _state = DialogState.idle; 
        });
      }
    } else {
      // STRICT: If not a worker or friend, it is INVALID.
      if (mounted) {
        setState(() {
           _state = DialogState.notFound;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: const Color(0xFF222222), // Dark theme background
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_state == DialogState.checking) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text("Verifying Code...", style: TextStyle(color: Colors.white)),
            ] else if (_state == DialogState.notFound) ...[
               const Icon(Icons.error_outline, color: Colors.grey, size: 60),
               const SizedBox(height: 16),
               const Text(
                 "Invalid or Revoked Code",
                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
               ),
               const SizedBox(height: 8),
               const Text(
                 "This QR code is not recognized as a valid Worker Token.",
                 textAlign: TextAlign.center,
                 style: TextStyle(color: Colors.grey),
               ),
               const SizedBox(height: 24),
               SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("EXIT", style: TextStyle(fontSize: 18)),
                ),
              ),
            ] else if (_state == DialogState.idle) ...[
                 // Worker Found State
                 Row(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     const Icon(Icons.verified_user, color: Colors.blue, size: 24),
                     const SizedBox(width: 8),
                     Text(
                      "Verified: ${_verifiedWorker!.firstName}", 
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                   ],
                 ),
                const SizedBox(height: 16),
                
                if (_activeTournament != null && _activeTournament!.games.isNotEmpty) ...[
                    // T O U R N A M E N T   M O D E
                    Text("Current Event: ${_activeTournament!.title}", 
                      style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text("Select Game to Award:", style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 12),
                    
                    // Grid of Games
                    Flexible(
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: _activeTournament!.games.map((game) {
                            return SizedBox(
                              width: 130, // Fixed width for consistent grid look
                              height: 100,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF333333),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: const BorderSide(color: Colors.blueAccent, width: 2),
                                  ),
                                  elevation: 4,
                                ),
                                onPressed: () => _logWin(points: game.value, description: "Won ${game.title}"),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(game.title, 
                                      textAlign: TextAlign.center, 
                                      maxLines: 2, 
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)
                                    ),
                                    const SizedBox(height: 4),
                                    Text("${game.value} pts", 
                                      style: const TextStyle(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold)
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                ] else ...[
                  // F A L L B A C K   M O D E
                  const Text("No active tournament found.", style: TextStyle(color: Colors.white54)),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _logWin(points: 10, description: "Authorized Check-in"),
                      child: const Text("STANDARD CHECK-IN (+10 pts)", style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("CANCEL", style: TextStyle(fontSize: 16)),
                ),
              ),
            ] else if (_state == DialogState.addFriend && _friendProfile != null) ...[
               const Icon(Icons.person_add, color: Colors.blueAccent, size: 60),
               const SizedBox(height: 16),
               const Text(
                 "Add Friend",
                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
               ),
               const SizedBox(height: 8),
               Text(
                 "Send friend request to @${_friendProfile!.username}?",
                 textAlign: TextAlign.center,
                 style: const TextStyle(color: Colors.white70),
               ),
               const SizedBox(height: 24),
               SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _sendFriendRequest(),
                  child: const Text("SEND REQUEST", style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("CANCEL", style: TextStyle(fontSize: 16)),
                ),
              ),
            ] else if (_state == DialogState.loading) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text("Processing Transaction...", style: TextStyle(color: Colors.white)),
            ] else if (_state == DialogState.success) ...[
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 16),
              const Text("Points Added!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              if (_verifiedWorker != null) 
                const Text("Authorized Transaction", style: TextStyle(color: Colors.grey)),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _logWin({required int points, required String description}) async {
    setState(() => _state = DialogState.loading);

    final user = ref.read(authStateChangesProvider).value;
    if (user != null && _targetHallId != null) {
      try {
        await ref.read(transactionServiceProvider).awardPoints(
          userId: user.uid,
          hallId: _targetHallId!, 
          points: points,
          description: "$description (${_verifiedWorker!.firstName})", // include worker name
          authorizedByWorkerId: _verifiedWorker?.uid,
        );

        setState(() => _state = DialogState.success);
        
        await Future.delayed(const Duration(milliseconds: 1000)); // Faster close
        
        if (mounted) {
          Navigator.pop(context); 
          // Navigator.of(context).popUntil((route) => route.isFirst); // Don't pop to root, just close dialog
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$description Recorded!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
           setState(() => _state = DialogState.idle);
         }
      }
    }
  }

  Future<void> _sendFriendRequest() async {
    setState(() => _state = DialogState.loading);
    final user = ref.read(authStateChangesProvider).value;
    if (user != null && _friendUid != null) {
      try {
        await ref.read(friendsRepositoryProvider).sendFriendRequest(user.uid, _friendUid!);
        setState(() => _state = DialogState.success);
        await Future.delayed(const Duration(milliseconds: 1000));
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Friend Request Sent!'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
          setState(() => _state = DialogState.addFriend);
        }
      }
    }
  }
}
