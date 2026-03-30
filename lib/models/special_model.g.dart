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
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      recurrence: json['recurrence'] as String? ?? 'none',
      recurrenceRule: json['recurrenceRule'] == null
          ? null
          : RecurrenceRule.fromJson(
              json['recurrenceRule'] as Map<String, dynamic>,
            ),
      isTemplate: json['isTemplate'] as bool? ?? false,
      templateId: json['templateId'] as String?,
      isCancelled: json['isCancelled'] as bool? ?? false,
      archivedAt: json['archivedAt'] == null
          ? null
          : DateTime.parse(json['archivedAt'] as String),
      reactionUserIds:
          (json['reactionUserIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      interestedUserIds:
          (json['interestedUserIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
      authorType: json['authorType'] as String? ?? 'venue',
      authorId: json['authorId'] as String?,
      postedByUid: json['postedByUid'] as String?,
      latestComment: json['latestComment'] as String?,
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
      'endTime': instance.endTime?.toIso8601String(),
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'tags': instance.tags,
      'recurrence': instance.recurrence,
      'recurrenceRule': instance.recurrenceRule?.toJson(),
      'isTemplate': instance.isTemplate,
      'templateId': instance.templateId,
      'isCancelled': instance.isCancelled,
      'archivedAt': instance.archivedAt?.toIso8601String(),
      'reactionUserIds': instance.reactionUserIds,
      'interestedUserIds': instance.interestedUserIds,
      'commentCount': instance.commentCount,
      'authorType': instance.authorType,
      'authorId': instance.authorId,
      'postedByUid': instance.postedByUid,
      'latestComment': instance.latestComment,
    };

_RecurrenceRule _$RecurrenceRuleFromJson(Map<String, dynamic> json) =>
    _RecurrenceRule(
      frequency: json['frequency'] as String,
      interval: (json['interval'] as num?)?.toInt() ?? 1,
      daysOfWeek:
          (json['daysOfWeek'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      endCondition: json['endCondition'] as String? ?? 'never',
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      occurrenceCount: (json['occurrenceCount'] as num?)?.toInt(),
    );

Map<String, dynamic> _$RecurrenceRuleToJson(_RecurrenceRule instance) =>
    <String, dynamic>{
      'frequency': instance.frequency,
      'interval': instance.interval,
      'daysOfWeek': instance.daysOfWeek,
      'endCondition': instance.endCondition,
      'endDate': instance.endDate?.toIso8601String(),
      'occurrenceCount': instance.occurrenceCount,
    };
