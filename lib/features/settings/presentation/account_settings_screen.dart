import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/auth_service.dart';
import '../../manager/presentation/claim_venue_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/venue_team_member_model.dart';
import '../../../services/session_context_controller.dart';
import '../../admin/presentation/superadmin_dashboard_screen.dart';
import '../../admin/presentation/spoof_workspace_screen.dart';
import '../../../services/session_context_controller.dart';
import '../../admin/repositories/admin_repository.dart';
import '../../../core/widgets/notification_badge.dart';

class AccountSettingsScreen extends ConsumerWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text('Account Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null)
            return const Center(
              child: Text(
                "User not found",
                style: TextStyle(color: Colors.white),
              ),
            );
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (user.systemRole == 'admin' || user.systemRole == 'superadmin') ...[
                  const Text(
                    "Platform Administration",
                    style: TextStyle(
                      color: Colors.purpleAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(color: Colors.purpleAccent),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Superadmin CMS Hub',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: const Text(
                      'Manage platform-wide venues, claims, and users.',
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                    leading: const Icon(Icons.admin_panel_settings, color: Colors.purpleAccent),
                    trailing: Consumer(
                      builder: (context, ref, child) {
                        final pendingAsync = ref.watch(pendingClaimsProvider);
                        final count = pendingAsync.value?.length ?? 0;
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (count > 0)
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white54,
                              size: 16,
                            ),
                          ],
                        );
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SuperadminDashboardScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],



                const Text(
                  "Your Workspaces",
                  style: TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(color: Colors.amber),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collectionGroup('team').where('uid', isEqualTo: user.uid).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text("No active workspaces.", style: TextStyle(color: Colors.white54)),
                      );
                    }
                    return Column(
                      children: snapshot.data!.docs.map((doc) {
                        try {
                          final teamData = VenueTeamMemberModel.fromJson(doc.data() as Map<String, dynamic>);
                          
                          Widget title = Text(teamData.venueName, style: const TextStyle(color: Colors.white));
                          Widget subtitle = Text(teamData.assignedRole.toUpperCase(), style: const TextStyle(color: Colors.white54, fontSize: 12));
                          
                          if (teamData.claimStatus == 'pending') {
                             title = Row(children: [Text(teamData.venueName, style: const TextStyle(color: Colors.white)), const SizedBox(width:8), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), borderRadius: BorderRadius.circular(4)), child: const Text('PENDING', style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)))]);
                             subtitle = const Text("Sandbox provisioning active. Awaiting review.", style: TextStyle(color: Colors.amber, fontSize: 12));
                          } else if (teamData.claimStatus == 'rejected') {
                             title = Row(children: [Text(teamData.venueName, style: const TextStyle(color: Colors.white)), const SizedBox(width:8), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.red.withOpacity(0.2), borderRadius: BorderRadius.circular(4)), child: const Text('DENIED', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)))]);
                             subtitle = const Text("Tap to view Superadmin feedback & Appeal", style: TextStyle(color: Colors.redAccent, fontSize: 12));
                          }

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.work, color: teamData.claimStatus == 'rejected' ? Colors.red : (teamData.claimStatus == 'pending' ? Colors.amber : Colors.blueAccent)),
                            title: title,
                            subtitle: subtitle,
                            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
                            onLongPress: () async {
                              final res = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: const Color(0xFF2C2C2C),
                                  title: const Text("Remove Workspace", style: TextStyle(color: Colors.redAccent)),
                                  content: const Text("Remove this orphaned workspace completely off your profile?", style: TextStyle(color: Colors.white70)),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text("Remove"),
                                    ),
                                  ],
                                ),
                              );
                              if (res == true) {
                                 await FirebaseFirestore.instance.doc(doc.reference.path).delete();
                              }
                            },
                            onTap: () {
                               if (teamData.claimStatus == 'rejected') {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      backgroundColor: const Color(0xFF1E1E1E),
                                      title: const Text("Verification Denied", style: TextStyle(color: Colors.redAccent)),
                                      content: Text("Superadmin Feedback:\n${teamData.rejectReason ?? 'No reason provided'}\n\nPlease adjust your configuration inside the Sandbox and confirm here to resubmit your limits automatically.", style: const TextStyle(color: Colors.white70)),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Dismiss", style: TextStyle(color: Colors.white54))),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
                                          onPressed: () async {
                                             Navigator.pop(context); // Close Alert
                                             final claimsQuery = await FirebaseFirestore.instance.collection('venue_claims').where('requestedVenueId', isEqualTo: teamData.venueId).limit(1).get();
                                             if (claimsQuery.docs.isNotEmpty) {
                                                 final claimId = claimsQuery.docs.first.id;
                                                 await FirebaseFirestore.instance.collection('venue_claims').doc(claimId).update({'status': 'pending'});
                                                 await FirebaseFirestore.instance.collection('venues').doc(teamData.venueId).collection('team').doc(user.uid).update({'claimStatus': 'pending'});
                                                 if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Appeal Submitted!")));
                                             }
                                          },
                                          child: const Text("SUBMIT APPEAL")
                                        )
                                      ]
                                    )
                                  );
                               } else {
                                 ref.read(sessionContextProvider.notifier).switchToBusiness(
                                   teamData.venueId,
                                   teamData.venueName,
                                   teamData.assignedRole,
                                 );
                                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Switched context to ${teamData.venueName}")));
                                 Navigator.of(context).popUntil((route) => route.isFirst);
                               }
                            },
                          );
                        } catch (e) {
                          print("Account Settings Team Model Crash: $e");
                          return const SizedBox.shrink();
                        }
                      }).toList(),
                    );
                  },
                ),

                
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Register Business / Hall Portal',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'Claim and verify your venue to unlock the management CMS.',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                  leading: const Icon(Icons.storefront, color: Colors.amber),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white54,
                    size: 16,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ClaimVenueScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                if (user.systemRole == 'superadmin') ...[
                  const Text(
                    "God Mode (Superadmin)",
                    style: TextStyle(
                      color: Colors.purpleAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(color: Colors.purpleAccent),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Spoof Workspace Context',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: const Text(
                      'Force inject active B2B session routing.',
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                    leading: const Icon(Icons.security, color: Colors.purpleAccent),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SpoofWorkspaceScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],

                const SizedBox(height: 24),

                const Text(
                  "Danger Zone",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(color: Colors.redAccent),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Delete Account',
                    style: TextStyle(color: Colors.red),
                  ),
                  subtitle: const Text(
                    'Permanently remove your data. This cannot be undone.',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: const Color(0xFF2C2C2C),
                        title: const Text(
                          "Delete Account?",
                          style: TextStyle(color: Colors.white),
                        ),
                        content: const Text(
                          "Are you sure? This will permanently delete your profile, wallet balance, and membership data. This action cannot be undone.",
                          style: TextStyle(color: Colors.white70),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text("DELETE PERMANENTLY"),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      try {
                        await ref.read(authServiceProvider).deleteAccount();
                        if (context.mounted) {
                          Navigator.pop(context); // Close Settings
                          // AuthWrapper will handle redirect to Login
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Account Deleted.")),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text("Error: $e")));
                        }
                      }
                    }
                  },
                ),
              ],
            ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Text("Error: $e", style: const TextStyle(color: Colors.red)),
        ),
      ),
    );
  }
}
