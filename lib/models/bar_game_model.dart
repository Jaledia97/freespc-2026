import 'package:freezed_annotation/freezed_annotation.dart';

part 'bar_game_model.freezed.dart';
part 'bar_game_model.g.dart';

@freezed
abstract class BarGameModel with _$BarGameModel {
  const BarGameModel._();

  @JsonSerializable(explicitToJson: true)
  const factory BarGameModel({
    required String id,
    required String venueId,
    required String gameType, // e.g., 'Darts', 'Billiards', 'Beer Pong'
    @Default('Registration') String status, // 'Registration', 'Active', 'Completed'
    @Default(0) int participantCount,
    int? maxParticipants,
    DateTime? createdAt,
  }) = _BarGameModel;

  factory BarGameModel.fromJson(Map<String, Object?> json) =>
      _$BarGameModelFromJson(json);
}
