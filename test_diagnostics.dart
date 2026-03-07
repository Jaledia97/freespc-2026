import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'lib/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Find a user with notifications
  final users = await FirebaseFirestore.instance.collection('users').limit(10).get();
  for (var u in users.docs) {
    final notifs = await u.reference.collection('notifications').orderBy('createdAt', descending: true).get();
    if (notifs.docs.isNotEmpty) {
      print("USER: \${u.id} - Notifications: \${notifs.docs.length}");
      for (var n in notifs.docs) {
         final data = n.data();
         print("  ID: \${n.id}");
         print("  Title: \${data['title']}");
         print("  CreatedAt type: \${data['createdAt'].runtimeType}");
         print("  CreatedAt val : \${data['createdAt']}");
      }
      break;
    }
  }
}
