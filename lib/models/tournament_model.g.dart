// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tournament_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TournamentModel _$TournamentModelFromJson(Map<String, dynamic> json) =>
    _TournamentModel(
      id: json['id'] as String,
      hallId: json['hallId'] as String,
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String?,
      description: json['description'] as String? ?? '',
      startTime: json['startTime'] == null
          ? null
          : DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      recurrenceRule: json['recurrenceRule'] == null
          ? null
          : RecurrenceRule.fromJson(
              json['recurrenceRule'] as Map<String, dynamic>,
            ),
      isTemplate: json['isTemplate'] as bool? ?? false,
      archivedAt: json['archivedAt'] == null
          ? null
          : DateTime.parse(json['archivedAt'] as String),
      games:
          (json['games'] as List<dynamic>?)
              ?.map((e) => TournamentGame.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$TournamentModelToJson(_TournamentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'hallId': instance.hallId,
      'title': instance.title,
      'imageUrl': instance.imageUrl,
      'description': instance.description,
      'startTime': instance.startTime?.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'recurrenceRule': instance.recurrenceRule,
      'isTemplate': instance.isTemplate,
      'archivedAt': instance.archivedAt?.toIso8601String(),
      'games': instance.games,
    };

_TournamentGame _$TournamentGameFromJson(Map<String, dynamic> json) =>
    _TournamentGame(
      id: json['id'] as String,
      title: json['title'] as String,
      value: (json['value'] as num).toInt(),
    );

Map<String, dynamic> _$TournamentGameToJson(_TournamentGame instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'value': instance.value,
    };
