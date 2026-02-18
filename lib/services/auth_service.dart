import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

final roleOverrideProvider = StateProvider<String?>((ref) => null);

final userProfileProvider = StreamProvider<UserModel?>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return Stream.value(null);
  
  final overrideRole = ref.watch(roleOverrideProvider);
  return ref.watch(authServiceProvider).getUserStream(user.uid).map((userData) {
    if (userData != null && userData.role == 'super-admin' && overrideRole != null) {
      return userData.copyWith(role: overrideRole);
    }
    return userData;
  });
});

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Stream<UserModel?> getUserStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return UserModel.fromJson(snapshot.data()!);
      }
      return null;
    });
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

  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print("Error signing in: $e");
      rethrow; 
    }
  }

  Future<UserCredential?> registerWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
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
        final OAuthCredential credential = FacebookAuthProvider.credential(accessToken.tokenString);
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

  Future<UserCredential?> verifySmsCode(String verificationId, String smsCode) async {
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

  Future<UserCredential?> signInWithCredential(AuthCredential credential) async {
    try {
      return await _auth.signInWithCredential(credential);
    } catch (e) {
       print("Error signing in with credential: $e");
       rethrow;
    }
  }

  Future<void> updateUserProfile(String uid, {
    String? firstName, 
    String? lastName,
    String? username,
    String? bio,
    String? email, // Optional if we allow email changes
  }) async {
    final Map<String, dynamic> updates = {};
    if (firstName != null) updates['firstName'] = firstName;
    if (lastName != null) updates['lastName'] = lastName;
    if (username != null) updates['username'] = username;
    if (bio != null) updates['bio'] = bio;
    
    // Safety check just in case
    if (updates.isEmpty) return;

    try {
      // 1. Update private User document
      await _firestore.collection('users').doc(uid).update(updates);

      // 2. Update Public Profile (Dual-Write)
      // We only update fields that exist in PublicProfile
      final publicUpdates = <String, dynamic>{};
      if (username != null) publicUpdates['username'] = username;
      if (firstName != null) publicUpdates['firstName'] = firstName;
      if (lastName != null) publicUpdates['lastName'] = lastName;
      if (bio != null) publicUpdates['bio'] = bio;
      
      // If we have public updates, apply them. 
      // Note: If the public profile doesn't exist, we might want to set it, 
      // but 'update' will fail if doc missing. Use set with merge if uncertain, 
      // but here we assume parity. Safe approach: set(..., SetOptions(merge: true))
      if (publicUpdates.isNotEmpty) {
         await _firestore.collection('public_profiles').doc(uid).set(publicUpdates, SetOptions(merge: true));
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
      final publicKeys = ['username', 'firstName', 'lastName', 'photoUrl', 'bio'];
      final publicUpdates = <String, dynamic>{};
      
      for (var key in publicKeys) {
        if (data.containsKey(key)) {
          publicUpdates[key] = data[key];
        }
      }

      if (publicUpdates.isNotEmpty) {
        await _firestore.collection('public_profiles').doc(uid).set(publicUpdates, SetOptions(merge: true));
      }

    } catch (e) {
      print("Error updating user fields: $e");
      rethrow;
    }
  }

  Future<List<PublicProfile>> searchUsers(String query) async {
    if (query.isEmpty) return [];
    try {
      final term = query.toLowerCase();
      
      // SECURE SEARCH: Query 'public_profiles' instead of 'users'
      // Note: Firestore doesn't support native partial text search (LIKE %term%).
      // We continue with the client-side filtering approach on a limited set, 
      // OR we rely on a specific 'keywords' array if we implemented that.
      // For now, retaining the "download recent/limit 50 and filter" approach 
      // but effectively safe because we are reading public data.

      final snapshot = await _firestore.collection('public_profiles').limit(50).get();
      
      return snapshot.docs.map((doc) {
        // Handle potential malformed data gracefully
        try {
          return PublicProfile.fromJson(doc.data());
        } catch (e) {
          return null; 
        }
      }).where((profile) {
        if (profile == null) return false;
        final name = "${profile.firstName} ${profile.lastName}".toLowerCase();
        final username = profile.username.toLowerCase();
        return name.contains(term) || username.contains(term);
      }).cast<PublicProfile>().toList();

    } catch (e) {
      print("Error searching users: $e");
      return [];
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}