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
      templateId: json['templateId'] as String?,
      isCancelled: json['isCancelled'] as bool? ?? false,
      archivedAt: json['archivedAt'] == null
          ? null
          : DateTime.parse(json['archivedAt'] as String),
      games:
          (json['games'] as List<dynamic>?)
              ?.map((e) => TournamentGame.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
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
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      latestComment: json['latestComment'] as String?,
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
      'recurrenceRule': instance.recurrenceRule?.toJson(),
      'isTemplate': instance.isTemplate,
      'templateId': instance.templateId,
      'isCancelled': instance.isCancelled,
      'archivedAt': instance.archivedAt?.toIso8601String(),
      'games': instance.games.map((e) => e.toJson()).toList(),
      'reactionUserIds': instance.reactionUserIds,
      'interestedUserIds': instance.interestedUserIds,
      'commentCount': instance.commentCount,
      'authorType': instance.authorType,
      'authorId': instance.authorId,
      'postedByUid': instance.postedByUid,
      'createdAt': instance.createdAt?.toIso8601String(),
      'latestComment': instance.latestComment,
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
