// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hall_charity_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HallCharityModel _$HallCharityModelFromJson(Map<String, dynamic> json) =>
    _HallCharityModel(
      id: json['id'] as String,
      name: json['name'] as String,
      logoUrl: json['logoUrl'] as String,
      websiteUrl: json['websiteUrl'] as String?,
    );

Map<String, dynamic> _$HallCharityModelToJson(_HallCharityModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'logoUrl': instance.logoUrl,
      'websiteUrl': instance.websiteUrl,
    };
