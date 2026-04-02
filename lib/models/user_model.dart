import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

import '../core/utils/timestamp_converter.dart';

@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String uid,
    required String email,
    required String firstName,
    required String lastName,
    required String username,
    required DateTime birthday,
    String? phoneNumber,
    String? recoveryEmail,
    @Default(0) int currentPoints,
    @Default('user')
    String systemRole, // superadmin, admin, user
    String? qrToken,
    String? bio,
    String? photoUrl,
    String? bannerUrl,
    @Default([]) List<String> following,
    @Default('Private')
    String realNameVisibility, // 'Private', 'Friends Only', 'Everyone'
    @Default('Online') String onlineStatus,
    String? currentCheckInHallId,
    @Default([])
    List<String> blockedUsers, // Array of User IDs this user has blocked
    @Default([])
    List<String>
    customCategories, // Array of Custom Tags/Categories the user has saved
    @NullableTimestampConverter()
    DateTime?
    lastViewedPhotoApprovals, // Track when the worker last viewed pending photos
    @Default([]) List<String> fcmTokens, // Device tokens for push notifications
    @Default([]) List<String> squadIds,
    String? pendingVenueClaimId, // Added for B2B Verification Funnel Tracking
    @NullableTimestampConverter() DateTime? lastSeen,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, Object?> json) =>
      _$UserModelFromJson(json);
}
