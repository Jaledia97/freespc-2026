import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'cms/manage_specials_screen.dart';
import 'cms/edit_hall_profile_screen.dart';
import 'cms/manage_raffles_screen.dart'; // New Import
import 'cms/photo_approval_screen.dart';
import 'cms/manage_tournaments_screen.dart'; // New Import
import 'cms/loyalty_settings_screen.dart'; // New Import
import 'cms/bluetooth_settings_screen.dart'; // New Import
import 'cms/manage_personnel_screen.dart'; // New Import
import 'cms/manage_store_screen.dart'; // New Import
import '../../profile/presentation/hall_selection_screen.dart';
import '../../../../core/widgets/notification_badge.dart'; // Import NotificationBadge
// import 'raffle_tool/raffle_tool_screen.dart'; // No longer direct link
import '../../../../services/auth_service.dart';
import '../../home/repositories/hall_repository.dart';
import '../../../../models/bingo_hall_model.dart';

import '../../../../core/utils/role_utils.dart';

class ManagerDashboardScreen extends ConsumerStatefulWidget {
  const ManagerDashboardScreen({super.key});

  @override
  ConsumerState<ManagerDashboardScreen> createState() => _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends ConsumerState<ManagerDashboardScreen> {
  Future<bool> _showExitConfirmation() async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF222222),
        title: const Text("Exit Manager Mode?", style: TextStyle(color: Colors.white)),
        content: const Text(
          "You will need to scan your ID or enter your PIN to access this dashboard again.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("EXIT", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ) ?? false;
  }

  void _handleBack() async {
    final shouldExit = await _showExitConfirmation();
    if (shouldExit && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProfileProvider);
    final user = userAsync.value;
    final homeHallId = user?.homeBaseId;

    // Fetch hall details to get Beacon Code & specific Name
    final hallAsync = homeHallId != null ? ref.watch(hallStreamProvider(homeHallId)) : const AsyncValue.data(null);
    final hall = hallAsync.value;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF141414), // Darker than standard
        appBar: AppBar(
          leading: BackButton(
            onPressed: _handleBack,
            color: Colors.white,
          ),
          title: const Text('Hall Manager'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(onPressed: (){}, icon: const Icon(Icons.notifications_none)),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome / Status
                _buildStatusHeader(hall, homeHallId),
                const SizedBox(height: 24),

                // Super Admin Section
                if (RoleUtils.isSuperAdmin(user!)) ...[
                   const Text("Super Admin Controls", style: TextStyle(color: Colors.amber, fontSize: 14, fontWeight: FontWeight.bold)),
                   const SizedBox(height: 12),
                   _buildModuleCard(
                      context, 
                      title: "Switch Managed Hall", 
                      icon: Icons.swap_horiz, 
                      color: Colors.amberAccent,
                      desc: "Select a different hall to manage",
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HallSelectionScreen()))
                   ),
                   const SizedBox(height: 24),
                ],

                const Text("Select a Module:", style: TextStyle(color: Colors.white54, fontSize: 14)),
                const SizedBox(height: 12),
                
                // Modules Grid
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.95,
                    children: [
                      // CMS PROFILE (Manager+)
                      if (homeHallId != null && RoleUtils.canManageGames(user, homeHallId))
                        _buildModuleCard(
                        context,
                        title: "Hall Profile",
                        icon: Icons.storefront, 
                        color: Colors.deepPurpleAccent,
                        desc: "Edit Logo, Banner, Name",
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditHallProfileScreen(hallId: homeHallId))),
                      ),

                      // SPECIALS (Manager+)
                      if (homeHallId != null && RoleUtils.canManageGames(user, homeHallId))
                      _buildModuleCard(
                        context,
                        title: "Manage Events",
                        icon: Icons.calendar_today,
                        color: Colors.blueAccent, 
                        desc: "Add Daily Specials",
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageSpecialsScreen())),
                      ),

                      // FINANCIALS (Owner Only - Placeholder)
                      if (RoleUtils.isOwner(user))
                      _buildModuleCard(
                        context,
                        title: "Financials",
                        icon: Icons.attach_money,
                        color: Colors.teal,
                        desc: "Revenue, Payouts, Taxes",
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Financials Dashboard coming soon"))),
                      ),
                      // REMOVED DUPLICATE PERSONNEL TILE
                      
                      // RAFFLES (Manager+)
                      if (homeHallId != null && RoleUtils.canManageGames(user, homeHallId))
                       _buildModuleCard(
                        context,
                        title: "Manage Raffles", 
                        icon: Icons.confirmation_number,
                        color: Colors.amber,
                        desc: "Create & Run Drawings", 
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ManageRafflesScreen(hallId: homeHallId))),
                      ),

                      // TOURNAMENTS (Manager+)
                      if (homeHallId != null && RoleUtils.canManageGames(user, homeHallId))
                       _buildModuleCard(
                        context,
                        title: "Tournaments", 
                        icon: Icons.emoji_events,
                        color: Colors.purple,
                        desc: "Create & Run Events", 
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageTournamentsScreen())),
                      ),

                      // PHOTOS (Worker+)
                       if (homeHallId != null && RoleUtils.canScanAndVerify(user, homeHallId))
                       _buildModuleCard(
                        context,
                        title: "Photo Approvals",
                        icon: Icons.photo_library,
                        color: Colors.teal,
                        desc: "Review tagged photos",
                        useManagerBadge: true,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PhotoApprovalScreen(hallId: homeHallId, hallName: hall?.name ?? ''))),
                      ),

                      // STORE (Manager+)
                       if (homeHallId != null && RoleUtils.canManageGames(user, homeHallId))
                       _buildModuleCard(
                        context,
                        title: "Manage Store",
                        icon: Icons.store_mall_directory,
                        color: Colors.orangeAccent,
                        desc: "Redemption Items",
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ManageStoreScreen(hallId: homeHallId))),
                      ),

                      // LOYALTY SETTINGS (Owner Only)
                      if (homeHallId != null && (RoleUtils.isOwner(user) || RoleUtils.isSuperAdmin(user)) && hall != null)
                        _buildModuleCard(
                          context,
                          title: "Loyalty Settings",
                          icon: Icons.settings_suggest,
                          color: Colors.cyan,
                          desc: "Configure points & bonuses",
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LoyaltySettingsScreen(hallId: homeHallId, hall: hall))),
                        ),

                      // BLUETOOTH SETTINGS (Owner/SuperAdmin)
                       if (homeHallId != null && (RoleUtils.isOwner(user) || RoleUtils.isSuperAdmin(user)) && hall != null)
                        _buildModuleCard(
                          context,
                          title: "Bluetooth Settings",
                          icon: Icons.bluetooth_audio,
                          color: Colors.blueAccent,
                          desc: "Manage Beacons (BP101E)",
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BluetoothSettingsScreen(hallId: homeHallId, hall: hall))),
                        ),

                      // PERSONNEL (Owner/SuperAdmin/Manager - only limited access for manager?)
                      // Logic: Owners can manage managers/workers. Managers can manage workers.
                      // RoleUtils.canManagePersonnel handles this check.
                      if (homeHallId != null && RoleUtils.canManagePersonnel(user, homeHallId) && hall != null)
                        _buildModuleCard(
                          context,
                          title: "Personnel",
                          icon: Icons.people_alt,
                          color: Colors.pink,
                          desc: "Manage Staff & Roles",
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ManagePersonnelScreen(hallId: homeHallId, hall: hall, currentUser: user))),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusHeader(BingoHallModel? hall, String? hallId) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2C3E50), Color(0xFF000000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white10,
            child: const Icon(Icons.admin_panel_settings, color: Colors.white),
          ),
          const SizedBox(width: 16),
           Expanded(
             child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Admin Mode Active", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                if (hall != null) ...[
                   Text(hall.name, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)), 
                   Text("Beacon: ${hall.beaconUuid}", style: const TextStyle(color: Colors.orangeAccent, fontSize: 12, fontFamily: 'Courier')), 
                ] else 
                   Text(hallId != null ? "Managing: $hallId" : "No Hall Assigned", style: const TextStyle(color: Colors.white70, fontSize: 14)), 
              ],
                       ),
           ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(BuildContext context, {
    required String title, required IconData icon, required Color color, required String desc, required VoidCallback onTap, bool useManagerBadge = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
             BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0,4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: useManagerBadge 
                ? NotificationBadge(showForGeneral: false, showForManager: true, child: Icon(icon, color: color, size: 28))
                : Icon(icon, color: color, size: 28),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(color: Colors.white38, fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
