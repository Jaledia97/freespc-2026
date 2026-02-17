// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tournament_participation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TournamentParticipationModel _$TournamentParticipationModelFromJson(
  Map<String, dynamic> json,
) => _TournamentParticipationModel(
  id: json['id'] as String,
  tournamentId: json['tournamentId'] as String,
  title: json['title'] as String,
  hallId: json['hallId'] as String,
  hallName: json['hallName'] as String,
  currentPlacement: json['currentPlacement'] as String,
  status: json['status'] as String,
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
);

Map<String, dynamic> _$TournamentParticipationModelToJson(
  _TournamentParticipationModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'tournamentId': instance.tournamentId,
  'title': instance.title,
  'hallId': instance.hallId,
  'hallName': instance.hallName,
  'currentPlacement': instance.currentPlacement,
  'status': instance.status,
  'lastUpdated': instance.lastUpdated.toIso8601String(),
};
