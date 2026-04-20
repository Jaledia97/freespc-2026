// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_post_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TextPostModel _$TextPostModelFromJson(Map<String, dynamic> json) =>
    _TextPostModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userProfilePicture: json['userProfilePicture'] as String?,
      venueId: json['venueId'] as String?,
      venueName: json['venueName'] as String?,
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
      authorType: json['authorType'] as String? ?? 'user',
      authorId: json['authorId'] as String?,
      postedByUid: json['postedByUid'] as String?,
      latestComment: json['latestComment'] as String?,
    );

Map<String, dynamic> _$TextPostModelToJson(_TextPostModel instance) =>
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
      'authorType': instance.authorType,
      'authorId': instance.authorId,
      'postedByUid': instance.postedByUid,
      'latestComment': instance.latestComment,
    };
