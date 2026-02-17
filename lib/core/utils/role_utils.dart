
import '../../models/user_model.dart';

class RoleUtils {
  static const String superadmin = 'superadmin';
  static const String admin = 'admin';
  static const String owner = 'owner';
  static const String manager = 'manager';
  static const String worker = 'worker';
  static const String player = 'player';

  // App-Level Permissions
  static bool isSuperAdmin(UserModel user) {
    return user.role == superadmin;
  }

  static bool isAdmin(UserModel user) {
    return user.role == superadmin || user.role == admin;
  }

  // Hall-Level Permissions
  // Note: App-level admins usually have implicit access to all halls for support purposes.
  
  static bool canManageFinancials(UserModel user, String hallId) {
    if (isSuperAdmin(user)) return true;
    if (user.role == owner && user.homeBaseId == hallId) return true;
    return false;
  }

  static bool canManagePersonnel(UserModel user, String hallId) {
    if (isSuperAdmin(user)) return true;
    if (user.role == owner && user.homeBaseId == hallId) return true;
    return false;
  }

  static bool canManageSpecials(UserModel user, String hallId) {
    if (isAdmin(user)) return true; // Admins can help setup
    if ([owner, manager].contains(user.role) && user.homeBaseId == hallId) return true;
    return false;
  }

  static bool canManageGames(UserModel user, String hallId) {
     return canManageSpecials(user, hallId);
  }

  static bool canScanAndVerify(UserModel user, String hallId) {
    if (isAdmin(user)) return true;
    if ([owner, manager, worker].contains(user.role) && user.homeBaseId == hallId) return true;
    return false;
  }
  
  static bool canAccessDashboard(UserModel user) {
    // Anyone worker or above can access the dashboard, but tiles will be hidden
    return [superadmin, admin, owner, manager, worker].contains(user.role);
  }
}
