// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bingo_hall_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BingoHallModel _$BingoHallModelFromJson(Map<String, dynamic> json) =>
    _BingoHallModel(
      id: json['id'] as String,
      name: json['name'] as String,
      beaconUuid: json['beaconUuid'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$BingoHallModelToJson(_BingoHallModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'beaconUuid': instance.beaconUuid,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'isActive': instance.isActive,
    };
