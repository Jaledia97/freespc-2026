// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hall_program_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HallProgramModel _$HallProgramModelFromJson(Map<String, dynamic> json) =>
    _HallProgramModel(
      title: json['title'] as String,
      pricing: json['pricing'] as String? ?? '',
      details: json['details'] as String? ?? '',
      specificDay: json['specificDay'] as String?,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$HallProgramModelToJson(_HallProgramModel instance) =>
    <String, dynamic>{
      'title': instance.title,
      'pricing': instance.pricing,
      'details': instance.details,
      'specificDay': instance.specificDay,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'isActive': instance.isActive,
    };
