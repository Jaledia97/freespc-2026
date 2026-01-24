// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'special_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SpecialModel _$SpecialModelFromJson(Map<String, dynamic> json) =>
    _SpecialModel(
      id: json['id'] as String,
      hallId: json['hallId'] as String,
      hallName: json['hallName'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      postedAt: DateTime.parse(json['postedAt'] as String),
      startTime: json['startTime'] == null
          ? null
          : DateTime.parse(json['startTime'] as String),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
    );

Map<String, dynamic> _$SpecialModelToJson(_SpecialModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'hallId': instance.hallId,
      'hallName': instance.hallName,
      'title': instance.title,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'postedAt': instance.postedAt.toIso8601String(),
      'startTime': instance.startTime?.toIso8601String(),
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'tags': instance.tags,
    };
