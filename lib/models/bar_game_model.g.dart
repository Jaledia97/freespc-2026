// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bar_game_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BarGameModel _$BarGameModelFromJson(Map<String, dynamic> json) =>
    _BarGameModel(
      id: json['id'] as String,
      venueId: json['venueId'] as String,
      gameType: json['gameType'] as String,
      status: json['status'] as String? ?? 'Registration',
      participantCount: (json['participantCount'] as num?)?.toInt() ?? 0,
      maxParticipants: (json['maxParticipants'] as num?)?.toInt(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$BarGameModelToJson(_BarGameModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'venueId': instance.venueId,
      'gameType': instance.gameType,
      'status': instance.status,
      'participantCount': instance.participantCount,
      'maxParticipants': instance.maxParticipants,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
