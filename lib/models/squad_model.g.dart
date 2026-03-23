// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'squad_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SquadModel _$SquadModelFromJson(Map<String, dynamic> json) => _SquadModel(
  id: json['id'] as String,
  name: json['name'] as String,
  memberIds:
      (json['memberIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  captainId: json['captainId'] as String,
);

Map<String, dynamic> _$SquadModelToJson(_SquadModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'memberIds': instance.memberIds,
      'captainId': instance.captainId,
    };
