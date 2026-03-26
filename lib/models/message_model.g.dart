// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MessageModel _$MessageModelFromJson(Map<String, dynamic> json) =>
    _MessageModel(
      id: json['id'] as String,
      chatId: json['chatId'] as String,
      senderId: json['senderId'] as String,
      text: json['text'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      replyToMessageId: json['replyToMessageId'] as String?,
      replyToText: json['replyToText'] as String?,
      replyToSenderName: json['replyToSenderName'] as String?,
      payloadType: json['payloadType'] as String?,
      payloadId: json['payloadId'] as String?,
      mediaUrl: json['mediaUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      aspectRatio: (json['aspectRatio'] as num?)?.toDouble(),
      reactions:
          (json['reactions'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      deletedBy:
          (json['deletedBy'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$MessageModelToJson(_MessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'chatId': instance.chatId,
      'senderId': instance.senderId,
      'text': instance.text,
      'createdAt': instance.createdAt.toIso8601String(),
      'replyToMessageId': instance.replyToMessageId,
      'replyToText': instance.replyToText,
      'replyToSenderName': instance.replyToSenderName,
      'payloadType': instance.payloadType,
      'payloadId': instance.payloadId,
      'mediaUrl': instance.mediaUrl,
      'thumbnailUrl': instance.thumbnailUrl,
      'aspectRatio': instance.aspectRatio,
      'reactions': instance.reactions,
      'deletedBy': instance.deletedBy,
    };
