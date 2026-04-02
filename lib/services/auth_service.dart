import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/public_profile.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});
final userProfileProvider = StreamProvider<UserModel?>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return Stream.value(null);

  return ref.watch(authServiceProvider).getUserStream(user.uid);
});

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Stream<UserModel?> getUserStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        try {
          return UserModel.fromJson(snapshot.data()!);
        } catch (e) {
          print("CRITICAL RESILIENCE WARNING: Failed to parse UserModel for $uid. Sending to Onboarding to self-heal. Error: $e");
          return null; // Forcing null routes the broken account directly back into Onboarding where it will be regenerated with all explicit fields upon submit
        }
      }
      return null;
    });
  }

  Future<PublicProfile?> getPublicProfile(String uid) async {
    try {
      final doc = await _firestore.collection('public_profiles').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return PublicProfile.fromJson(doc.data()!);
      }

      // Fallback: If older test accounts don't have a public profile, read their private user profile
      final privateDoc = await _firestore.collection('users').doc(uid).get();
      if (privateDoc.exists && privateDoc.data() != null) {
        final data = privateDoc.data()!;
        // Synthesize a PublicProfile from the private data
        return PublicProfile(
          uid: uid,
          username: data['username'] ?? 'unknown',
          firstName: data['firstName'] ?? 'Hidden',
          lastName: data['lastName'] ?? '',
          points: data['currentPoints'] ?? 0,
          realNameVisibility: 'Everyone',
          onlineStatus: 'Offline',
        );
      }
    } catch (e) {
      print("Error fetching public profile: $e");
    }
    return null;
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print("Error signing in with Google: $e");
      return null;
    }
  }

  Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print("Error signing in: $e");
      rethrow;
    }
  }

  Future<UserCredential?> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print("Error registering: $e");
      rethrow;
    }
  }

  Future<UserCredential?> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final OAuthProvider oauthProvider = OAuthProvider('apple.com');
      final AuthCredential credential = oauthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print("Error signing in with Apple: $e");
      // Identify if canceled by user
      return null;
    }
  }

  Future<UserCredential?> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        final OAuthCredential credential = FacebookAuthProvider.credential(
          accessToken.tokenString,
        );
        return await _auth.signInWithCredential(credential);
      } else {
        print("Facebook Login Failed: ${result.status} - ${result.message}");
        return null;
      }
    } catch (e) {
      print("Error signing in with Facebook: $e");
      return null;
    }
  }

  Future<void> verifyPhoneNumber(
    String phoneNumber,
    Function(String, int?) codeSent,
    Function(FirebaseAuthException) failed,
  ) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: failed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<UserCredential?> verifySmsCode(
    String verificationId,
    String smsCode,
  ) async {
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print("Error verifying SMS code: $e");
      rethrow;
    }
  }

  Future<UserCredential?> signInWithCredential(
    AuthCredential credential,
  ) async {
    try {
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print("Error signing in with credential: $e");
      rethrow;
    }
  }

  Future<void> updateUserProfile(
    String uid, {
    String? firstName,
    String? lastName,
    String? username,
    String? bio,
    String? email, // Optional if we allow email changes
    String? realNameVisibility,
    String? onlineStatus,
    String? currentCheckInHallId,
  }) async {
    final Map<String, dynamic> updates = {};
    if (firstName != null) updates['firstName'] = firstName;
    if (lastName != null) updates['lastName'] = lastName;
    if (username != null) updates['username'] = username;
    if (bio != null) updates['bio'] = bio;
    if (realNameVisibility != null)
      updates['realNameVisibility'] = realNameVisibility;
    if (onlineStatus != null) updates['onlineStatus'] = onlineStatus;
    if (currentCheckInHallId != null)
      updates['currentCheckInHallId'] = currentCheckInHallId;

    // Safety check just in case
    if (updates.isEmpty) return;

    try {
      // 1. Update private User document
      await _firestore.collection('users').doc(uid).update(updates);

      // 2. Update Public Profile (Dual-Write)
      // We only update fields that exist in PublicProfile
      final publicUpdates = <String, dynamic>{};
      if (username != null) {
        publicUpdates['username'] = username;
        publicUpdates['searchName'] = username.toLowerCase();
      }
      if (firstName != null) publicUpdates['firstName'] = firstName;
      if (lastName != null) publicUpdates['lastName'] = lastName;
      if (bio != null) publicUpdates['bio'] = bio;
      if (realNameVisibility != null)
        publicUpdates['realNameVisibility'] = realNameVisibility;
      if (onlineStatus != null) publicUpdates['onlineStatus'] = onlineStatus;
      if (currentCheckInHallId != null)
        publicUpdates['currentCheckInHallId'] = currentCheckInHallId;

      // If we have public updates, apply them.
      if (publicUpdates.isNotEmpty) {
        await _firestore
            .collection('public_profiles')
            .doc(uid)
            .set(publicUpdates, SetOptions(merge: true));
      }
    } catch (e) {
      print("Error updating profile: $e");
      rethrow;
    }
  }

  Future<void> updateUserFields(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);

      // Dual-write specific fields to public profile
      final publicKeys = [
        'username',
        'firstName',
        'lastName',
        'photoUrl',
        'bio',
      ];
      final publicUpdates = <String, dynamic>{};

      for (var key in publicKeys) {
        if (data.containsKey(key)) {
          publicUpdates[key] = data[key];
          if (key == 'username') {
            publicUpdates['searchName'] = data[key].toString().toLowerCase();
          }
        }
      }

      if (publicUpdates.isNotEmpty) {
        await _firestore
            .collection('public_profiles')
            .doc(uid)
            .set(publicUpdates, SetOptions(merge: true));
      }
    } catch (e) {
      print("Error updating user fields: $e");
      rethrow;
    }
  }

  Future<void> updateLastViewedPhotoApprovals(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'lastViewedPhotoApprovals': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print("Error updating lastViewedPhotoApprovals: $e");
    }
  }

  Future<void> updateFcmToken(String uid) async {
    try {
      // Defer import to avoid clutter if used elsewhere, or just rely on global import if we added it
      // Actually we need to add firebase_messaging import at the top of the file
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await _firestore.collection('users').doc(uid).update({
          'fcmTokens': FieldValue.arrayUnion([fcmToken]),
        });
      }

      // Also listen to token refreshes
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        await _firestore.collection('users').doc(uid).update({
          'fcmTokens': FieldValue.arrayUnion([newToken]),
        });
      });
    } catch (e) {
      print("Error updating FCM token: $e");
    }
  }

  Future<List<PublicProfile>> searchUsers(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      // Force format for identical matching and strip @ just in case
      final term = query
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'\s+'), '')
          .replaceAll('@', '');

      // SECURE & PERFORMANT SEARCH: Natively index query public_profiles by username
      final snapshot = await _firestore
          .collection('public_profiles')
          .where('username', isGreaterThanOrEqualTo: term)
          .where('username', isLessThanOrEqualTo: '$term\uf8ff')
          .limit(25)
          .get();

      var results = snapshot.docs
          .map((doc) {
            try {
              return PublicProfile.fromJson(doc.data());
            } catch (e) {
              return null;
            }
          })
          .where((profile) => profile != null)
          .cast<PublicProfile>()
          .toList();

      // Typo-Tolerant Fallback: If exact prefix fails, pull general subset and perform stripped-substring fuzzy matching
      if (results.length < 3) {
        final fallbackSnap = await _firestore.collection('public_profiles').limit(50).get();
        final rawQuery = term.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');

        final fallbackResults = fallbackSnap.docs
            .map((doc) {
              try {
                return PublicProfile.fromJson(doc.data());
              } catch (_) {
                return null;
              }
            })
            .whereType<PublicProfile>()
            .where((profile) {
              final rawUsername = profile.username.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
              final rawFirst = profile.firstName.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
              return rawUsername.contains(rawQuery) || rawFirst.contains(rawQuery);
            })
            .toList();

        for (var profile in fallbackResults) {
          if (!results.any((r) => r.uid == profile.uid)) {
            results.add(profile);
          }
        }
      }

      return results;
    } catch (e) {
      print("Error searching users: $e");
      return [];
    }
  }

  Future<List<PublicProfile>> getSuggestedUsers() async {
    try {
      final String? currentUid = _auth.currentUser?.uid;
      final snapshot = await _firestore
          .collection('public_profiles')
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) {
            try {
              return PublicProfile.fromJson(doc.data());
            } catch (e) {
              return null;
            }
          })
          .where((profile) => profile != null && profile.uid != currentUid)
          .cast<PublicProfile>()
          .toList();
    } catch (e) {
      print("Error getting suggested users: $e");
      return [];
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("No user logged in");

      // 1. Delete Firestore Data (Optional: Cloud Function usually better for recursive delete)
      // Here we just delete the main doc. Subcollections might persist unless recursive delete used.
      // For compliance, a flag 'deleted' might be better, but strict delete requested.
      // Deleting main doc:
      await _firestore.collection('users').doc(user.uid).delete();
      await _firestore.collection('public_profiles').doc(user.uid).delete();

      // 2. Delete Auth Account
      // Requires recent login. Re-authentication might be needed if old session.
      await user.delete();
    } catch (e) {
      print("Error deleting account: $e");
      // If error is 'requires-recent-login', generic e.code check
      if (e is FirebaseAuthException && e.code == 'requires-recent-login') {
        // UI should handle re-auth, but for now we rethrow
        throw Exception(
          "Please log out and log back in to delete your account.",
        );
      }
      rethrow;
    }
  }

  // --- Custom Categories Management ---
  Future<void> saveCustomCategory(String userId, String category) async {
    try {
      final docRef = _firestore.collection('users').doc(userId);
      await docRef.update({
        'customCategories': FieldValue.arrayUnion([category]),
      });
    } catch (e) {
      print("Error saving custom category: $e");
      throw Exception("Failed to save custom category.");
    }
  }

  Future<void> removeCustomCategory(String userId, String category) async {
    try {
      final docRef = _firestore.collection('users').doc(userId);
      await docRef.update({
        'customCategories': FieldValue.arrayRemove([category]),
      });
    } catch (e) {
      print("Error removing custom category: $e");
      throw Exception("Failed to remove custom category.");
    }
  }
}
