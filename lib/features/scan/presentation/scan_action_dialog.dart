import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../wallet/services/transaction_service.dart';
import '../../../services/auth_service.dart';
import '../../home/repositories/hall_repository.dart';
import '../../../models/user_model.dart';
import '../../../models/bingo_hall_model.dart'; // Just in case, though we used string ID

// Added notFound state
enum DialogState { checking, idle, loading, success, notFound }

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

  @override
  void initState() {
    super.initState();
    _verifyScanContent();
  }

  Future<void> _verifyScanContent() async {
    // Check if this is a worker
    final worker = await ref.read(hallRepositoryProvider).getWorkerFromQr(widget.content);
    
    if (worker != null && worker.homeBaseId != null) {
      _verifiedWorker = worker;
      _targetHallId = worker.homeBaseId;
      if (mounted) {
        setState(() {
           _state = DialogState.idle; // Idle here means "Found & Waiting for confirmation"
        });
      }
    } else {
      // STRICT: If not a worker, it is INVALID.
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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_state == DialogState.checking) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text("Verifying Code..."),
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
                 const Icon(Icons.verified_user, color: Colors.blue, size: 48),
                 const SizedBox(height: 8),
                 Text(
                  "Verified by ${_verifiedWorker!.firstName}", 
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                  textAlign: TextAlign.center,
                ),
                Text("Role: ${_verifiedWorker!.role}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 16),
                Text("Checking in at: $_targetHallId"),

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
                  onPressed: _logWin,
                  child: const Text("ACCEPT WIN (+10 pts)", style: TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red.shade100,
                    foregroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("CANCEL", style: TextStyle(fontSize: 18)),
                ),
              ),
            ] else if (_state == DialogState.loading) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text("Processing Transaction..."),
            ] else if (_state == DialogState.success) ...[
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 16),
              const Text("Points Added!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              if (_verifiedWorker != null) 
                const Text("Authorized Transaction", style: TextStyle(color: Colors.grey)),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _logWin() async {
    setState(() => _state = DialogState.loading);

    final user = ref.read(authStateChangesProvider).value;
    if (user != null && _targetHallId != null) {
      try {
        await ref.read(transactionServiceProvider).awardPoints(
          userId: user.uid,
          hallId: _targetHallId!, 
          points: 10,
          description: "Authorized Check-in by ${_verifiedWorker!.firstName} (${_verifiedWorker!.role})",
          authorizedByWorkerId: _verifiedWorker?.uid,
        );

        setState(() => _state = DialogState.success);
        
        await Future.delayed(const Duration(milliseconds: 1500));
        
        if (mounted) {
          Navigator.pop(context); 
          Navigator.of(context).popUntil((route) => route.isFirst); 
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Points Added!')),
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
}
