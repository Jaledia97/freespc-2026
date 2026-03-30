import '../../models/user_model.dart';
import '../../services/session_context_controller.dart';

class RoleUtils {
  static const String superadmin = 'superadmin';
  static const String admin = 'admin';
  static const String owner = 'owner';
  static const String manager = 'manager';
  static const String worker = 'worker';

  // App-Level Permissions
  static bool isSuperAdmin(UserModel user) {
    return user.systemRole == superadmin;
  }

  static bool isAdmin(UserModel user) {
    return user.systemRole == superadmin || user.systemRole == admin;
  }

  static bool isPendingOwner(UserModel user) {
    return user.pendingVenueClaimId != null;
  }

  // Hall-Level Permissions
  static bool isOwner(UserModel user, SessionState session) {
    if (isSuperAdmin(user)) return true;
    return session.isBusiness && session.activeRole == owner;
  }

  static bool canManageHall(UserModel user, SessionState session, String hallId) {
    if (isSuperAdmin(user)) return true;
    if (session.activeVenueId != hallId) return false;
    return session.isBusiness && [owner, manager].contains(session.activeRole);
  }

  static bool canManageFinancials(UserModel user, SessionState session, String hallId) {
    if (isSuperAdmin(user)) return true;
    if (session.activeVenueId != hallId) return false;
    return session.isBusiness && session.activeRole == owner;
  }

  static bool canManagePersonnel(UserModel user, SessionState session, String hallId) {
    if (isSuperAdmin(user)) return true;
    if (session.activeVenueId != hallId) return false;
    return session.isBusiness && [owner, manager].contains(session.activeRole);
  }

  static bool canManageSpecials(UserModel user, SessionState session, String hallId) {
    if (isAdmin(user)) return true; // Admins can help setup
    if (session.activeVenueId != hallId) return false;
    return session.isBusiness && [owner, manager].contains(session.activeRole);
  }

  static bool canManageGames(UserModel user, SessionState session, String hallId) {
    return canManageSpecials(user, session, hallId);
  }

  static bool canScanAndVerify(UserModel user, SessionState session, String hallId) {
    if (isAdmin(user)) return true;
    if (session.activeVenueId != hallId) return false;
    return session.isBusiness && [owner, manager, worker].contains(session.activeRole);
  }
}
