import 'package:flutter/material.dart';

class PresenceUtils {
  /// Evaluates `lastSeen` combined with user's manual override preference
  /// to yield a true real-time display string.
  static String getDerivedStatus(String overrideStatus, DateTime? lastSeen) {
    if (overrideStatus == 'Offline') {
      return 'Offline';
    }
    
    if (lastSeen == null) {
      return 'Offline'; // Never seen
    }
    
    final diff = DateTime.now().difference(lastSeen);
    
    if (overrideStatus == 'Online') {
      if (diff.inMinutes <= 15) {
        return 'Online';
      } else if (diff.inHours <= 12) {
        return 'Away';
      } else {
        return 'Offline';
      }
    } else if (overrideStatus == 'Away') {
      if (diff.inHours <= 12) {
        return 'Away';
      } else {
        return 'Offline';
      }
    }
    
    return 'Offline'; // Fallback
  }

  /// Returns the corresponding color for the status.
  static Color getStatusColor(String status) {
    switch (status) {
      case 'Online':
        return Colors.greenAccent;
      case 'Away':
        return Colors.amber;
      case 'Offline':
      default:
        return Colors.grey;
    }
  }
}
