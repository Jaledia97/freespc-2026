import 'package:freezed_annotation/freezed_annotation.dart';

// Force recompile
part 'tournament_participation_model.freezed.dart';
part 'tournament_participation_model.g.dart';

@freezed
abstract class TournamentParticipationModel with _$TournamentParticipationModel {
  const factory TournamentParticipationModel({
    required String id,
    required String tournamentId,
    required String title,
    required String hallId, // Added field
    required String hallName, // Kept for fallback
    required String currentPlacement, // e.g. "1st", "Eliminated", "Qualifying"
    required String status, // Active, Completed, Pending
    required DateTime lastUpdated,
  }) = _TournamentParticipationModel;

  factory TournamentParticipationModel.fromJson(Map<String, Object?> json) => _$TournamentParticipationModelFromJson(json);
}
