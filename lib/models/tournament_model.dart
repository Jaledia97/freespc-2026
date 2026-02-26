import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'special_model.dart'; // For RecurrenceRule

part 'tournament_model.freezed.dart';
part 'tournament_model.g.dart';


@freezed
abstract class TournamentModel with _$TournamentModel {
  const TournamentModel._();

  @JsonSerializable(explicitToJson: true)
  const factory TournamentModel({
    required String id,
    required String hallId,
    required String title,
    String? imageUrl,
    @Default('') String description,
    DateTime? startTime,
    DateTime? endTime,
    RecurrenceRule? recurrenceRule,
    @Default(false) bool isTemplate,
    DateTime? archivedAt,
    @Default([]) List<TournamentGame> games,
  }) = _TournamentModel;

  factory TournamentModel.fromJson(Map<String, dynamic> json) => _$TournamentModelFromJson(json);

  factory TournamentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TournamentModel.fromJson(data).copyWith(id: doc.id);
  }
}

@freezed
abstract class TournamentGame with _$TournamentGame {
  const factory TournamentGame({
    required String id,
    required String title,
    required int value, // Points awardable
  }) = _TournamentGame;

  factory TournamentGame.fromJson(Map<String, dynamic> json) => _$TournamentGameFromJson(json);
}
