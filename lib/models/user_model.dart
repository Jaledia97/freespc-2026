import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

class NullableTimestampConverter implements JsonConverter<DateTime?, dynamic> {
  const NullableTimestampConverter();

  @override
  DateTime? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.tryParse(json);
    return null;
  }

  @override
  dynamic toJson(DateTime? date) {
    if (date == null) return null;
    return date.toIso8601String();
  }
}

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
    @Default('player') String role, // superadmin, admin, owner, manager, worker, player
    @Default(0) int currentPoints,
    String? homeBaseId,
    String? qrToken,
    String? bio, 
    String? photoUrl,
    String? bannerUrl,
    @Default([]) List<String> following,
    @Default('Private') String realNameVisibility, // 'Private', 'Friends Only', 'Everyone'
    @Default('Online') String onlineStatus,
    String? currentCheckInHallId,
    @Default([]) List<String> blockedUsers, // Array of User IDs this user has blocked
    @Default([]) List<String> customCategories, // Array of Custom Tags/Categories the user has saved
    @NullableTimestampConverter() DateTime? lastViewedPhotoApprovals, // Track when the worker last viewed pending photos
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, Object?> json) => _$UserModelFromJson(json);
}