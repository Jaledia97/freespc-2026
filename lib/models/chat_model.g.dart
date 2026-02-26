// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatModel _$ChatModelFromJson(Map<String, dynamic> json) => _ChatModel(
  id: json['id'] as String,
  name: json['name'] as String?,
  isGroup: json['isGroup'] as bool,
  participantIds: (json['participantIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  participantNames:
      (json['participantNames'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
  lastMessage: json['lastMessage'] as String? ?? '',
  lastMessageAt: DateTime.parse(json['lastMessageAt'] as String),
  lastMessageSenderId: json['lastMessageSenderId'] as String? ?? '',
  unreadCounts:
      (json['unreadCounts'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
  mutedBy:
      (json['mutedBy'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$ChatModelToJson(_ChatModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'isGroup': instance.isGroup,
      'participantIds': instance.participantIds,
      'participantNames': instance.participantNames,
      'lastMessage': instance.lastMessage,
      'lastMessageAt': instance.lastMessageAt.toIso8601String(),
      'lastMessageSenderId': instance.lastMessageSenderId,
      'unreadCounts': instance.unreadCounts,
      'mutedBy': instance.mutedBy,
    };
