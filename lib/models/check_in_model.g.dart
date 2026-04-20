// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_in_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CheckInModel _$CheckInModelFromJson(Map<String, dynamic> json) =>
    _CheckInModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userProfilePicture: json['userProfilePicture'] as String?,
      venueId: json['venueId'] as String,
      venueName: json['venueName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      reactionUserIds:
          (json['reactionUserIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      interestedUserIds:
          (json['interestedUserIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
      latestComment: json['latestComment'] as String?,
    );

Map<String, dynamic> _$CheckInModelToJson(_CheckInModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'userId': instance.userId,
      'userName': instance.userName,
      'userProfilePicture': instance.userProfilePicture,
      'venueId': instance.venueId,
      'venueName': instance.venueName,
      'createdAt': instance.createdAt.toIso8601String(),
      'reactionUserIds': instance.reactionUserIds,
      'interestedUserIds': instance.interestedUserIds,
      'commentCount': instance.commentCount,
      'latestComment': instance.latestComment,
    };
