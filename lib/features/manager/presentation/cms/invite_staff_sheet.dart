import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class InviteStaffSheet extends StatelessWidget {
  final String hallId;
  final String hallName;

  const InviteStaffSheet({super.key, required this.hallId, required this.hallName});

  @override
  Widget build(BuildContext context) {
    // Ensure we handle URL encoding for spaces in hall names, though standard URI builders handle it.
    // Deep Link Format: https://freespc.app/join?hallId=...
    // Note: In development/local, this might open the browser if not configured in AndroidManifest/Info.plist yet.
    // But 'app_links' will catch it if configured. For now, we simulate the link string.
    
    // We can use a custom scheme 'freespc://join?hallId=...' or http if verified.
    // Let's use a robust https link that *could* be a dynamic link.
    final String inviteLink = "https://freespc.app/join?hallId=$hallId";

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Invite Staff", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(
            "Send this link to your staff members. When they click it, they will join '$hallName' as a pending member.",
            style: TextStyle(color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          
          // Link Display
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                const Icon(Icons.link, color: Colors.cyan),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    inviteLink,
                    style: const TextStyle(color: Colors.cyan, fontFamily: 'Courier'),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Share Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.share),
              label: const Text("Share Invitation Link"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                Share.share("Join $hallName team on FreeSPC! Tap here: $inviteLink");
                Navigator.pop(context);
              },
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
