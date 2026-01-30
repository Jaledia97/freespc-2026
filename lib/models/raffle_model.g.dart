// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'raffle_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RaffleModel _$RaffleModelFromJson(Map<String, dynamic> json) => _RaffleModel(
  id: json['id'] as String,
  hallId: json['hallId'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  imageUrl: json['imageUrl'] as String,
  maxTickets: (json['maxTickets'] as num?)?.toInt() ?? 100,
  soldTickets: (json['soldTickets'] as num?)?.toInt() ?? 0,
  endsAt: DateTime.parse(json['endsAt'] as String),
);

Map<String, dynamic> _$RaffleModelToJson(_RaffleModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'hallId': instance.hallId,
      'name': instance.name,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'maxTickets': instance.maxTickets,
      'soldTickets': instance.soldTickets,
      'endsAt': instance.endsAt.toIso8601String(),
    };
