import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'lib/firebase_options.dart';

void main() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  final snap = await FirebaseFirestore.instance
      .collection('specials')
      .where('isTemplate', isEqualTo: false)
      .orderBy('postedAt', descending: true)
      .limit(10)
      .get();
      
  print('--- Top 10 Specials by postedAt DESC ---');
  for (var doc in snap.docs) {
    final d = doc.data();
    print('ID: ${doc.id}');
    print('Title: ${d['title']}');
    print('postedAt: ${(d['postedAt'] as Timestamp).toDate()}');
    if (d['startTime'] != null) {
      print('startTime: ${(d['startTime'] as Timestamp).toDate()}');
    }
    print('isTemplate: ${d['isTemplate']}');
    print('-------------------------');
  }
}
