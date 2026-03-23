// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'win_post_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WinPostModel _$WinPostModelFromJson(Map<String, dynamic> json) =>
    _WinPostModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userProfilePicture: json['userProfilePicture'] as String?,
      hallId: json['hallId'] as String,
      hallName: json['hallName'] as String,
      winAmount: (json['winAmount'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String?,
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

Map<String, dynamic> _$WinPostModelToJson(_WinPostModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'userId': instance.userId,
      'userName': instance.userName,
      'userProfilePicture': instance.userProfilePicture,
      'hallId': instance.hallId,
      'hallName': instance.hallName,
      'winAmount': instance.winAmount,
      'imageUrl': instance.imageUrl,
      'createdAt': instance.createdAt.toIso8601String(),
      'reactionUserIds': instance.reactionUserIds,
      'interestedUserIds': instance.interestedUserIds,
      'commentCount': instance.commentCount,
      'latestComment': instance.latestComment,
    };
