import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/notification_service.dart';
import '../models/gallery_photo_model.dart';

final photoRepositoryProvider = Provider((ref) => PhotoRepository(
  FirebaseFirestore.instance, 
  FirebaseStorage.instance
));

final unreadPendingPhotosCountProvider = StreamProvider<int>((ref) {
  final userAsync = ref.watch(userProfileProvider);
  final user = userAsync.value;
  if (user == null || user.homeBaseId == null) return Stream.value(0);

  final repo = ref.watch(photoRepositoryProvider);
  return repo.getPendingHallPhotos(user.homeBaseId!).map((photos) {
    if (user.lastViewedPhotoApprovals == null) {
      return photos.where((p) => p.pendingHallIds.contains(user.homeBaseId!)).length;
    }
    return photos.where((p) => 
      p.pendingHallIds.contains(user.homeBaseId!) && 
      p.timestamp.isAfter(user.lastViewedPhotoApprovals!)
    ).length;
  });
});

class PhotoRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  PhotoRepository(this._firestore, this._storage);

  /// Get a single photo by ID (Useful for deep-linking from notifications)
  Future<GalleryPhotoModel?> getPhotoById(String photoId) async {
    try {
      final doc = await _firestore.collection('gallery_photos').doc(photoId).get();
      if (doc.exists && doc.data() != null) {
        return GalleryPhotoModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print("Error fetching photo by ID $photoId: $e");
      return null;
    }
  }

  /// Uploads a photo to Storage and creates a GalleryPhotoModel in Firestore.
  /// Halls tagged are initially added to 'pendingHallIds'.
  Future<void> uploadPhoto({
    required File imageFile,
    required String uploaderId,
    String? description,
    List<String> taggedHallIds = const [],
    List<String> taggedUserIds = const [],
  }) async {
    final photoId = const Uuid().v4();
    final ref = _storage.ref().child('gallery_photos/$uploaderId/$photoId.jpg');
    
    // 1. Upload Image
    await ref.putFile(imageFile);
    final downloadUrl = await ref.getDownloadURL();

    // 2. Create Model
    final photo = GalleryPhotoModel(
      id: photoId,
      uploaderId: uploaderId,
      imageUrl: downloadUrl,
      timestamp: DateTime.now(),
      description: description,
      taggedUserIds: taggedUserIds,
      taggedHallIds: taggedHallIds,
      // All tagged halls start as PENDING.
      pendingHallIds: taggedHallIds, 
      approvedHallIds: [], 
    );

    // 3. Save to Firestore
    await _firestore.collection('gallery_photos').doc(photoId).set(photo.toJson());

    // 4. Send Notifications
    final ns = NotificationService(_firestore);

    // Notify Uploader
    await ns.sendNotification(
      userId: uploaderId,
      title: "Photo Awaiting Approval",
      body: "Your uploaded photo has been submitted and is awaiting manager approval.",
      type: 'photo_pending',
      metadata: {'photoId': photoId},
    );

    // Notify Workers/Managers of Tagged Halls
    if (taggedHallIds.isNotEmpty) {
      for (final hallId in taggedHallIds) {
        // Find workers/managers for this hall
        final snapshot = await _firestore
            .collection('users')
            .where('homeBaseId', isEqualTo: hallId)
            .where('role', whereIn: ['manager', 'worker', 'owner', 'superadmin', 'admin'])
            .get();

        for (final doc in snapshot.docs) {
          final workerId = doc.id;
          if (workerId == uploaderId) continue; // Skip uploader

          await ns.sendNotification(
            userId: workerId,
            title: "New Photo Awaiting Approval",
            body: "A user has uploaded a photo tagged to your hall. Please review it.",
            type: 'hall_photo_pending',
            hallId: hallId,
            metadata: {'photoId': photoId},
          );
        }
      }
    }
  }

  /// Get Public Photos for a Hall (Must be APPROVED)
  Stream<List<GalleryPhotoModel>> getHallPhotos(String hallId) {
    return _firestore
        .collection('gallery_photos')
        .where('approvedHallIds', arrayContains: hallId)
        .where('isHidden', isEqualTo: false) // Hide reported content if needed
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GalleryPhotoModel.fromJson(doc.data()))
            .toList());
  }

  /// Get Pending Photos for a Manager Dashboard
  Stream<List<GalleryPhotoModel>> getPendingHallPhotos(String hallId) {
    return _firestore
        .collection('gallery_photos')
        .where('pendingHallIds', arrayContains: hallId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GalleryPhotoModel.fromJson(doc.data()))
            .toList());
  }

  /// Approve a photo for a specific hall
  Future<void> approvePhoto(String photoId, String hallId) async {
    final docRef = _firestore.collection('gallery_photos').doc(photoId);
    
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) throw Exception("Photo not found");

      // Move from Pending -> Approved
      transaction.update(docRef, {
        'pendingHallIds': FieldValue.arrayRemove([hallId]),
        'approvedHallIds': FieldValue.arrayUnion([hallId]),
      });
      
      // We also need to notify the user.
      // But transaction can't easily trigger side effects reliably if retried.
      // So we will do it after the transaction.
    });
    
    // Fetch photo to get uploader
    final photoDoc = await docRef.get();
    if (photoDoc.exists) {
      final photo = GalleryPhotoModel.fromJson(photoDoc.data()!);
      final ns = NotificationService(_firestore);
      await ns.sendNotification(
        userId: photo.uploaderId,
        title: "Photo Approved! 📸",
        body: "Your tagged photo has been approved for the gallery.",
        type: 'photo_approval',
        hallId: hallId,
        metadata: {'photoId': photo.id, 'uploaderId': photo.uploaderId},
      );
    }
  }

  /// Decline a photo for a specific hall
  Future<void> declinePhoto(String photoId, String hallId) async {
    final docRef = _firestore.collection('gallery_photos').doc(photoId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) throw Exception("Photo not found");

      // Remove from Pending (and Tagged, so it effectively disappears for this hall)
      transaction.update(docRef, {
        'pendingHallIds': FieldValue.arrayRemove([hallId]),
        'taggedHallIds': FieldValue.arrayRemove([hallId]),
      });
    });
    
    // Fetch photo to get uploader
    final photoDoc = await docRef.get();
    if (photoDoc.exists) {
      final photo = GalleryPhotoModel.fromJson(photoDoc.data()!);
      final ns = NotificationService(_firestore);
      await ns.sendNotification(
        userId: photo.uploaderId,
        title: "Photo Declined",
        body: "Your photo was not approved for the hall's gallery.",
        type: 'photo_declined',
        hallId: hallId,
        metadata: {'photoId': photo.id, 'uploaderId': photo.uploaderId},
      );
    }
  }

  /// Get User's Gallery (All photos they uploaded)
  Stream<List<GalleryPhotoModel>> getUserGallery(String userId) {
    return _firestore
        .collection('gallery_photos')
        .where('uploaderId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GalleryPhotoModel.fromJson(doc.data()))
            .toList());
  }
  /// Delete a photo permanently (Firestore & Storage)
  Future<void> deletePhoto(String photoId, String imageUrl) async {
    try {
      // 1. Delete from Storage
      await _storage.refFromURL(imageUrl).delete();
    } catch (e) {
      // Ignore storage errors (e.g., if file missing)
      print("Storage delete error: $e");
    }

    // 2. Delete from Firestore
    await _firestore.collection('gallery_photos').doc(photoId).delete();
  }

  /// Report a photo for inappropriate content
  Future<void> reportPhoto(String photoId) async {
    final docRef = _firestore.collection('gallery_photos').doc(photoId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) throw Exception("Photo not found");

      final currentReports = snapshot.data()?['reportCount'] as int? ?? 0;
      final newReportCount = currentReports + 1;

      transaction.update(docRef, {
        'reportCount': newReportCount,
        // Auto-hide if reports > 5 (Simple Auto-Mod)
        'isHidden': newReportCount > 5, 
      });
    });
  }
}
