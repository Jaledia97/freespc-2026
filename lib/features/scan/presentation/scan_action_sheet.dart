import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../wallet/services/transaction_service.dart';
import '../../../services/auth_service.dart';

class ScanActionSheet extends ConsumerWidget {
  final String hallId;
  final VoidCallback onResumeCamera;

  const ScanActionSheet({
    super.key,
    required this.hallId,
    required this.onResumeCamera,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Found Hall: $hallId",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 80,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () async {
                final user = ref.read(authStateChangesProvider).value;
                if (user != null) {
                  try {
                    await ref.read(transactionServiceProvider).awardPoints(
                      userId: user.uid,
                      hallId: hallId,
                      points: 10,
                      description: "Scanned at $hallId",
                    );
                    if (context.mounted) {
                      Navigator.pop(context); // Close sheet
                      Navigator.pop(context); // Close ScanScreen (return to Home)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Succcess! +10 Points!')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                }
              },
              child: const Text(
                "LOG WIN! (+10 pts)",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 60,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                onResumeCamera();
              },
              child: const Text(
                "CANCEL",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
