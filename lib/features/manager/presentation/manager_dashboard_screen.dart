import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'cms/manage_specials_screen.dart';
import 'cms/edit_hall_profile_screen.dart';
import 'cms/manage_raffles_screen.dart'; // New Import
// import 'raffle_tool/raffle_tool_screen.dart'; // No longer direct link
import '../../../../services/auth_service.dart';

class ManagerDashboardScreen extends ConsumerWidget {
  const ManagerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);
    final user = userAsync.value;
    final homeHallId = user?.homeBaseId;

    return Scaffold(
      backgroundColor: const Color(0xFF141414), // Darker than standard
      appBar: AppBar(
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
              _buildStatusHeader(user?.homeBaseId),
              const SizedBox(height: 32),
              
              const Text("Management Modules", style: TextStyle(color: Colors.white54, fontSize: 14)),
              const SizedBox(height: 16),

              // Module Grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2, // 2 columns
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildModuleCard(
                      context,
                      title: "Hall Profile",
                      icon: Icons.storefront,
                      color: Colors.blue,
                      desc: "Edit details, logo, hours",
                      onTap: () {
                         if (homeHallId != null) {
                           Navigator.push(context, MaterialPageRoute(builder: (_) => EditHallProfileScreen(hallId: homeHallId)));
                         } else {
                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error: No Home Hall Assigned")));
                         }
                      },
                    ),
                    _buildModuleCard(
                      context,
                      title: "Specials",
                      icon: Icons.local_offer,
                      color: Colors.green,
                      desc: "Promote food, drink, games",
                      onTap: () {
                         Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageSpecialsScreen()));
                      },
                    ),
                    _buildModuleCard(
                      context,
                      title: "Tournaments",
                      icon: Icons.emoji_events,
                      color: Colors.purple,
                      desc: "Manage event calendar",
                      onTap: () {
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tournament CMS coming in Phase 21")));
                      },
                    ),
                     _buildModuleCard(
                      context,
                      title: "Manage Raffles", // Renamed for clarity
                      icon: Icons.confirmation_number,
                      color: Colors.amber,
                      desc: "Create & Run Drawings", // Updated desc
                      onTap: () {
                        if (homeHallId != null) {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => ManageRafflesScreen(hallId: homeHallId)));
                         } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error: No Hall Assigned")));
                         }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusHeader(String? hallId) {
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
           Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Admin Mode Active", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              Text(hallId != null ? "Managing: $hallId" : "No Hall Assigned", style: const TextStyle(color: Colors.white70, fontSize: 14)), 
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(BuildContext context, {
    required String title, required IconData icon, required Color color, required String desc, required VoidCallback onTap
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
              child: Icon(icon, color: color, size: 28),
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
