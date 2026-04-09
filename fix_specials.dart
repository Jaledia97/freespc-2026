import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'lib/firebase_options.dart';

void main() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  final snap = await FirebaseFirestore.instance
      .collection('specials')
      .where('isTemplate', isEqualTo: false)
      .get();
      
  final batch = FirebaseFirestore.instance.batch();
  int count = 0;
  
  final now = Timestamp.now();
  
  for (var doc in snap.docs) {
    batch.update(doc.reference, {'postedAt': now});
    count++;
  }
  
  await batch.commit();
  print('Successfully migrated $count specials backwards!');
}
