import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/user_model.dart';
import '../../../../models/bingo_hall_model.dart';
import '../../../../models/venue_team_member_model.dart';
import '../../../../core/utils/role_utils.dart';
import '../../repositories/personnel_repository.dart';
import '../../../../services/session_context_controller.dart';
import 'invite_staff_sheet.dart';
import '../../../../services/auth_service.dart';
import '../../../home/repositories/hall_repository.dart';

class ManagePersonnelScreen extends ConsumerWidget {
  const ManagePersonnelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionContextProvider);

    if (!session.isBusiness || session.activeVenueId == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(
          child: Text(
            "Access Denied: No Active Venue Session",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
    
    final currentUserAsync = ref.watch(userProfileProvider);
    final hallId = session.activeVenueId!;
    final staffStream = ref.watch(staffStreamProvider(hallId));
    final hallAsync = ref.watch(hallStreamProvider(hallId));

    if (currentUserAsync.value == null || hallAsync.value == null) {
        return const Scaffold(
          backgroundColor: Color(0xFF141414),
          body: Center(child: CircularProgressIndicator()),
        );
    }

    final currentUser = currentUserAsync.value!;
    final hall = hallAsync.value!;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Personnel Management"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: RoleUtils.canManagePersonnel(currentUser, session, hallId)
          ? FloatingActionButton.extended(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) =>
                      InviteStaffSheet(hallId: hallId, hallName: hall.name),
                );
              },
              label: const Text("Invite Staff"),
              icon: const Icon(Icons.person_add),
              backgroundColor: Colors.cyan,
            )
          : null,
      body: staffStream.when(
        data: (staff) {
          if (staff.isEmpty) {
            return const Center(
              child: Text(
                "No staff found.",
                style: TextStyle(color: Colors.white54),
              ),
            );
          }

          // Group by assignedRole priority
          final owners = staff.where((u) => u.assignedRole == RoleUtils.owner).toList();
          final managers = staff.where((u) => u.assignedRole == RoleUtils.manager).toList();
          final workers = staff.where((u) => u.assignedRole == RoleUtils.worker).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (owners.isNotEmpty)
                _buildSection(context, ref, "Owners", owners, Colors.amber, session, currentUser, hallId),
              if (managers.isNotEmpty)
                _buildSection(
                  context,
                  ref,
                  "Managers",
                  managers,
                  Colors.purpleAccent,
                  session,
                  currentUser,
                  hallId,
                ),
              if (workers.isNotEmpty)
                _buildSection(
                  context,
                  ref,
                  "Workers",
                  workers,
                  Colors.greenAccent,
                  session,
                  currentUser,
                  hallId,
                ),
              const SizedBox(height: 80), // Fab space
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(
          child: Text("Error: $e", style: const TextStyle(color: Colors.red)),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    WidgetRef ref,
    String title,
    List<VenueTeamMemberModel> users,
    Color color,
    SessionState session,
    UserModel currentUser,
    String hallId,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        ...users.map((user) => _buildUserTile(context, ref, user, session, currentUser, hallId)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildUserTile(BuildContext context, WidgetRef ref, VenueTeamMemberModel user, SessionState session, UserModel currentUser, String hallId) {
    final bool canEdit = _canEditUser(currentUser, session, user);

    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: user.photoUrl != null
              ? NetworkImage(user.photoUrl!)
              : null,
          backgroundColor: Colors.grey[800],
          child: user.photoUrl == null
              ? Text(user.username.isNotEmpty ? user.username[0].toUpperCase() : '?')
              : null,
        ),
        title: Text(
          user.firstName.isEmpty
              ? user.username
              : "${user.firstName} ${user.lastName}",
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          "@${user.username}",
          style: const TextStyle(color: Colors.white54),
        ),
        trailing: canEdit
            ? IconButton(
                icon: const Icon(Icons.edit, color: Colors.white54),
                onPressed: () => _showEditRoleDialog(context, ref, user, currentUser, hallId),
              )
            : null,
      ),
    );
  }

  bool _canEditUser(UserModel admin, SessionState session, VenueTeamMemberModel target) {
    // SuperAdmin can edit everyone
    if (RoleUtils.isSuperAdmin(admin)) return true;

    // Owner can edit Managers, Workers
    if (RoleUtils.isOwner(admin, session)) {
      if (target.assignedRole == RoleUtils.owner)
        return false; // Cannot edit other owners (unless super admin)
      return true;
    }

    // Manager can edit Workers
    if (session.isBusiness && session.activeRole == RoleUtils.manager) {
      if ([RoleUtils.owner, RoleUtils.manager].contains(target.assignedRole))
        return false;
      return true;
    }

    return false;
  }

  void _showEditRoleDialog(
    BuildContext context,
    WidgetRef ref,
    VenueTeamMemberModel user,
    UserModel currentUser,
    String hallId,
  ) {
    final session = ref.read(sessionContextProvider);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: Text(
          "Edit Role: ${user.username}",
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (RoleUtils.isSuperAdmin(currentUser) ||
                RoleUtils.isOwner(currentUser, session))
              _roleOption(ctx, ref, user, "Manager", RoleUtils.manager, hallId),
            _roleOption(ctx, ref, user, "Worker", RoleUtils.worker, hallId),
            _roleOption(
              ctx,
              ref,
              user,
              "Remove from Hall",
              "REMOVE",
              hallId,
              isDestructive: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  Widget _roleOption(
    BuildContext context,
    WidgetRef ref,
    VenueTeamMemberModel user,
    String label,
    String roleValue,
    String hallId, {
    bool isDestructive = false,
  }) {
    return ListTile(
      title: Text(
        label,
        style: TextStyle(color: isDestructive ? Colors.red : Colors.white),
      ),
      onTap: () async {
        Navigator.pop(context);
        if (isDestructive) {
          await ref.read(personnelRepositoryProvider).removeStaff(hallId, user.uid);
        } else {
          await ref
              .read(personnelRepositoryProvider)
              .updateRole(hallId, user.uid, roleValue);
        }
      },
    );
  }
}

final staffStreamProvider = StreamProvider.family<List<VenueTeamMemberModel>, String>((
  ref,
  hallId,
) {
  return ref.watch(personnelRepositoryProvider).getStaffStream(hallId);
});
