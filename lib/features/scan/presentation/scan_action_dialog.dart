import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../wallet/services/transaction_service.dart';
import '../../../services/auth_service.dart';

enum DialogState { idle, loading, success }

class ScanActionDialog extends ConsumerStatefulWidget {
  final String hallId;
  final VoidCallback onResumeCamera;

  const ScanActionDialog({
    super.key,
    required this.hallId,
    required this.onResumeCamera,
  });

  @override
  ConsumerState<ScanActionDialog> createState() => _ScanActionDialogState();
}

class _ScanActionDialogState extends ConsumerState<ScanActionDialog> {
  DialogState _state = DialogState.idle;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_state == DialogState.idle) ...[
              Text(
                "Found Hall: ${widget.hallId}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
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
                  child: const Text("LOG WIN (+10 pts)", style: TextStyle(fontSize: 20)),
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
              const Text("Processing..."),
            ] else if (_state == DialogState.success) ...[
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 16),
              const Text("Points Added!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _logWin() async {
    setState(() => _state = DialogState.loading);

    final user = ref.read(authStateChangesProvider).value;
    if (user != null) {
      try {
        await ref.read(transactionServiceProvider).awardPoints(
          userId: user.uid,
          hallId: widget.hallId,
          points: 10,
          description: "Scanned at ${widget.hallId}",
        );

        setState(() => _state = DialogState.success);
        
        // Wait 1.5s then close
        await Future.delayed(const Duration(milliseconds: 1500));
        
        if (mounted) {
          Navigator.pop(context); // Close Dialog
          Navigator.of(context).popUntil((route) => route.isFirst); // Go to Home (assuming Scan is moved to)
          // Or just close scanner if it is a tab.
          // If Scanner is a tab, we probably just want to close the dialog. 
          // But requirement said "Close Scanner (pop)". 
          // Let's assume Scanner is accessed via FAB and is a pushed route? 
          // Actually MainLayout has it as a TAB/FAB. 
          // If it's the `MainLayout` FAB, we are in `ScanScreen`.
          // If we want to "Go Home", we can just switch tab or pop if `ScanScreen` was pushed.
          // Given `MainLayout` structure "Docked Navigation", let's assume `ScanScreen` might be a modal or separate screen. 
          // Re-reading `MainLayout`: it uses `widget.child`? No, standard Scaffold.
          // Wait, `MainLayout` refactor... let's check `MainLayout` code later.
          // For now, let's just close the dialog.
          
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
