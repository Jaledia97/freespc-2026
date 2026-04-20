import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final storageServiceProvider = Provider(
  (ref) => StorageService(FirebaseStorage.instance),
);

class StorageService {
  final FirebaseStorage _storage;
  final ImagePicker _picker = ImagePicker();

  StorageService(this._storage);

  Future<XFile?> pickImage({ImageSource source = ImageSource.gallery}) async {
    return await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
  }

  Future<String> uploadProfileImage(File file, String userId) async {
    try {
      final ref = _storage.ref().child(
        'users/$userId/profile_v${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      debugPrint('Starting upload to: ${ref.fullPath}');

      try {
        final snapshot = await ref.putFile(file);
        debugPrint('Upload state: ${snapshot.state}');

        if (snapshot.state == TaskState.success) {
          final url = await ref.getDownloadURL();
          debugPrint('Download success: $url');
          return url;
        } else {
          throw Exception('Upload failed with state: ${snapshot.state}');
        }
      } catch (uploadError) {
        debugPrint('PutFile Error: $uploadError');
        // Check if this is a permission error
        if (uploadError.toString().contains('permission-denied')) {
          throw Exception(
            'Permission Denied: Ensure you are logged in and rules allow write.',
          );
        }
        rethrow;
      }
    } catch (e) {
      debugPrint('General Upload Error: $e');
      rethrow;
    }
  }

  Future<String> uploadBannerImage(File file, String userId) async {
    try {
      final ref = _storage.ref().child(
        'users/$userId/banner_v${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      debugPrint('Starting banner upload to: ${ref.fullPath}');

      final snapshot = await ref.putFile(file);
      if (snapshot.state == TaskState.success) {
        return await ref.getDownloadURL();
      } else {
        throw Exception('Banner upload failed: ${snapshot.state}');
      }
    } catch (e) {
      debugPrint('Error uploading banner image: $e');
      rethrow;
    }
  }

  Future<String> uploadHallImage(File file, String venueId, String type) async {
    try {
      final ref = _storage.ref().child(
        'venues/$venueId/${type}_v${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      debugPrint('Starting venue image upload to: ${ref.fullPath}');

      final snapshot = await ref.putFile(file);
      if (snapshot.state == TaskState.success) {
        return await ref.getDownloadURL();
      } else {
        throw Exception('Venue image upload failed: ${snapshot.state}');
      }
    } catch (e) {
      debugPrint('Error uploading venue image: $e');
      rethrow;
    }
  }

  Future<String> uploadVenueClaimImage(File file, String userId) async {
    try {
      final ref = _storage.ref().child(
        'claims/$userId/logo_v${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      debugPrint('Starting claim logo upload to: ${ref.fullPath}');

      final snapshot = await ref.putFile(file);
      if (snapshot.state == TaskState.success) {
        return await ref.getDownloadURL();
      } else {
        throw Exception('Claim logo upload failed: ${snapshot.state}');
      }
    } catch (e) {
      debugPrint('Error uploading claim logo: $e');
      rethrow;
    }
  }
}
