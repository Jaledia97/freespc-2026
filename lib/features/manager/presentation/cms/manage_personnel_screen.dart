import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/user_model.dart';
import '../../../../models/bingo_hall_model.dart';
import '../../../../core/utils/role_utils.dart';
import '../../repositories/personnel_repository.dart';
import 'invite_staff_sheet.dart';
import 'package:share_plus/share_plus.dart';

class ManagePersonnelScreen extends ConsumerWidget {
  final String hallId;
  final BingoHallModel hall;
  final UserModel currentUser;

  const ManagePersonnelScreen({
    super.key,
    required this.hallId,
    required this.hall,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staffStream = ref.watch(staffStreamProvider(hallId));

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Personnel Management"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => InviteStaffSheet(hallId: hallId, hallName: hall.name),
          );
        },
        label: const Text("Invite Staff"),
        icon: const Icon(Icons.person_add),
        backgroundColor: Colors.cyan,
      ),
      body: staffStream.when(
        data: (staff) {
          if (staff.isEmpty) {
            return const Center(child: Text("No staff found.", style: TextStyle(color: Colors.white54)));
          }

          // Group by Role priority
          final owners = staff.where((u) => u.role == RoleUtils.owner).toList();
          final managers = staff.where((u) => u.role == RoleUtils.manager).toList();
          final workers = staff.where((u) => u.role == RoleUtils.worker).toList();
          final pending = staff.where((u) => u.role == RoleUtils.player).toList(); // "Players" attached to hall are pending staff

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (owners.isNotEmpty) _buildSection(context, ref, "Owners", owners, Colors.amber),
              if (managers.isNotEmpty) _buildSection(context, ref, "Managers", managers, Colors.purpleAccent),
              if (workers.isNotEmpty) _buildSection(context, ref, "Workers", workers, Colors.greenAccent),
              if (pending.isNotEmpty) _buildSection(context, ref, "Pending Assignment", pending, Colors.grey),
              const SizedBox(height: 80), // Fab space
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Error: $e", style: const TextStyle(color: Colors.red))),
      ),
    );
  }

  Widget _buildSection(BuildContext context, WidgetRef ref, String title, List<UserModel> users, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        ...users.map((user) => _buildUserTile(context, ref, user)).toList(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildUserTile(BuildContext context, WidgetRef ref, UserModel user) {
    final bool canEdit = _canEditUser(currentUser, user);

    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
          backgroundColor: Colors.grey[800],
          child: user.photoUrl == null ? Text(user.username[0].toUpperCase()) : null,
        ),
        title: Text(user.firstName.isEmpty ? user.username : "${user.firstName} ${user.lastName}", style: const TextStyle(color: Colors.white)),
        subtitle: Text("@${user.username} • ${user.phoneNumber ?? 'No Phone'}", style: const TextStyle(color: Colors.white54)),
        trailing: canEdit
            ? IconButton(
                icon: const Icon(Icons.edit, color: Colors.white54),
                onPressed: () => _showEditRoleDialog(context, ref, user),
              )
            : null,
      ),
    );
  }

  bool _canEditUser(UserModel admin, UserModel target) {
    // SuperAdmin can edit everyone
    if (RoleUtils.isSuperAdmin(admin)) return true;
    
    // Owner can edit Managers, Workers, Players
    if (RoleUtils.isOwner(admin)) {
      if (target.role == RoleUtils.owner) return false; // Cannot edit other owners (unless super owner?)
      return true; 
    }

    // Manager can edit Workers, Players
    if (admin.role == RoleUtils.manager) {
      if ([RoleUtils.owner, RoleUtils.manager].contains(target.role)) return false;
      return true;
    }

    return false;
  }

  void _showEditRoleDialog(BuildContext context, WidgetRef ref, UserModel user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: Text("Edit Role: ${user.username}", style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (RoleUtils.isSuperAdmin(currentUser) || RoleUtils.isOwner(currentUser))
              _roleOption(ctx, ref, user, "Manager", RoleUtils.manager),
            _roleOption(ctx, ref, user, "Worker", RoleUtils.worker),
             _roleOption(ctx, ref, user, "Remove from Hall", "REMOVE", isDestructive: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
        ],
      ),
    );
  }

  Widget _roleOption(BuildContext context, WidgetRef ref, UserModel user, String label, String roleValue, {bool isDestructive = false}) {
    return ListTile(
      title: Text(label, style: TextStyle(color: isDestructive ? Colors.red : Colors.white)),
      onTap: () async {
        Navigator.pop(context);
        if (isDestructive) {
           await ref.read(personnelRepositoryProvider).removeStaff(user.uid);
        } else {
           await ref.read(personnelRepositoryProvider).updateRole(user.uid, roleValue);
        }
      },
    );
  }
}

final staffStreamProvider = StreamProvider.family<List<UserModel>, String>((ref, hallId) {
  return ref.watch(personnelRepositoryProvider).getStaffStream(hallId);
});
