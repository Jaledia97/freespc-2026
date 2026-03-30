import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'venue_team_member_model.freezed.dart';
part 'venue_team_member_model.g.dart';

class _TimestampConverter implements JsonConverter<DateTime, dynamic> {
  const _TimestampConverter();

  @override
  DateTime fromJson(dynamic json) {
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.parse(json);
    return DateTime.now();
  }

  @override
  dynamic toJson(DateTime date) {
    return date.toIso8601String();
  }
}

@freezed
abstract class VenueTeamMemberModel with _$VenueTeamMemberModel {
  const factory VenueTeamMemberModel({
    required String uid,
    required String firstName,
    required String lastName,
    required String username,
    String? photoUrl,
    required String venueId,
    required String venueName,
    required String assignedRole, // 'owner', 'manager', 'worker'
    @_TimestampConverter() required DateTime addedAt,
    required String addedByUid,
  }) = _VenueTeamMemberModel;

  factory VenueTeamMemberModel.fromJson(Map<String, Object?> json) => _$VenueTeamMemberModelFromJson(json);
}
