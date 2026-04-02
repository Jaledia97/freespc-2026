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
    
    if (overrideStatus == 'Away') {
      return 'Away';
    }

    if (overrideStatus == 'Online') {
      if (diff.inMinutes <= 15) {
        return 'Online';
      } else if (diff.inMinutes <= 60) {
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
  /// Computes a relative 'Last Seen' string bounded by a 30-day cutoff
  static String getLastSeenText(DateTime? lastSeen) {
    if (lastSeen == null) return "Offline";
    
    final diff = DateTime.now().difference(lastSeen);
    if (diff.inDays > 30) {
      return "Offline";
    } else if (diff.inDays >= 1) {
      return "Last seen: ${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago";
    } else if (diff.inHours >= 1) {
      return "Last seen: ${diff.inHours} hr${diff.inHours == 1 ? '' : 's'} ago";
    } else if (diff.inMinutes >= 1) {
      return "Last seen: ${diff.inMinutes} min${diff.inMinutes == 1 ? '' : 's'} ago";
    } else {
      return "Last seen: Just now";
    }
  }
}
