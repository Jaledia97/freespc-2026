import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

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
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, Object?> json) => _$UserModelFromJson(json);
}