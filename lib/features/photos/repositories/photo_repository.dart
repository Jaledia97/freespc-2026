import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/notification_service.dart';
import '../../../../services/session_context_controller.dart';
import '../models/gallery_photo_model.dart';

final photoRepositoryProvider = Provider(
  (ref) =>
      PhotoRepository(FirebaseFirestore.instance, FirebaseStorage.instance),
);

final unreadPendingPhotosCountProvider = StreamProvider<int>((ref) {
  final session = ref.watch(sessionContextProvider);
  if (!session.isBusiness || session.activeVenueId == null) return Stream.value(0);

  final repo = ref.watch(photoRepositoryProvider);
  return repo.getPendingHallPhotos(session.activeVenueId!).map((photos) {
    return photos.length; 
  });
});

class PhotoRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  PhotoRepository(this._firestore, this._storage);

  /// Get a single photo by ID (Useful for deep-linking from notifications)
  Future<GalleryPhotoModel?> getPhotoById(String photoId) async {
    try {
      final doc = await _firestore
          .collection('gallery_photos')
          .doc(photoId)
          .get();
      if (doc.exists && doc.data() != null) {
        return GalleryPhotoModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching photo by ID $photoId: $e");
      return null;
    }
  }

  /// Uploads a photo to Storage and creates a GalleryPhotoModel in Firestore.
  /// Venues tagged are initially added to 'pendingHallIds'.
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
      // All tagged venues start as PENDING.
      pendingHallIds: taggedHallIds,
      approvedHallIds: [],
    );

    // 3. Save to Firestore
    await _firestore
        .collection('gallery_photos')
        .doc(photoId)
        .set(photo.toJson());

    // 4. Send Notifications
    final ns = NotificationService(_firestore);

    // Notify Uploader
    await ns.sendNotification(
      userId: uploaderId,
      title: "Photo Awaiting Approval",
      body:
          "Your uploaded photo has been submitted and is awaiting manager approval.",
      type: 'photo_pending',
      metadata: {'photoId': photoId},
    );

    // Note: Notifying managers via push requires a Cloud Function to securely query managers
    // without violating Firestore rules. For now, managers will see pending photos in their dashboard.
  }

  /// Get Public Photos for a Venue (Must be APPROVED)
  Stream<List<GalleryPhotoModel>> getHallPhotos(String venueId) {
    return _firestore
        .collection('gallery_photos')
        .where('approvedHallIds', arrayContains: venueId)
        .where('isHidden', isEqualTo: false) // Hide reported content if needed
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => GalleryPhotoModel.fromJson(doc.data()))
              .toList(),
        );
  }

  /// Get Pending Photos for a Manager Dashboard
  Stream<List<GalleryPhotoModel>> getPendingHallPhotos(String venueId) {
    return _firestore
        .collection('gallery_photos')
        .where('pendingHallIds', arrayContains: venueId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => GalleryPhotoModel.fromJson(doc.data()))
              .toList(),
        );
  }

  /// Approve a photo for a specific venue
  Future<void> approvePhoto(String photoId, String venueId) async {
    final docRef = _firestore.collection('gallery_photos').doc(photoId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) throw Exception("Photo not found");

      // Move from Pending -> Approved
      transaction.update(docRef, {
        'pendingHallIds': FieldValue.arrayRemove([venueId]),
        'approvedHallIds': FieldValue.arrayUnion([venueId]),
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
        venueId: venueId,
        metadata: {'photoId': photo.id, 'uploaderId': photo.uploaderId},
      );
    }
  }

  /// Decline a photo for a specific venue
  Future<void> declinePhoto(String photoId, String venueId) async {
    final docRef = _firestore.collection('gallery_photos').doc(photoId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) throw Exception("Photo not found");

      // Remove from Pending (and Tagged, so it effectively disappears for this venue)
      transaction.update(docRef, {
        'pendingHallIds': FieldValue.arrayRemove([venueId]),
        'taggedHallIds': FieldValue.arrayRemove([venueId]),
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
        body: "Your photo was not approved for the venue's gallery.",
        type: 'photo_declined',
        venueId: venueId,
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
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => GalleryPhotoModel.fromJson(doc.data()))
              .toList(),
        );
  }

  /// Delete a photo permanently (Firestore & Storage)
  Future<void> deletePhoto(String photoId, String imageUrl) async {
    try {
      // 1. Delete from Storage
      await _storage.refFromURL(imageUrl).delete();
    } catch (e) {
      // Ignore storage errors (e.g., if file missing)
      debugPrint("Storage delete error: $e");
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
