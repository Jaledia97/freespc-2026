// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    _NotificationModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: json['type'] as String,
      hallId: json['hallId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      isRead: json['isRead'] as bool? ?? false,
    );

Map<String, dynamic> _$NotificationModelToJson(_NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'body': instance.body,
      'type': instance.type,
      'hallId': instance.hallId,
      'metadata': instance.metadata,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'isRead': instance.isRead,
    };
