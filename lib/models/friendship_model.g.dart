// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friendship_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FriendshipModel _$FriendshipModelFromJson(Map<String, dynamic> json) =>
    _FriendshipModel(
      id: json['id'] as String,
      user1Id: json['user1Id'] as String,
      user2Id: json['user2Id'] as String,
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$FriendshipModelToJson(_FriendshipModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user1Id': instance.user1Id,
      'user2Id': instance.user2Id,
      'status': instance.status,
      'createdAt': instance.createdAt.toIso8601String(),
    };
