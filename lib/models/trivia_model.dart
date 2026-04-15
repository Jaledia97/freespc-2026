import 'package:freezed_annotation/freezed_annotation.dart';

part 'trivia_model.freezed.dart';
part 'trivia_model.g.dart';

@freezed
abstract class TriviaModel with _$TriviaModel {
  const TriviaModel._();

  @JsonSerializable(explicitToJson: true)
  const factory TriviaModel({
    required String id,
    required String venueId,
    required String title,
    required DateTime date,
    required String category,
    required String prizeString,
    String? imageUrl,
    @Default(true) bool isActive,
    DateTime? createdAt,
  }) = _TriviaModel;

  factory TriviaModel.fromJson(Map<String, Object?> json) =>
      _$TriviaModelFromJson(json);
}
