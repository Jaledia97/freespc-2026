import 'package:freezed_annotation/freezed_annotation.dart';

part 'public_profile.freezed.dart';
part 'public_profile.g.dart';

@freezed
abstract class PublicProfile with _$PublicProfile {
  const factory PublicProfile({
    required String uid,
    required String username,
    required String firstName,
    required String lastName,
    String? photoUrl,
    String? bio,
    @Default(0) int points, // syncing points for potential leaderboards? kept simple for now
    @Default('Private') String realNameVisibility,
    @Default('Online') String onlineStatus,
    String? currentCheckInHallId,
  }) = _PublicProfile;

  factory PublicProfile.fromJson(Map<String, Object?> json) => _$PublicProfileFromJson(json);
}
