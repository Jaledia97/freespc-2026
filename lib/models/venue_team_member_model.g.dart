// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'venue_team_member_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VenueTeamMemberModel _$VenueTeamMemberModelFromJson(
  Map<String, dynamic> json,
) => _VenueTeamMemberModel(
  uid: json['uid'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  username: json['username'] as String,
  photoUrl: json['photoUrl'] as String?,
  venueId: json['venueId'] as String,
  venueName: json['venueName'] as String,
  assignedRole: json['assignedRole'] as String,
  addedAt: const _TimestampConverter().fromJson(json['addedAt']),
  addedByUid: json['addedByUid'] as String,
  claimStatus: json['claimStatus'] as String?,
  rejectReason: json['rejectReason'] as String?,
);

Map<String, dynamic> _$VenueTeamMemberModelToJson(
  _VenueTeamMemberModel instance,
) => <String, dynamic>{
  'uid': instance.uid,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'username': instance.username,
  'photoUrl': instance.photoUrl,
  'venueId': instance.venueId,
  'venueName': instance.venueName,
  'assignedRole': instance.assignedRole,
  'addedAt': const _TimestampConverter().toJson(instance.addedAt),
  'addedByUid': instance.addedByUid,
  'claimStatus': instance.claimStatus,
  'rejectReason': instance.rejectReason,
};
